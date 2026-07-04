import 'package:flutter/material.dart';

/// Thin wrapper around [TextFormField] - the actual look (fill color,
/// border radius, focus color) comes entirely from the app's
/// `InputDecorationTheme`, this widget just standardizes the parameters
/// every screen passes (label, icon, validator) so call sites stay short.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? prefix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.prefix,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix == null && prefixIcon != null
            ? Icon(prefixIcon)
            : null,
        prefix: prefix,
      ),
    );
  }
}
