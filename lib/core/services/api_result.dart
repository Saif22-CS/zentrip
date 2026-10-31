/// نتيجة موحّدة لكل عمليات الـ API — تُغلّف حالة النجاح والفشل في نوع واحد.
/// الـ Controllers تتعامل مع ApiResult فقط ولا تعالج exceptions مباشرةً.
class ApiResult<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  const ApiResult._({this.data, this.errorMessage, required this.isSuccess});

  factory ApiResult.success([T? data]) =>
      ApiResult._(data: data, isSuccess: true);

  factory ApiResult.failure(String message) =>
      ApiResult._(errorMessage: message, isSuccess: false);

  bool get isFailure => !isSuccess;

  @override
  String toString() => isSuccess
      ? 'ApiResult.success(data: $data)'
      : 'ApiResult.failure($errorMessage)';
}

/// حالة الخدمة داخل أي Controller — بدلاً من isLoading + errorMessage منفصلَين.
enum ServiceStatus { idle, loading, success, failure }

class ServiceState<T> {
  final ServiceStatus status;
  final T? data;
  final String? error;

  const ServiceState({
    this.status = ServiceStatus.idle,
    this.data,
    this.error,
  });

  bool get isLoading => status == ServiceStatus.loading;
  bool get isSuccess => status == ServiceStatus.success;
  bool get isFailure => status == ServiceStatus.failure;
  bool get isIdle => status == ServiceStatus.idle;
  bool get hasData => data != null;

  ServiceState<T> copyWith({ServiceStatus? status, T? data, String? error}) {
    return ServiceState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  static ServiceState<T> loading<T>() =>
      const ServiceState(status: ServiceStatus.loading);
  static ServiceState<T> success<T>(T data) =>
      ServiceState(status: ServiceStatus.success, data: data);
  static ServiceState<T> failure<T>(String error) =>
      ServiceState(status: ServiceStatus.failure, error: error);
  static ServiceState<T> idle<T>() =>
      const ServiceState(status: ServiceStatus.idle);
}
