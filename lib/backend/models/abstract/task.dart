import 'package:agendo/backend/models/abstract/record.dart';

export 'task.dart'
    show ReadOnlyTask, Task, TaskAddParams, TaskEditParams, TaskOperation;

abstract class ReadOnlyTask {
  String get id;

  int get position;

  String get description;

  bool get isChecked;
}

abstract class Task extends ReadOnlyTask {
  set position(value);

  set description(value);

  set isChecked(value);
}

class TaskAddParams {
  final int position;
  final String description;
  final bool isChecked;

  const TaskAddParams(
      {required this.position,
      required this.description,
      this.isChecked = false});
}

class TaskEditParams {
  final String id;
  final int? position;
  final String? description;
  final bool? isChecked;

  const TaskEditParams(
      {required this.id, this.position, this.description, this.isChecked});

  bool get isEmpty {
    return position == null && description == null && isChecked == null;
  }
}

class TaskOperation {
  final RecordAction action;
  final TaskEditParams params;

  TaskOperation(this.action, this.params);
}
