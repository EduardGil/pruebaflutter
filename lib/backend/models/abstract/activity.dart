import 'package:agendo/backend/models/abstract/task.dart';
import 'package:agendo/local_config.dart';

export 'activity.dart'
    show
        ActivityState,
        ActivityAction,
        ReadOnlyActivity,
        Activity,
        ActivityAddParams,
        ActivityEditParams;

enum ActivityState {
  waiting,
  active,
  expired,
  complete,
  cancel,
}

enum ActivityAction { complete, cancel, none }

abstract class ReadOnlyActivity {
  abstract final String id;

  String get name;

  String get description;

  bool get hasDescription;

  /// this represents the HUE value, the SATURATION and LIGHT are given by frontend theme
  int get color;

  String get icon;

  abstract final DateTime creationDate;

  /// Update by hand when changes to be saved are done
  DateTime? get lastEdit;

  abstract final List<ReadOnlyTask> tasks;

  bool get hasTasks;

  bool get hasStartDate;

  bool get hasStartTime;

  /// When null the params hasStartDate and hasStartTime are set as false
  ///
  /// When Date the end will edited to maintain the duration
  DateTime? get start;

  /// Amount of SECONDS the start time was delayed, will be lost when START is edited
  int get postponed;

  bool get wasPostponed;

  bool get hasStart;

  bool get hasEndDate;

  bool get hasEndTime;

  /// When null the params hasEndDate and hasEndTime are set as false
  DateTime? get end;

  bool get hasEnd;

  Duration? get duration;

  ActivityAction get action;

  ActivityState get state;

  void checkEditable(ActivityEditParams params);
}

abstract class Activity extends ReadOnlyActivity {
  set name(value);

  set description(value);

  set color(value);

  set icon(value);

  set lastEdit(value);

  @override
  abstract final List<Task> tasks;

  void addTasks(List<TaskAddParams> tasks);

  void editTasks(List<TaskEditParams> tasks);

  void removeTasks(List<String> ids);

  set hasStartDate(value);

  set hasStartTime(value);

  set start(value);

  set postponed(value);

  set hasEndDate(value);

  set hasEndTime(value);

  set end(value);

  set action(value);
}

class ActivityAddParams {
  final String name;
  final String description;
  final int color;
  final String icon;
  final bool hasStartDate;
  final bool hasStartTime;
  final DateTime? start;
  final bool hasEndDate;
  final bool hasEndTime;
  final DateTime? end;
  final List<TaskAddParams>? tasks;

  const ActivityAddParams({
    required this.name,
    required this.description,
    this.color = activityDefaultColor,
    this.icon = activityDefaultIcon,
    required this.hasStartDate,
    required this.hasStartTime,
    this.start,
    required this.hasEndDate,
    required this.hasEndTime,
    this.end,
    this.tasks,
  });
}

class ActivityEditParams {
  final String id;
  final String? name;
  final String? description;
  final int? color;
  final String? icon;
  final bool? hasStartDate;
  final bool? hasStartTime;
  final DateTime? start;
  final bool? hasEndDate;
  final bool? hasEndTime;
  final DateTime? end;
  final int? postponed;
  final ActivityAction? action;
  final List<TaskOperation>? tasks;

  const ActivityEditParams({
    required this.id,
    this.name,
    this.description,
    this.color,
    this.icon,
    this.hasStartDate,
    this.hasStartTime,
    this.start,
    this.hasEndDate,
    this.hasEndTime,
    this.end,
    this.postponed,
    this.action,
    this.tasks,
  });
}
