abstract class Mapping<O, I> {
  O from(I input);
}

abstract class FutureMapping<O, I> {
  Future<O> from(I input);
}
