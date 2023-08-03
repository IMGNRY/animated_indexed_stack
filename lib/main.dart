import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'animated_indexed_stack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _selectedIndex = ValueNotifier(0);
  int _prevSelectedIndex = 0;

  @override
  void initState() {
    _selectedIndex.addListener(() async {
      await Future.delayed(Duration(milliseconds: 100));
      _prevSelectedIndex = _selectedIndex.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.black87,
        child: Column(
          children: [
            Expanded(
              child: AnimatedIndexedStack(
                children: [
                  Navigator(onGenerateRoute: (_) => _sharedAxisPageRouteBuilder(RootPage(color: Colors.red, text: 'Red'))),
                  Navigator(onGenerateRoute: (_) => _sharedAxisPageRouteBuilder(RootPage(color: Colors.green, text: 'Green'))),
                  Navigator(onGenerateRoute: (_) => _sharedAxisPageRouteBuilder(RootPage(color: Colors.blue, text: 'Blue'))),
                ],
                index: _selectedIndex.value,
                transitionBuilder: (context, animation, child, i, direction) {
                  late CurvedAnimation curvedAnim = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
                  double offsetX = _selectedIndex.value > _prevSelectedIndex ? 1.0 : -1.0;
                  if (direction == TransitionDirection.Out) {
                    offsetX *= -1;
                  }

                  final scaleAnim = Tween(begin: 0.8, end: 1.0).animate(curvedAnim);
                  final positionAnim = Tween(begin: Offset(offsetX, 0), end: Offset.zero).animate(curvedAnim);
                  return SlideTransition(
                    position: positionAnim,
                    child: ScaleTransition(
                      scale: scaleAnim,
                      child: Container(color: Colors.black87, child: child),
                    ),
                  );
                },
              ),
            ),
            Container(
                color: Color.fromRGBO(30, 30, 30, 1),
                height: 100,
                child: Row(
                  children: [
                    Expanded(child: GestureDetector(onTap: () => setState(() => _selectedIndex.value = 0), child: Container(color: Colors.red))),
                    Expanded(child: GestureDetector(onTap: () => setState(() => _selectedIndex.value = 1), child: Container(color: Colors.green))),
                    Expanded(child: GestureDetector(onTap: () => setState(() => _selectedIndex.value = 2), child: Container(color: Colors.blue))),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class RootPage extends StatefulWidget {
  final Color color;
  final String text;

  const RootPage({Key? key, required this.color, required this.text}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with AutomaticKeepAliveClientMixin<RootPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(_sharedAxisPageRouteBuilder(AnotherPage()));
      },
      child: Container(
        padding: EdgeInsets.all(30),
        color: Colors.black87,
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: EdgeInsets.all(20),
            color: widget.color,
            child: Center(
              child: Text(
                widget.text,
                textScaleFactor: 6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black87,
        child: const Center(
          child: Text(
            'Another page!',
            textScaleFactor: 3,
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder<dynamic> _sharedAxisPageRouteBuilder(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration(milliseconds: 600),
    reverseTransitionDuration: Duration(milliseconds: 600),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        fillColor: Colors.black87,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.scaled,
        child: child,
      );
    },
  );
}
