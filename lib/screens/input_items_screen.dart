import 'package:flutter/material.dart';
import 'spinner_screen.dart';

class InputItemsScreen extends StatefulWidget {
  @override
  _InputItemsScreenState createState() => _InputItemsScreenState();
}

class _InputItemsScreenState extends State<InputItemsScreen> {
  final int maxItems = 10;
  List<TextEditingController> controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    if (controllers.length < maxItems) {
      setState(() {
        controllers.add(TextEditingController());
      });
    }
  }

  void _goToSpinner() {
    final items =
        controllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập ít nhất 1 giá trị!')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SpinnerScreen(items: items)),
    );
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
            iconTheme: IconThemeData(color: Colors.amberAccent),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.amberAccent, size: 28),
                SizedBox(width: 8),
                Text(
                  'Nhập giá trị vòng quay',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  Text(
                    'Nhập tối đa 10 giá trị cho vòng quay may mắn',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ...List.generate(
                    controllers.length,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: TextField(
                        controller: controllers[i],
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.label,
                            color: Colors.purpleAccent,
                          ),
                          labelText: 'Giá trị ${i + 1}',
                          labelStyle: TextStyle(color: Colors.deepPurple),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.purpleAccent.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Colors.amber,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  if (controllers.length < maxItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addItem,
                          icon: Icon(Icons.add, color: Colors.deepPurple),
                          label: Text(
                            'Thêm',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.deepPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToSpinner,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.deepPurple,
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.casino, size: 28),
                          SizedBox(width: 10),
                          Text('Xác nhận'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
