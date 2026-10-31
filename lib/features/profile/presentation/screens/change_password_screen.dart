import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../global_widgets/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../logic/profile_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ctrl = ProfileController();
  bool _showCurrent = false, _showNew = false, _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose(); _ctrl.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _ctrl.changePassword(current: _currentCtrl.text, newPass: _newCtrl.text);
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, AppLocalizations.of(context).passwordChangedSuccess);
      Navigator.pop(context);
    } else {
      AppSnackbar.error(context, _ctrl.errorMessage ?? AppLocalizations.of(context).genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(controller: _currentCtrl, label: l10n.currentPasswordLabel, icon: Icons.lock_outlined, obscureText: !_showCurrent,
                  validator: Validators.requiredValidator(l10n.currentPasswordLabel),
                  suffixIcon: IconButton(icon: Icon(_showCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _showCurrent = !_showCurrent))),
              const SizedBox(height: 14),
              AuthTextField(controller: _newCtrl, label: l10n.newPasswordLabel, icon: Icons.lock_outlined, obscureText: !_showNew,
                  validator: Validators.passwordValidator(l10n.newPasswordLabel, l10n.genericError),
                  suffixIcon: IconButton(icon: Icon(_showNew ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _showNew = !_showNew))),
              const SizedBox(height: 14),
              AuthTextField(controller: _confirmCtrl, label: l10n.confirmPasswordLabel, icon: Icons.lock_outlined, obscureText: !_showConfirm, textInputAction: TextInputAction.done,
                  validator: Validators.confirmPasswordValidator(() => _newCtrl.text, l10n.confirmPasswordLabel, l10n.genericError),
                  onFieldSubmitted: (_) => _change(),
                  suffixIcon: IconButton(icon: Icon(_showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _showConfirm = !_showConfirm))),
              const SizedBox(height: 28),
              ListenableBuilder(listenable: _ctrl, builder: (_, __) => PrimaryButton(label: l10n.saveChanges, isLoading: _ctrl.isLoading, onPressed: _change)),
            ],
          ),
        ),
      ),
    );
  }
}
