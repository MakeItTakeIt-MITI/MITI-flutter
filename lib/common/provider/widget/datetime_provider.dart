import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DateTimeType { start, end }

final dateProvider = StateProvider.autoDispose.family<DateTime?, DateTimeType>((ref, type) => null);


final timeProvider = StateProvider.autoDispose
    .family<DateTime, DateTimeType>((ref, type) => DateTime.now());
