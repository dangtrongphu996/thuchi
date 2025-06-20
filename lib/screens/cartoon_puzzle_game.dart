import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MaterialApp(home: PuzzleGame()));
}

class PuzzleGame extends StatefulWidget {
  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  final Map<int, Widget> tileImages = {};
  List<int> tiles = [];
  static const int gridRows = 5; // 5 hàng
  static const int gridCols = 4; // 4 cột
  static const int tileSize = 80;
  static const int totalTiles = 20; // 5x4 ảnh con

  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    loadAndSliceImage();
  }

  Future<void> loadAndSliceImage() async {
    final ByteData data = await rootBundle.load('assets/images/input.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final img.Image? fullImage = img.decodeImage(bytes);
    if (fullImage == null) return;

    // Cắt ảnh thành 5x4 = 20 mảnh
    List<Image> allTiles = [];
    final tileWidth = (fullImage.width / gridCols).floor();
    final tileHeight = (fullImage.height / gridRows).floor();

    for (int y = 0; y < gridRows; y++) {
      for (int x = 0; x < gridCols; x++) {
        final img.Image tile = img.copyCrop(
          fullImage,
          x: x * tileWidth,
          y: y * tileHeight,
          width: tileWidth,
          height: tileHeight,
        );
        final Uint8List tileBytes = Uint8List.fromList(img.encodeJpg(tile));
        allTiles.add(Image.memory(tileBytes, fit: BoxFit.cover));
      }
    }

    // Gán đúng mảnh ảnh cho từng tileID
    tileImages.clear();
    for (int i = 0; i < totalTiles; i++) {
      tileImages[i + 1] = allTiles[i]; // tile ID từ 1 → 20
    }

    // Chỉ giữ ảnh số 1 đúng vị trí, các ảnh khác sẽ được xáo trộn
    List<int> validTiles = List.generate(20, (i) => i + 1);
    validTiles.remove(1); // Xóa số 1 khỏi danh sách để xáo trộn
    //validTiles.shuffle();

    // Tạo tiles: hàng đầu tiên là [0, -1, -1, -1], sau đó là 1,2,3,...,19
    tiles = [
      0, -1, -1, -1, // hàng đầu tiên: 1 ô trống, 3 ô ẩn
      1, 2, 3, 4,
      5, 6, 7, 8,
      9, 10, 11, 12,
      13, 14, 15, 16,
      17, 18, 19, 20,
    ];

    setState(() {});
  }

  void shuffleTiles() {
    List<int> validTiles = List.generate(19, (i) => i + 1);
    validTiles.shuffle();

    // Tạo tiles: hàng đầu tiên là [0, -1, -1, -1], sau đó là 19 mảnh xáo trộn
    tiles = [
      0,
      -1,
      -1,
      -1,
      ...validTiles.sublist(0, 4),
      ...validTiles.sublist(4, 8),
      ...validTiles.sublist(8, 12),
      ...validTiles.sublist(12, 16),
      ...validTiles.sublist(16, 20),
    ];
    setState(() {});
  }

  // Thêm hàm để hoàn thành ảnh
  void completePuzzle() {
    setState(() {
      showCompleted = true;
    });
    Future.delayed(Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          showCompleted = false;
        });
        checkCompletion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.extension_rounded, color: Colors.orangeAccent, size: 30),
            SizedBox(width: 8),
            Text('Cartoon Puzzle Sliding'),
          ],
        ),
        backgroundColor: Colors.pink[100],
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.greenAccent, size: 30),
            onPressed: completePuzzle,
            tooltip: 'Hoàn thành ảnh',
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/input.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: gridCols * (tileSize + 8), // tileSize + margin
                  child:
                      showCompleted
                          ? _buildCompletedImageLikeSample()
                          : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(gridRows, (row) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(gridCols, (col) {
                                  final index = row * gridCols + col;
                                  if (index >= tiles.length) return Container();
                                  final tileNumber = tiles[index];
                                  if (tileNumber == -1) {
                                    return SizedBox(
                                      width: tileSize.toDouble(),
                                      height: tileSize.toDouble(),
                                    );
                                  }
                                  if (tileNumber == 0) return _buildEmptyTile();
                                  return _buildTile(tileNumber, index);
                                }),
                              );
                            }),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị ảnh hoàn thành giống mẫu:
  /// - Hàng đầu tiên: 1 ô trống màu xám nhạt, 3 ô không hiển thị
  /// - Các tile còn lại là ảnh, có số thứ tự ở góc trên phải, nền số màu đen, chữ trắng
  Widget _buildCompletedImageLikeSample() {
    return Column(
      children: List.generate(gridRows, (row) {
        return Row(
          children: List.generate(gridCols, (col) {
            final index = row * gridCols + col;
            if (row == 0) {
              if (col == 0) {
                // Góc trên cùng bên trái là ô trống màu xám nhạt + icon
                return Container(
                  width: tileSize.toDouble(),
                  height: tileSize.toDouble(),
                  margin: EdgeInsets.all(2),
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                  ),
                );
              } else {
                // 3 ô đầu tiên không hiển thị
                return SizedBox(
                  width: tileSize.toDouble(),
                  height: tileSize.toDouble(),
                );
              }
            }
            // Các tile còn lại: ảnh + số thứ tự ở góc phải trên
            int tileNumber = (row - 1) * gridCols + col + 1;
            return Stack(
              children: [
                Container(
                  width: tileSize.toDouble(),
                  height: tileSize.toDouble(),
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.purpleAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      tileImages[tileNumber] ?? Container(color: Colors.blue),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_emotions,
                          color: Colors.yellow,
                          size: 14,
                        ),
                        SizedBox(width: 2),
                        Text(
                          tileNumber.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      }),
    );
  }

  Widget _buildEmptyTile() {
    return Container(
      width: tileSize.toDouble(),
      height: tileSize.toDouble(),
      //margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.purple.withOpacity(0.18),
        //     blurRadius: 8,
        //     offset: Offset(2, 2),
        //   ),
        // ],
        //borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurpleAccent, width: 2),
      ),
      child: Center(
        child: Icon(Icons.cake_rounded, color: Colors.pinkAccent, size: 32),
      ),
    );
  }

  Widget _buildTile(int number, int index) {
    return GestureDetector(
      onTap: () => moveTile(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.18),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.deepPurpleAccent, width: 2),
        ),
        child: Stack(
          children: [
            Container(
              width: tileSize.toDouble(),
              height: tileSize.toDouble(),
              margin: EdgeInsets.all(2),
              child: tileImages[number] ?? Container(color: Colors.blue),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: Colors.redAccent, size: 12),
                    SizedBox(width: 2),
                    Text(
                      number.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void moveTile(int index) {
    if (showCompleted) return;
    final emptyIndex = tiles.indexOf(0);
    final canMove = isAdjacent(index, emptyIndex);
    if (canMove && tiles[index] > 0) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
      });
      checkCompletion();
    }
  }

  void checkCompletion() {
    if (_isCompleted()) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.amber, size: 28),
                      SizedBox(width: 8),
                      Text('🎉 Chúc mừng!'),
                    ],
                  ),
                  content: Text('Bạn đã hoàn thành bức tranh!'),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.refresh, color: Colors.blueAccent),
                      label: Text('Chơi lại'),
                      onPressed: () {
                        Navigator.pop(context);
                        //shuffleTiles();
                      },
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.cancel, color: Colors.redAccent),
                      label: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
          );
        }
      });
    }
  }

  bool isAdjacent(int a, int b) {
    int ax = a % gridCols, ay = a ~/ gridCols;
    int bx = b % gridCols, by = b ~/ gridCols;
    return (ax == bx && (ay - by).abs() == 1) ||
        (ay == by && (ax - bx).abs() == 1);
  }

  bool _isCompleted() {
    // Chỉ kiểm tra 15 tile còn lại (bỏ qua 4 ô đầu tiên)
    for (int i = 4; i < tiles.length; i++) {
      if (tiles[i] != i - 3) return false;
    }
    // 4 ô đầu tiên phải là [0, -1, -1, -1]
    if (tiles.length < 16 ||
        tiles[0] != 0 ||
        tiles[1] != -1 ||
        tiles[2] != -1 ||
        tiles[3] != -1)
      return false;
    return true;
  }
}
