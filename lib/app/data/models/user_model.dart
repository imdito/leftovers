import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {

  @HiveField(0)
  late int id;
  @HiveField(1)
  late String name;

  @HiveField(2)
  String? email;
  @HiveField(3)
  late String token;

  @HiveField(4)
  late double total_savings;
  @HiveField(5)
  late int streak_count;
  @HiveField(6)
  late String level;

  @HiveField(7)
  late DateTime created_at;
  @HiveField(8)
  late DateTime last_sync;

}