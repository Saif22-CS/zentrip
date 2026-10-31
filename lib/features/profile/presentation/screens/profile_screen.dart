import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../global_widgets/confirm_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../routes/app_routes.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../../../favorites/logic/favorites_controller.dart';
import '../../../chatbot/presentation/screens/chat_history_screen.dart';
import '../../../chatbot/logic/chatbot_controller.dart';
import '../../logic/profile_controller.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'appearance_screen.dart';
import 'language_screen.dart';
import 'currency_screen.dart';
import 'notification_settings_screen.dart';
import 'travel_preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ctrl = ProfileController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppConfirmDialog(context,
        title: l10n.logoutConfirmTitle, message: l10n.logoutConfirmMessage);
    if (!ok || !mounted) return;
    await ApiService.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.auth, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ApiService.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            children: [
              // ── Avatar + Name ─────────────────────────────────────────
              _ProfileHeader(
                  user: user,
                  isDark: isDark,
                  onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()),
                      )),
              const SizedBox(height: 28),

              // ── Stats Row ─────────────────────────────────────────────
              _StatsRow(isDark: isDark).animate().fade(delay: 150.ms),
              const SizedBox(height: 24),

              // ── Menu sections ─────────────────────────────────────────
              _MenuSection(
                  title: l10n.profileSectionTripsChats,
                  items: [
                    if (user?.isAdmin == true || user?.isPartner == true)
                      _MenuItem(
                          Icons.admin_panel_settings_outlined,
                          user!.isPartner
                              ? l10n.partnerDashboard
                              : l10n.adminDashboard,
                          AppColors.primary,
                          () => Navigator.pushNamed(
                              context,
                              user.isPartner
                                  ? AppRoutes.partnerDashboard
                                  : AppRoutes.adminDashboard)),
                    _MenuItem(
                        Icons.card_travel_rounded,
                        l10n.myTrips,
                        AppColors.primary,
                        () => Navigator.pushNamed(context, AppRoutes.home)),
                    _MenuItem(
                        Icons.bookmark_rounded,
                        l10n.favorites,
                        AppColors.accentPurple,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FavoritesScreen()))),
                    _MenuItem(
                        Icons.history_rounded,
                        l10n.chatHistory,
                        AppColors.accentTeal,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatHistoryScreen()))),
                  ],
                  isDark: isDark),
              const SizedBox(height: 16),

              _MenuSection(
                  title: l10n.profileSectionPreferences,
                  items: [
                    _MenuItem(
                        Icons.tune_rounded,
                        l10n.travelPreferencesTitle,
                        AppColors.primary,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const TravelPreferencesScreen()))),
                    _MenuItem(
                        Icons.notifications_outlined,
                        l10n.notificationSettingsTitle,
                        AppColors.accentOrange,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationSettingsScreen()))),
                    _MenuItem(
                        Icons.palette_outlined,
                        l10n.appearance,
                        AppColors.accentPurple,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AppearanceScreen()))),
                    _MenuItem(
                        Icons.language_outlined,
                        l10n.language,
                        AppColors.primary,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LanguageScreen()))),
                    _MenuItem(
                        Icons.attach_money_rounded,
                        l10n.currencyTitle,
                        AppColors.accentGreen,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CurrencyScreen()))),
                  ],
                  isDark: isDark),
              const SizedBox(height: 16),

              _MenuSection(
                  title: l10n.profileSectionAccountSecurity,
                  items: [
                    _MenuItem(
                        Icons.person_outline_rounded,
                        l10n.editProfileTitle,
                        AppColors.accentGreen,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()))),
                    _MenuItem(
                        Icons.lock_outlined,
                        l10n.changePasswordTitle,
                        AppColors.accentOrange,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen()))),
                    _MenuItem(
                        Icons.description_outlined,
                        l10n.termsAndConditions,
                        AppColors.accentTeal,
                        () => Navigator.pushNamed(context, AppRoutes.terms)),
                    _MenuItem(
                        Icons.privacy_tip_outlined,
                        l10n.privacyPolicy,
                        AppColors.primary,
                        () => Navigator.pushNamed(context, AppRoutes.privacy)),
                    _MenuItem(Icons.logout_rounded, l10n.logout,
                        AppColors.accentRed, _logout,
                        isDestructive: true),
                  ],
                  isDark: isDark),
              const SizedBox(height: 16),

              // ── App version ───────────────────────────────────────────
              const Text('Zentrip v1.0.0',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool isDark;
  final VoidCallback onEdit;
  const _ProfileHeader(
      {required this.user, required this.isDark, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: user?.photoUrl != null
                  ? ClipOval(
                      child: Image.network(user!.photoUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.person_rounded,
                      size: 44, color: Colors.white),
            ),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ],
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 14),
        Text(user?.name ?? AppLocalizations.of(context).profileDefaultUserName,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800))
            .animate()
            .fade(delay: 200.ms),
        const SizedBox(height: 4),
        Text(user?.email ?? '',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13))
            .animate()
            .fade(delay: 280.ms),
      ],
    );
  }
}

class _StatsRow extends StatefulWidget {
  final bool isDark;
  const _StatsRow({required this.isDark});

  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow> {
  int? _tripsCount;
  int? _chatsCount;
  bool _isLoading = true;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    ApiService.flightTripsRevision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    ApiService.flightTripsRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final flightsResult = await ApiService.instance.getMyFlightTrips();
    final sessions = await ChatbotController.loadHistory();
    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _tripsCount = ProfileController.countNonCancelledFlights(
        flightsResult.data ?? const [],
      );
      _chatsCount = sessions.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: widget.isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: _isLoading ? '-' : '${_tripsCount ?? 0}',
            label: l10n.profileStatTrips,
            icon: Icons.flight_rounded,
            color: AppColors.primary,
          ),
          Container(
              width: 1,
              height: 40,
              color: widget.isDark ? AppColors.darkBorder : AppColors.border),
          _StatItem(
            value: _isLoading ? '-' : '${_chatsCount ?? 0}',
            label: l10n.profileStatChats,
            icon: Icons.auto_awesome_rounded,
            color: AppColors.accentPurple,
          ),
          Container(
              width: 1,
              height: 40,
              color: widget.isDark ? AppColors.darkBorder : AppColors.border),
          ListenableBuilder(
            listenable: FavoritesController.instance,
            builder: (_, __) => _StatItem(
              value: '${FavoritesController.instance.all.length}',
              label: l10n.profileStatSaved,
              icon: Icons.bookmark_rounded,
              color: AppColors.accentOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  final bool isDark;
  const _MenuSection(
      {required this.title, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 4),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  _MenuTileWidget(item: e.value),
                  if (!isLast)
                    Divider(
                        height: 1,
                        color:
                            isDark ? AppColors.darkBorder : AppColors.divider,
                        indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuItem(this.icon, this.label, this.color, this.onTap,
      {this.isDestructive = false});
}

class _MenuTileWidget extends StatelessWidget {
  final _MenuItem item;
  const _MenuTileWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: item.onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, color: item.color, size: 18),
        ),
        title: Text(item.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: item.isDestructive ? AppColors.accentRed : null,
            )),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 18),
      ),
    );
  }
}
