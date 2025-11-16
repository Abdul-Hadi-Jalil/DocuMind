class ErrorUtils {
  static String getFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('network')) {
      return 'Network connection error. Please check your internet connection and ensure Ollama is running on localhost:11434.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. The server is taking too long to respond.';
    } else if (errorString.contains('ollama') ||
        errorString.contains('localhost')) {
      return 'Ollama server is not available. Please make sure Ollama is installed and running on your system.';
    } else if (errorString.contains('permission')) {
      return 'Permission denied. Please check app permissions.';
    } else if (errorString.contains('format')) {
      return 'Invalid file format. Please check the file and try again.';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }

  static bool isConnectionError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('timeout');
  }
}
