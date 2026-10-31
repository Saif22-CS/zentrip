import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/country_codes.dart';
import '../l10n/app_localizations.dart';

/// حقل إدخال رقم هاتف مع اختيار كود الدولة (علم + كود اتصال) من قايمة قابلة
/// للبحث. القيمة النهائية (كود الدولة + الرقم المحلي) بتتكتب تلقائيًا في
/// [controller] اللي المستخدم بيبعتها — يعني أي كود قائم بيستخدم _phoneCtrl.text
/// هيشتغل زي ما هو من غير أي تعديل تاني.
class PhoneField extends StatefulWidget {
  /// الكنترولر اللي هيحمل الرقم الكامل جاهز للإرسال (مثال: +201001234567).
  /// لو فيه قيمة مبدئية فيه (لتعديل بروفايل مثلاً)، هيتفكك تلقائيًا لدولة + رقم محلي.
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PhoneField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late Country _country;
  late final TextEditingController _nationalCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.text;
    if (existing.trim().isEmpty) {
      _country = CountryCodes.defaultCountry;
      _nationalCtrl = TextEditingController();
    } else {
      final (country, national) = CountryCodes.splitFullNumber(existing);
      _country = country;
      _nationalCtrl = TextEditingController(text: national);
    }
    _nationalCtrl.addListener(_syncFullNumber);
    _syncFullNumber();
  }

  void _syncFullNumber() {
    widget.controller.text = '${_country.dialCode}${_nationalCtrl.text.trim()}';
  }

  @override
  void dispose() {
    _nationalCtrl.removeListener(_syncFullNumber);
    _nationalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CountryPickerSheet(selected: _country),
    );
    if (selected != null) {
      setState(() => _country = selected);
      _syncFullNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: _nationalCtrl,
      keyboardType: TextInputType.phone,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: (_) => widget.validator?.call(widget.controller.text),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _pickCountry,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_country.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    _country.dialCode,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.textSecondary),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    height: 24,
                    width: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ],
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final Country selected;
  const _CountryPickerSheet({required this.selected});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  List<Country> get _filtered {
    if (_query.trim().isEmpty) return CountryCodes.all;
    final q = _query.trim().toLowerCase();
    return CountryCodes.all.where((c) =>
        c.name.toLowerCase().contains(q) || c.dialCode.contains(q) || c.isoCode.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filtered;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).phoneCountrySearchHint,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 32))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final c = results[i];
                      final isSelected = c.isoCode == widget.selected.isoCode;
                      return ListTile(
                        leading: Text(c.flag, style: const TextStyle(fontSize: 22)),
                        title: Text(c.name),
                        trailing: Text(c.dialCode, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        selected: isSelected,
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
