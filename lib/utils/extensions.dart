import 'package:agendo/backend/models/abstract/task.dart';
import 'package:agendo/backend/models/concrete/task.dart';

extension TaskList on List<Task> {
  void refreshPositions([bool sort = true]) {
    if (sort) {
      this.sort((a, b) => a.position - b.position);
    }
    for (int i = 0; i < length; i++) {
      this[i].position = i;
    }
  }

  void addTasks(List<TaskAddParams> tasks) {
    tasks.sort((a, b) => a.position - b.position);
    int dataI = 0, localI = 0;
    while (dataI < tasks.length && localI < length) {
      if (this[localI].position < tasks[dataI].position) {
        localI++;
      } else {
        for (int i = localI; i < length; i++) {
          this[i].position++;
        }
        dataI++;
      }
    }
    for (final task in tasks) {
      add(TaskC.create(task));
    }
    refreshPositions();
  }

  void editTasks(List<TaskEditParams> tasks) {
    final edits = <TaskEditParams>[];
    final founds = <Task>[];
    final missing = <String>[];
    for (var task in tasks) {
      if (task.isEmpty) {
        continue;
      }
      final index = indexWhere((t) => t.id == task.id);
      if (index == -1) {
        missing.add(task.id);
      } else {
        edits.add(task);
        founds.add(this[index]);
      }
    }
    if (missing.isNotEmpty) {
      throw StateError('Task not found');
    }
    if (founds.isEmpty) {
      return;
    }
    for (int i = 0; i < founds.length; i++) {
      final params = edits[i];
      final task = founds[i];

      final position = params.position;
      if (position != null && position != task.position) {
        for (var local in this) {
          if (local.position >= position) {
            local.position = task.position;
          }
        }
        task.position = position;
      }
      final description = params.description;
      if (description != null && description != task.description) {
        task.description = description;
      }
      final isChecked = params.isChecked;
      if (isChecked != null && isChecked != task.isChecked) {
        task.isChecked = isChecked;
      }
    }
    refreshPositions();
  }

  void removeTasks(List<String> ids) {
    removeWhere((t) => ids.contains(t.id));
  }
}
