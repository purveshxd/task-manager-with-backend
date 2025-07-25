// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Tasks {
  String name;
  String id;
  bool isComplete;
  String desc;

  Tasks({
    required this.name,
    required this.id,
    required this.isComplete,
    required this.desc,
  });

  Tasks copyWith({String? name, String? id, bool? isComplete, String? desc}) {
    return Tasks(
      name: name ?? this.name,
      id: id ?? this.id,
      isComplete: isComplete ?? this.isComplete,
      desc: desc ?? this.desc,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'isComplete': isComplete,
      'desc': desc,
    };
  }

  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
      name: map['name'] as String,
      id: map['id'] as String,
      isComplete: map['isComplete'] as bool,
      desc: map['desc'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tasks.fromJson(String source) =>
      Tasks.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Tasks(name: $name, id: $id, isComplete: $isComplete, desc: $desc)';
  }

  @override
  bool operator ==(covariant Tasks other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.id == id &&
        other.isComplete == isComplete &&
        other.desc == desc;
  }

  @override
  int get hashCode {
    return name.hashCode ^ id.hashCode ^ isComplete.hashCode ^ desc.hashCode;
  }
}
