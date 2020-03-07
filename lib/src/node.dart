class Node<T> {
  static int typeGroup = 10000;
  static int typeMember = 10001;

  // 是否展开
  bool expand;
  // 深度
  int depth;
  // 类型
  int type;
  // 唯一节点号
  int nodeId;
  // 父节点号
  int fatherId;
  // 数据
  T object;
  Node(
      this.expand,
      this.depth,
      this.type,
      this.nodeId,
      this.fatherId,
      this.object);
}