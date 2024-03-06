import 'package:agendo/backend/models/abstract/activity.dart';
import 'package:agendo/backend/models/abstract/data_manager.dart';
import 'package:agendo/backend/models/abstract/record.dart';

class MockLocalStorage implements LocalStorage {
  final _activities = <String, Activity>{};
  final _records = <String, Record>{};

  @override
  Future<List<Activity>> getActivities(List<String> ids) async {
    final result = <Activity>[];
    for (final id in ids) {
      final value = _activities[id];
      if (value != null) {
        result.add(value);
      }
    }
    return result;
  }

  @override
  Future<Activity?> getActivity(String id) async {
    return _activities[id];
  }

  @override
  Future<List<Activity>> getAllActivities(DateTime? lastEdit) async {
    if (lastEdit != null) {
      final result = <Activity>[];
      for (var activity in _activities.values) {
        final last = activity.lastEdit;
        if (last != null &&
            last.microsecondsSinceEpoch > lastEdit.microsecondsSinceEpoch) {
          result.add(activity);
        }
      }
      return result;
    } else {
      return _activities.values.toList();
    }
  }

  @override
  Future<List<Record>> getRecords(DateTime? after) async {
    if (after != null) {
      return _records.values
          .where((r) =>
              r.date.microsecondsSinceEpoch >= after.microsecondsSinceEpoch)
          .toList();
    } else {
      return _records.values.toList();
    }
  }

  @override
  Future<void> removeActivities(List<String> ids) async {
    for (final id in ids) {
      _activities.remove(id);
    }
  }

  @override
  Future<void> removeActivity(String id) async {
    _activities.remove(id);
  }

  @override
  Future<void> removeAllActivities() async {
    _activities.clear();
  }

  @override
  Future<void> removeAllRecords() async {
    _records.clear();
  }

  @override
  Future<void> setActivities(List<Activity> activities) async {
    for (final activity in activities) {
      _activities[activity.id] = activity;
    }
  }

  @override
  Future<void> setActivity(Activity activity) async {
    _activities[activity.id] = activity;
  }

  @override
  Future<void> setRecord(Record record) async {
    _records[record.id] = record;
  }
  @override
  Future<void> setAllRecords(List<Record> records) async {
    for(final record in records) {
      _records[record.id] = record;
    }
  }
}
