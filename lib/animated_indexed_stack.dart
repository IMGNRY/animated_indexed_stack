import 'package:flutter/material.dart';

typedef TransitionBuilder = Widget Function(BuildContext context, Animation<double> animation, Widget child, int index, TransitionDirection direction);

enum TransitionDirection { In, Out }

class AnimatedIndexedStack extends StatefulWidget {
  final TransitionBuilder transitionBuilder;
  final int index;
  final List<Widget> children;
  final Duration duration;

  const AnimatedIndexedStack({
    required this.transitionBuilder,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  _AnimatedIndexedStackState createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration)..forward();
  int _previousIndex = 0;

  @override
  void didUpdateWidget(covariant AnimatedIndexedStack oldWidget) {
    if (widget.index != oldWidget.index) {
      _previousIndex = oldWidget.index;
      _controller.reset();
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    for (int i = 0; i < widget.children.length; i++) {
      TransitionDirection direction = i == widget.index ? TransitionDirection.In : TransitionDirection.Out;
      final animated = i == widget.index || i == _previousIndex;
      stackChildren.add(
        IgnorePointer(
          ignoring: i != widget.index,
          child: Visibility(
            visible: animated,
            maintainState: true,
            child: widget.transitionBuilder(context, direction == TransitionDirection.Out ? _controller.drive(Tween(begin: 1.0, end: 0.0)) : _controller, widget.children[i], i, direction),
          ),
        ),
      );
    }

    return Stack(
      children: stackChildren,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
