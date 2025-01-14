abstract class Base {}

abstract class IModelWithId extends Base {
  final int id;

  IModelWithId({
    required this.id,
  });
}

abstract class NullIModelWithId extends Base {
  final int? id;

  NullIModelWithId({
    this.id,
  });
}
