import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatefulWidget {
  ViewImagePage({this.images, this.initialIndex});

  final ImageProvider image;
  final List<String> images;
  final int initialIndex;
  @override
  _ViewImagePageState createState() => _ViewImagePageState();
}

class _ViewImagePageState extends State<ViewImagePage> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PhotoView(
          imageProvider: NetworkImage(widget.images[index]),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context, index),
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
              FlatButton(
                onPressed: () {
                  setState(() {
                    index = index == 0 ? 0 : index - 1;
                  });
                },
                child: Icon(Icons.arrow_left, color: Colors.white, size: 45.0),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    index =
                        index == widget.images.length - 1 ? index : index + 1;
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
