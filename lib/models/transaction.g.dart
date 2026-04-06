part of 'transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return Transaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as TransactionType,
      category: fields[3] as TransactionCategory,
      date: fields[4] as DateTime,
      description: fields[5] as String?,
      createdAt: fields[6] as DateTime,
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
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final typeId = 10;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }
}

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final typeId = 11;

  @override
  TransactionCategory read(BinaryReader reader) {
    return TransactionCategory.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    writer.writeByte(obj.index);
  }
}