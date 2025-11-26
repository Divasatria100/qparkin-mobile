import 'package:flutter/material.dart';

/// Widget for displaying validation error messages below form fields
///
/// Shows error text with red color and icon, highlights invalid fields
/// with red border, and clears errors when user corrects input.
///
/// Requirements: 11.3
class ValidationErrorText extends StatelessWidget {
  final String? errorText;
  final EdgeInsetsGeometry? padding;

  const ValidationErrorText({
    Key? key,
    this.errorText,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorText == null || errorText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFF44336),
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Color(0xFFF44336),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decoration helper for form fields with validation errors
///
/// Requirements: 11.3
class ValidationDecorationHelper {
  /// Get input decoration with error styling
  static InputDecoration getDecoration({
    required String label,
    String? hint,
    IconData? icon,
    bool hasError = false,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFF44336) : Colors.grey.shade300,
          width: hasError ? 2 : 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFF44336) : Colors.grey.shade300,
          width: hasError ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFF44336) : const Color(0xFF573ED1),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFF44336),
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFF44336),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: hasError ? Colors.red.shade50 : Colors.white,
    );
  }

  /// Get box decoration for card-style fields with validation errors
  static BoxDecoration getCardDecoration({
    bool hasError = false,
    bool isFocused = false,
  }) {
    return BoxDecoration(
      color: hasError ? Colors.red.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: hasError
            ? const Color(0xFFF44336)
            : isFocused
                ? const Color(0xFF573ED1)
                : Colors.grey.shade300,
        width: hasError || isFocused ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
