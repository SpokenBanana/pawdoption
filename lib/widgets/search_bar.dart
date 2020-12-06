import 'dart:async';

import 'package:flutter/material.dart';

import '../colors.dart';

/// A callback to retrieve the list of items to be used.
typedef Future<List<String>> ItemCallback();

/// Let's user search from a list of items by typing then selecting the items
/// that show up.
///
/// Either item or listFetcher must be supplied, but not both. Items get's
/// priority if both are supplied.
///
/// This is currently only used for selecting breeds but may want to re-use for
/// other things (like maybe for shelters).
class SearchBar extends StatefulWidget {
  SearchBar(
      {this.key,
      this.items,
      this.listFetcher,
      this.onSelectedItem,
      this.hintText,
      this.refetchNotifier})
      : super(key: key);
  final Key key;
  final ChangeNotifier refetchNotifier;
  final List<String> items;
  final Function(String selected) onSelectedItem;
  final ItemCallback listFetcher;
  final String hintText;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<String> matches = List<String>();
  TrieNode _trie = TrieNode();
  List<String> items;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.items == null) {
      widget.listFetcher().then((list) {
        buildTrie(list);
      });
    } else {
      buildTrie(widget.items);
    }
    widget.refetchNotifier.addListener(_handleChange);
    controller.addListener(handleText);
  }

  @override
  void dispose() {
    widget.refetchNotifier.removeListener(_handleChange);
    controller.removeListener(handleText);
    super.dispose();
  }

  _handleChange() {
    matches.clear();
    _trie = TrieNode();
    if (widget.items == null) {
      widget.listFetcher().then((list) {
        buildTrie(list);
      });
    } else {
      buildTrie(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Theme.of(context).accentColor,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: matches.map((match) {
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => selectItem(match),
                          child: Text(match),
                        ),
                        ButtonTheme(
                          height: 30.0,
                          child: FlatButton(
                            shape: CircleBorder(),
                            onPressed: () => selectItem(match),
                            color: kPetThemecolor,
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  selectItem(String match) {
    if (widget.onSelectedItem != null) widget.onSelectedItem(match);
    setState(() {
      matches.clear();
      controller.text = '';
    });
  }

  handleText() {
    setState(() {
      matches = _getMatches(controller.text);
    });
  }

  List<String> _getMatches(String text) {
    if (text == '') return List<String>();
    List<String> results = List<String>();
    TrieNode current = _trie;
    String prefix = '';
    for (int i = 0; i < text.length; i++) {
      if (!current.children.containsKey(text[i].toLowerCase())) {
        return List<String>();
      }
      current = current.children[text[i].toLowerCase()];
      prefix += current.content;
    }
    search(current, prefix, results);
    return results;
  }

  search(TrieNode current, String str, List<String> result) {
    for (TrieNode node in current.children.values) {
      if (node.isEnd) {
        result.add(str + node.content);
      }
      search(node, str + node.content, result);
    }
  }

  buildTrie(List<String> options) {
    for (String option in options) {
      TrieNode current = _trie;
      for (int i = 0; i < option.length; i++) {
        var char = option[i].toLowerCase();
        if (!current.children.containsKey(char))
          current.children[char] = TrieNode(content: option[i]);
        current = current.children[char];
      }
      current.isEnd = true;
    }
  }
}

class TrieNode {
  Map<String, TrieNode> children = Map<String, TrieNode>();
  String content;
  bool isEnd = false;
  TrieNode({this.content});
}
