import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thuchi/models/todo.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> _todos = [];

  String _selectedGroup = 'Tất cả chưa hoàn thành';
  final List<String> _groups = [
    'Tất cả chưa hoàn thành',
    'Quá khứ chưa hoàn thành',
    'Hôm nay',
    'Tương lai',
    'Đã hoàn thành quá khứ',
  ];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todos.json');
  }

  Future<void> _saveTodos() async {
    final file = await _localFile;
    final jsonString = jsonEncode(_todos.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<void> _loadTodos() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        setState(() {
          _todos = jsonList.map((e) => Todo.fromJson(e)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _todos = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _addOrEditTodo({Todo? todo, int? index}) {
    final controller = TextEditingController(text: todo?.title ?? '');
    DateTime selectedDate = todo?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.blueAccent, size: 28),
                      SizedBox(width: 8),
                      Text(todo == null ? 'Thêm công việc' : 'Sửa công việc'),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.task_alt, color: Colors.green, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Tên công việc',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Nhập công việc',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.orange, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Ngày thực hiện',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            side: BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.blue.withOpacity(0.05),
                          ),
                          icon: Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                          label: Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actionsPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Hủy', style: TextStyle(fontSize: 16)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            if (todo == null) {
                              _todos.add(Todo(title: text, date: selectedDate));
                            } else {
                              _todos[index!] = Todo(
                                title: text,
                                isDone: todo.isDone,
                                date: selectedDate,
                              );
                            }
                          });
                          _saveTodos();
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        todo == null ? 'Thêm' : 'Lưu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
    _saveTodos();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  Color getBackgroundColor(Todo todo) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todoDate = DateTime(todo.date.year, todo.date.month, todo.date.day);
    if (todoDate.isBefore(today) && !todo.isDone) {
      return Colors.red[50]!;
    } else if (todoDate.isAtSameMomentAs(today)) {
      return Colors.blue[50]!;
    } else if (todoDate.isAfter(today)) {
      return Colors.purple[50]!;
    } else if (todoDate.isBefore(today) && todo.isDone) {
      return Colors.grey[200]!;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.checklist_rounded, color: Colors.blueAccent, size: 32),
            SizedBox(width: 10),
            Text(
              'Công việc hằng ngày',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Colors.yellow, Colors.blue],
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hãy hoàn thành các công việc mỗi ngày để nâng cao hiệu suất và tinh thần!',
                    style: TextStyle(fontSize: 15, color: Colors.blueGrey[700]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final List<Todo> pastUndone = [];
                final List<Todo> todayTodos = [];
                final List<Todo> futureTodos = [];
                final List<Todo> pastDone = [];
                for (var todo in _todos) {
                  final todoDate = DateTime(
                    todo.date.year,
                    todo.date.month,
                    todo.date.day,
                  );
                  if (todoDate.isBefore(today) && !todo.isDone) {
                    pastUndone.add(todo);
                  } else if (todoDate.isAtSameMomentAs(today)) {
                    todayTodos.add(todo);
                  } else if (todoDate.isAfter(today)) {
                    futureTodos.add(todo);
                  } else if (todoDate.isBefore(today) && todo.isDone) {
                    pastDone.add(todo);
                  }
                }
                List<Todo> displayTodos;
                switch (_selectedGroup) {
                  case 'Tất cả chưa hoàn thành':
                    displayTodos = _todos.where((t) => !t.isDone).toList();
                    break;
                  case 'Quá khứ chưa hoàn thành':
                    displayTodos = pastUndone;
                    break;
                  case 'Hôm nay':
                    displayTodos = todayTodos;
                    break;
                  case 'Tương lai':
                    displayTodos = futureTodos;
                    break;
                  case 'Đã hoàn thành quá khứ':
                    displayTodos = pastDone;
                    break;
                  default:
                    displayTodos = _todos.where((t) => !t.isDone).toList();
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGroup,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Lọc theo nhóm',
                                labelStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: Colors.blue[50],
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down_circle,
                                color: Colors.blueAccent,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              dropdownColor: Colors.white,
                              items:
                                  _groups
                                      .map(
                                        (g) => DropdownMenuItem<String>(
                                          value: g,
                                          child: Row(
                                            children: [
                                              Icon(
                                                g == 'Tất cả chưa hoàn thành'
                                                    ? Icons.all_inbox
                                                    : g ==
                                                        'Quá khứ chưa hoàn thành'
                                                    ? Icons.history_toggle_off
                                                    : g == 'Hôm nay'
                                                    ? Icons.today
                                                    : g == 'Tương lai'
                                                    ? Icons.upcoming
                                                    : Icons.check_circle,
                                                color:
                                                    g == 'Tất cả chưa hoàn thành'
                                                        ? Colors.blueAccent
                                                        : g ==
                                                            'Quá khứ chưa hoàn thành'
                                                        ? Colors.redAccent
                                                        : g == 'Hôm nay'
                                                        ? Colors.blueAccent
                                                        : g == 'Tương lai'
                                                        ? Colors.purple
                                                        : Colors.grey,
                                              ),
                                              SizedBox(width: 8),
                                              Text(g),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGroup = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          displayTodos.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 80,
                                      color: Colors.blue[100],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Không có công việc nào',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Nhấn nút + để thêm công việc mới!',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blueGrey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                itemCount: displayTodos.length,
                                itemBuilder: (context, index) {
                                  final todo = displayTodos[index];
                                  return Dismissible(
                                    key: UniqueKey(),
                                    background: Container(
                                      color: Colors.green,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Sửa',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.redAccent,
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Xóa',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      if (direction ==
                                          DismissDirection.startToEnd) {
                                        _addOrEditTodo(
                                          todo: todo,
                                          index: index,
                                        );
                                        return false;
                                      } else if (direction ==
                                          DismissDirection.endToStart) {
                                        final shouldDelete = await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text('Xác nhận'),
                                                content: Text(
                                                  'Bạn có chắc muốn xóa công việc này?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: Text('Hủy'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: Text('Xóa'),
                                                  ),
                                                ],
                                              ),
                                        );
                                        return shouldDelete ?? false;
                                      }
                                      return false;
                                    },
                                    onDismissed: (direction) {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        _deleteTodo(index);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                      margin: EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 2,
                                      ),
                                      child: Card(
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        color: getBackgroundColor(todo),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 10,
                                          ),
                                          leading: Checkbox(
                                            value: todo.isDone,
                                            onChanged:
                                                (_) => _toggleTodo(
                                                  _todos.indexOf(todo),
                                                ),
                                            activeColor: Colors.green,
                                            checkColor: Colors.white,
                                            side: BorderSide(
                                              color:
                                                  todo.isDone
                                                      ? Colors.green
                                                      : Colors.grey,
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          title: Text(
                                            todo.title,
                                            style: TextStyle(
                                              decoration:
                                                  todo.isDone
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                              color:
                                                  todo.isDone
                                                      ? Colors.green.shade700
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Icon(
                                                Icons.event,
                                                color: Colors.orange,
                                                size: 18,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(todo.date),
                                                style: TextStyle(
                                                  color: Colors.blueGrey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blueAccent,
                                            ),
                                            onPressed:
                                                () => _addOrEditTodo(
                                                  todo: todo,
                                                  index: index,
                                                ),
                                            tooltip: 'Sửa',
                                          ),
                                          onTap: null,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () => _addOrEditTodo(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, size: 32, color: Colors.white),
          tooltip: 'Thêm công việc',
        ),
      ),
    );
  }
}
