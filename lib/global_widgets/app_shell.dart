import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart' as app_colors;
import '../features/home/presentation/screens/home_screen.dart';
import '../features/chatbot/presentation/screens/chatbot_screen.dart';
import '../features/nearby/presentation/screens/nearby_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/trips/presentation/screens/my_trips_screen.dart';
import '../l10n/app_localizations.dart';
import 'offline_banner.dart';

/// بيسمح لأي شاشة جوه الـ IndexedStack (زي HomeScreen) إنها "تنادي" على
/// AppShell وتخليه يبدّل التاب — من غير ما تعمل Navigator.push لصفحة جديدة
/// (لأن AppShell أصلاً هي الشاشة الحالية، وبس بنبدّل مين اللي ظاهر جواها).
class AppShellTabController {
  static final ValueNotifier<int?> pendingIndex = ValueNotifier<int?>(null);

  static void goToChatbot() => pendingIndex.value = 2;
  static void goToTab(int index) => pendingIndex.value = index;
}

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  late int _selectedIndex;
  late final AnimationController _animController;

  final List<Widget> _screens = const [
    HomeScreen(),
    NearbyScreen(),
    ChatbotScreen(),
    MyTripsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        AppShellTabController.pendingIndex.value ?? widget.initialIndex;
    AppShellTabController.pendingIndex.value = null;
    AppShellTabController.pendingIndex.addListener(_onPendingIndexChanged);
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _animController.forward();
  }

  void _onPendingIndexChanged() {
    final target = AppShellTabController.pendingIndex.value;
    if (target != null) {
      _onItemTapped(target);
      AppShellTabController.pendingIndex.value = null;
    }
  }

  @override
  void dispose() {
    AppShellTabController.pendingIndex.removeListener(_onPendingIndexChanged);
    _animController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _animController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? app_colors.AppColors.darkSurface : Colors.white;

    return Scaffold(
      body: Column(
        children: [
          const SafeArea(bottom: false, child: OfflineBanner()),
          Expanded(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (_, __) => FadeTransition(
                opacity: _animController,
                child: IndexedStack(index: _selectedIndex, children: _screens),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            height: 84,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 68,
                  child: Container(
                    decoration: BoxDecoration(
                      color: navBg,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _dockItem(
                          icon: Icons.explore_outlined,
                          activeIcon: Icons.explore_rounded,
                          label: l10n.navHome,
                          index: 0,
                          isDark: isDark,
                        ),
                        _dockItem(
                          icon: Icons.place_outlined,
                          activeIcon: Icons.place_rounded,
                          label: l10n.navNearby,
                          index: 1,
                          isDark: isDark,
                        ),
                        const Expanded(child: SizedBox()),
                        _dockItem(
                          icon: Icons.card_travel_outlined,
                          activeIcon: Icons.card_travel_rounded,
                          label: l10n.navTrips,
                          index: 3,
                          isDark: isDark,
                        ),
                        _dockItem(
                          icon: Icons.person_outline_rounded,
                          activeIcon: Icons.person_rounded,
                          label: l10n.navProfile,
                          index: 4,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'app-shell-ai-hub',
                        tooltip: l10n.navChatbot,
                        onPressed: () => _onItemTapped(2),
                        backgroundColor: app_colors.AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(Icons.auto_awesome_rounded),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.navChatbot,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: _selectedIndex == 2
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedIndex == 2
                              ? app_colors.AppColors.primary
                              : isDark
                                  ? app_colors.AppColors.darkTextSecondary
                                  : app_colors.AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dockItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? app_colors.AppColors.primary
        : isDark
            ? app_colors.AppColors.darkTextSecondary
            : app_colors.AppColors.textSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isSelected ? activeIcon : icon, color: color, size: 23),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
