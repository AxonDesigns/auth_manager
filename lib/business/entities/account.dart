import 'package:hive_ce_flutter/hive_flutter.dart';

const accountTypeId = 0;

@HiveType(typeId: accountTypeId)
class Account extends HiveObject {
  Account({
    required this.id,
    required String url,
  }) : uri = Uri.parse(url);

  @HiveField(0)
  final int id;

  @HiveField(1)
  final Uri uri;

  String get username {
    return uri.pathSegments[0].split(":")[1];
  }

  String get provider {
    final issuer = uri.queryParameters["issuer"];
    if (issuer != null) {
      return issuer;
    }
    return uri.pathSegments[0].split(":")[0];
  }

  String get secret {
    final secret = uri.queryParameters["secret"];
    if (secret != null) {
      return secret;
    }

    final token = uri.queryParameters["token"];
    if (token != null) {
      return token;
    }

    return "";
  }

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json["id"],
        url: json["uri"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uri": uri.toString(),
      };
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  Account read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Account(
      id: (fields[0] as num).toInt(),
      url: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeByte(2) // num of fields (2) is written at the end
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uri.toString());
  }

  @override
  int get typeId => accountTypeId;

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
