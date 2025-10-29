// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountHiveModelAdapter extends TypeAdapter<AccountHiveModel> {
  @override
  final int typeId = 0;

  @override
  AccountHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountHiveModel(
      id: fields[0] as int?,
      name: fields[1] as String,
      holderName: fields[2] as String,
      accountNumber: fields[3] as String,
      iconCodePoint: fields[4] as int,
      colorValue: fields[5] as int,
      isDefault: fields[6] as bool,
      balance: fields[7] as double,
      income: fields[8] as double,
      expense: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AccountHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.holderName)
      ..writeByte(3)
      ..write(obj.accountNumber)
      ..writeByte(4)
      ..write(obj.iconCodePoint)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.isDefault)
      ..writeByte(7)
      ..write(obj.balance)
      ..writeByte(8)
      ..write(obj.income)
      ..writeByte(9)
      ..write(obj.expense);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
