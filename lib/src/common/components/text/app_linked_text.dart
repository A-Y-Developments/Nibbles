import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';

/// Body text with tappable, underlined substrings.
///
/// [links] maps an exact substring of [text] to the callback fired when that
/// substring is tapped. A null callback renders the substring as ordinary body
/// text — that is how an unpublished destination is expressed, so the widget
/// never paints a link that leads nowhere.
///
/// Span recognizers win over an ancestor [InkWell]/[GestureDetector], so this
/// composes inside a tappable row: the link opens, the rest of the row toggles.
class AppLinkedText extends StatefulWidget {
  const AppLinkedText({
    required this.text,
    required this.links,
    this.style,
    this.linkStyle,
    super.key,
  });

  final String text;
  final Map<String, VoidCallback?> links;
  final TextStyle? style;
  final TextStyle? linkStyle;

  @override
  State<AppLinkedText> createState() => _AppLinkedTextState();
}

class _AppLinkedTextState extends State<AppLinkedText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  List<_Match> _matches() {
    final matches = <_Match>[];
    for (final entry in widget.links.entries) {
      if (entry.value == null) continue;
      final start = widget.text.indexOf(entry.key);
      if (start < 0) continue;
      matches.add(
        _Match(
          start: start,
          end: start + entry.key.length,
          onTap: entry.value!,
        ),
      );
    }
    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final textTheme = Theme.of(context).textTheme;
    final baseStyle =
        widget.style ??
        textTheme.bodyLarge?.copyWith(color: AppColors.fgDefault);
    final linkStyle =
        widget.linkStyle ??
        baseStyle?.copyWith(
          color: AppColors.greenDeep,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.greenDeep,
        );

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _matches()) {
      if (match.start < cursor) continue;
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      }
      final recognizer = TapGestureRecognizer()..onTap = match.onTap;
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: widget.text.substring(match.start, match.end),
          style: linkStyle,
          recognizer: recognizer,
        ),
      );
      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}

class _Match {
  const _Match({required this.start, required this.end, required this.onTap});

  final int start;
  final int end;
  final VoidCallback onTap;
}
