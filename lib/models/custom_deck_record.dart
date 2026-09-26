/// A user-created deck, stored as just a name + the ids of the Kana it contains. 
/// actual Kana objects are looked up from KanaDataset when the deck is used
class CustomDeckRecord {
  const CustomDeckRecord({
    required this.id,
    required this.name,
    required this.kanaIds,
  });

  final String id;
  final String name;
  final List<String> kanaIds;

  CustomDeckRecord copyWith({String? name, List<String>? kanaIds}) {
    return CustomDeckRecord(
      id: id,
      name: name ?? this.name,
      kanaIds: kanaIds ?? this.kanaIds,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'kanaIds': kanaIds};

  factory CustomDeckRecord.fromJson(Map<String, dynamic> json) => CustomDeckRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        kanaIds: (json['kanaIds'] as List<dynamic>).cast<String>(),
      );
}
