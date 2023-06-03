
import 'dart:ui';

class DikoubaColors {
  DikoubaColors._(); // this basically makes it so you can instantiate this class

  static const Map<String, Color> testblue = const <String, Color>{
    'pri': const Color(0xFF00016d),
    'lig': const Color(0xFF3B5FF6),
    'dar': const Color(0xFF092dc6),
  };

  static const Map<String, Color> blue = const <String, Color>{
    'pri': const Color(0xFF3B5FF6),
    'lig': const Color(0xFFacbbfb),
    'dar': const Color(0xFF092dc6),
  };

  static const Map<String, Color> white = const <String, Color>{
    'pri': const Color(0xFFCFCFCF),
    'lig': const Color(0xFFFFFFFF),
    'dar': const Color(0xFFA6A6A6),
  };
  static const Map<String, Color> red = const <String, Color>{
    'pri': const Color(0xFFec1b24),
    'lig': const Color(0xFFf1585e),
    'dar': const Color(0xFFc21018),
  };
}