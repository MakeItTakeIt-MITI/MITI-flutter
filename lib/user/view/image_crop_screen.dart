import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropScreen extends StatefulWidget {
  final XFile? pickedFile;

  static String get routeName => 'imageCrop';

  const ImageCropScreen({
    super.key,
    required this.pickedFile,
  });

  @override
  _ImageCropScreenState createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  CroppedFile? _croppedFile;
  File? _image;
  String _imageInfo = '';

  // final dio = ref.read(dioProvider);
  //
  // // if (image != null) {
  // //   final imageFile = File(image.path);
  // //   final imageBytes =
  // //       imageFile.readAsBytes();
  // //
  // //   final options = Options(
  // //     contentType: 'image/png',
  // //   );
  // //
  // //   log("model url = ${model.profileImageUpdateUrl}");
  // //
  // //   final response = await dio.put(
  // //       model.profileImageUpdateUrl,
  // //       options: options,
  // //       data: imageBytes);
  // //
  // //   log("response statusCode = ${response.statusCode}");
  // //   log("response data =  ${response.data}");
  // //   if (response.statusCode == 200) {
  // //     context.pop();
  // //     ref
  // //         .read(userProfileProvider
  // //             .notifier)
  // //         .getInfo();
  // //     Future.delayed(
  // //         const Duration(
  // //             milliseconds: 100), () {
  // //       FlashUtil.showFlash(context,
  // //           '프로필 이미지가 변경 되었습니다.');
  // //     });
  // //   }
  // // }
  @override
  void initState() {
    super.initState();
    _getImageSizeSimple();
    WidgetsBinding.instance.addPostFrameCallback((s) {
      _cropImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: !kIsWeb ? AppBar(title: const Text("widget.title")) : null,
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
    if (_croppedFile != null || widget.pickedFile != null) {
      log("cropFile");
      return _imageCard();
    } else {
      log("cropFile");
      return _uploaderCard();
    }
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
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
          const SizedBox(height: 24.0),
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
        child: kIsWeb ? Image.network(path) : Image.file(File(path)),
      );
    } else if (widget.pickedFile != null) {
      final path = widget.pickedFile!.path;
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
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            onPressed: () {
              _cropImage();
            },
            backgroundColor: const Color(0xFFBC764A),
            tooltip: 'Crop',
            child: const Icon(Icons.crop),
          ),
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
                            'Upload an image to start',
                            style: kIsWeb
                                ? Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: Theme.of(context).highlightColor)
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color:
                                            Theme.of(context).highlightColor),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 24.0),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       _uploadImage();
              //     },
              //     style:
              //         ElevatedButton.styleFrom(foregroundColor: Colors.white),
              //     child: const Text('Upload'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // 대체 방법: 이미지 크기만 더 간단하게 확인하기
  Future<void> _getImageSizeSimple() async {
    try {
      final XFile? pickedFile = widget.pickedFile;

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        int fileSize = await file.length();

        // 이미지 디코딩하여 크기 확인
        final decodedImage = await decodeImageFromList(file.readAsBytesSync());

        setState(() {
          _image = file;
          _imageInfo = '파일 크기: ${(fileSize / 1024).toStringAsFixed(2)} KB\n'
              '이미지 너비: ${decodedImage.width} px\n'
              '이미지 높이: ${decodedImage.height} px';
          log('_imageInfo = $_imageInfo');
        });
      }
    } catch (e) {
      setState(() {
        _imageInfo = '이미지 정보를 가져오는 중 오류 발생: $e';
      });
    }
  }

  Future<void> _cropImage() async {
    if (widget.pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.pickedFile!.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '이미지 설정',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            // initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            // cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

// Future<void> _uploadImage() async {
//   final pickedFile =
//       await ImagePicker().pickImage(source: ImageSource.gallery);
//   if (pickedFile != null) {
//     setState(() {
//       widget.pickedFile = pickedFile;
//     });
//   }
// }
//
// void _clear() {
//   setState(() {
//     widget.pickedFile = null;
//     _croppedFile = null;
//   });
// }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
