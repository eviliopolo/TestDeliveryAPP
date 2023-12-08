import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
//import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  const AppConfig({
    Key? key,
    required this.development,
    required Widget child,
  }) : super(child: child);

  final bool development;

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
