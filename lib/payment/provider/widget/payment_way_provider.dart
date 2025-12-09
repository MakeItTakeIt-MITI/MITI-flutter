import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/model/entity_enum.dart';

final paymentWayProvider =
    StateProvider.autoDispose<PaymentMethodType?>((s) => null);
