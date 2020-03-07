import 'package:flutter/material.dart';
import 'group.dart';
import 'node.dart';
import 'node_search.dart';
import 'node_ui.dart';

class TreeSelector extends StatefulWidget {
  final List<Group> organs;
  // 是否显示搜索栏
  final bool showSearchBar;
  // 选中的数据
  final Function selectedData;
  // 自定义节点组件，（接受一个Node数据，自定义组件包裹在TreeSelectorProvider内）
  final Function customNodeUI;

  TreeSelector(this.organs, {this.showSearchBar = true, this.customNodeUI, this.selectedData});

  @override
  State<StatefulWidget> createState() {
    return TreeSelectorState();
  }
}

class TreeSelectorState extends State<TreeSelector> {
  ///保存所有数据的List
  List<Node> list = new List();

  ///保存当前展示数据的List
  List<Node> expand = new List();

  ///保存List的下标的List，用来做标记用
  List<int> mark = new List();

  ///第一个节点的index
  int nodeId = 1;

  ///展示搜索结构
  bool showSearchResult = false;
  List<Node> keep;

  /// 选中的数据集合
  Set<Node> selectedNodes = new Set();

  @override
  void initState() {
    super.initState();
    nodeId = 1;
    _parseOrgans(widget.organs);
    selectedNodes.addAll(list);
    _addRoot();
    _getSelectedMemberData(selectedNodes);
  }

  void _getSelectedMemberData(Set<Node> selectedNodes) {
    Set<Member> data = new Set<Member>();
    for (Node n in selectedNodes.toList()) {
      if (n.type == Node.typeMember) {
        data.add((n.object as Member));
      }
    }
    widget.selectedData(data.toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: TreeSelectorProvider(
          selectedNodes: this.selectedNodes,
          onChangeSelected: this._onChangeSelected,
          child: Scaffold(
            backgroundColor: Colors.grey[200],
            body: Column(
              children: <Widget>[
                widget.showSearchBar ?
                Container(
                  padding: EdgeInsets.only(top: 5),
                  color: Colors.white,
                  child: NodeSearch(
                    dataSource: this.list,
                    onResult:_onSearch,
                  ),
                ): Container(),
                Expanded(
                  child: ListView(
                    children: _buildNode(expand),
                ),
              ),
            ],
          ),
      ),
        )
    );
  }

  ///搜索结果
  void _onSearch(List<Node> result) {
    setState(() {
      if (result == null) {
        //如果为空，代表搜索关键字为空
        showSearchResult = false;
        expand = keep; //将之前保存的状态还原
      } else {
        if (!showSearchResult) {
          //如果之前展示的不是搜索的结果，保存状态，为了之后状态还原做准备
          keep = expand;
        }
        showSearchResult = true; //展示搜索结果
        expand = result;
      }
    });
  }

  ///如果解析的数据是一个list列表，采用这个方法
  void _parseOrgans(List<Group> organs) {
    for (Group organ in organs) {
      _parseOrgan(organ);
    }
  }

  ///递归解析原始数据，将organ递归，记录其深度，nodeID和fatherID，将根节点的fatherID置为-1，
  ///保存原始数据为泛型T
  void _parseOrgan(Group organ, {int depth = 0, int fatherId = -1}) {
    int currentId = nodeId;
    list.add(Node(false, depth, Node.typeGroup, nodeId++, fatherId, organ));

    List<Node<Member>> members = new List();
    if (organ.members != null) {
      for (Member member in organ.members) {
        members.add(Node(
            false, depth + 1, Node.typeMember, nodeId++, currentId, member));
      }
    }
    list.addAll(members);

    if (organ.subOrgans != null) {
      for (Group organ in organ.subOrgans) {
        _parseOrgan(organ, depth: depth + 1, fatherId: currentId);
      }
    }
  }

  ///扩展机构树：id代表被点击的机构id
  ///做法是遍历整个list列表，将直接挂在该机构下面的节点增加到一个临时列表中，
  ///然后将临时列表插入到被点击的机构下面
  void _expand(int id) {
    //保存到临时列表
    List<Node> tmp = new List();
    for (Node node in list) {
      if (node.fatherId == id) {
        tmp.add(node);
      }
    }
    //找到插入点
    int index = -1;
    int length = expand.length;
    for (int i = 0; i < length; i++) {
      if (id == expand[i].nodeId) {
        index = i + 1;
        break;
      }
    }
    //插入
    expand.insertAll(index, tmp);
  }

  ///收起机构树：id代表被点击的机构id
  ///做法是遍历整个expand列表，将直接和间接挂在该机构下面的节点标记，
  ///将这些被标记节点删除即可，此处用到的是将没有被标记的节点加入到新的列表中
  void _collect(int id) {
    //清楚之前的标记
    mark.clear();
    //标记
    _mark(id);
    //重新对expand赋值
    List<Node> tmp = new List();
    for (Node node in expand) {
      if (mark.indexOf(node.nodeId) < 0) {
        tmp.add(node);
      } else {
        node.expand = false;
      }
    }
    expand.clear();
    expand.addAll(tmp);
  }

  ///标记，在收起机构树的时候用到
  void _mark(int id) {
    for (Node node in expand) {
      if (id == node.fatherId) {
        if (node.type == Node.typeGroup) {
          _mark(node.nodeId);
        }
        mark.add(node.nodeId);
      }
    }
  }

  ///增加根
  void _addRoot() {
    for (Node node in list) {
      if (node.fatherId == -1) {
        expand.add(node);
      }
    }
  }

  void _onChangeSelected(bool isSelected, Node selectedNode) {
//    print('isSelected: ${isSelected.toString()}, nodeId: ${selectedNode.nodeId}, fatherId: ${selectedNode.fatherId}, deep:${selectedNode.depth}');
    // 拿到子节点
    List<Node> subNodes = this.list.where((item) => item.fatherId == selectedNode.nodeId).toList();
    // 如果当前选中的节点下有子节点，那么子节点也一并选中添加
    if(isSelected) {
      setState(() {
        this.selectedNodes.add(selectedNode);
        this.selectedNodes.addAll(subNodes);
      });
    } else { //如果当前选中的节点下有子节点，那么子节点也一并选中删除
      setState(() {
        this.selectedNodes.removeWhere((item) => item.nodeId == selectedNode.nodeId);
        this.selectedNodes.removeWhere((item) => item.fatherId == selectedNode.nodeId);
      });
    }

    // 递归选中节点下的子节点进行同样的操作
    for (Node n in subNodes) {
      _onChangeSelected(isSelected, n);
    }

    // 如果选中节点的兄弟节点，全部已选择，那么该节点的父节点也要选中（全选该节点），反之只要有一个兄弟节点没选中，那么判定为非全选。
   if (selectedNode.fatherId > 0) { // 根节点没有父节点不需要检查
     _checkFatherNode(selectedNode);
   }

    // 将数据返回
    _getSelectedMemberData(selectedNodes);
  }

  void _checkFatherNode(Node selectedNode) {
    // 拿到父节点
    Node fatherNode = selectedNode.fatherId > 0 ? this.list.firstWhere((item) => item.nodeId == selectedNode.fatherId) : null;
    if (fatherNode != null) {
      // 兄弟节点总数量
      int brothers = this.list.where((item) => item.fatherId == fatherNode.nodeId).length;
      // 已选中的兄弟节点数量
      int brotherSelectedCounts = this.selectedNodes.where((item) => item.fatherId == fatherNode.nodeId).length;
//      print('兄弟个数${brothers.toString()},兄弟被选数量:${brotherSelectedCounts.toString()}');
      if (brotherSelectedCounts >= brothers) {
        setState(() {
          this.selectedNodes.add(fatherNode);
        });
      } else {
        this.selectedNodes.removeWhere((item) => item.nodeId == fatherNode.nodeId);
      }
    }
    // 如果还有父节点递归
    if (fatherNode.fatherId > 0) {
      _checkFatherNode(fatherNode);
    }
  }

  ///构建元素
  List<Widget> _buildNode(List<Node> nodes) {
    List<Widget> widgets = List();
    if (nodes != null && nodes.length > 0) {
      for (Node node in nodes) {
        widgets.add(GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: widget.customNodeUI == null ? NodeUI(
            node,
            padding: showSearchResult ? 0 : node.depth * 20.0, //如果展示搜索结果，那么不缩进
          ) : widget.customNodeUI(node),
          onTap: () {
            if (node.type == Node.typeGroup) {
              if (node.expand) {
                //之前是扩展状态，收起列表
                node.expand = false;
                _collect(node.nodeId);
              } else {
                //之前是收起状态，扩展列表
                node.expand = true;
                _expand(node.nodeId);
              }
              setState(() {});
            }
          },
        ));
      }
    }
    return widgets;
  }
}

class TreeSelectorProvider extends InheritedWidget {
  final Set<Node> selectedNodes;
  final Function onChangeSelected;
  final Widget child;

  TreeSelectorProvider(
      {this.selectedNodes, this.onChangeSelected, this.child})
      : super(child: child);

  static TreeSelectorProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(TreeSelectorProvider);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}