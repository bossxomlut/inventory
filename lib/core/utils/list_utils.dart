class SplitListUtils {
  static const int seeMoreCount = 2;

  static List<T> splitList<T>(List<T> list, {int maxLength = seeMoreCount}) {
    //if list length is less than maxLength, return the list
    if (list.length <= maxLength) {
      return list.toList();
    }

    return list.sublist(0, maxLength);
  }
}

extension ListUtils on List<dynamic>? {
  bool get isNullOrEmpty {
    return this == null || this!.isEmpty;
  }

  bool get isNotNullAndEmpty {
    return !isNullOrEmpty;
  }
}

Future<List<R>> mapListAsync<T, R>(List<T> list, Future<R> Function(T) mapper) async {
  return await Future.wait(list.map(mapper));
}
