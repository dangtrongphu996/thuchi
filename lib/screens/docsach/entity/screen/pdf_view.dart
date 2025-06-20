import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LimitedPDFViewer extends StatefulWidget {
  final String title;
  final String pdfPath;
  final int startPage;
  final int endPage;

  const LimitedPDFViewer({
    super.key,
    required this.pdfPath,
    required this.title,
    required this.startPage,
    required this.endPage,
  });

  @override
  _LimitedPDFViewerState createState() => _LimitedPDFViewerState();
}

class _LimitedPDFViewerState extends State<LimitedPDFViewer> {
  final PdfViewerController _pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Nhảy đến trang bắt đầu ngay khi load
      _pdfController.jumpToPage(widget.startPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: widget.title.length > 20 ? 16 : 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color:
              Colors
                  .white, // Màu cho icon trở lại hoặc các icon khác trên AppBar
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: SfPdfViewer.asset(
        widget.pdfPath,
        controller: _pdfController,
        onPageChanged: (PdfPageChangedDetails details) {
          if (details.newPageNumber > widget.endPage) {
            // Nếu vượt quá endPage, quay về trang cuối cùng cho phép
            _pdfController.jumpToPage(widget.endPage);
          }
          if (details.newPageNumber < widget.startPage) {
            // Nếu vượt quá endPage, quay về trang cuối cùng cho phép
            _pdfController.jumpToPage(widget.startPage);
          }
        },
      ),
    );
  }
}
