/// دوال التحقق من صحة المدخلات — تُستخدم مباشرةً في حقل validator بـ Form.
abstract class Validators {
  static String? Function(String?) emailValidator(String emptyMsg, String invalidMsg) {
    return (value) {
      if (value == null || value.trim().isEmpty) return emptyMsg;
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) return invalidMsg;
      return null;
    };
  }

  static String? Function(String?) passwordValidator(String emptyMsg, String weakMsg) {
    return (value) {
      if (value == null || value.isEmpty) return emptyMsg;
      if (value.length < 8) return weakMsg;
      return null;
    };
  }

  static String? Function(String?) confirmPasswordValidator(
      String Function() getPassword, String emptyMsg, String mismatchMsg) {
    return (value) {
      if (value == null || value.isEmpty) return emptyMsg;
      if (value != getPassword()) return mismatchMsg;
      return null;
    };
  }

  static String? Function(String?) requiredValidator(String emptyMsg, {int? minLength, String? minLengthMsg}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return emptyMsg;
      if (minLength != null && value.trim().length < minLength) return minLengthMsg ?? emptyMsg;
      return null;
    };
  }

  static String? Function(String?) phoneValidator(String emptyMsg, String invalidMsg) {
    return (value) {
      if (value == null || value.trim().isEmpty) return emptyMsg;
      final phoneRegex = RegExp(r'^\+?[0-9]{9,15}$');
      if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) return invalidMsg;
      return null;
    };
  }
}
