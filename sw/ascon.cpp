//helloworld
#include <iostream>
#include <cstdint>
#include <cstring>
#include <cstdio>

using namespace std;

using u8  = uint8_t;
using u64 = uint64_t;

static constexpr u64 ASCON_IV = 0x80400c0600000000ULL;
// key=128, rate=64, a=12, b=6

static constexpr int PA = 12;   // số vòng permutation cho init/final
static constexpr int PB = 6;    // số vòng permutation cho AD/PT

// Round constants
static const u64 RC[12] = {
    0xF0,0xE1,0xD2,0xC3,
    0xB4,0xA5,0x96,0x87,
    0x78,0x69,0x5A,0x4B
};

struct State {
    u64 x[5];   // x0 | x1 | x2 | x3 | x4
};

// rotate right
static inline u64 rotr(u64 x, int n) {
    return (x >> n) | (x << (64 - n));
}

// Load 8 byte -> u64 (big-endian)
static inline u64 load64_be(const u8* b) {
    u64 x = 0;
    for (int i = 0; i < 8; i++)
        x = (x << 8) | b[i];
    return x;
}

// Store u64 -> 8 byte (big-endian)
static inline void store64_be(u8* b, u64 x) {
    for (int i = 7; i >= 0; i--) {
        b[i] = x & 0xFF;
        x >>= 8;
    }
}


// S-box layer
void sbox(State& s) {
    s.x[0] ^= s.x[4];
    s.x[4] ^= s.x[3];
    s.x[2] ^= s.x[1];

    u64 t0 = ~s.x[0] & s.x[1];
    u64 t1 = ~s.x[1] & s.x[2];
    u64 t2 = ~s.x[2] & s.x[3];
    u64 t3 = ~s.x[3] & s.x[4];
    u64 t4 = ~s.x[4] & s.x[0];

    s.x[0] ^= t1;
    s.x[1] ^= t2;
    s.x[2] ^= t3;
    s.x[3] ^= t4;
    s.x[4] ^= t0;

    s.x[1] ^= s.x[0];
    s.x[0] ^= s.x[4];
    s.x[3] ^= s.x[2];
    s.x[2]  = ~s.x[2];
}

// Linear diffusion layer
void linear(State& s) {
    s.x[0] ^= rotr(s.x[0],19) ^ rotr(s.x[0],28);
    s.x[1] ^= rotr(s.x[1],61) ^ rotr(s.x[1],39);
    s.x[2] ^= rotr(s.x[2], 1) ^ rotr(s.x[2], 6);
    s.x[3] ^= rotr(s.x[3],10) ^ rotr(s.x[3],17);
    s.x[4] ^= rotr(s.x[4], 7) ^ rotr(s.x[4],41);
}

// Permutation 
void perm(State& s, int rounds) {
    for (int i = 12 - rounds; i < 12; i++) {
        s.x[2] ^= RC[i];   // add round constant
        sbox(s);
        linear(s);
    }
}

int main() {

    u8 key[16] = {
        0x8e,0xc9,0x6f,0x64,0xe4,0x37,0xf5,0xb1,
        0x40,0xc8,0x12,0x47,0x1e,0x3e,0xea,0x2c
    };

    u8 nonce[16] = {
        0xda,0x10,0x6d,0x95,0x21,0x35,0x58,0x7c,
        0x1c,0xa0,0xc1,0x55,0x1c,0xba,0xe9,0xfd
    };

    const u8* ad = (const u8*)"Making Ascon cipher easier to play with Duong hehe";
    const u8* pt = (const u8*)"Making Ascon cipher easier to play with Duong hehe";

    size_t adlen = strlen((const char*)ad);
    size_t ptlen = strlen((const char*)pt);

    // Init
    State s{};
    s.x[0] = ASCON_IV;
    s.x[1] = load64_be(key);
    s.x[2] = load64_be(key + 8);
    s.x[3] = load64_be(nonce);
    s.x[4] = load64_be(nonce + 8);

    perm(s, PA);

    s.x[3] ^= load64_be(key);
    s.x[4] ^= load64_be(key + 8);

    // AD
    size_t i = 0;
    while (i + 8 <= adlen) {
        s.x[0] ^= load64_be(ad + i);
        perm(s, PB);
        i += 8;
    }

    // block cuối + padding 0x80
    u64 last = 0;
    for (size_t j = 0; j < adlen - i; j++)
        last |= (u64)ad[i + j] << (56 - 8*j);

    last |= (u64)0x80 << (56 - 8*(adlen - i));
    s.x[0] ^= last;

    perm(s, PB);

    // domain separation
    s.x[4] ^= 1;

    // Encrypt
    u8 ct[64]{};
    i = 0;

    while (i + 8 <= ptlen) {
        u64 p = load64_be(pt + i);
        u64 c = s.x[0] ^ p;
        store64_be(ct + i, c);
        s.x[0] = c;
        perm(s, PB);
        i += 8;
    }

    // block cuối + padding
    last = 0;
    for (size_t j = 0; j < ptlen - i; j++)
        last |= (u64)pt[i + j] << (56 - 8*j);

    last |= (u64)0x80 << (56 - 8*(ptlen - i));

    u64 c = s.x[0] ^ last;
    for (size_t j = 0; j < ptlen - i; j++)
        ct[i + j] = (c >> (56 - 8*j)) & 0xFF;

    s.x[0] = c;

    // Final
    s.x[1] ^= load64_be(key);
    s.x[2] ^= load64_be(key + 8);

    perm(s, PA);

    s.x[3] ^= load64_be(key);
    s.x[4] ^= load64_be(key + 8);

    u8 tag[16];
    store64_be(tag,     s.x[3]);
    store64_be(tag + 8, s.x[4]);

    // output
    cout << "Ciphertext: ";
    for (size_t k = 0; k < ptlen; k++)
        printf("%02x", ct[k]);

    cout << "\nTag       : ";
    for (int k = 0; k < 16; k++)
        printf("%02x", tag[k]);
    cout << endl;

    return 0;
}
