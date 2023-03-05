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

  int index = 0;
  late AnimationController finishAnimation;
  double scrollPercent = 0.0;
  late Offset startDrag;
  late double startPercent;
  late double finishStart;
  late double finishEnd;

  @override
  void initState() {
    super.initState();
    finishAnimation = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() {
        setState(() {
          scrollPercent =
              lerpDouble(finishStart, finishEnd, finishAnimation.value)!;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return ViewImagePage(images: widget.images, initialIndex: index);
          },
        ).then((lastIndex) {
          if (lastIndex != null)
            setState(() {
              index = lastIndex;
              scrollPercent = index / widget.images.length;
            });
        });
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
          Offset(index - (scrollPercent / (1 / widget.images.length)), 0.0),
      child: Container(
        height: 550.0,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
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
          width: i == index ? 8.0 : 6.0,
          height: i == index ? 8.0 : 6.0,
          decoration: BoxDecoration(
            color: i == index ? Colors.white : Colors.grey[300],
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: i == index
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
    finishStart = scrollPercent;
    final end = (scrollPercent * widget.images.length);
    final dist = scrollPercent - startPercent;
    if (dist.abs() < .4) {
      finishEnd = (dist < 0 ? end.floor() : end.ceil()) / widget.images.length;
    } else {
      finishEnd = end.round() / widget.images.length;
    }
    finishAnimation.forward(from: 0.0);
    setState(() {
      index = (finishEnd / (1 / widget.images.length)).round();
    });
  }

  _onPanStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startPercent = scrollPercent;
  }

  _onPanUpdate(DragUpdateDetails details) {
    final distance = details.globalPosition.dx - startDrag.dx;
    final dragPercent = distance / context.size!.width;
    final length = widget.images.length;

    setState(() {
      scrollPercent = (startPercent + (-dragPercent / length))
          .clamp(0.0, 1.0 - (1 / length));
    });
  }
}
