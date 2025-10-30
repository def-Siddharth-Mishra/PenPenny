import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smart form with built-in validation and state management
class SmartForm extends StatefulWidget {
  final Widget child;
  final VoidCallback? onChanged;
  final bool autovalidateMode;
  final GlobalKey<FormState>? formKey;
  
  const SmartForm({
    super.key,
    required this.child,
    this.onChanged,
    this.autovalidateMode = false,
    this.formKey,
  });

  @override
  State<SmartForm> createState() => _SmartFormState();
}

class _SmartFormState extends State<SmartForm> {
  late final GlobalKey<FormState> _formKey;
  
  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode 
        ? AutovalidateMode.onUserInteraction 
        : AutovalidateMode.disabled,
      onChanged: widget.onChanged,
      child: widget.child,
    );
  }
}

/// Optimized text field with built-in validation
class SmartTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  
  const SmartTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.controller,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
  });

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
    
    // Clear error state when user starts typing
    if (_hasError && _controller.text.isNotEmpty) {
      setState(() {
        _hasError = false;
      });
    }
  }
  
  void _onFocusChanged() {
    if (!_focusNode.hasFocus && widget.validator != null) {
      final error = widget.validator!(_controller.text);
      setState(() {
        _hasError = error != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onSaved: widget.onSaved,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Smart dropdown field
class SmartDropdownField<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  
  const SmartDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  @override
  State<SmartDropdownField<T>> createState() => _SmartDropdownFieldState<T>();
}

class _SmartDropdownFieldState<T> extends State<SmartDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.enabled ? widget.onChanged : null,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}