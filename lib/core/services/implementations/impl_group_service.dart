import 'package:rxdart/rxdart.dart';
import 'package:splitcount/core/models/group.dart';
import 'package:splitcount/core/services/group_service.dart';

import 'package:appwrite/appwrite.dart';
import 'package:get_storage/get_storage.dart';

import 'package:splitcount/constants.dart';

const String currentUser = "David"; // hardcoded for now

class GroupService implements IGroupService, ILocalGroupInformationService {
  static const String groupCollectionId = "642e86754648f1898e7b";

  late Realtime _realtime;
  late Databases _databases;
  GetStorage? _groupStorage;

  GroupService() {
    _databases = Databases(appwriteClient);
    _realtime = Realtime(appwriteClient);
  }

  @override
  Future<Group> getGroupById(String groupId) async {
    var document = await _databases.getDocument(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        documentId: groupId);

    var group = Group.fromAppwriteDocument(document.data);
    group.localMember = await getLocalGroupMember(group);

    return group;
  }

  @override
  Future<Group> createGroup(Group group) async {
    var document = await _databases.createDocument(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        documentId: ID.unique(),
        data: group.toDataMap());

    return Group.fromAppwriteDocument(document.data);
  }

  @override
  Future<Group> updateGroup(Group group) async {
    var document = await _databases.updateDocument(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        documentId: group.id,
        data: group.toDataMap());
    return Group.fromAppwriteDocument(document.data);
  }

  @override
  Future<void> deleteGroup(Group group) async {
    await _databases.deleteDocument(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        documentId: group.id);
  }

  @override
  Stream<List<Group>> getGroups() async* {
    final subscription = _realtime.subscribe([
      'databases.$appwriteDatabaseId.collections.$groupCollectionId.documents'
    ]);

    yield* subscription.stream
        .asyncMap((event) => _getGroupList())
        .startWith(await _getGroupList());
  }

  Future<List<Group>> _getGroupList() async {
    final groupDocuments = await _databases.listDocuments(
        databaseId: appwriteDatabaseId,
        collectionId: groupCollectionId,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.select(["groupName", "owner", "members", "description"])
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

  @override
  Future<void> setLocalGroupMember(Group group, String member) async {
    _groupStorage ??= await _createStorage();
    await _groupStorage!.write(group.id, member);
  }

  @override
  Future<String?> getLocalGroupMember(Group group) async {
    _groupStorage ??= await _createStorage();
    return _groupStorage!.read(group.id);
  }

  Future<GetStorage> _createStorage() async {
    var name = "GroupStorage";
    await GetStorage.init(name);
    var storage = GetStorage(name);
    return storage;
  }
}
