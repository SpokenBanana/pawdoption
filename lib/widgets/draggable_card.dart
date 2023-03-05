import 'dart:math';

import 'package:flutter/material.dart';

import '../api.dart';

class DraggableCard extends StatefulWidget {
  DraggableCard({
    required this.child,
    required this.onLeftSwipe,
    required this.onRightSwipe,
    required this.onSwipe,
    required this.onSlideBack,
    required this.onTap,
    required this.notifier,
  });
  final Widget child;
  final SwipeNotifier notifier;
  final Function(Offset delta) onSwipe;
  final Function() onLeftSwipe;
  final Function() onSlideBack;
  final Function() onTap;
  final Function() onRightSwipe;
  @override
  _DraggableCardState createState() => new _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  double swipSensitivity = 0.15;
  Offset? dragStart;
  Offset dragPosition = Offset(0.0, 0.0);
  Offset card = const Offset(0.0, 0.0);
  Offset start = Offset(0.0, 0.0);
  GlobalKey cardKey = GlobalKey(debugLabel: 'cardKey');

  Tween slideTween = Tween();

  double likeOpacity = 0.0;
  double skipOpacity = 0.0;
  late AnimationController slideBack;
  late AnimationController slideOut;
  late AnimationController undoAnimation;
  bool swipedRight = false;
  late RenderBox currentBox;

  @override
  void initState() {
    super.initState();
    slideBack = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          card = Offset.lerp(dragStart, const Offset(0.0, 0.0),
              Curves.elasticOut.transform(slideBack.value))!;
          widget.onSwipe(card);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            likeOpacity = 0.0;
            skipOpacity = 0.0;
            widget.onSwipe(const Offset(0.0, 0.0));
          });
        }
      });

    slideOut = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          card = slideTween.evaluate(slideOut) as Offset;
          widget.onSwipe(card);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (swipedRight)
            widget.onRightSwipe();
          else
            widget.onLeftSwipe();
          widget.onSwipe(const Offset(0.0, 0.0));
          setState(() {
            dragStart = null;
            card = const Offset(0.0, 0.0);
            likeOpacity = 0.0;
            skipOpacity = 0.0;
          });
        }
      });

    undoAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          card = Offset.lerp(
              Offset(-2 * context.size!.width, 0.0),
              const Offset(0.0, 0.0),
              Curves.decelerate.transform(undoAnimation.value))!;
          widget.onSwipe(card);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          widget.onSwipe(const Offset(0.0, 0.0));
          setState(() {
            card = const Offset(0.0, 0.0);
            likeOpacity = 0.0;
            skipOpacity = 0.0;
          });
        }
      });
    widget.notifier.addListener(_onSwipeChange);
  }

  @override
  void dispose() {
    slideOut.dispose();
    slideBack.dispose();
    widget.notifier.removeListener(_onSwipeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double _screenHeight = screenSize.height / 1.65;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Transform(
          transform: Matrix4.translationValues(card.dx, 0.0, 0.0)
            ..rotateZ(_getRotation(_screenHeight)),
          origin: _getOrigin(),
          child: Container(
            key: cardKey,
            child: GestureDetector(
              onPanStart: (details) => _onPanStart(context, details),
              onPanEnd: _onPanEnd,
              onPanUpdate: (details) => _onPanUpdate(context, details),
              onTap: widget.onTap,
              child: Stack(children: [
                Align(alignment: Alignment.center, child: widget.child),
                SwipeIndicator(
                  text: "LIKE",
                  rotation: -pi / 6,
                  color: Colors.green,
                  alignment: Alignment.topLeft,
                  opacity: likeOpacity,
                  dx: 40.0,
                  dy: 70.0,
                  margin: const EdgeInsets.only(left: 40.0),
                ),
                SwipeIndicator(
                  text: "SKIP",
                  rotation: pi / 6,
                  color: Color.fromARGB(255, 42, 107, 168),
                  dx: -20.0,
                  dy: 10.0,
                  alignment: Alignment.topRight,
                  opacity: skipOpacity,
                  margin: const EdgeInsets.only(right: 40.0),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  double _getRotation(height) {
    final rotation = dragPosition.dy >= (height / 2) ? -1 : 1;
    return (pi / 8.0) * (card.dx / 300) * rotation;
  }

  Offset _getOrigin() {
    return dragPosition;
  }

  Offset _getRandomDragPosition() {
    var context = cardKey.currentContext;
    RenderBox box = context?.findRenderObject() as RenderBox;
    var topLeft = box.localToGlobal(const Offset(0.0, 0.0));
    final dy =
        context!.size!.height * (Random().nextDouble() < .5 ? .25 : .75) +
            topLeft.dy;
    return Offset(context.size!.width / 2 + topLeft.dx, dy);
  }

  _onSwipeChange() {
    if (slideBack.isAnimating ||
        slideOut.isAnimating ||
        undoAnimation.isAnimating) return;
    var width = context.size!.width;
    if (widget.notifier.swiped == Swiped.left) {
      dragPosition = _getRandomDragPosition();
      swipedRight = false;
      slideTween =
          Tween(begin: const Offset(0.0, 0.0), end: Offset(-2 * width, 0.0));
      skipOpacity = 1.0;
      slideOut.forward(from: 0.0);
    } else if (widget.notifier.swiped == Swiped.right) {
      dragPosition = _getRandomDragPosition();
      swipedRight = true;
      likeOpacity = 1.0;
      slideTween =
          Tween(begin: const Offset(0.0, 0.0), end: Offset(2 * width, 0.0));
      slideOut.forward(from: 0.0);
    } else if (widget.notifier.swiped == Swiped.undo) {
      dragPosition = _getRandomDragPosition();
      undoAnimation.forward(from: 0.0);
    }
  }

  _onPanStart(BuildContext context, DragStartDetails details) {
    start = details.globalPosition;
    currentBox = context.findRenderObject() as RenderBox;
    dragPosition = currentBox.globalToLocal(details.globalPosition);
    if (slideBack.isAnimating) {
      slideBack.stop(canceled: true);
    }
  }

  _onPanEnd(DragEndDetails details) {
    final dragDirection = card / card.distance;
    final inLeft = (card.dx / context.size!.width) < -this.swipSensitivity;
    final inRight = (card.dx / context.size!.width) > this.swipSensitivity;
    setState(() {
      if (inLeft || inRight) {
        swipedRight = inRight;
        slideTween =
            Tween(begin: card, end: dragDirection * (2 * context.size!.width));
        slideOut.forward(from: 0.0);
      } else {
        dragStart = card;
        slideBack.forward(from: 0.0);
        widget.onSlideBack();
        likeOpacity = 0.0;
        skipOpacity = 0.0;
      }
    });
  }

  _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    setState(() {
      card = details.globalPosition - start;
      widget.onSwipe(card);
      if (card.direction.abs() < 1) {
        likeOpacity = (card.distance / 200).clamp(0.0, 1.0);
        skipOpacity = 0.0;
      } else {
        skipOpacity = (card.distance / 200).clamp(0.0, 1.0);
        likeOpacity = 0.0;
      }
    });
  }
}

class SwipeIndicator extends StatelessWidget {
  SwipeIndicator({
    required this.text,
    required this.alignment,
    required this.color,
    required this.opacity,
    required this.margin,
    required this.rotation,
    required this.dx,
    required this.dy,
  });
  final String text;
  final Alignment alignment;
  final Color color;
  final double opacity;
  final EdgeInsetsGeometry margin;
  final double rotation;
  final double dx;
  final double dy;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: this.alignment,
        child: Transform(
          transform: Matrix4.translationValues(this.dx, this.dy, 0.0)
            ..rotateZ(rotation),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 3.0, color: color.withOpacity(this.opacity)),
            ),
            child: Text(this.text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                  color: color.withOpacity(this.opacity),
                  fontSize: 30.0,
                )),
          ),
        ));
  }
}
