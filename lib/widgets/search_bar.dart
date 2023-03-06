import 'dart:async';

import 'package:flutter/material.dart';

/// A callback to retrieve the list of items to be used.
typedef Future<List<String>> ItemCallback();

/// Lets the user search from a list of items by typing then selecting the items
/// that show up.
///
/// Either item or listFetcher must be supplied, but not both. Items get's
/// priority if both are supplied.
///
/// This is currently only used for selecting breeds but may want to re-use for
/// other things (like maybe for shelters).
class SearchBar extends StatefulWidget {
  SearchBar(
      {required this.items,
      required this.listFetcher,
      required this.onSelectedItem,
      required this.hintText,
      required this.refetchNotifier});
  final ChangeNotifier refetchNotifier;
  final List<String> items;
  final Function(String selected) onSelectedItem;
  final ItemCallback listFetcher;
  final String hintText;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<String> matches = [];
  TrieNode _trie = TrieNode(content: '');
  List<String> items = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.items.isEmpty) {
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
    _trie = TrieNode(content: "");
    if (widget.items.isEmpty) {
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
            primaryColor: Theme.of(context).secondaryHeaderColor,
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
                          child: TextButton(
                            onPressed: () => selectItem(match),
                            // color: kPetThemecolor,
                            // shape: CircleBorder(),
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
    widget.onSelectedItem(match);
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
    if (text == '') return [];
    List<String> results = [];
    TrieNode current = _trie;
    String prefix = '';
    for (int i = 0; i < text.length; i++) {
      if (!current.children.containsKey(text[i].toLowerCase())) {
        return [];
      }
      current = current.children[text[i].toLowerCase()]!;
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
        current = current.children[char]!;
      }
      current.isEnd = true;
    }
  }
}

class TrieNode {
  Map<String, TrieNode> children = Map<String, TrieNode>();
  String content;
  bool isEnd = false;
  TrieNode({required this.content});
}
