import 'dart:async';

import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Duration speed;
  final int charactersPerTick;
  final TextStyle? style;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 20),
    this.charactersPerTick = 3,
    this.style,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  Timer? _cursorTimer;
  int _currentIndex = 0;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _cursorTimer?.cancel();
      _currentIndex = 0;
      _showCursor = true;
      _startAnimation();
    }
  }

  void _startAnimation() {
    if (widget.text.isEmpty) {
      widget.onComplete?.call();
      return;
    }

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) return;
      setState(() => _showCursor = !_showCursor);
    });

    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) return;

      if (_currentIndex < widget.text.length) {
        setState(() {
          _currentIndex = (_currentIndex + widget.charactersPerTick).clamp(0, widget.text.length);
        });
      } else {
        _timer?.cancel();
        _cursorTimer?.cancel();
        setState(() => _showCursor = false);
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = widget.text.substring(0, _currentIndex.clamp(0, widget.text.length));
    final isTyping = _currentIndex < widget.text.length;

    return RichText(
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: visibleText),
          if (isTyping)
            TextSpan(
              text: _showCursor ? '|' : ' ',
              style: widget.style,
            ),
        ],
      ),
    );
  }
}
