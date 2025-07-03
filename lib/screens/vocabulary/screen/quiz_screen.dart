import 'package:flutter/material.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';
import 'dart:math';
import 'package:thuchi/screens/vocabulary/utils/data_loader.dart' as loader;

class QuizScreen extends StatefulWidget {
  final String mode; // 'kanji' or 'hiragana'
  final int questionCount; // Số câu hỏi được chọn
  final int? character; // Bài được chọn (null là tất cả)
  final int? section;
  QuizScreen({
    required this.mode,
    required this.questionCount,
    this.character,
    this.section,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Vocabulary> vocabList = [];
  Vocabulary? currentQuestion;
  List<String> options = [];
  String correctAnswer = '';
  int currentIndex = 0;

  int? selectedIndex; // Lưu đáp án đã chọn
  bool? isCorrectSelected; // Lưu trạng thái đúng/sai của đáp án đã chọn

  List<Vocabulary> remainingQuestions = [];
  bool finished = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    loadAndStartQuiz();
  }

  void loadAndStartQuiz() async {
    final list = await loader.loadVocabularyFromLocal();
    // Lọc theo character nếu có
    List<Vocabulary> filteredList = list;
    if (widget.character != null) {
      filteredList =
          list.where((v) => v.character == widget.character).toList();
    }
    // Lọc tiếp theo section nếu có
    if (widget.section != null) {
      filteredList =
          filteredList.where((v) => v.section == widget.section).toList();
    }

    // Trộn và lấy số lượng câu hỏi
    filteredList.shuffle();
    final questionCount =
        widget.questionCount > filteredList.length
            ? filteredList.length
            : widget.questionCount;
    final selectedList = filteredList.take(questionCount).toList();

    setState(() {
      vocabList = selectedList;
      remainingQuestions = List<Vocabulary>.from(selectedList);
      finished = false;
      score = 0;
      currentIndex = 0;
      generateQuestion();
    });
  }

  void generateQuestion() {
    if (remainingQuestions.isEmpty) {
      setState(() {
        finished = true;
        currentQuestion = null;
        options = [];
        correctAnswer = '';
      });
      return;
    }
    final random = Random();
    final idx = random.nextInt(remainingQuestions.length);
    currentQuestion = remainingQuestions[idx];
    remainingQuestions.removeAt(idx);
    currentIndex = vocabList.length - remainingQuestions.length - 1;

    if (widget.mode == 'kanji') {
      correctAnswer = currentQuestion!.hiragana;
      options = _generateOptions(
        correctAnswer,
        vocabList.map((e) => e.hiragana).toList(),
      );
    } else if (widget.mode == 'kanji_meaning') {
      correctAnswer = currentQuestion!.mean;
      options = _generateOptions(
        correctAnswer,
        vocabList.map((e) => e.mean).toList(),
      );
    } else {
      correctAnswer = currentQuestion!.kanji;
      options = _generateOptions(
        correctAnswer,
        vocabList.map((e) => e.kanji).toList(),
      );
    }
  }

  List<String> _generateOptions(String correct, List<String> pool) {
    final random = Random();
    final Set<String> choices = {correct};
    while (choices.length < 4) {
      choices.add(pool[random.nextInt(pool.length)]);
    }
    return choices.toList()..shuffle();
  }

  void checkAnswer(String selected) async {
    final isCorrect = selected == correctAnswer;
    final idx = options.indexOf(selected);
    setState(() {
      selectedIndex = idx;
      isCorrectSelected = isCorrect;
      if (isCorrect) score++;
    });
    await Future.delayed(Duration(milliseconds: 500));

    // Xử lý ví dụ tách dòng nếu có dấu '。'
    List<String> exampleLines = [];
    if (currentQuestion!.example.contains('。')) {
      final parts = currentQuestion!.example.split('。');
      if (parts.length > 1) {
        exampleLines = [parts[0] + '。', parts.sublist(1).join('。').trim()];
      } else {
        exampleLines = [currentQuestion!.example];
      }
    } else {
      exampleLines = [currentQuestion!.example];
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor:
                isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isCorrect ? 'Đúng rồi!' : 'Sai rồi!',
              style: TextStyle(
                color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mode == 'kanji_meaning'
                      ? 'Từ vựng: ${currentQuestion!.kanji}\nHiragana: ${currentQuestion!.hiragana}'
                      : 'Đáp án: $correctAnswer',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Nghĩa: ${currentQuestion!.mean}',
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ví dụ:',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                ...exampleLines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                    child: Text(
                      line,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Tiếp tục', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedIndex = null;
                    isCorrectSelected = null;
                    generateQuestion();
                  });
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (vocabList.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (finished) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Luyện tập từ vựng',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          elevation: 4,
          leading: Icon(Icons.quiz, color: Colors.white),
        ),
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 64),
              SizedBox(height: 24),
              Text(
                'Bạn đã hoàn thành tất cả câu hỏi!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Điểm số của bạn: $score / ${vocabList.length}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loadAndStartQuiz();
                  });
                },
                child: Text('Làm lại', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final question =
        widget.mode == 'kanji'
            ? currentQuestion!.kanji
            : widget.mode == 'kanji_meaning'
            ? currentQuestion!.kanji
            : currentQuestion!.hiragana;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Luyện tập từ vựng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 4,
        leading: Icon(Icons.quiz, color: Colors.white),
      ),
      backgroundColor: Color(0xFFF6F7FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tiến độ
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Câu hỏi ${currentIndex + 1} / ${vocabList.length}',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Box câu hỏi
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 36),
            // Các lựa chọn
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => SizedBox(height: 18),
                itemBuilder: (context, idx) {
                  final opt = options[idx];
                  Color bgColor = Colors.white;
                  if (selectedIndex != null && selectedIndex == idx) {
                    bgColor =
                        isCorrectSelected == true
                            ? Colors.green.shade300
                            : Colors.red.shade300;
                  }
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap:
                          selectedIndex == null ? () => checkAnswer(opt) : null,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 12.0,
                          ),
                          child: Center(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
