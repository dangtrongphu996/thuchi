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

// Phiên bản Advanced Scrollable (MỚI - có tùy chọn bao gồm AppBar)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useAdvancedScrollable: true, // Chụp ảnh với tùy chọn AppBar
  includeAppBar: true, // Có thể là true hoặc false
  child: YourWidget(),
),

// Phiên bản Full Page (MỚI - luôn bao gồm AppBar)
body: AppWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useFullPage: true, // Chụp toàn bộ trang bao gồm AppBar
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

## Các wrapper mới với hỗ trợ AppBar

### AdvancedScrollableScreenshotWrapper
- **Đặc điểm**: Có dialog cho phép chọn chụp ảnh có hoặc không có AppBar
- **Sử dụng**: `useAdvancedScrollable: true`
- **Tùy chọn**: `includeAppBar: true/false` để đặt mặc định
- **Dialog options**: 
  - "Toàn màn hình (bao gồm AppBar)" 
  - "Chỉ nội dung (không có AppBar)"

### FullPageScreenshotWrapper  
- **Đặc điểm**: Luôn chụp toàn bộ trang bao gồm AppBar
- **Sử dụng**: `useFullPage: true`
- **Phù hợp**: Khi bạn luôn muốn có AppBar trong ảnh

## ScreenWrapper - Giải pháp tối ưu cho AppBar

**ScreenWrapper** là wrapper mới cho phép bạn wrap toàn bộ screen và có control hoàn toàn về việc có bao gồm AppBar hay không.

### Cách sử dụng ScreenWrapper:
```dart
import '../utils/screen_wrapper.dart';

// Thay vì Scaffold truyền thống:
return ScreenWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useAdvancedScrollable: true, // Có dialog chọn có/không AppBar
  includeAppBar: true, // Mặc định bao gồm AppBar
  appBar: AppBar(
    title: Text('Title'),
    backgroundColor: Colors.purple,
  ),
  body: YourContentWidget(),
);

// Hoặc để luôn bao gồm AppBar:
return ScreenWrapper(
  screenName: 'ten_man_hinh_${DateTime.now().millisecondsSinceEpoch}',
  useFullPage: true, // Luôn chụp toàn bộ
  appBar: AppBar(title: Text('Title')),
  body: YourContentWidget(),
);
```

### Tính năng "Chụp không có AppBar":
- Khi chọn "Chỉ nội dung (không có AppBar)", hệ thống sẽ:
  1. Chụp toàn màn hình trước
  2. Tự động crop (cắt bỏ) phần AppBar ở trên
  3. Lưu ảnh chỉ có phần nội dung body
- Nếu không thể crop được, sẽ thông báo và lưu ảnh toàn màn hình

### Menu item trong AppBar:
**Giờ đây các button chụp ảnh đã được tích hợp vào AppBar menu!**
- Icon camera (📷) trong AppBar actions
- Menu gồm 2 options:
  - "Chụp ảnh (tùy chọn)" hoặc "Chụp toàn màn hình"
  - "Xem thư viện ảnh"
- Giao diện gọn gàng, không có floating buttons

### Logic chụp ảnh có AppBar (MỚI):
**Đã sửa lỗi không hiển thị AppBar!**
- Khi chọn "Toàn màn hình (bao gồm AppBar)":
  1. Tự động tìm kiếm parent RepaintBoundary chứa Scaffold
  2. Chụp từ boundary cao nhất để bao gồm AppBar
  3. Fallback về boundary hiện tại nếu không tìm thấy
- Đảm bảo AppBar được hiển thị đúng trong ảnh chụp

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
