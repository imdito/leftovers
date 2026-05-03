import 'package:hive/hive.dart';

part 'session_box.g.dart';

@HiveType(typeId: 1)
class SessionBox extends HiveObject {
  @HiveField(0)
  String token;

  @HiveField(1)
  bool isLoggedIn;

  @HiveField(2)
  String username;

  @HiveField(3)
  DateTime expiryTime;

  SessionBox({
    required this.token,
    required this.isLoggedIn,
    required this.username,
    required this.expiryTime,
  });
}
