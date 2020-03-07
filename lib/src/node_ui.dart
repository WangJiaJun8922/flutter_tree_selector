import 'package:flutter/material.dart';
import 'group.dart';
import 'node.dart';
import 'tree.dart';

class NodeUI extends StatelessWidget {
  final Node node;
  final double padding;
  NodeUI(this.node, { this.padding = 0 });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      alignment: AlignmentDirectional.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(padding, 0, 10, 0),
                    child: _buildImage(context)
                ),
                _buildText(),
                _buildArrow(),
              ],
            ),
          ),
          Divider(height: 2, indent: 20, endIndent: 20,)
        ],
      ),
    );
  }

  Widget _buildText() {
    return Expanded(
        child: Text(
            node.type == Node.typeGroup
              ? (node.object as Group).name
              : (node.object as Member).name,
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: node.type == Node.typeGroup ? FontWeight.bold : FontWeight.normal)
      )
    );
  }

  Widget _buildArrow() {
    return node.type == Node.typeGroup ? Padding(
      padding: EdgeInsets.only(right: 10),
      child: Icon(node.expand
          ? Icons.keyboard_arrow_up
          : Icons.keyboard_arrow_down, color: Colors.grey[600]),
    ) : Container();
  }

  Widget _buildImage(BuildContext context){
    TreeSelectorProvider provider = TreeSelectorProvider.of(context);
    dynamic data = node.type == Node.typeGroup ? (node.object as Group) :  (node.object as Member);
    return Row(
      children: <Widget>[
        Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: provider.selectedNodes.where((node) => node.nodeId == this.node.nodeId).length > 0,
            activeColor: Colors.yellow,
            checkColor: Colors.black,
            onChanged: (bool flag) {
              provider.onChangeSelected(flag, this.node);
            },
          ),
        ),
        data.avatarUrl == null ? Container() : Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Image.network(data.avatarUrl, width:  node.type == Node.typeGroup ? 40 : 30, height:  node.type == Node.typeGroup ? 40 : 30,),
        )
      ],
    );
  }
}
