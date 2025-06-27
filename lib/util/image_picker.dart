import 'package:image_picker/image_picker.dart';

class MultiImagePicker {
  final ImagePicker _picker = ImagePicker();

  // 여러 이미지 선택
  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80, // 이미지 품질 조정 (1-100)
        maxWidth: 1920, // 최대 너비 제한
        maxHeight: 1080, // 최대 높이 제한
        limit: 10,
      );
      return images;
    } catch (e) {
      print('이미지 선택 오류: $e');
      return null;
    }
  }
}
