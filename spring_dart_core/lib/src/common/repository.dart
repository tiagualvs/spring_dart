import 'page.dart';
import 'result.dart';

abstract class SpringRepository<T, I> {
  const SpringRepository();
}

abstract class InsertOneParams<T> {
  const InsertOneParams();
}

abstract class FindManyParams<T> {
  const FindManyParams();
}

abstract class FindOneParams<T> {
  const FindOneParams();
}

abstract class UpdateOneParams<T> {
  const UpdateOneParams();
}

abstract class DeleteOneParams<T> {
  const DeleteOneParams();
}

abstract class CrudRepository<T, I> extends SpringRepository<T, I> {
  const CrudRepository();
  AsyncResult<T, Exception> insertOne(InsertOneParams<T> params);
  AsyncResult<List<T>, Exception> findMany(FindManyParams<T> params);
  AsyncResult<T, Exception> findOne(FindOneParams<T> params);
  AsyncResult<T, Exception> updateOne(UpdateOneParams<T> params);
  AsyncResult<T, Exception> deleteOne(DeleteOneParams<T> params);
}

abstract class PagingAndSortingRepository<T, I> extends SpringRepository<T, I> {
  const PagingAndSortingRepository();
  AsyncResult<Page<T>, Exception> findManyPaginated(FindManyParams<T> params);
}
