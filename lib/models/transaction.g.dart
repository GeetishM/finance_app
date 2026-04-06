// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String?,
      amount: fields[1] as double,
      type: fields[2] as TransactionType,
      category: fields[3] as TransactionCategory,
      date: fields[4] as DateTime,
      description: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final int typeId = 3;

  @override
  TransactionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategory.food;
      case 1:
        return TransactionCategory.transport;
      case 2:
        return TransactionCategory.entertainment;
      case 3:
        return TransactionCategory.utilities;
      case 4:
        return TransactionCategory.shopping;
      case 5:
        return TransactionCategory.health;
      case 6:
        return TransactionCategory.education;
      case 7:
        return TransactionCategory.other;
      case 8:
        return TransactionCategory.salary;
      case 9:
        return TransactionCategory.freelance;
      case 10:
        return TransactionCategory.bonus;
      default:
        return TransactionCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    switch (obj) {
      case TransactionCategory.food:
        writer.writeByte(0);
        break;
      case TransactionCategory.transport:
        writer.writeByte(1);
        break;
      case TransactionCategory.entertainment:
        writer.writeByte(2);
        break;
      case TransactionCategory.utilities:
        writer.writeByte(3);
        break;
      case TransactionCategory.shopping:
        writer.writeByte(4);
        break;
      case TransactionCategory.health:
        writer.writeByte(5);
        break;
      case TransactionCategory.education:
        writer.writeByte(6);
        break;
      case TransactionCategory.other:
        writer.writeByte(7);
        break;
      case TransactionCategory.salary:
        writer.writeByte(8);
        break;
      case TransactionCategory.freelance:
        writer.writeByte(9);
        break;
      case TransactionCategory.bonus:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
