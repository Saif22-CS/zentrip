import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../models/travel_package_model.dart';
import '../../../models/trip_model.dart';

enum NotifKind { booking, cancel, chat, promo, reminder }

class NotificationItem {
  final String id;
  final NotifKind kind;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        kind: kind,
        title: title,
        subtitle: subtitle,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'subtitle': subtitle,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String,
        kind: NotifKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => NotifKind.booking),
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        isRead: j['is_read'] as bool? ?? false,
      );
}

/// إشعارات حقيقية بتتولّد من أحداث فعلية في التطبيق (حجز ناجح، إلغاء
/// رحلة..إلخ) — مش بيانات وهمية ثابتة. متخزنة محليًا ومربوطة بحساب
/// المستخدم الحالي، بنفس أسلوب المفضلة بالظبط.
class NotificationsStore extends ChangeNotifier {
  static final NotificationsStore instance = NotificationsStore._();
  NotificationsStore._();

  static const int _maxStored = 30;
  final List<NotificationItem> _items = [];

  List<NotificationItem> get all => List.unmodifiable(_items);
  bool get hasUnread => _items.any((n) => !n.isRead);

  String get _key => 'notifications_${ApiService.instance.currentUser?.email ?? 'guest'}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _items
      ..clear()
      ..addAll(raw.map((e) => NotificationItem.fromJson(jsonDecode(e) as Map<String, dynamic>)));
    notifyListeners();
  }

  /// بتتنادى عند تسجيل الخروج — عشان الإشعارات متفضلش في الذاكرة لحساب قديم.
  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<void> add({required NotifKind kind, required String title, required String subtitle, String? dedupeId}) async {
    if (dedupeId != null && _items.any((n) => n.id == dedupeId)) return; // إشعار زي ده اتبعت قبل كده
    _items.insert(0, NotificationItem(
      id: dedupeId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      kind: kind,
      title: title,
      subtitle: subtitle,
      createdAt: DateTime.now(),
    ));
    if (_items.length > _maxStored) _items.removeRange(_maxStored, _items.length);
    notifyListeners();
    await _persist();
  }

  /// بتقارن العروض الحالية بآخر عروض شافها المستخدم، وتولّد إشعار بس
  /// للعروض الجديدة فعلاً. أول مرة يفتح فيها المستخدم التطبيق، كل العروض
  /// بتتسجّل كـ "متشافة" من غير ما تغرقه بإشعارات لعروض كانت موجودة أصلاً.
  Future<void> notifyNewOffers(List<TravelPackage> offers, {required String promoTitle}) async {
    final seenKey = '${_key}_seen_offers';
    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList(seenKey) ?? []).toSet();
    final isFirstRun = seen.isEmpty;
    var changed = false;
    for (final o in offers) {
      if (seen.add(o.id)) {
        changed = true;
        if (!isFirstRun) {
          await add(kind: NotifKind.promo, title: promoTitle, subtitle: o.title, dedupeId: 'offer_${o.id}');
        }
      }
    }
    if (changed) await prefs.setStringList(seenKey, seen.toList());
  }

  /// بيدوّر على رحلات قريب ميعادها (خلال 3 أيام) ويولّد تذكير — مرة واحدة
  /// بس لكل رحلة (مش هيكرر التذكير كل ما تفتح التطبيق).
  Future<void> checkTripReminders(List<TripModel> trips, {required String reminderTitle}) async {
    final now = DateTime.now();
    for (final t in trips) {
      if (t.status != 'upcoming') continue;
      final daysUntil = t.departureDate.difference(now).inDays;
      if (daysUntil < 0 || daysUntil > 3) continue;
      await add(
        kind: NotifKind.reminder,
        title: reminderTitle,
        subtitle: '${t.originCode} → ${t.destinationCode}',
        dedupeId: 'reminder_${t.id}',
      );
    }
  }

  Future<void> markAllRead() async {
    if (!hasUnread) return;
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _items.map((n) => jsonEncode(n.toJson())).toList());
  }
}
