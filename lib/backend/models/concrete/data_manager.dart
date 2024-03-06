import 'package:agendo/backend/models/abstract/activity.dart';
import 'package:agendo/backend/models/abstract/data_manager.dart';
import 'package:agendo/backend/models/abstract/record.dart';
import 'package:agendo/backend/models/concrete/record.dart';
import 'package:agendo/db/models/mock.dart';
import 'package:agendo/frontend/models/mock.dart';

export 'data_manager.dart';

class DataManagerC implements DataManager {
  DataManagerC._();

  static final DataManagerC _instance = DataManagerC._();

  factory DataManagerC() => _instance;

  @override
  final LocalStorage ls = MockLocalStorage();
  @override
  final DataBase db = MockDataBase();

  final Map<String, Activity> _activities = {};
  DateTime? _lastActivityFetch;

  final _recordHolder = RecordHolderC();
  DateTime? _lastRecordFetch;

  @override
  Future<void> setActivity(Activity activity) async {
    _activities[activity.id] = activity;
    await Future.wait([ls.setActivity(activity), db.setActivity(activity)]);
  }

  @override
  Future<void> setActivities(List<Activity> activities) async {
    for (final activity in activities) {
      _activities[activity.id] = activity;
    }
    await Future.wait([
      ls.setActivities(activities),
      db.setActivities(activities),
    ]);
  }

  @override
  Future<Activity?> getActivity(String id) async {
    Activity? activity = _activities[id] ?? await ls.getActivity(id);
    if (activity == null) {
      activity = await db.getActivity(id);
      if (activity != null) {
        ls.setActivity(activity);
        _activities[activity.id] = activity;
      }
    }
    return activity;
  }

  @override
  Future<List<Activity>> getActivities(List<String> ids,
      [bool errorWhenMissing = true]) async {
    final List<Activity> found = [];
    List<String> missing = [];
    for (final id in ids) {
      final activity = _activities[id];
      if (activity != null) {
        found.add(activity);
      } else {
        missing.add(id);
      }
    }
    if (missing.isNotEmpty) {
      final List<String> newMissing = [];
      final activities = await ls.getActivities(missing);
      final locals = activities.map((a) => a.id);
      for (final id in missing) {
        if (!locals.contains(id)) {
          newMissing.add(id);
        }
      }
      missing = newMissing;
      for (final activity in activities) {
        found.add(activity);
      }
    }
    if (missing.isNotEmpty) {
      final List<String> newMissing = [];
      final activities = await db.getActivities(ids);
      final locals = activities.map((a) => a.id);
      for (final id in missing) {
        if (!locals.contains(id)) {
          newMissing.add(id);
        }
      }
      missing = newMissing;
      for (final activity in activities) {
        found.add(activity);
        _activities[activity.id] = activity;
      }
      ls.setActivities(activities);
    }
    if (missing.isNotEmpty && errorWhenMissing) {
      throw AssertionError('Activities not found $missing');
    }
    return found;
  }

  @override
  Future<List<Activity>> getAllActivities(bool fetch) async {
    final List<Activity> activities;
    if (!fetch) {
      activities = await ls.getAllActivities(null);
    } else {
      activities = await db.getAllActivities(_lastActivityFetch);
      await ls.setActivities(activities);
    }
    for (final activity in activities) {
      _activities[activity.id] = activity;
    }
    return activities;
  }

  @override
  Future<Activity?> removeActivity(String id) async {
    final activity = await getActivity(id);
    if (activity == null) {
      return null;
    }
    _activities.remove(id);
    await Future.wait([
      ls.removeActivity(id),
      db.removeActivity(id),
    ]);
    return activity;
  }

  @override
  Future<List<Activity>> removeActivities(List<String> ids) async {
    final activities = await getActivities(ids, false);
    ids = activities.map((a) => a.id).toList();
    await Future.wait([
      ls.removeActivities(ids),
      db.removeActivities(ids),
    ]);
    return activities;
  }

  @override
  Future<List<Record>> fetchRecords() async {
    final List<Record> records = await db.getRecords(_lastRecordFetch);
    ls.setAllRecords(records);
    for (final record in records) {
      _recordHolder.records[record.id] = record;
    }
    _lastRecordFetch =
        DateTime.now().copyWith(second: DateTime.now().second - 3);
    return _recordHolder.records.values.toList();
  }

  @override
  List<Record> getRecords(
      {String? activity, DateTime? from, DateTime? to, RecordAction? action}) {
    if (activity == null && from == null && to == null && action == null) {
      return _recordHolder.records.values.toList();
    }
    final List<Record> result = [];
    for (final record in _recordHolder.records.values) {
      if (activity != null && record.activity != activity) {
        continue;
      }
      if (from != null && record.date.isBefore(from)) {
        continue;
      }
      if (to != null && to.isBefore(record.date)) {
        continue;
      }
      if (action != null && record.action != action) {
        continue;
      }
      result.add(record);
    }
    return result;
  }

  @override
  Future<Record> addRecord(RecordAction action, Activity activity,
      [ActivityEditParams? changes]) async {
    final record = _recordHolder.addRecord(action, activity, changes);
    await Future.wait([ls.setRecord(record), db.setRecord(record)]);
    return record;
  }

  @override
  Future<void> clearCache() async {
    _activities.clear();
    _recordHolder.records.clear();
    _lastRecordFetch = null;
    await Future.wait([ls.removeAllActivities(), ls.removeAllRecords()]);
  }
}
