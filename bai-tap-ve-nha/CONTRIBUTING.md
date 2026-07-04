# Đóng góp cho series Bài Tập Về Nhà

Series này mở nguồn (MIT — xem [LICENSE](../LICENSE)). Mọi đóng góp từ cộng đồng đều hoan nghênh.

## Cách đóng góp

### Báo lỗi trong bài hiện tại
Mở issue mô tả: bài nào (`NN-slug`), lỗi gì (topology không deploy được, sai đề bài, sai config skeleton...), kèm output lỗi nếu có.

### Đề xuất bài mới
Mở issue hoặc PR với ý tưởng chủ đề, thuộc Arc nào (xem bảng Arc trong [README.md](./README.md)), độ khó tương ứng. Ưu tiên bài có thể tự deploy bằng containerlab, không phụ thuộc thiết bị vật lý.

### Nộp giải pháp thay thế
**Chỉ nộp sau khi `loi-giai.md` của bài đó đã được công bố** — tránh lộ đáp án cho học viên khác đang làm bài. PR thêm file `loi-giai-cong-dong-<ten-ban>.md` trong đúng thư mục bài, giải thích cách tiếp cận khác với đáp án gốc.

### Chuẩn bài mới (khi PR thêm 1 tuần mới)
Copy khung từ [`_template/`](./_template/) làm điểm bắt đầu. Mỗi bài nằm trong `bai-tap-ve-nha/NN-slug/`, gồm:
- `lab-guide.md` — đề bài (Mục tiêu, Yêu cầu tiên quyết, Sơ đồ/topology, Đề bài không kèm lời giải, Cách nộp bài)
- `topology/*.clab.yml` — topology (3–6 node, ưu tiên tái dùng image `quay.io/frrouting/frr` hoặc `wbitt/network-multitool` đã dùng trong repo)
- `configs/` — config khởi tạo dạng skeleton, không hoàn chỉnh (bỏ qua nếu bài không cần)
- Cập nhật bảng trong `bai-tap-ve-nha/README.md`

Không đưa `loi-giai.md` vào cùng lúc với `lab-guide.md` — đáp án chỉ thêm sau khi hết hạn nộp bài (~1 tuần).
