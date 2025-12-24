
class AppError implements Exception {
  final String message;
  final String? code;

  AppError(this.message, {this.code});

  @override
  String toString() => 'AppError: $message (Code: $code)';
}

class NetworkError extends AppError {
  NetworkError() : super("The internet is broken (not us).", code: "NET_001");
}

class NoFaceDetectedError extends AppError {
  NoFaceDetectedError() : super("Is that a ghost? 👻 We couldn't find a face.", code: "AI_001");
}

class GenerationTimeoutError extends AppError {
  GenerationTimeoutError() : super("Improving humor algorithms...", code: "AI_002");
}

class ExportError extends AppError {
  ExportError() : super("WhatsApp rejected the funk.", code: "EXP_001");
}

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is AppError) {
      return error.message;
    }
    return "Something weird happened. Try again?";
  }
}
