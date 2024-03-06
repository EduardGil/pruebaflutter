import 'package:uuid/uuid.dart';

export 'id_generator.dart';

String randomId() {
  return const Uuid().v4();
}