import 'package:appwrite/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';

import 'package:appwrite/appwrite.dart';

const String currentUser = "David"; // hardcoded for now

class RemoteGroupService implements IGroupService {
  final Client client = Client();
  late Realtime realtime;
  late Databases databases;

  static const String databaseId = "642e85442ecb0146d94f";
  static const String collectionId = "642e86754648f1898e7b";

  RemoteGroupService() {
    client
        .setEndpoint('https://appwrite.perz.cloud/v1')
        .setProject('642c3fa6c1557c18bdbf');

    databases = Databases(client);
    realtime = Realtime(client);
  }

  @override
  Future<Group> createGroup(Group group, {int? index}) async {
    var document = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          "groupName": group.groupName,
          "owner": group.owner,
          "members": group.members,
        });

    return _createGroupFromDocument(document);
  }

  @override
  Future<void> deleteGroup(Group group) async {
    await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: group.id);
  }

  @override
  Stream<List<Group>> getGroups() async* {
    final subscription = realtime.subscribe(
        ['databases.$databaseId.collections.$collectionId.documents']);

    yield* subscription.stream
        .asyncMap((event) => _getGroupList())
        .startWith(await _getGroupList());
  }

  Future<List<Group>> _getGroupList() async {
    final groupDocuments = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [Query.orderDesc("\$createdAt")]);
    // queries: [Query.equal("owner", [currentUser])]);

    // List<Group> groups = <Group>[];
    // for (var group
    //     in groupDocuments.documents.map(_createGroupFromDocument).toList()) {
    //   if (group.members.contains(currentUser)) {
    //     groups.add(group);
    //   }
    // }
    // return groups;
    return groupDocuments.documents.map(_createGroupFromDocument).toList();
  }

  Group _createGroupFromDocument(Document document) {
    var dynamicList = document.data["members"];
    List<String> members = <String>[];

    // Need to do it this way because document.data["members"] is of type List<dynamic>
    for (var strEl in dynamicList) {
      members.add(strEl.toString());
    }

    return Group(document.$id, document.data["groupName"],
        document.data["owner"], members);
  }
}
