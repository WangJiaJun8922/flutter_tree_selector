class Group {
  String name;
  String avatarUrl;
  List<Member> members;
  List<Group> subOrgans;

  Group(this.name, this.avatarUrl, this.members, this.subOrgans);
}

class Member{
  int id;
  String name;
  String avatarUrl;
  int identity;
  Member(this.id, this.name, this.avatarUrl, this.identity);
}