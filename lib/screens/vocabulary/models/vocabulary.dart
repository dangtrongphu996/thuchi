import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

List<Vocabulary> vocabularyFromJson(String str) =>
    List<Vocabulary>.from(json.decode(str).map((x) => Vocabulary.fromJson(x)));

String vocabularyToJson(List<Vocabulary> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Vocabulary {
  final String kanji;
  final String hiragana;
  final String mean;
  final String example;
  final int character;
  final int section;

  Vocabulary({
    required this.kanji,
    required this.hiragana,
    required this.mean,
    required this.example,
    required this.character,
    required this.section,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) => Vocabulary(
    kanji: json["kanji"],
    hiragana: json["hiragana"],
    mean: json["mean"],
    example: json["example"],
    character: json["character"],
    section: json["section"],
  );

  Map<String, dynamic> toJson() => {
    "kanji": kanji,
    "hiragana": hiragana,
    "mean": mean,
    "example": example,
    "character": character,
    "section": section,
  };
}

Future<List<Vocabulary>> loadVocabulary() async {
  final String data = await rootBundle.loadString(
    'assets/data/vocabulary.json',
  );
  final List<dynamic> jsonData = json.decode(data);
  return jsonData.map((e) => Vocabulary.fromJson(e)).toList();
}
