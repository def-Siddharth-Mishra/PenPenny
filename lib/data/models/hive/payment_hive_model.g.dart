// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentHiveModelAdapter extends TypeAdapter<PaymentHiveModel> {
  @override
  final int typeId = 2;

  @override
  PaymentHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentHiveModel(
      id: fields[0] as int?,
      accountId: fields[1] as int,
      categoryId: fields[2] as int,
      amount: fields[3] as double,
      paymentType: fields[4] as int,
      datetime: fields[5] as DateTime,
      title: fields[6] as String,
      description: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accountId)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paymentType)
      ..writeByte(5)
      ..write(obj.datetime)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
