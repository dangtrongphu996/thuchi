# Hướng dẫn sử dụng chức năng chụp ảnh màn hình

## Tổng quan
Chức năng chụp ảnh màn hình cho phép người dùng chụp toàn bộ nội dung màn hình (bao gồm cả phần scroll) và lưu vào thư viện ảnh.

## Cách sử dụng

### 1. Sử dụng ScreenshotWrapper trực tiếp
```dart
import '../utils/screenshot_wrapper.dart';

// Wrap toàn bộ body của Scaffold
body: ScreenshotWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  child: YourWidget(),
),
```

### 2. Sử dụng AppWrapper (khuyến nghị)
```dart
import '../utils/app_wrapper.dart';

// Phiên bản đầy đủ (lưu vào thư viện ảnh)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  child: YourWidget(),
),

// Phiên bản đơn giản (lưu vào thư mục Documents)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useSimpleScreenshot: true,
  child: YourWidget(),
),

// Phiên bản enhanced (có cả nút chụp ảnh và gallery)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useEnhanced: true, // Có nút chụp ảnh và gallery
  child: YourWidget(),
),

// Phiên bản scrollable (tối ưu cho màn hình có scroll)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useScrollable: true, // Chụp toàn bộ nội dung scroll với chất lượng cao
  child: YourWidget(),
),

// Phiên bản đơn giản chỉ có gallery (tránh lỗi Hero)
body: AppWrapper(
  useSimpleGallery: true, // Chỉ có nút gallery, không có chụp ảnh
  child: YourWidget(),
),

// Phiên bản an toàn (có cả chụp ảnh và gallery, không lỗi Hero)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useSafe: true, // Có cả nút chụp ảnh và gallery, an toàn không lỗi Hero
  child: YourWidget(),
),

// Phiên bản Hero-Free (khuyến nghị - hoàn toàn không lỗi Hero)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useHeroFree: true, // Có cả nút chụp ảnh và gallery, hoàn toàn không lỗi Hero
  child: YourWidget(),
),
```

## Ví dụ tích hợp vào màn hình

### Trước khi tích hợp:
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Màn hình')),
    body: YourContentWidget(),
  );
}
```

### Sau khi tích hợp:
```dart
import '../utils/app_wrapper.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Màn hình')),
    body: AppWrapper(
      screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
      child: YourContentWidget(),
    ),
  );
}
```

## Tính năng

### Chụp ảnh màn hình:
- **Chụp toàn bộ nội dung**: Bao gồm cả phần scroll
- **Nút chụp ảnh**: FloatingActionButton ở góc trên bên phải
- **Lưu tự động**: Ảnh được lưu vào thư viện ảnh hoặc thư mục Documents
- **Thông báo**: Hiển thị kết quả chụp ảnh
- **Loading state**: Hiển thị trạng thái đang chụp ảnh

### Xem ảnh đã chụp:
- **Gallery**: Màn hình hiển thị danh sách ảnh đã chụp
- **Xem chi tiết**: Zoom, pan, swipe giữa các ảnh
- **Xóa ảnh**: Có thể xóa ảnh không cần thiết
- **Thông tin file**: Hiển thị tên file, kích thước, ngày tạo
- **Refresh**: Làm mới danh sách ảnh

## Lưu ý

1. **Quyền truy cập**: Ứng dụng cần quyền truy cập bộ nhớ để lưu ảnh
2. **Tên file**: Sử dụng timestamp để tránh trùng lặp
3. **Chất lượng**: Ảnh được lưu với chất lượng 90%
4. **Hiệu suất**: Chỉ hiển thị nút chụp ảnh khi cần thiết

## Danh sách màn hình cần tích hợp

- [x] bar_chart_screen.dart
- [ ] dashboard_screen.dart
- [ ] home_screen.dart
- [ ] thong_ke_danh_muc_screen.dart
- [ ] thong_ke_thang_danh_muc_screen.dart
- [ ] giao_dich_theo_ngay_screen.dart
- [ ] giao_dich_theo_nam_screen.dart
- [ ] thong_ke_nam_danh_muc_screen.dart
- [ ] Và tất cả màn hình khác...
