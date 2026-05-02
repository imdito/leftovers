// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel()
      ..id = fields[0] as int
      ..name = fields[1] as String
      ..email = fields[2] as String
      ..token = fields[3] as String
      ..total_savings = fields[4] as double
      ..streak_count = fields[5] as int
      ..level = fields[6] as String
      ..created_at = fields[7] as DateTime
      ..last_sync = fields[8] as DateTime;
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.token)
      ..writeByte(4)
      ..write(obj.total_savings)
      ..writeByte(5)
      ..write(obj.streak_count)
      ..writeByte(6)
      ..write(obj.level)
      ..writeByte(7)
      ..write(obj.created_at)
      ..writeByte(8)
      ..write(obj.last_sync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
