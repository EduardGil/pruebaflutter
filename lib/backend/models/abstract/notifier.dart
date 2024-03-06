import 'package:agendo/backend/models/abstract/activity.dart';

enum ActionNotification { add, edit, delete, complete, cancel, delay }

enum UpdateNotification { anticipation, active, reminder, warn, expire }

enum ContactNotification { touch, accept, reject, remove }

typedef Group = Notifiable;

abstract class Notifier {
  /// Instant notification when an activity of your own is updated
  Future<void> activity(Notifiable author, Notifiable target, Activity activity,
      ActionNotification type);

  /// Instant notification when you are added in a group
  Future<void> group(
      Notifiable author, Notifiable target, Activity activity, Group group);

  /// Instant notification when a contact interacts with you
  Future<void> contact(
      Notifiable author, Notifiable target, ContactNotification type);

  /// Scheduled or update the notifications for an activity
  ///
  /// Includes:
  /// - anticipations
  /// - activation (multiple in case of not-all day and multiple day duration)
  /// - reminders
  /// - warnings
  /// - expiration (only last one)
  /// - repetitions (and each of the above for repetitions)
  Future<void> scheduled(
      Notifiable author, Notifiable target, Activity activity);
}

abstract class Notifiable {}
