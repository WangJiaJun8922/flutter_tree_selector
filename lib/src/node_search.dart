import 'package:flutter/material.dart';
import 'group.dart';
import 'node.dart';

class NodeSearch extends StatefulWidget {
  final List<Node> dataSource;
  final Function onResult;

  NodeSearch({this.dataSource, this.onResult});

  @override
  _NodeSearchState createState() => _NodeSearchState();
}

class _NodeSearchState extends State<NodeSearch> {
  static bool _delOff = true; //是否展示删除按钮
  static String _key = ""; //搜索的关键字

  void onSearch(String text) {
    _key = text;
    List<Node> tmp = List();
    if (text.isEmpty) { //如果关键字为空，代表全匹配
      _delOff = true;
      widget.onResult(null);
    } else {
      _delOff = false;
      for (Node n in widget.dataSource) {
        if (n.type == Node.typeMember) {
          Member m = n.object as Member;
          if (m.name.toLowerCase().contains(text.toLowerCase())) { //匹配大小写
            tmp.add(n);
          }
        }
      }
      widget.onResult(tmp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      color: Colors.white,
      padding: EdgeInsets.all(5),
      child: Theme(
        data: new ThemeData(primaryColor: Colors.grey[200], hintColor:Colors.grey[200],),
        child: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            prefixIcon: Icon(Icons.search, color: Colors.grey,),
            fillColor: Colors.grey[200],
            filled: true,
            contentPadding: EdgeInsets.all(8),
            hintText: '输入搜索成员',
            hintStyle: TextStyle(color: Colors.grey[500]),
            suffixIcon: GestureDetector(
              child: Offstage(
                offstage: _delOff,
                child: Icon(Icons.highlight_off, color: Colors.grey,),
              ),
              onTap: () {
                setState(() {
                  _key = "";
                  onSearch(_key);
                });
              },
            ),
          ),
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: _key,
              selection: TextSelection.fromPosition(
                TextPosition(
                  offset: _key == null ? 0 : _key.length, //保证光标在最后
                ),
              ),
            ),
          ),
          onChanged: onSearch,
        ),
      ),
    );
  }
}
