import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  Game.fromJson(Map<String, dynamic> json)
      : parsed = json['parsed'] ?? false,
        name = json['name'] ?? "",
        docId = json['docId'] ?? "1",
        results = json['results'],
        gameItems = List<GameItem>.from(json.entries.where(
          (element) {
            return element.value is Map && element.key != 'results';
          },
        ).fold<List<GameItem>>(
            [],
            (previousValue, element) =>
                [...previousValue, GameItem.fromJson(element.value)]));

  List<GameItem> gameItems;
  String name;
  bool parsed;
  String docId;
  Map<String, dynamic>? results;
}

class GameItem {
  GameItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? "404",
        url = json['url'] ?? "",
        prompt = json['prompt'] ?? "",
        person1 = json['person1'] ?? "",
        person2 = json['person2'] ?? "",
        interaction = json['interaction'] ?? "",
        isPossible = (json['isPossible'] ?? false);

  GameItem(this.id, this.url, this.prompt, this.person1, this.person2,
      this.interaction, this.isPossible);
  String url;
  String prompt;
  String person1;
  String person2;
  String interaction;
  bool isPossible;
  String id;
}

class PersonItem {
  PersonItem.fromJson(Map<String, dynamic> json)
      : birthdate = (json['birthdate'] as Timestamp?)?.toDate().toLocal() ??
            DateTime.now(),
        deathdate = (json['deathdate'] as Timestamp?)?.toDate().toLocal(),
        isDead = json['isDead'] ?? false,
        name = json['name'] ?? "";

  DateTime birthdate;
  DateTime? deathdate;

  bool aliveSameTime(PersonItem other) {
    // If this person was born after the other died, they weren't alive at the same time
    if (birthdate.isAfter(other.deathdate ?? DateTime.now())) {
      return false;
    }

    // If this person died before the other was born, they weren't alive at the same time
    if (isDead && deathdate!.isBefore(other.birthdate)) {
      return false;
    }

    // If neither of the above cases are true, they must have been alive at the same time
    return true;
  }

  String name;
  bool isDead;
}
