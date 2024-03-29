import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatefulWidget {
  ViewImagePage({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;
  @override
  _ViewImagePageState createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: NetworkImage(widget.images[_index]),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context, _index),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.close, color: Colors.white, size: 35.0),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _index = _index == 0 ? 0 : _index - 1;
                  });
                },
                child: Icon(Icons.arrow_left, color: Colors.white, size: 45.0),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _index = _index == widget.images.length - 1
                        ? _index
                        : _index + 1;
                  });
                },
                child: Icon(Icons.arrow_right, color: Colors.white, size: 45.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
