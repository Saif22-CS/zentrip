import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../global_widgets/app_snackbar.dart';
import '../../../../global_widgets/confirm_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/chatbot_controller.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await ChatbotController.loadHistory();
    if (mounted) setState(() { _sessions = sessions; _isLoading = false; });
  }

  Future<void> _delete(ChatSession session) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showAppConfirmDialog(
      context,
      title: l10n.chatDeleteTitle,
      message: l10n.chatDeleteMessage,
      isDanger: true,
    );
    if (!ok) return;
    await ChatbotController.deleteSession(session.id);
    setState(() => _sessions.removeWhere((s) => s.id == session.id));
    if (mounted) AppSnackbar.success(context, l10n.chatDeletedSuccess);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatHistoryTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text(l10n.noChatHistory, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(l10n.noChatHistorySubtitle, style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final session = _sessions[i];
                    return Dismissible(
                      key: Key(session.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                      ),
                      onDismissed: (_) => ChatbotController.deleteSession(session.id),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, session),
                        onLongPress: () => _delete(session),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.purpleGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(session.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${session.messages.length} ${l10n.chatMessagesCount} · ${DateTimeUtils.relativeTime(session.savedAt, locale: Localizations.localeOf(context).languageCode)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                            ],
                          ),
                        ).animate(delay: Duration(milliseconds: 60 * i)).fade().slideY(begin: 0.05, end: 0),
                      ),
                    );
                  },
                ),
    );
  }
}
