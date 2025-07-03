import '../../provider/load_list.dart';

abstract class CrudRepository<T, Id> {
  Future<T> create(T item);
  Future<T> read(Id id);
  Future<T> update(T item);
  Future<bool> delete(T item);
}

abstract class SearchRepositoryWithPagination<T> {
  Future<LoadResult<T>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter});
}

abstract class SearchRepository<T> {
  Future<List<T>> searchAll(String keyword);
}

abstract class GetOneByNameRepository<T> {
  Future<T?> getOneByName(String name);
}

abstract class GetAllRepository<T> {
  Future<List<T>> getAll();
}

abstract class SearchByName<T> {
  Future<T?> searchByName(String name);
}
