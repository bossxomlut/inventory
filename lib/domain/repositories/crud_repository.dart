abstract class CrudRepository<T, Id> {
  Future<T> create(T item);
  Future<T> read(Id id);
  Future<T> update(T item);
  Future<bool> delete(T item);
}

abstract class SearchRepositoryWithPagination<T> {
  Future<List<T>> search(String keyword, int page, int limit);
}

abstract class GetOneByNameRepository<T> {
  Future<T?> getOneByName(String name);
}

abstract class GetAllRepository<T> {
  Future<List<T>> getAll();
}
