import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../logger/custom_logger.dart';

part 'default_model.g.dart';

abstract class BaseModel {}

class LoadingModel extends BaseModel {}

@JsonSerializable()
class CompletedModel extends BaseModel {
  final int status_code;
  final String message;
  final String? data;

  CompletedModel({
    required this.status_code,
    required this.message,
    required this.data,
  });

  factory CompletedModel.fromJson(Map<String, dynamic> json) =>
      _$CompletedModelFromJson(json);
}

class ErrorModel<T> extends BaseModel {
  final int status_code;
  final String message;
  final T? data;
  final int error_code;

  ErrorModel({
    required this.status_code,
    required this.message,
    required this.data,
    required this.error_code,
  });

  static ErrorModel respToError(e) {
    logger.e(e);
    switch (e.runtimeType) {
      case DioException:
        final resp = (e as DioException).response!.data;
        return ErrorModel(
          status_code: resp['status_code'],
          message: resp['message'],
          data: resp['data'],
          error_code: resp['error_code'],
        );
      default:
        return ErrorModel(
          status_code: 500,
          message: '',
          data: '',
          error_code: 0,
        );
    }
  }
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class ResponseModel<T> extends BaseModel {
  final int status_code;
  final String message;
  final T? data;

  ResponseModel({
    required this.status_code,
    required this.message,
    required this.data,
  });

  factory ResponseModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$ResponseModelFromJson(json, fromJsonT);
  }
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class ResponseListModel<T> extends BaseModel {
  final int status_code;
  final String message;
  final List<T>? data;

  ResponseListModel({
    required this.status_code,
    required this.message,
    required this.data,
  });

  factory ResponseListModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$ResponseListModelFromJson(json, fromJsonT);
  }
}
