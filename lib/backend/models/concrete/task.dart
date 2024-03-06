import 'package:agendo/backend/apis/id_generator.dart';
import 'package:agendo/backend/models/abstract/task.dart';
import 'package:agendo/local_config.dart';

export 'task.dart';

class TaskC implements Task {
  @override
  String description;

  @override
  bool isChecked;

  @override
  int position;

  @override
  final String id;

  TaskC(this.id, this.position, this.description, this.isChecked);

  TaskC.create(TaskAddParams data)
      : id = taskIdIdentifier + randomId(),
        position = data.position,
        description = data.description,
        isChecked = data.isChecked;
}
