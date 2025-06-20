import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class SpinnerScreen extends StatefulWidget {
  final List<String>? items;
  SpinnerScreen({Key? key, this.items}) : super(key: key);
  @override
  _SpinnerScreenState createState() => _SpinnerScreenState();
}

class _SpinnerScreenState extends State<SpinnerScreen> {
  List<String> get items =>
      widget.items ?? List.generate(10, (index) => 'Số \\${index + 1}');
  final StreamController<int> controller = StreamController<int>.broadcast();
  int? _lastSelectedIndex;
  bool _shouldShowResult = false;
  double _buttonScale = 1.0;

  double _buttonScale2 = 1.0;
  bool _isSpinning = false;
  double _iconRotation = 0.0;
  final List<Color> chipColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.amber,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
  ];

  List<bool> _chipVisible = [];
  int? _highlightedChipIndex;
  Timer? _chipHighlightTimer;
  double _spinDurationSeconds = 3.0;
  final TextEditingController _durationController = TextEditingController(
    text: '3',
  );

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = null;
    _shouldShowResult = false;
    _chipVisible = List.filled(items.length, false);
    _showChipsAnimated();
  }

  @override
  void dispose() {
    controller.close();
    _chipHighlightTimer?.cancel();
    _durationController.dispose();
    super.dispose();
  }

  void _onSpinPressed() {
    if (_isSpinning) return;
    final randomIndex = Random().nextInt(items.length);
    _lastSelectedIndex = randomIndex;
    _shouldShowResult = true;
    _isSpinning = true;
    int intervalMs = 80;
    int totalSteps = (_spinDurationSeconds * 1000 ~/ intervalMs);
    int step = 0;
    _chipHighlightTimer?.cancel();
    _highlightedChipIndex = 0;
    _chipHighlightTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
      timer,
    ) {
      setState(() {
        _highlightedChipIndex = (_highlightedChipIndex! + 1) % items.length;
      });
      step++;
      if (step >= totalSteps) {
        timer.cancel();
        setState(() {
          _highlightedChipIndex = _lastSelectedIndex;
        });
      }
    });
    controller.add(randomIndex);
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade50,
                    Colors.pink.shade50,
                    Colors.purple.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.12),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 56),
                  SizedBox(height: 12),
                  Text(
                    '🎉 KẾT QUẢ 🎉',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bạn quay trúng:',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    result,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> saveResultToFile(String result) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/ket_qua.txt';
      final file = File(filePath);

      // Ghi thêm kết quả mới vào cuối file
      await file.writeAsString('$result\n', mode: FileMode.append);
      print('✅ Đã lưu kết quả vào: $filePath');
    } catch (e) {
      print('❌ Lỗi khi lưu file: $e');
    }
  }

  Future<String> readSavedResults() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/ket_qua.txt';
    final file = File(filePath);

    if (await file.exists()) {
      return await file.readAsString();
    } else {
      return 'Chưa có kết quả nào.';
    }
  }

  void _showChipsAnimated() async {
    for (int i = 0; i < items.length; i++) {
      await Future.delayed(Duration(milliseconds: 80));
      if (mounted) setState(() => _chipVisible[i] = true);
    }
  }

  void stopChipHighlightAndSetWinner() {
    _chipHighlightTimer?.cancel();
    if (_lastSelectedIndex != null) {
      setState(() {
        _highlightedChipIndex = _lastSelectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pinkAccent,
                Colors.deepPurpleAccent,
                Colors.amber,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.2),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.amberAccent),
            title: Row(
              children: [
                Icon(Icons.casino, color: Colors.amberAccent, size: 32),
                SizedBox(width: 8),
                Text(
                  'Quay Số May Mắn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade50,
                Colors.purple.shade50,
                Colors.amber.shade50,
                Colors.cyan.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 32),
                  // TextField chọn thời gian quay
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Thời gian quay: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              double? v = double.tryParse(value);
                              if (v == null || v < 1.0) v = 1.0;
                              if (v > 10.0) v = 10.0;
                              setState(() {
                                _spinDurationSeconds = v!;
                                if (_durationController.text != v.toString()) {
                                  _durationController.text = v.toString();
                                  _durationController
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _durationController.text.length,
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'giây',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 300,
                      width: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FortuneWheel(
                            selected: controller.stream,
                            animateFirst: false,
                            duration: Duration(
                              milliseconds:
                                  (_spinDurationSeconds * 1000).round(),
                            ),
                            items: [
                              for (var i = 0; i < items.length; i++)
                                FortuneItem(
                                  child: Text(
                                    items[i],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  style: FortuneItemStyle(
                                    color: chipColors[i % chipColors.length]
                                        .withOpacity(0.7),
                                    borderColor: Colors.deepPurpleAccent,
                                    borderWidth: 2,
                                  ),
                                ),
                            ],
                            onAnimationEnd: () async {
                              print('onAnimationEnd called');
                              if (_shouldShowResult &&
                                  _lastSelectedIndex != null) {
                                final result = items[_lastSelectedIndex!];
                                print('Kết quả: ' + result);
                                await saveResultToFile(
                                  'Kết quả: $result - \\${DateTime.now()}',
                                );
                                _showResultDialog(result);
                                _shouldShowResult = false;
                                _isSpinning = false;
                                stopChipHighlightAndSetWinner();
                              } else {
                                print(
                                  '❌ _lastSelectedIndex is null hoặc không nên show dialog!',
                                );
                              }
                            },
                          ),
                          AnimatedScale(
                            scale: _buttonScale,
                            duration: Duration(milliseconds: 120),
                            child: GestureDetector(
                              onTapDown:
                                  (_) => setState(() => _buttonScale = 0.93),
                              onTapUp:
                                  (_) => setState(() => _buttonScale = 1.0),
                              onTapCancel:
                                  () => setState(() => _buttonScale = 1.0),
                              onTap: _onSpinPressed,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber,
                                      Colors.pinkAccent,
                                      Colors.deepPurpleAccent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Quay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  AnimatedScale(
                    scale: _buttonScale2,
                    duration: Duration(milliseconds: 120),
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _buttonScale2 = 0.93),
                      onTapUp: (_) => setState(() => _buttonScale2 = 1.0),
                      onTapCancel: () => setState(() => _buttonScale2 = 1.0),
                      onTap: _onSpinPressed,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber,
                              Colors.pinkAccent,
                              Colors.deepPurpleAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 22,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedRotation(
                              turns: _isSpinning ? 1 : 0,
                              duration: Duration(milliseconds: 500),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Quay Ngay',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: Colors.amberAccent.withOpacity(0.7),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var i = 0; i < items.length; i++)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 1.0,
                              end: (_isSpinning ? 1.15 : 1.0),
                            ),
                            duration: Duration(
                              milliseconds: _isSpinning ? 300 : 400,
                            ),
                            curve:
                                _isSpinning
                                    ? Curves.easeInOutBack
                                    : Curves.easeOut,
                            builder: (context, scale, child) {
                              final bool isHighlight =
                                  (_isSpinning && i == _highlightedChipIndex) ||
                                  (!_isSpinning &&
                                      i == _lastSelectedIndex &&
                                      !_shouldShowResult);
                              return AnimatedOpacity(
                                opacity: _chipVisible[i] ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 400),
                                child: AnimatedScale(
                                  scale: _chipVisible[i] ? scale : 0.7,
                                  duration: Duration(milliseconds: 400),
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        if (isHighlight)
                                          BoxShadow(
                                            color: Colors.amberAccent
                                                .withOpacity(0.9),
                                            blurRadius: 22,
                                            spreadRadius: 3,
                                          ),
                                        BoxShadow(
                                          color: Colors.purpleAccent
                                              .withOpacity(0.15),
                                          blurRadius: 8,
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Chip(
                                      label:
                                          items[i].length > 6
                                              ? SizedBox.shrink()
                                              : Text(
                                                items[i],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      isHighlight
                                                          ? Colors
                                                              .amber
                                                              .shade900
                                                          : Colors
                                                              .deepPurple
                                                              .shade900,
                                                ),
                                              ),
                                      backgroundColor:
                                          isHighlight
                                              ? Colors.amber.shade100
                                              : chipColors[i %
                                                  chipColors.length],
                                      elevation: 4,
                                      shadowColor: Colors.purpleAccent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  // Chỗ này có thể thêm hiệu ứng confetti nếu muốn
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
