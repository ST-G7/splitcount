import 'package:splitcount/core/models/group.dart';

abstract interface class IGroupService {
  Future<Group> getGroupById(String groupId);

  Future<Group> createGroup(Group group);

  Future<Group> updateGroup(Group group);

  Future<void> deleteGroup(Group group);

  Stream<List<Group>> getGroups();
}
