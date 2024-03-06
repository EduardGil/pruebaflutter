import 'package:agendo/backend/apis/id_generator.dart';
import 'package:agendo/backend/models/abstract/activity.dart';
import 'package:agendo/backend/models/abstract/task.dart';
import 'package:agendo/backend/models/concrete/task.dart';
import 'package:agendo/local_config.dart';
import 'package:agendo/utils/calculus.dart';
import 'package:agendo/utils/extensions.dart';

class ActivityC implements Activity {
  @override
  final String id;
  @override
  String name;
  @override
  @override
  final DateTime creationDate;
  @override
  DateTime? lastEdit;
  @override
  String description;
  @override
  int color;
  @override
  String icon;
  @override
  bool hasStartDate;
  @override
  bool hasStartTime;
  int _postponed;
  DateTime _start;
  @override
  bool hasEndDate;
  @override
  bool hasEndTime;
  DateTime _end;
  @override
  ActivityAction action;
  @override
  final List<Task> tasks;

  ActivityC(
      this.id,
      this.name,
      this.creationDate,
      this.lastEdit,
      this.description,
      this.color,
      this.icon,
      this.hasStartDate,
      this.hasStartTime,
      this._postponed,
      this._start,
      this.hasEndDate,
      this.hasEndTime,
      this._end,
      this.action,
      this.tasks);

  ActivityC.create(ActivityAddParams params)
      : id = activityIdIdentifier + randomId(),
        name = params.name,
        creationDate = DateTime.now(),
        lastEdit = null,
        description = params.description,
        color = params.color,
        icon = params.icon,
        hasStartDate = params.hasStartDate,
        hasStartTime = params.hasStartTime,
        _postponed = 0,
        _start = params.start ?? DateTime.now(),
        hasEndDate = params.hasEndDate,
        hasEndTime = params.hasEndTime,
        _end =
            params.end ?? DateTime.now().copyWith(day: DateTime.now().day + 1),
        action = ActivityAction.none,
        tasks = params.tasks?.map((t) => TaskC.create(t)).toList() ?? [];

  @override
  bool get hasDescription => description.isNotEmpty;

  @override
  int get postponed => _postponed;

  @override
  set postponed(value) {
    if (value < 0) {
      throw AssertionError("Postposition time cant be negative");
    }
    _postponed = value;
  }

  @override
  bool get wasPostponed => postponed > 0;

  @override
  bool get hasStart => hasStartDate || hasStartTime;

  @override
  bool get hasEnd => hasEndDate || hasEndTime;

  @override
  Duration? get duration {
    if (!hasStart || !hasEnd) {
      return null;
    }
    return _end.difference(_start);
  }

  @override
  DateTime? get start {
    if (!hasStart) {
      return null;
    }
    final date = hasStartDate;
    final time = hasStartTime;
    return DateTime(
        date ? _start.year : 0,
        date ? _start.month : 0,
        date ? _start.day : 0,
        time ? _start.hour : 0,
        time ? _start.minute : 0,
        time ? _start.second + _postponed : 0,
        0);
  }

  @override
  set start(value) {
    if (value == null) {
      hasStartDate = false;
      hasStartTime = false;
    } else {
      _end = value.copyWith().add(duration ?? activityDefaultDuration);
      _start = value;
      _postponed = 0;
    }
  }

  @override
  DateTime? get end {
    if (!hasEnd) {
      return null;
    }
    final date = hasEndDate;
    final time = hasEndTime;
    return DateTime(
        date ? _end.year : _end.year + 1,
        date ? _end.month : 11,
        date ? _end.day : 28,
        time ? _end.hour : 23,
        time ? _end.minute : 59,
        time ? _end.second : 59,
        0);
  }

  @override
  set end(value) {
    if (value == null) {
      hasEndDate = false;
      hasEndTime = false;
    } else {
      if (value.isAfter(_start)) {
        if (hasStart) {
          throw AssertionError(
              "Negative duration is not possible, end must be after start");
        } else {
          _start = value.copyWith().subtract(activityDefaultDuration);
        }
      }
      _end = value;
    }
  }

  @override
  ActivityState get state {
    if (action == ActivityAction.complete) {
      return ActivityState.complete;
    }
    if (action == ActivityAction.cancel) {
      return ActivityState.cancel;
    }
    final now = DateTime.now();
    final start = this.start;
    final end = this.end;

    if (hasStartDate && start!.isAfter(now)) {
      return ActivityState.waiting;
    }
    if (hasEndDate && end!.isBefore(now)) {
      return ActivityState.expired;
    }
    const minPoint = 0;
    final startPoint =
        hasStartTime ? start!.hour * 60 + start.minute : minPoint;
    const maxPoint = 23 * 60 + 59;
    final endPoint = hasEndTime ? end!.hour * 60 + end.minute : maxPoint;
    final actualPoint = now.hour * 60 + now.minute;
    if (startPoint > endPoint) {
      return isBetween(startPoint, actualPoint, maxPoint) ||
              isBetween(minPoint, actualPoint, endPoint)
          ? ActivityState.active
          : ActivityState.waiting;
    } else {
      return isBetween(startPoint, actualPoint, endPoint)
          ? ActivityState.active
          : ActivityState.waiting;
    }
  }

  @override
  void checkEditable(ActivityEditParams params) {
    if (params.tasks != null && params.tasks!.isNotEmpty) {
      const List<String> missing = [];
      for (final operation in params.tasks!) {
        if (tasks.indexWhere((t) => t.id == operation.params.id) == -1) {
          missing.add(id);
        }
      }
      if (missing.isNotEmpty) {
        throw AssertionError('Task not found $missing');
      }
    }
    if (params.postponed != null && params.postponed! < 0) {
      throw AssertionError("Postposition time cant be negative");
    }
    final hasStart = params.start != null ||
        (params.hasStartTime ?? hasStartTime) ||
        (params.hasStartDate ?? hasStartDate);
    final hasEnd = params.end != null ||
        (params.hasEndTime ?? hasEndTime) ||
        (params.hasEndDate ?? hasEndDate);
    if (hasStart && hasEnd) {
      if ((params.start ?? start ?? _start)
          .isAfter(params.end ?? end ?? _end)) {
        throw AssertionError(
            "Negative duration is not possible, end must be after start");
      }
    }
    if (params.color != null) {
      if (!isBetween(0, params.color!, 360)) {
        throw AssertionError('Activity color must be between 0 and 360');
      }
    }
  }

  @override
  bool get hasTasks => tasks.isNotEmpty;

  @override
  void addTasks(List<TaskAddParams> tasks) {
    this.tasks.addTasks(tasks);
  }

  @override
  void editTasks(List<TaskEditParams> tasks) {
    this.tasks.editTasks(tasks);
  }

  @override
  void removeTasks(List<String> ids) {
    tasks.removeTasks(ids);
  }
}
