import 'package:flutter/painting.dart';

import 'html_source.dart';

/// 正文 class/标签的排版语义由本文件维护。

/// 正文样式来源。
class ReaderContentStyle {
  const ReaderContentStyle({
    required this.fontSize,
    required this.lineHeight,
    required this.firstLineIndent,
    required this.justify,
    this.lineSpace = 0,
    this.fontFamily,
    this.preferredFontFamily,
  });

  final double fontSize;
  final double lineHeight;
  final double lineSpace;
  final bool firstLineIndent;
  final bool justify;

  /// 章节混淆字体族名，负责绘制服务端映射的字形。
  final String? fontFamily;

  /// 用户选择的常规字体，暂时不参与正文渲染。
  final String? preferredFontFamily;

  TextStyle get textStyle => TextStyle(
    fontSize: fontSize,
    height: lineHeight,
    fontFamily: fontFamily,
  );

  static const List<double> _fontTagSizes = <double>[
    0.63,
    0.82,
    1,
    1.13,
    1.5,
    2,
    3,
  ];

  static const Set<String> _indentCancelling = <String>{
    htmlImageBlockClass,
    'center',
    'left',
    'right',
    'zin',
    'message',
    'cut-line',
    'meg',
    'pius1',
    'pius2',
    'ph4',
  };

  bool indentsParagraph({
    required String? tag,
    required Iterable<String> classes,
  }) =>
      firstLineIndent && tag == 'p' && !classes.any(_indentCancelling.contains);

  Map<String, String>? stylesFor({
    required String? tag,
    required Iterable<String> classes,
    required Map<String, String> attributes,
  }) {
    final styles = <String, String>{};
    switch (tag) {
      case 'p':
        styles['margin'] = '0';
        if (justify) styles['text-align'] = 'justify';
      case 'h1':
        styles.addAll(_heading(1.65));
        styles['margin'] = '0.1em 0 0.4em';
      case 'h2':
        styles.addAll(_heading(1.25));
        styles['margin'] = '0.3em 0 0.5em';
      case 'h3':
        styles.addAll(_heading(0.95));
        styles['margin'] = '0.2em 0';
      case 'h4':
        styles.addAll(_subheading());
      case 'a':
        styles['text-decoration'] = 'none';
      case 'img':
        styles['max-width'] = '100%';
      case 'table':
        styles['width'] = '100%';
        styles['margin'] = '0 0 0.8em';
      case 'th':
      case 'td':
        styles['padding'] = '0';
        styles['vertical-align'] = 'top';
      case 'rt':
        styles['font-size'] = '0.5em';
      case 'font':
        final size = int.tryParse(attributes['size'] ?? '');
        if (size != null && size >= 1 && size <= _fontTagSizes.length) {
          styles['font-size'] = _px(fontSize * _fontTagSizes[size - 1]);
        }
    }

    for (final className in classes) {
      switch (className) {
        case htmlImageBlockClass:
          styles['display'] = 'block';
        case htmlImageSpacingClass:
          styles['margin-bottom'] = _px(lineSpace);
        case 'right':
          styles['text-align'] = 'right';
        case 'left':
          styles['text-align'] = 'left';
        case 'center':
          styles['text-align'] = 'center';
        case 'bold':
          styles['font-weight'] = 'bold';
        case 'ita':
          styles['font-style'] = 'italic';
        case 'stress':
          styles['font-size'] = '1.1em';
          styles['font-weight'] = 'bold';
          styles['margin'] = '0.3em 0';
        case 'author':
          styles['font-size'] = '1.2em';
          styles['font-weight'] = 'bold';
          styles['font-style'] = 'italic';
          styles['text-align'] = 'right';
          styles['margin-right'] = '1em';
        case 'message':
        case 'cut-line':
          styles['line-height'] = '1.2em';
          styles['margin'] = '0.2em 0';
        case 'meg':
          styles['font-size'] = '1.3em';
          styles['line-height'] = '1.3em';
          styles['margin'] = '0.5em 0 0';
        case 'lh':
          styles['line-height'] = '1em';
        case 'm0':
          styles['margin'] = '0';
        case 'p0':
          styles['padding'] = '0';
        case 'no-d':
          styles['text-decoration'] = 'none';
        case 'red':
          styles['color'] = '#D32F2F';
        case 'green':
          styles['color'] = '#2E7D32';
        case 'blue':
          styles['color'] = '#1565C0';
        case 'black':
          styles['color'] = '#000000';
        case 'white':
          styles['color'] = '#FFFFFF';
        case 'dot':
        case 'em-dot':
          styles['text-emphasis'] = 'circle';
        case 'pius1':
        case 'pius2':
        case 'ph4':
          styles.addAll(_subheading());
        case 'illu':
        case 'illus':
        case 'duokan-image-single':
          styles['text-align'] = 'center';
        default:
          final scale = _emScale(className);
          if (scale != null) styles['font-size'] = _px(fontSize * scale);
      }
    }
    return styles.isEmpty ? null : styles;
  }

  Map<String, String> _heading(double scale) => <String, String>{
    'font-size': _px(fontSize * scale),
    'font-weight': 'bold',
    'text-align': 'center',
    'line-height': '1.2',
  };

  Map<String, String> _subheading() => <String, String>{
    'font-size': _px(fontSize * 1.5),
    'font-weight': 'bold',
    'text-align': 'center',
    'margin': '0.5em 0 1em',
  };

  static String _px(double size) => '${size.toStringAsFixed(2)}px';

  static double? _emScale(String className) {
    if (className.length != 4 || !className.startsWith('em')) return null;
    final value = int.tryParse(className.substring(2));
    if (value == null || value < 5 || value > 30 || value == 10) return null;
    return value / 10;
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderContentStyle &&
      other.fontSize == fontSize &&
      other.lineHeight == lineHeight &&
      other.lineSpace == lineSpace &&
      other.firstLineIndent == firstLineIndent &&
      other.justify == justify &&
      other.fontFamily == fontFamily &&
      other.preferredFontFamily == preferredFontFamily;

  @override
  int get hashCode => Object.hash(
    fontSize,
    lineHeight,
    lineSpace,
    firstLineIndent,
    justify,
    fontFamily,
    preferredFontFamily,
  );
}
