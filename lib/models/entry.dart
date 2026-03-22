import 'package:hive/hive.dart';

// flutter pub run build_runner build
part 'entry.g.dart';

@HiveType(typeId: 0)
class Entry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late String text;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  String? mood; // Ruh hali emojisi veya metni

  @HiveField(5)
  String? locationName; // Konum bilgisi (örn: Moda Sahil)

  Entry({
    required this.id,
    required this.date,
    required this.text,
    this.imagePath,
    this.mood,
    this.locationName,
  });
}


