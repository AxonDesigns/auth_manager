import 'package:auth_manager/business/entities/provider.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final dbProvider = Provider(
  (ref) {
    return Isar.openSync(
      [ProviderSchema],
      directory: "",
    );
  },
);
