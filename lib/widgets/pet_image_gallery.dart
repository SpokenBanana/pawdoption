import 'dart:ui';

import 'package:flutter/material.dart';

import 'photo_view_page.dart';

class PetImageGallery extends StatefulWidget {
  PetImageGallery(this.images, {required this.tag});
  final List<String> images;
  final String tag;

  @override
  _PetImageGallery createState() => _PetImageGallery();
}

class _PetImageGallery extends State<PetImageGallery>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<PetImageGallery> {
  @override
  bool get wantKeepAlive => true;

  int _index = 0;
  late AnimationController _finishAnimation;
  double _scrollPercent = 0.0;
  late Offset _startDrag;
  late double _startPercent;
  late double _finishStart;
  late double _finishEnd;

  @override
  void initState() {
    super.initState();
    _finishAnimation = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() {
        setState(() {
          _scrollPercent =
              lerpDouble(_finishStart, _finishEnd, _finishAnimation.value)!;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        if (widget.images.isNotEmpty && widget.images[0].isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return ViewImagePage(images: widget.images, initialIndex: _index);
            },
          ).then((lastIndex) {
            if (lastIndex != null)
              setState(() {
                _index = lastIndex;
                _scrollPercent = _index / widget.images.length;
              });
          });
        }
      },
      onHorizontalDragStart: _onPanStart,
      onHorizontalDragUpdate: _onPanUpdate,
      onHorizontalDragEnd: _onPanEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: <Widget>[
          Stack(
            children: List<Widget>.generate(widget.images.length, (index) {
              return buildImage(index);
            }).toList(),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              width: 300.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildIndicators(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage(int index) {
    return FractionalTranslation(
      translation:
          Offset(index - (_scrollPercent / (1 / widget.images.length)), 0.0),
      child: Container(
        height: 550.0,
        decoration: BoxDecoration(
          color: Colors.black,
          image: widget.images[index].isEmpty
              ? null
              : DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: NetworkImage(widget.images[index]),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildIndicators() {
    List<Widget> indicators = [];
    for (int i = 0; i < widget.images.length; i++) {
      indicators.add(
        Container(
          margin: const EdgeInsets.all(4.0),
          width: i == _index ? 8.0 : 6.0,
          height: i == _index ? 8.0 : 6.0,
          decoration: BoxDecoration(
            color: i == _index ? Colors.white : Colors.grey[300],
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: i == _index
                ? [
                    BoxShadow(
                      color: Color(0x22000000),
                      spreadRadius: 2.0,
                      blurRadius: 2.0,
                      offset: const Offset(0.0, 1.0),
                    )
                  ]
                : null,
          ),
        ),
      );
    }
    return indicators;
  }

  _onPanEnd(DragEndDetails details) {
    _finishStart = _scrollPercent;
    final end = (_scrollPercent * widget.images.length);
    final dist = _scrollPercent - _startPercent;
    if (dist.abs() < .4) {
      _finishEnd = (dist < 0 ? end.floor() : end.ceil()) / widget.images.length;
    } else {
      _finishEnd = end.round() / widget.images.length;
    }
    _finishAnimation.forward(from: 0.0);
    setState(() {
      _index = (_finishEnd / (1 / widget.images.length)).round();
    });
  }

  _onPanStart(DragStartDetails details) {
    _startDrag = details.globalPosition;
    _startPercent = _scrollPercent;
  }

  _onPanUpdate(DragUpdateDetails details) {
    final distance = details.globalPosition.dx - _startDrag.dx;
    final dragPercent = distance / context.size!.width;
    final length = widget.images.length;

    setState(() {
      _scrollPercent = (_startPercent + (-dragPercent / length))
          .clamp(0.0, 1.0 - (1 / length));
    });
  }
}
