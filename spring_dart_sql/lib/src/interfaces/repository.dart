import '../common/page.dart';

abstract class SpringRepository<T> {
  const SpringRepository();
}

abstract class CrudRepository<T> extends SpringRepository<T> {
  const CrudRepository();
  Future<T> insertOne(InsertOneParams<T> params);
  Future<T> findOne(FindOneParams<T> params);
  Future<List<T>> findMany(FindManyParams<T> params);
  Future<T> updateOne(UpdateOneParams<T> params);
  Future<T> deleteOne(DeleteOneParams<T> params);
}

abstract class InsertOneParams<T> {
  const InsertOneParams();

  String get query;

  List<Object?> get values;
}

abstract class FindOneParams<T> {
  const FindOneParams();

  String get query;

  List<Object?> get values;
}

abstract class FindManyParams<T> {
  const FindManyParams();

  String get query;

  List<Object?> get values;
}

abstract class UpdateOneParams<T> {
  const UpdateOneParams();

  String get query;

  List<Object?> get values;
}

abstract class DeleteOneParams<T> {
  const DeleteOneParams();

  String get query;

  List<Object?> get values;
}

abstract class PagingRepository<T> extends SpringRepository<T> {
  Future<Page<T>> findManyPaginated(FindManyPaginagedParams<T> params);
}

abstract class FindManyPaginagedParams<T> {
  final int page;
  final int perPage;

  const FindManyPaginagedParams({required this.page, required this.perPage});
}
