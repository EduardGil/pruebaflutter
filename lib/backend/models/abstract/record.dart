import 'package:agendo/backend/models/abstract/activity.dart';

export 'record.dart'
    show
    RecordAction,
    Record,
    EditRecord,
    RecordHolder;

enum RecordAction { add, edit, remove }

abstract class Record {
  abstract final String id;
  abstract final DateTime date;
  abstract final RecordAction action;
  abstract final String activity;
}

abstract class EditRecord extends Record {
  abstract final ActivityEditParams changes;
}

abstract class RecordHolder {
  abstract final Map<String, Record> records;
  List<Record> getRecords(
      {String? activity, DateTime? from, DateTime? to, RecordAction? action, Set<String>? ids});
  Record addRecord(
      RecordAction action, Activity activity, [ActivityEditParams? changes]);
}
