import 'dart:async';

import 'package:agendo/backend/models/abstract/activity.dart';
import 'package:agendo/backend/models/abstract/record.dart';

export 'data_manager.dart' show DataManager, LocalStorage, DataBase;

abstract class DataManager {
  abstract final LocalStorage ls;
  abstract final DataBase db;

  Future<void> setActivity(Activity activity);

  Future<void> setActivities(List<Activity> activities);

  Future<Activity?> getActivity(String id);

  /// [errorWhenMissing] is TRUE by default
  Future<List<Activity>> getActivities(
      List<String> ids, [bool errorWhenMissing]);

  Future<List<Activity>> getAllActivities(bool fetch);

  Future<Activity?> removeActivity(String id);

  Future<List<Activity>> removeActivities(List<String> ids);

  Future<List<Record>> fetchRecords();

  List<Record> getRecords({String? activity, DateTime? from, DateTime? to, RecordAction? action});

  Future<Record> addRecord(
      RecordAction action, Activity activity, [ActivityEditParams? changes]);

  Future<void> clearCache();
}

/// Implemented on DB section
abstract class DataBase {
  Future<Activity?> getActivity(String id);

  Future<List<Activity>> getActivities(List<String> ids);

  Future<List<Activity>> getAllActivities(DateTime? lastEdit);

  Future<void> setActivity(Activity activity);

  Future<void> setActivities(List<Activity> activities);

  Future<void> removeActivity(String id);

  Future<void> removeActivities(List<String> ids);

  Future<List<Record>> getRecords(DateTime? after);

  Future<void> setRecord(Record record);
}

/// Implemented on FRONTEND section
abstract class LocalStorage {
  Future<Activity?> getActivity(String id);

  Future<List<Activity>> getActivities(List<String> ids);

  Future<List<Activity>> getAllActivities(DateTime? lastEdit);

  Future<void> setActivity(Activity activity);

  Future<void> setActivities(List<Activity> activities);

  Future<void> removeActivity(String id);

  Future<void> removeActivities(List<String> ids);

  Future<void> removeAllActivities();

  Future<List<Record>> getRecords(DateTime? after);

  Future<void> setRecord(Record record);
  Future<void> setAllRecords(List<Record> records);

  Future<void> removeAllRecords();
}
