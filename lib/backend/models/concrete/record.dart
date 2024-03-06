import 'package:agendo/backend/apis/id_generator.dart';
import 'package:agendo/backend/models/abstract/activity.dart';
import 'package:agendo/backend/models/abstract/record.dart';
import 'package:agendo/local_config.dart';

export 'record.dart';

class RecordC implements Record {
  @override
  final String id;

  @override
  final DateTime date;
  @override
  final String activity;

  @override
  final RecordAction action;

  RecordC(this.id, this.date, this.activity, this.action);

  RecordC.create(this.action, Activity activity)
      : id = recordIdIdentifier + randomId(),
        date = DateTime.now(),
        activity = activity.id;
}

class EditRecordC extends RecordC implements EditRecord {
  @override
  final ActivityEditParams changes;

  EditRecordC(super.id, super.date, super.activity, super.action, this.changes);

  EditRecordC.create(super.action, super.activity, this.changes)
      : super.create();
}

class RecordHolderC implements RecordHolder {
  @override
  final Map<String, Record> records = {};

  @override
  List<Record> getRecords(
      {String? activity,
      DateTime? from,
      DateTime? to,
      RecordAction? action,
      Set<String>? ids}) {
    final result = <Record>[];
    for (final record in records.values) {
      if (ids != null && !ids.contains(record.id)) {
        continue;
      }
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
  Record addRecord(
      RecordAction action, Activity activity, [ActivityEditParams? changes]) {
    final Record record;
    switch (action) {
      case RecordAction.add:
      case RecordAction.remove:
        record = RecordC.create(action, activity);
        break;
      case RecordAction.edit:
        if (changes == null) {
          throw ArgumentError(
              'Record.action == Edit requires changes', 'missing changes');
        }
        record = EditRecordC.create(action, activity, changes);
        break;
    }
    records[record.id] = record;
    return record;
  }
}
