import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/models/transaction.dart';

abstract class IGroupService {
  Future<Group> createGroup(Group transaction, {int? index});

  Future<void> deleteGroup(Group transaction);

  Stream<List<Group>> getGroups();
}
