import 'package:auth_manager/business/entities/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

final accountsProvider = Provider(
  (ref) {
    return Hive.box<Account>("accounts");
  },
);
