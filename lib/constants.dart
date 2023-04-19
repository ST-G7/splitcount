import 'package:appwrite/appwrite.dart';

const String appwriteEndpoint = "https://appwrite.perz.cloud/v1";
const String appwriteProjectId = "642c3fa6c1557c18bdbf";
const String appwriteDatabaseId = "642e85442ecb0146d94f";

final Client appwriteClient =
    Client().setEndpoint(appwriteEndpoint).setProject(appwriteProjectId);
