// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      isOffline: fields[13] as bool?,
      birthDate: fields[14] as Timestamp?,
      lastSeenTime: fields[15] as Timestamp,
      authenticationType: fields[1] as String,
      userName: fields[2] as String?,
      accountName: fields[3] as String?,
      gender: fields[4] as String?,
      email: fields[5] as String?,
      phoneNumber: fields[6] as String?,
      profilePictureUrl: fields[7] as String?,
      userPostsIds: (fields[8] as List).cast<String>(),
      savedPostsIds: (fields[9] as List).cast<String>(),
      chatIds: (fields[10] as List).cast<String>(),
      freindsIds: (fields[11] as List).cast<String>(),
      isDarkMode: fields[12] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.authenticationType)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.accountName)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phoneNumber)
      ..writeByte(7)
      ..write(obj.profilePictureUrl)
      ..writeByte(8)
      ..write(obj.userPostsIds)
      ..writeByte(9)
      ..write(obj.savedPostsIds)
      ..writeByte(10)
      ..write(obj.chatIds)
      ..writeByte(11)
      ..write(obj.freindsIds)
      ..writeByte(12)
      ..write(obj.isDarkMode)
      ..writeByte(13)
      ..write(obj.isOffline)
      ..writeByte(14)
      ..write(obj.birthDate)
      ..writeByte(15)
      ..write(obj.lastSeenTime);
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
