import 'package:isar/isar.dart';

part 'provider.g.dart';

@collection
class Provider {
  Id id = Isar.autoIncrement;

  late String name;

  late String token;
}
