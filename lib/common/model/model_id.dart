abstract class Base {}

abstract class IModelWithId extends Base {
  final int id;

  IModelWithId({
    required this.id,
  });
}
