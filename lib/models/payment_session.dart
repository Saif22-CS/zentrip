class PaymentSession {
  final String sessionId;
  final String checkoutUrl;

  const PaymentSession({required this.sessionId, required this.checkoutUrl});

  static String _stringFromDynamic(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  factory PaymentSession.fromJson(Map<String, dynamic> json) => PaymentSession(
        sessionId: _stringFromDynamic(json['session_id']),
        checkoutUrl: _stringFromDynamic(json['checkout_url']),
      );
}
