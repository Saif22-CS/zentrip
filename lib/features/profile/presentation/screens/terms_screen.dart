import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// شاشة شروط الاستخدام وسياسة الخصوصية — محتوى ثنائي اللغة حسب لغة التطبيق.
class TermsScreen extends StatelessWidget {
  /// عند true تُفتح الشاشة على قسم سياسة الخصوصية.
  final bool showPrivacy;
  const TermsScreen({super.key, this.showPrivacy = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final sections =
        showPrivacy ? _privacySections(isAr) : _termsSections(isAr);

    return Scaffold(
      appBar: AppBar(
        title: Text(showPrivacy ? l10n.privacyPolicy : l10n.termsAndConditions),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: sections.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                l10n.termsLastUpdated,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            );
          }
          final s = sections[i - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$i. ${s.$1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(s.$2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.7)),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: 40 * i))
              .fade()
              .slideY(begin: 0.04, end: 0);
        },
      ),
    );
  }

  List<(String, String)> _termsSections(bool ar) => ar
      ? [
          (
            'قبول الشروط',
            'باستخدامك تطبيق Zentrip فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يرجى التوقف عن استخدام التطبيق.'
          ),
          (
            'استخدام الخدمة',
            'يوفر Zentrip منصة لحجز الرحلات والفنادق والسيارات والأنشطة السياحية. أنت مسؤول عن صحة البيانات التي تدخلها وعن الحفاظ على سرية بيانات حسابك.'
          ),
          (
            'الحجوزات والأسعار',
            'جميع الأسعار المعروضة تشمل الضرائب ما لم يُذكر خلاف ذلك. قد تتغير الأسعار حتى إتمام الحجز، ويُعد تأكيد الحجز عقداً بينك وبين مزوّد الخدمة.'
          ),
          (
            'الإلغاء والاسترداد',
            'تخضع سياسات الإلغاء والاسترداد لشروط مزوّد الخدمة لكل حجز. راجع تفاصيل سياسة الإلغاء الظاهرة قبل تأكيد أي حجز.'
          ),
          (
            'مساعد Zen AI',
            'اقتراحات المساعد الذكي إرشادية فقط ولا تُعد التزاماً تعاقدياً. تحقق دائماً من التفاصيل النهائية قبل الحجز.'
          ),
          (
            'الملكية الفكرية',
            'جميع العلامات والشعارات والمحتوى في التطبيق مملوكة لـ Zentrip أو مرخّصة لها، ولا يجوز نسخها أو إعادة استخدامها دون إذن كتابي.'
          ),
          (
            'حدود المسؤولية',
            'لا يتحمل Zentrip مسؤولية الأضرار غير المباشرة الناتجة عن استخدام التطبيق أو انقطاع الخدمة أو أخطاء مزوّدي الخدمات الخارجيين.'
          ),
          (
            'التعديلات',
            'قد نُحدّث هذه الشروط من وقت لآخر، وسيتم إشعارك بالتغييرات الجوهرية داخل التطبيق. استمرارك في الاستخدام يعني موافقتك على الشروط المحدّثة.'
          ),
          (
            'التواصل',
            'لأي استفسار حول هذه الشروط تواصل معنا عبر support@zentrip.app.'
          ),
        ]
      : [
          (
            'Acceptance of Terms',
            'By using the Zentrip app you agree to be bound by these terms and conditions. If you do not agree with any part of them, please stop using the app.'
          ),
          (
            'Use of the Service',
            'Zentrip provides a platform for booking flights, hotels, cars and travel activities. You are responsible for the accuracy of the information you provide and for keeping your account credentials secure.'
          ),
          (
            'Bookings & Prices',
            'All displayed prices include taxes unless stated otherwise. Prices may change until a booking is completed; a booking confirmation forms a contract between you and the service provider.'
          ),
          (
            'Cancellation & Refunds',
            'Cancellation and refund policies follow the service provider\'s terms for each booking. Review the cancellation policy shown before confirming any booking.'
          ),
          (
            'Zen AI Assistant',
            'Suggestions from the AI assistant are for guidance only and are not contractually binding. Always verify the final details before booking.'
          ),
          (
            'Intellectual Property',
            'All trademarks, logos and content in the app are owned by or licensed to Zentrip and may not be copied or reused without written permission.'
          ),
          (
            'Limitation of Liability',
            'Zentrip is not liable for indirect damages arising from use of the app, service interruptions, or errors by third-party service providers.'
          ),
          (
            'Changes to These Terms',
            'We may update these terms from time to time and will notify you of material changes in the app. Continued use means you accept the updated terms.'
          ),
          (
            'Contact Us',
            'For any questions about these terms, contact us at support@zentrip.app.'
          ),
        ];

  List<(String, String)> _privacySections(bool ar) => ar
      ? [
          (
            'البيانات التي نجمعها',
            'نجمع بيانات الحساب (الاسم، البريد الإلكتروني، رقم الهاتف) وبيانات الحجوزات وموقعك الجغرافي عند منح الإذن لاقتراح أماكن قريبة.'
          ),
          (
            'كيف نستخدم بياناتك',
            'نستخدم بياناتك لإتمام الحجوزات، وتخصيص الاقتراحات، وتحسين تجربة مساعد Zen AI، وإرسال إشعارات تخص رحلاتك.'
          ),
          (
            'مشاركة البيانات',
            'نشارك الحد الأدنى الضروري من البيانات مع مزوّدي الخدمات (شركات الطيران، الفنادق) لإتمام حجوزاتك، ولا نبيع بياناتك لأي طرف ثالث.'
          ),
          (
            'حماية البيانات',
            'نستخدم تشفيراً ومعايير أمان حديثة لحماية بياناتك أثناء النقل والتخزين.'
          ),
          (
            'حقوقك',
            'يمكنك طلب نسخة من بياناتك أو تصحيحها أو حذف حسابك نهائياً في أي وقت من إعدادات الملف الشخصي أو عبر support@zentrip.app.'
          ),
          (
            'ملفات الارتباط والتحليلات',
            'نستخدم أدوات تحليل مجهولة الهوية لفهم استخدام التطبيق وتحسينه، ويمكنك إيقاف الإشعارات التسويقية من الإعدادات.'
          ),
        ]
      : [
          (
            'Data We Collect',
            'We collect account data (name, email, phone number), booking data, and your location when permission is granted to suggest nearby places.'
          ),
          (
            'How We Use Your Data',
            'We use your data to complete bookings, personalize suggestions, improve the Zen AI assistant experience, and send notifications about your trips.'
          ),
          (
            'Data Sharing',
            'We share only the minimum data necessary with service providers (airlines, hotels) to complete your bookings. We never sell your data to third parties.'
          ),
          (
            'Data Protection',
            'We use encryption and modern security standards to protect your data in transit and at rest.'
          ),
          (
            'Your Rights',
            'You can request a copy of your data, correct it, or permanently delete your account at any time from profile settings or via support@zentrip.app.'
          ),
          (
            'Cookies & Analytics',
            'We use anonymized analytics to understand and improve app usage. You can turn off marketing notifications in settings.'
          ),
        ];
}
