abstract class UseCase<OUTPUT, INPUT> {
  OUTPUT execute(INPUT input);
}

abstract class FutureUseCase<OUTPUT, INPUT> {
  Future<OUTPUT> execute(INPUT input);
}
