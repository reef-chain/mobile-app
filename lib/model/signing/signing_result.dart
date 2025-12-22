// Result types for signing operations
// Provides detailed error information for better UX

/// Specific error types that can occur during signing
enum SigningError {
  /// Wrong password provided
  wrongPassword,

  /// Biometric authentication failed or was cancelled
  biometricsFailed,

  /// Network timeout during transaction submission
  networkTimeout,

  /// Account not found in storage
  accountNotFound,

  /// User explicitly cancelled the operation
  userCancelled,

  /// Insufficient balance for transaction
  insufficientBalance,

  /// Unknown or unexpected error
  unknown,
}

/// Result of a signing operation
/// Contains success status and detailed error information if failed
class SigningResult {
  /// Whether the signing operation succeeded
  final bool success;

  /// The specific error that occurred (null if successful)
  final SigningError? error;

  /// Human-readable error message (null if successful)
  final String? errorMessage;

  /// Create a successful result
  SigningResult.success()
      : success = true,
        error = null,
        errorMessage = null;

  /// Create a failed result with error details
  SigningResult.failure(this.error, [this.errorMessage]) : success = false;

  /// Get user-friendly error message for UI display
  String getUserFriendlyMessage() {
    if (success) return 'Operation completed successfully';

    switch (error) {
      case SigningError.wrongPassword:
        return 'Incorrect password. Please try again.';
      case SigningError.biometricsFailed:
        return 'Biometric authentication failed. Please try password.';
      case SigningError.networkTimeout:
        return 'Network timeout. Please check your connection and try again.';
      case SigningError.accountNotFound:
        return 'Account not found. Please select a valid account.';
      case SigningError.userCancelled:
        return 'Operation cancelled.';
      case SigningError.insufficientBalance:
        return 'Insufficient balance for this transaction.';
      case SigningError.unknown:
      default:
        return errorMessage ?? 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() {
    if (success) {
      return 'SigningResult(success: true)';
    }
    return 'SigningResult(success: false, error: $error, message: $errorMessage)';
  }
}
