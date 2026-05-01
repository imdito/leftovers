import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;

  final Client client = Client();
  late final Storage storage;

  AppwriteService._internal() {
    // Gunakan dotenv.env['KEY']!
    client
        .setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
        .setProject(dotenv.env['APPWRITE_PROJECT_ID']!)
        .setSelfSigned(status: true);
    storage = Storage(client);
  }

  Future<String?> uploadProfileImage(XFile file, String userId) async {
    try {
      // Ambil Bucket ID dari .env
      final String bucketId = dotenv.env['APPWRITE_BUCKET_ID']!;

      try {
        await storage.deleteFile(bucketId: bucketId, fileId: userId);
      } catch (_) {}

      final models.File result = await storage.createFile(
        bucketId: bucketId,
        fileId: userId,
        file: InputFile.fromPath(path: file.path, filename: "profile_$userId.jpg"),
      );

      return result.$id;
    } on AppwriteException catch (e) {
      print("Appwrite Error: ${e.message}");
      return null;
    }
  }

  // Di dalam class AppwriteService
  String getImageUrl(String fileId) {
    if (fileId.isEmpty) return "https://via.placeholder.com/150";

    final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
    final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
    final bucketId = dotenv.env['APPWRITE_BUCKET_ID']!;

    return "$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId";
  }
}