# GIAI ĐOẠN 1: CORE PERMUTATION (Lõi mã hóa)

Các module này độc lập và là nền tảng của toàn bộ hệ thống:

* **`ascon_round_constant.v` (Đơn giản nhất)**: Chỉ là LUT tạo hằng số vòng; dễ kiểm tra và không có logic phức tạp.
* **`ascon_sbox.v` & `ascon_linear.v`**: Đây là hai module cốt lõi của round function; có thể test độc lập với test vector.
* **`ascon_round.v`**: Kết hợp S-box và Linear diffusion; test với round constant đã có.
* **`ascon_permutation_optimized.v`**: Module permutation hoàn chỉnh; cần test state machine và số vòng.

---

# GIAI ĐOẠN 2: DATA HANDLING MODULES

Các module xử lý dữ liệu đầu vào/đầu ra:

* **`data_assembler_128.v` & `data_assembler_160.v`**: Đơn giản, chỉ là shift register; test với write enable.
* **`fifo_in.v`**: FIFO gom 32-bit → 128-bit; test write/read và mode selection.
* **`fifo_split_128to32.v`**: FIFO tách 128-bit → 32-bit; test load và read.
* **`count_line_control.v`**: Logic đếm và điều khiển; test với các mode khác nhau.

---

# GIAI ĐOẠN 3: CORE CONTROLLER

* **`ascon_core_optimized.v`**: Module FSM chính điều khiển toàn bộ thuật toán.
* **Yêu cầu kiểm thử**: Là phần phức tạp nhất, cần test kỹ với các variant (128, 128a, 80pq), cả quá trình encrypt và decrypt, cùng AD và data processing.

---

# GIAI ĐOẠN 4: TOP-LEVEL INTEGRATION

* **`ascon_top.v`**: Kết hợp tất cả các module trên; test interface, data flow và verify với test vector đầy đủ.
* **`ascon_wb.v` (Wishbone Interface)**: Module cuối cùng dùng để giao tiếp với bus; test wishbone protocol.