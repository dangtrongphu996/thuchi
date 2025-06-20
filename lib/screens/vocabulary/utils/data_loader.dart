import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:thuchi/screens/vocabulary/models/vocabulary.dart';

Future<List<Vocabulary>> loadVocabulary() async {
  final data = await rootBundle.loadString('assets/data/vocabulary.json');
  final List<dynamic> jsonData = json.decode(data);
  return jsonData.map((e) => Vocabulary.fromJson(e)).toList();
}
