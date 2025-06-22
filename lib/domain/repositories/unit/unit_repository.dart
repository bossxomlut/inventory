import '../../entities/unit/unit.dart';
import '../crud_repository.dart';
import '../../../provider/load_list.dart';

abstract class UnitRepository extends CrudRepository<Unit, int> {
  Future<List<Unit>> getAll();
  Future<Unit> getById(int id);
  Future<LoadResult<Unit>> search(String keyword, int page, int limit, {Map<String, dynamic>? filter});
}
