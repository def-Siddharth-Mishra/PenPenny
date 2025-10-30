import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class DebouncedTextEditingController extends TextEditingController {
  final Duration delay;
  final void Function(String) onChanged;
  late final Debouncer _debouncer;

  DebouncedTextEditingController({
    required this.delay,
    required this.onChanged,
    super.text,
  }) {
    _debouncer = Debouncer(delay: delay);
    addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debouncer.call(() => onChanged(text));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}