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
  double _swipSensitivity = 0.15;
  Offset? _dragStart;
  Offset _dragPosition = Offset(0.0, 0.0);
  Offset _card = const Offset(0.0, 0.0);
  Offset _start = Offset(0.0, 0.0);
  GlobalKey _cardKey = GlobalKey(debugLabel: 'cardKey');

  Tween _slideTween = Tween();

  double _likeOpacity = 0.0;
  double _skipOpacity = 0.0;
  late AnimationController _slideBack;
  late AnimationController _slideOut;
  late AnimationController _undoAnimation;
  bool _swipedRight = false;
  late RenderBox _currentBox;

  @override
  void initState() {
    super.initState();
    _slideBack = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          _card = Offset.lerp(_dragStart, const Offset(0.0, 0.0),
              Curves.elasticOut.transform(_slideBack.value))!;
          widget.onSwipe(_card);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _dragStart = null;
            _likeOpacity = 0.0;
            _skipOpacity = 0.0;
            widget.onSwipe(const Offset(0.0, 0.0));
          });
        }
      });

    _slideOut = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          _card = _slideTween.evaluate(_slideOut) as Offset;
          widget.onSwipe(_card);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          if (_swipedRight)
            widget.onRightSwipe();
          else
            widget.onLeftSwipe();
          widget.onSwipe(const Offset(0.0, 0.0));
          setState(() {
            _dragStart = null;
            _card = const Offset(0.0, 0.0);
            _likeOpacity = 0.0;
            _skipOpacity = 0.0;
          });
        }
      });

    _undoAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          _card = Offset.lerp(
              Offset(-2 * context.size!.width, 0.0),
              const Offset(0.0, 0.0),
              Curves.decelerate.transform(_undoAnimation.value))!;
          widget.onSwipe(_card);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          widget.onSwipe(const Offset(0.0, 0.0));
          setState(() {
            _card = const Offset(0.0, 0.0);
            _likeOpacity = 0.0;
            _skipOpacity = 0.0;
          });
        }
      });
    widget.notifier.addListener(_onSwipeChange);
  }

  @override
  void dispose() {
    _slideOut.dispose();
    _slideBack.dispose();
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
          transform: Matrix4.translationValues(_card.dx, 0.0, 0.0)
            ..rotateZ(_getRotation(_screenHeight)),
          origin: _getOrigin(),
          child: Container(
            key: _cardKey,
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
                  opacity: _likeOpacity,
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
                  opacity: _skipOpacity,
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
    final rotation = _dragPosition.dy >= (height / 2) ? -1 : 1;
    return (pi / 8.0) * (_card.dx / 300) * rotation;
  }

  Offset _getOrigin() {
    return _dragPosition;
  }

  Offset _getRandomDragPosition() {
    var context = _cardKey.currentContext;
    RenderBox box = context?.findRenderObject() as RenderBox;
    var topLeft = box.localToGlobal(const Offset(0.0, 0.0));
    final dy =
        context!.size!.height * (Random().nextDouble() < .5 ? .25 : .75) +
            topLeft.dy;
    return Offset(context.size!.width / 2 + topLeft.dx, dy);
  }

  _onSwipeChange() {
    if (_slideBack.isAnimating ||
        _slideOut.isAnimating ||
        _undoAnimation.isAnimating) return;
    var width = context.size!.width;
    if (widget.notifier.swiped == Swiped.left) {
      _dragPosition = _getRandomDragPosition();
      _swipedRight = false;
      _slideTween =
          Tween(begin: const Offset(0.0, 0.0), end: Offset(-2 * width, 0.0));
      _skipOpacity = 1.0;
      _slideOut.forward(from: 0.0);
    } else if (widget.notifier.swiped == Swiped.right) {
      _dragPosition = _getRandomDragPosition();
      _swipedRight = true;
      _likeOpacity = 1.0;
      _slideTween =
          Tween(begin: const Offset(0.0, 0.0), end: Offset(2 * width, 0.0));
      _slideOut.forward(from: 0.0);
    } else if (widget.notifier.swiped == Swiped.undo) {
      _dragPosition = _getRandomDragPosition();
      _undoAnimation.forward(from: 0.0);
    }
  }

  _onPanStart(BuildContext context, DragStartDetails details) {
    _start = details.globalPosition;
    _currentBox = context.findRenderObject() as RenderBox;
    _dragPosition = _currentBox.globalToLocal(details.globalPosition);
    if (_slideBack.isAnimating) {
      _slideBack.stop(canceled: true);
    }
  }

  _onPanEnd(DragEndDetails details) {
    final dragDirection = _card / _card.distance;
    final inLeft = (_card.dx / context.size!.width) < -this._swipSensitivity;
    final inRight = (_card.dx / context.size!.width) > this._swipSensitivity;
    setState(() {
      if (inLeft || inRight) {
        _swipedRight = inRight;
        _slideTween =
            Tween(begin: _card, end: dragDirection * (2 * context.size!.width));
        _slideOut.forward(from: 0.0);
      } else {
        _dragStart = _card;
        _slideBack.forward(from: 0.0);
        widget.onSlideBack();
        _likeOpacity = 0.0;
        _skipOpacity = 0.0;
      }
    });
  }

  _onPanUpdate(BuildContext context, DragUpdateDetails details) {
    setState(() {
      _card = details.globalPosition - _start;
      widget.onSwipe(_card);
      if (_card.direction.abs() < 1) {
        _likeOpacity = (_card.distance / 200).clamp(0.0, 1.0);
        _skipOpacity = 0.0;
      } else {
        _skipOpacity = (_card.distance / 200).clamp(0.0, 1.0);
        _likeOpacity = 0.0;
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
