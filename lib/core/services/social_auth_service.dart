import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// بيرجّع الـ ID Token بس من جوجل/آبل — الباك اند هو اللي بيتحقق منه فعليًا
/// مع Google/Apple ويطلع بيانات المستخدم، مش التطبيق.
class SocialAuthService {
  static final SocialAuthService instance = SocialAuthService._();
  SocialAuthService._();

  final GoogleSignIn _google = GoogleSignIn(scopes: ['email']);

  /// بترجع null لو المستخدم لغى العملية بنفسه (مش خطأ).
  Future<String?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.idToken;
  }

  Future<void> signOutGoogle() => _google.signOut();

  /// متاحة على iOS بس (وأندرويد لو معمول له إعداد Web-based، نادرًا ما
  /// يُستخدم). بترجع null لو المستخدم لغى.
  Future<String?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      return credential.identityToken;
    } catch (_) {
      return null;
    }
  }
}
