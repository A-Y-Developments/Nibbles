import 'package:flutter/material.dart';

/// Caption that animates trailing dots on the text itself — text, text.,
/// text.., text..., text — cycling on a loop. The base word stays put; only
/// the dot slot fills, so the surrounding layout never reflows.
class AnimatedEllipsisText extends StatefulWidget {
  const AnimatedEllipsisText({
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.maxDots = 3,
    this.period = const Duration(milliseconds: 1200),
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int maxDots;
  final Duration period;

  @override
  State<AnimatedEllipsisText> createState() => _AnimatedEllipsisTextState();
}

class _AnimatedEllipsisTextState extends State<AnimatedEllipsisText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.maxDots + 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        ),
        // Fixed-width dots slot — the invisible widest-case text reserves the
        // space so the cycling dots grow rightward without shifting the word.
        Stack(
          children: [
            Opacity(
              opacity: 0,
              child: Text('.' * widget.maxDots, style: widget.style),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final count = (_controller.value * steps).floor().clamp(
                  0,
                  widget.maxDots,
                );
                return Text('.' * count, style: widget.style);
              },
            ),
          ],
        ),
      ],
    );
  }
}
