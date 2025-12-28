import 'package:file_picker/file_picker.dart';

class FileService {
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: false,
    );

    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }
}