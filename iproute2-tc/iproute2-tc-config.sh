# Xem các qdisc hiện có
tc qdisc show
# Xem các qdisc hiện có trên eth2
tc qdisc show dev eth2
# Xem thống kê chi tiết (số gói tin bị drop, overlimits): 
# dropped: Số lần gói tin bị DROP do hàng đợi đầy
# overlimits: Số lần lưu lượng vượt quá dung lượng cấu hình
tc -s qdisc show dev eth2
# Xóa toàn bộ cấu hình để quay lại mặc định: 
tc qdisc del root dev eth2
# Thay thế một qdisc đang chạy: 
tc qdisc replace dev eth2 root htb

# PoC 1: Giới hạn băng thông cơ bản (sử dụng TBF)
# Thuật toán TBF (Token Bucket Filter) rất hiệu quả để làm chậm giao diện mạng xuống một tốc độ cụ thể
# Kịch bản: Giới hạn tốc độ tải lên của card eth2 xuống còn 1Mbps.
# Câu lệnh: 
tc qdisc add dev eth2 root tbf rate 70mbit burst 5mbit latency 400ms
# Giải thích:
# rate: Tốc độ tối đa cho phép
# burst: Kích thước xô chứa token (lượng dữ liệu tối đa có thể gửi đi trong một đợt bùng phát)
# latency: Thời gian tối đa gói tin chờ trong hàng đợi trước khi bị loại bỏ

