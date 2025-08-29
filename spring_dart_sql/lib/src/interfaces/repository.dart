import 'package:spring_dart_core/spring_dart_core.dart';

import '../common/page.dart';

abstract class SpringRepository<T> {
  const SpringRepository();
}

abstract class CrudRepository<T> extends SpringRepository<T> {
  const CrudRepository();
  AsyncResult<T> insertOne(InsertOneParams<T> params);
  AsyncResult<T> findOne(FindOneParams<T> params);
  AsyncResult<List<T>> findMany(FindManyParams<T> params);
  AsyncResult<T> updateOne(UpdateOneParams<T> params);
  AsyncResult<T> deleteOne(DeleteOneParams<T> params);
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
  AsyncResult<Page<T>> findManyPaginated(FindManyPaginagedParams<T> params);
}

abstract class FindManyPaginagedParams<T> {
  final int page;
  final int perPage;

  const FindManyPaginagedParams({required this.page, required this.perPage});
}
