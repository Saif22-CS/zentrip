import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// رصد حالة الاتصال بالإنترنت — بيتستخدم لعرض بانر "أنت غير متصل" ولتفعيل
/// الرجوع للبيانات المحفوظة محليًا (Cache) بدل ما الشاشة تفضل فاضية.
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService instance = ConnectivityService._();
  ConnectivityService._();

  bool isOnline = true;

  Future<void> init() async {
    final result = await Connectivity().checkConnectivity();
    isOnline = !result.contains(ConnectivityResult.none);
    notifyListeners();
    Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != isOnline) {
        isOnline = online;
        notifyListeners();
      }
    });
  }
}
