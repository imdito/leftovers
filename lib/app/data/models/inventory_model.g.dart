// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 0;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItem(
      name: fields[0] as String,
      quantity: fields[1] as int,
      expirationDate: fields[2] as DateTime,
      category: fields[3] as String,
      id: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.expirationDate)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
