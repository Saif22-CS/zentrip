import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// إضافة أحداث الرحلات لتقويم الجهاز نفسه (Google Calendar/Apple Calendar
/// حسب الجهاز) — مش تقويم داخل التطبيق، ده تقويم النظام فعليًا.
class CalendarSyncService {
  static final CalendarSyncService instance = CalendarSyncService._();
  CalendarSyncService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  bool _tzReady = false;

  void _ensureTimezones() {
    if (_tzReady) return;
    tz_data.initializeTimeZones();
    _tzReady = true;
  }

  /// بيرجع true لو نجح الإضافة، false لو المستخدم رفض الصلاحية أو حصل خطأ.
  Future<bool> addTripEvent({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      _ensureTimezones();
      var permissions = await _plugin.hasPermissions();
      if (permissions.data != true) {
        permissions = await _plugin.requestPermissions();
        if (permissions.data != true) return false;
      }

      final calendarsResult = await _plugin.retrieveCalendars();
      final calendars = calendarsResult.data;
      if (calendars == null || calendars.isEmpty) return false;
      final defaultCalendar = calendars.firstWhere((c) => !(c.isReadOnly ?? true), orElse: () => calendars.first);
      if (defaultCalendar.isReadOnly == true) return false;

      final event = Event(
        defaultCalendar.id,
        title: title,
        description: description,
        start: tz.TZDateTime.from(start, tz.local),
        end: tz.TZDateTime.from(end, tz.local),
      );
      final createResult = await _plugin.createOrUpdateEvent(event);
      return createResult?.isSuccess == true;
    } catch (_) {
      return false;
    }
  }
}
