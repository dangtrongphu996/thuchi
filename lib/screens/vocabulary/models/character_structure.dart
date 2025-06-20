import 'dart:convert';

List<CharacterStructure> characterStructureFromJson(String str) =>
    List<CharacterStructure>.from(
      json.decode(str).map((x) => CharacterStructure.fromJson(x)),
    );

String characterStructureToJson(List<CharacterStructure> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CharacterStructure {
  final int character;
  final List<Section> sections;

  CharacterStructure({required this.character, required this.sections});

  factory CharacterStructure.fromJson(Map<String, dynamic> json) =>
      CharacterStructure(
        character: json["character"],
        sections: List<Section>.from(
          json["sections"].map((x) => Section.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "character": character,
    "sections": List<dynamic>.from(sections.map((x) => x.toJson())),
  };
}

class Section {
  final int section;
  final String name;

  Section({required this.section, required this.name});

  factory Section.fromJson(Map<String, dynamic> json) =>
      Section(section: json["section"], name: json["name"]);

  Map<String, dynamic> toJson() => {"section": section, "name": name};
}
