import 'package:flutter/material.dart';

import '../model/model_id.dart';


enum ScrollDirection { horizontal, vertical }

typedef PaginationWidgetBuilder<T extends Base> = Widget Function(
    BuildContext context, int index, T model);
