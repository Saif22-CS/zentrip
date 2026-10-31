import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'app_snackbar.dart';

/// نافذة كتابة تقييم حقيقي لعنصر (فندق/سيارة/نشاط/عرض) — بعد ما المستخدم
/// يكون حجزه فعلاً. استخدمها هكذا:
/// ```dart
/// ReviewFormSheet.show(context, itemId: hotel.id, itemType: 'hotel');
/// ```
class ReviewFormSheet extends StatefulWidget {
  final String itemId;
  final String itemType;
  final VoidCallback? onSubmitted;
  const ReviewFormSheet({
    super.key,
    required this.itemId,
    required this.itemType,
    this.onSubmitted,
  });

  static void show(
    BuildContext context, {
    required String itemId,
    required String itemType,
    VoidCallback? onSubmitted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ReviewFormSheet(
          itemId: itemId,
          itemType: itemType,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final result = await ApiService.instance.submitReview(
      itemId: widget.itemId,
      itemType: widget.itemType,
      rating: _rating.toDouble(),
      comment: _commentCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (result.isSuccess) {
      AppSnackbar.success(context, AppLocalizations.of(context).reviewSubmittedSuccess);
      widget.onSubmitted?.call();
      Navigator.pop(context);
    } else {
      AppSnackbar.error(context, AppLocalizations.of(context).genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.writeAReview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 32),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.reviewCommentHint,
                filled: true,
                fillColor: AppColors.surfaceSecondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.submitReview),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
