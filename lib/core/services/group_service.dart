import 'package:splitcount/core/models/group.dart';

abstract class IGroupService {
  Future<Group> createGroup(Group group);

  Future<Group> updateGroup(Group group);

  Future<void> deleteGroup(Group group);

  Stream<List<Group>> getGroups();
}
