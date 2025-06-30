// 방법 1: XFile.name 속성 사용 (가장 간단)
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

String getFileExtensionFromName(XFile file) {
  return path.extension(file.name).toLowerCase();
}

// 방법 2: XFile.path 속성 사용
String getFileExtensionFromPath(XFile file) {
  return path.extension(file.path).toLowerCase();
}

// 방법 3: MIME 타입으로 확장자 유추
String getExtensionFromMimeType(XFile file) {
  final mimeType = file.mimeType;
  switch (mimeType) {
    case 'image/jpeg':
      return '.jpg';
    case 'image/png':
      return '.png';
    case 'image/webp':
      return '.webp';
    case 'image/gif':
      return '.gif';
    default:
      return '.jpg'; // 기본값
  }
}

// 확장자에 따른 Content-Type 설정
String getContentTypeFromExtension(String extension) {
  switch (extension.toLowerCase()) {
    case '.png':
      return 'image/png';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.webp':
      return 'image/webp';
    case '.gif':
      return 'image/gif';
    default:
      return 'image/jpeg'; // 기본값
  }
}