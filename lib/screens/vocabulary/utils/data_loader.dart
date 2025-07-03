import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<List<Vocabulary>> loadVocabulary() async {
  final data = await rootBundle.loadString('assets/data/vocabulary.json');
  final List<dynamic> jsonData = json.decode(data);
  return jsonData.map((e) => Vocabulary.fromJson(e)).toList();
}

Future<List<Vocabulary>> loadVocabularyFromLocal() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/vocabulary_temp.json');
  if (!await file.exists()) {
    final data = await rootBundle.loadString('assets/data/vocabulary.json');
    await file.writeAsString(data);
  }
  final data = await file.readAsString();
  final List<dynamic> jsonData = json.decode(data);
  return jsonData.map((e) => Vocabulary.fromJson(e)).toList();
}
