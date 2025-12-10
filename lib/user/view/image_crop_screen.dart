import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:miti/auth/view/find_info/find_email_screen.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/FileSizeUtil.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../dio/provider/dio_provider.dart';
import '../provider/user_provider.dart'; // image 패키지 추가 필요

final imageValidProvider = StateProvider.autoDispose<bool>((s) => false);

class ImageCropScreen extends ConsumerStatefulWidget {
  final String pickedFilePath;
  final String profileImageUpdateUrl;

  static String get routeName => 'imageCrop';

  const ImageCropScreen({
    super.key,
    required this.pickedFilePath,
    required this.profileImageUpdateUrl,
  });

  @override
  ConsumerState createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends ConsumerState<ImageCropScreen> {
  CroppedFile? _croppedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((s) async {
      late File file;
      if (_croppedFile != null) {
        file = File(_croppedFile!.path);
      } else {
        file = File(widget.pickedFilePath);
      }
      final valid = !await FileSizeUtil.isLargerThan(file, 20);
      ref.read(imageValidProvider.notifier).update((s) => valid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: "프로필 이미지",
        hasBorder: false,
      ),
      // appBar: !kIsWeb ? AppBar(title: const Text("widget.title")) : null,
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final valid = ref.watch(imageValidProvider);

          return BottomButton(
            button: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor:
                      valid ? MITIColor.primary : MITIColor.gray500),
              onPressed: valid
                  ? () {
                      _registProfileImage();
                    }
                  : null,
              child: Text("이미지 변경하기",
                  style: MITITextStyle.mdBold.copyWith(
                    color: valid ? MITIColor.gray800 : MITIColor.gray50,
                  )),
            ),
            hasBorder: false,
          );
        },
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
              child: Text(
                "widget.title",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Theme.of(context).highlightColor),
              ),
            ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_croppedFile != null || widget.pickedFilePath != null) {
      log("cropFile");
      return _imageCard();
    } else {
      log("cropFile");
      return _uploaderCard();
    }
  }

  Future<void> _registProfileImage() async {
    String path =
        _croppedFile == null ? widget.pickedFilePath : _croppedFile!.path;

    final dio = ref.read(dioProvider);
    final imageFile = File(path);
    final imageBytes = await imageFile.readAsBytes();

    final options = Options(
      contentType: 'image/png',
    );

    log("profileImageUpdateUrl = ${widget.profileImageUpdateUrl}");

    try {
      final response = await dio.put(widget.profileImageUpdateUrl,
          options: options, data: imageBytes);

      log("response statusCode = ${response.statusCode}");
      log("response data =  ${response.data}");
      if (response.statusCode == 200) {
        context.pop();
        imageCache.clear();
        ref.read(userProfileProvider.notifier).getInfo();
        Future.delayed(const Duration(milliseconds: 200), () {
          FlashUtil.showFlash(context, '프로필 이미지가 변경 되었습니다.');
        });
      } else {
        ref.read(userInfoProvider.notifier).getUserInfo();
        Future.delayed(const Duration(milliseconds: 200), () {
          FlashUtil.showFlash(context, '프로필 이미지 변경을 실패했습니다.',
              textColor: V2MITIColor.red5);
        });
      }
    } catch (e) {
      ref.read(userInfoProvider.notifier).getUserInfo();
      Future.delayed(const Duration(milliseconds: 200), () {
        FlashUtil.showFlash(context, '프로필 이미지 변경을 실패했습니다.',
            textColor: V2MITIColor.red5);
      });
    }
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
              child: Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                  child: _imageComponent(),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final valid = ref.watch(imageValidProvider);
              return Visibility(
                visible: !valid,
                child: child!,
              );
            },
            child: Column(
              children: [
                Text(
                  "이미지 크기가 20MB 이상입니다.",
                  style: MITITextStyle.md.copyWith(color: V2MITIColor.red5),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          _menu(),
        ],
      ),
    );
  }

  Widget _imageComponent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb
            ? Image.network(
                path,
                // fit: BoxFit.cover,
              )
            : Image.file(
                File(path),
                // fit: BoxFit.cover,
              ),
      );
    } else if (widget.pickedFilePath != null) {
      final path = widget.pickedFilePath;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (_croppedFile == null)
        FloatingActionButton(
          onPressed: () {
            _cropImage();
          },
          backgroundColor: const Color(0xFFBC764A),
          tooltip: '자르기',
          child: const Icon(Icons.crop),
        )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SizedBox(
          width: kIsWeb ? 380.0 : 320.0,
          height: 300.0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DottedBorder(
                    radius: const Radius.circular(12.0),
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 4],
                    color: Theme.of(context).highlightColor.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Theme.of(context).highlightColor,
                            size: 80.0,
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            '갤러리에서 가져오기',
                            style: MITITextStyle.md
                                .copyWith(color: MITIColor.gray500),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.pickedFilePath,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '이미지 설정',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio:false,
          // aspectRatioPresets: [
          //   CropAspectRatioPreset.square,
          // ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          cropStyle: CropStyle.circle,
          // aspectRatioPresets: [
          //   CropAspectRatioPreset.square,
          // ],
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;

        /// 이미지 압축
        final file = File(_croppedFile!.path);
        exampleUsage(file);
      });
    }
  }

  Future<Map<String, dynamic>?> getCompressedImageInfo(File file) async {
    try {
      // 원본 파일 정보 (비교를 위해)
      int originalFileSize = await file.length();

      // 이미지 압축 (Future<Uint8List?>를 반환하므로 await 필요)
      final Uint8List? byteImage = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 70,
        format: CompressFormat.png,
      );

      if (byteImage != null) {
        // 압축된 이미지의 바이트 크기
        int compressedSize = byteImage.length;

        // 파일 크기를 KB 단위로 변환
        double originalSizeKB = originalFileSize / 1024;
        double compressedSizeKB = compressedSize / 1024;

        print('원본 이미지 크기: ${originalSizeKB.toStringAsFixed(2)} KB');
        print('압축된 이미지 크기: ${compressedSizeKB.toStringAsFixed(2)} KB');
        print(
            '압축률: ${(100 - (compressedSizeKB / originalSizeKB) * 100).toStringAsFixed(2)}%');

        // 이미지 해상도(너비, 높이) 확인하기
        // 방법 1: image 패키지 사용
        img.Image? decodedImage = img.decodeImage(byteImage);
        if (decodedImage != null) {
          print(
              '압축된 이미지 해상도: ${decodedImage.width} x ${decodedImage.height} 픽셀');
        }

        // 방법 2: Flutter의 기본 이미지 디코딩 사용
        final decodedImageFromPixels = await decodeImageFromList(byteImage);
        print(
            '압축된 이미지 해상도(방법 2): ${decodedImageFromPixels.width} x ${decodedImageFromPixels.height} 픽셀');

        // 압축된 이미지를 임시 파일로 저장 (필요한 경우)
        // final tempDir =
        //     await Directory.systemTemp.createTemp('compressed_img_');
        // final tempFile = File('${tempDir.path}/compressed.png');
        // await tempFile.writeAsBytes(byteImage);
        //
        // print('압축된 이미지 저장 경로: ${tempFile.path}');

        return {
          'originalSize': originalSizeKB,
          'compressedSize': compressedSizeKB,
          'compressionRatio': 100 - (compressedSizeKB / originalSizeKB) * 100,
          'width': decodedImageFromPixels.width,
          'height': decodedImageFromPixels.height,
          // 'compressedFile': tempFile
        };
      } else {
        print('이미지 압축 실패');
        return null;
      }
    } catch (e) {
      print('이미지 정보 확인 중 오류 발생: $e');
      return null;
    }
  }

// 사용 예시
  void exampleUsage(File imageFile) async {
    // 압축된 이미지 정보 가져오기
    var imageInfo = await getCompressedImageInfo(imageFile);

    if (imageInfo != null) {
      print('압축된 이미지 정보:');
      print('- 원본 크기: ${imageInfo['originalSize']} KB');
      print('- 압축 크기: ${imageInfo['compressedSize']} KB');
      print('- 압축률: ${imageInfo['compressionRatio']}%');
      print('- 해상도: ${imageInfo['width']} x ${imageInfo['height']} 픽셀');
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
