import 'dart:io';
import 'dart:math';

import '../common/logger/custom_logger.dart';

class FileSizeUtil {
  /// 파일 크기를 바이트 단위로 반환
  static Future<int> getBytes(File file) async {
    try {
      return await file.length();
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return 0;
    }
  }

  /// 파일 크기를 KB 단위로 반환 (소수점 2자리까지)
  static Future<double> getKiloBytes(File file) async {
    try {
      final int bytes = await file.length();
      return bytes / 1024;
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return 0;
    }
  }

  /// 파일 크기를 MB 단위로 반환 (소수점 2자리까지)
  static Future<double> getMegaBytes(File file) async {
    try {
      final int bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return 0;
    }
  }

  /// 파일 크기를 GB 단위로 반환 (소수점 2자리까지)
  static Future<double> getGigaBytes(File file) async {
    try {
      final int bytes = await file.length();
      return bytes / (1024 * 1024 * 1024);
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return 0;
    }
  }

  /// 파일 크기를 사람이 읽기 쉬운 형태로 반환 (B, KB, MB, GB)
  static Future<String> getReadableSize(File file, {int precision = 2}) async {
    try {
      final int bytes = await file.length();
      if (bytes <= 0) return '0 B';

      const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
      var i = (log(bytes) / log(1024)).floor();

      // 단위가 범위를 벗어나면 가장 큰 단위 사용
      if (i >= suffixes.length) i = suffixes.length - 1;

      return '${(bytes / pow(1024, i)).toStringAsFixed(precision)} ${suffixes[i]}';
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return '알 수 없음';
    }
  }

  /// 파일이 특정 크기(MB) 이상인지 확인
  static Future<bool> isLargerThan(File file, double sizeInMB) async {
    try {
      final double fileSizeInMB = await getMegaBytes(file);
      logger.d('이미지 사이즈 = ${fileSizeInMB}MB');
      return fileSizeInMB > sizeInMB;
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return false;
    }
  }

  /// 파일이 특정 크기(MB) 이하인지 확인
  static Future<bool> isSmallerThan(File file, double sizeInMB) async {
    try {
      final double fileSizeInMB = await getMegaBytes(file);
      return fileSizeInMB < sizeInMB;
    } catch (e) {
      print('파일 크기 확인 중 오류 발생: $e');
      return false;
    }
  }

  /// 파일 크기 비교 (두 파일의 상대적 크기 반환)
  static Future<int> compare(File file1, File file2) async {
    try {
      final int size1 = await file1.length();
      final int size2 = await file2.length();

      if (size1 < size2) return -1;  // file1이 더 작음
      if (size1 > size2) return 1;   // file1이 더 큼
      return 0;                      // 크기가 같음
    } catch (e) {
      print('파일 크기 비교 중 오류 발생: $e');
      return 0;
    }
  }

  /// 디렉토리 내의 모든 파일 크기 합계 (바이트)
  static Future<int> getDirectorySize(Directory directory) async {
    try {
      int totalSize = 0;
      final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();

      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      print('디렉토리 크기 확인 중 오류 발생: $e');
      return 0;
    }
  }

  /// 디렉토리 내의 모든 파일 크기 합계 (읽기 쉬운 형태)
  static Future<String> getReadableDirectorySize(Directory directory, {int precision = 2}) async {
    final int bytes = await getDirectorySize(directory);

    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = (log(bytes) / log(1024)).floor();

    if (i >= suffixes.length) i = suffixes.length - 1;

    return '${(bytes / pow(1024, i)).toStringAsFixed(precision)} ${suffixes[i]}';
  }
}