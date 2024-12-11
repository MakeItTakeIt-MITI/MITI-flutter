import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'throttle_provider.g.dart';

Throttle<bool> throttle = Throttle(const Duration(milliseconds: 300),
    initialValue: false, checkEquality: false);

@riverpod
class ApiThrottle extends _$ApiThrottle {
  final throttle = Throttle(const Duration(milliseconds: 300),
      initialValue: false, checkEquality: false);

  @override
  bool build({required int type}) {
    throttle.values.listen((bool state) {

    });
    return false;
  }

  void updateThrottle(){
    throttle.setValue(true);
  }
}
