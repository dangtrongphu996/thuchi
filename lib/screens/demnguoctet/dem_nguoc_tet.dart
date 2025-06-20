import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:thuchi/screens/holiday/holiday.dart';

class CountdownScreen extends StatefulWidget {
  final Holiday holiday;

  const CountdownScreen({super.key, required this.holiday});
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late Timer _timer;
  late DateTime _targetDate;
  late String _name;
  late String _path = 'assets/images/background.png';
  late Color _textColor;
  late List<Color> _appBarGradientColors;
  Duration _timeLeft = const Duration();

  @override
  void initState() {
    super.initState();
    _targetDate = widget.holiday.date;
    _name = widget.holiday.name;
    _path = widget.holiday.imagePath ?? 'assets/images/background.png';
    _randomizeColors();
    _updateTimeLeft();
    _startTimer();
  }

  void _randomizeColors() {
    final random = Random();
    _textColor = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    _appBarGradientColors = [
      Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
      Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
    ];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    setState(() {
      _timeLeft = _targetDate.difference(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGradientAppBar(),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(_path)),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // padding:
                  //     const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  // decoration: BoxDecoration(
                  //   color: Colors.black.withOpacity(0.6),
                  //   borderRadius: BorderRadius.circular(24),
                  //   border: Border.all(color: Colors.white30, width: 1),
                  // ),
                  child: Column(
                    children: [
                      Text(
                        'Đếm ngược đến $_name',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Chỉ còn...',
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildTimeBox('$days', 'Ngày'),
                          _buildTimeBox('$hours', 'Giờ'),
                          _buildTimeBox('$minutes', 'Phút'),
                          _buildTimeBox('$seconds', 'Giây'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize _buildGradientAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimeBox(String value, String label) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade400, Colors.orange.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
