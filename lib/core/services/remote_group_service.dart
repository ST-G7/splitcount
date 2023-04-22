import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';

import 'package:appwrite/appwrite.dart';

import '../../constants.dart';

const String currentUser = "David"; // hardcoded for now

class RemoteGroupService implements IGroupService {
  static const String groupCollectionId = "642e86754648f1898e7b";

  late Realtime realtime;
  late Databases databases;

  RemoteGroupService() {
    databases = Databases(appwriteClient);
    realtime = Realtime(appwriteClient);
  }

  @override
  Future<Group> createGroup(Group group, {int? index}) async {
    var document = await databases.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        documentId: ID.unique(),
        data: {
          "groupName": group.name,
          "owner": group.owner,
          "members": group.members,
        });

    return Group.fromAppwriteDocument(document.data);
  }

  @override
  Future<void> deleteGroup(Group group) async {
    await databases.deleteDocument(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        documentId: group.id);
  }

  @override
  Stream<List<Group>> getGroups() async* {
    final subscription = realtime.subscribe([
      'databases.$appwriteDatabaseId.collections.$groupCollectionId.documents'
    ]);

    yield* subscription.stream
        .asyncMap((event) => _getGroupList())
        .startWith(await _getGroupList());
  }

  Future<List<Group>> _getGroupList() async {
    final groupDocuments = await databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.select(["groupName", "owner", "members"])
        ]);
    // queries: [Query.equal("owner", [currentUser])]);

    // List<Group> groups = <Group>[];
    // for (var group
    //     in groupDocuments.documents.map(_createGroupFromDocument).toList()) {
    //   if (group.members.contains(currentUser)) {
    //     groups.add(group);
    //   }
    // }
    // return groups;
    return groupDocuments.documents
        .map((document) => Group.fromAppwriteDocument(document.data))
        .toList();
  }
}
