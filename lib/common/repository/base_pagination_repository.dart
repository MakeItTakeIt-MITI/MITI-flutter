import '../model/cursor_model.dart';
import '../model/default_model.dart';
import '../model/model_id.dart';
import '../param/pagination_param.dart';

abstract class IBaseCursorPaginationRepository<T extends Base,
S extends DefaultParam> {
  Future<ResponseModel<CursorPaginationModel<T>>> paginate({
    required CursorPaginationParam cursorPaginationParams,
    S? param,
    int? path,
  });
}
