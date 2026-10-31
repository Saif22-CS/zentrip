import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/currency_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/push_notification_service.dart';
import 'features/favorites/logic/favorites_controller.dart';
import 'features/notifications/logic/notifications_store.dart';
import 'features/price_alerts/logic/price_alerts_store.dart';
import 'global_widgets/app_snackbar.dart';
import 'global_widgets/locale_controller.dart';
import 'global_widgets/theme_controller.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_routes.dart';

/// مفتاح تنقّل عام يسمح بالتنقل من أي مكان في التطبيق حتى خارج BuildContext.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.instance.init();

  // عند أي رد 401 من الخادم: امسح الجلسة وأعد التوجيه لشاشة الدخول فوراً.
  ApiService.instance.onSessionExpired = () {
    final context = navigatorKey.currentContext;
    if (context != null) {
      AppSnackbar.warning(
        context,
        AppLocalizations.of(context).sessionExpiredMessage,
      );
    }
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.auth,
      (r) => false,
    );
  };

  // تحميل التفضيلات المحفوظة قبل بناء الواجهة
  await Future.wait([
    ThemeController.instance.loadSavedTheme(),
    LocaleController.instance.loadSavedLocale(),
    FavoritesController.instance.load(),
    NotificationsStore.instance.load(),
    PriceAlertsStore.instance.load(),
    CurrencyService.instance.init(),
    ConnectivityService.instance.init(),
  ]);

  // تسجيل استقبال Push Notifications (آمن تمامًا حتى لو Firebase لسه مش
  // مظبوط — بترجع فورًا من غير أي تأثير، راجع push_notification_service.dart).
  await PushNotificationService.instance.initialize();

  runApp(const ZentripApp());
}

class ZentripApp extends StatelessWidget {
  const ZentripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          locale: LocaleController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) =>
              LocaleController.resolveSupportedLocale(locale, supportedLocales),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
