import '../../core/persistence/security_storage.dart';
import '../../domain/index.dart';
import '../../domain/repositories/pin_code_repository.dart';
import '../../shared_widgets/index.dart';

class PinCodeRepositoryImpl extends PinCodeRepository {
  PinCodeRepositoryImpl(this._securityStorage);

  final SecurityStorage _securityStorage;

  @override
  Future<bool> get isSetPinCode {
    return getPinCode().then(
      (String? value) {
        return value != null && value.isNotEmpty;
      },
    ).onError(
      (error, StackTrace stackTrace) => false,
    );
  }

  @override
  void savePinCode(SecurityQuestionEntity securityQuestionEntity, String answer, String pin) {
    _securityStorage.saveString('pin_code', pin);
    _securityStorage.saveInt('security_question', securityQuestionEntity.id);
    _securityStorage.saveString('security_answer', answer);
  }

  @override
  Future<String> getPinCode() {
    return _securityStorage.getString('pin_code').then(
      (String? value) {
        return value ?? '';
      },
    ).onError(
      (error, StackTrace stackTrace) => '',
    );
  }

  @override
  Future<bool> checkSecurityQuestion(SecurityQuestionEntity question, String answer) {
    return _securityStorage.getInt('security_question').then(
      (int? value) {
        if (value == question.id) {
          return _securityStorage.getString('security_answer').then(
            (String? value) {
              return value == answer;
            },
          );
        } else {
          return Future.value(false);
        }
      },
    ).onError(
      (error, StackTrace stackTrace) => false,
    );
  }

  @override
  List<SecurityQuestionEntity> get securityQuestions => [
        SecurityQuestionEntity(id: 1, question: LKey.whatIsYourFavoriteColor.tr()),
        SecurityQuestionEntity(id: 2, question: LKey.whatIsYourFavoriteFood.tr()),
        SecurityQuestionEntity(id: 3, question: LKey.whatIsYourFavoriteMovie.tr()),
      ];

  @override
  Future<void> login(String pin) async {
    final existPinCode = await getPinCode();

    if (existPinCode == pin) {
      return;
    } else {
      throw Exception('Invalid pin code');
    }
  }

  @override
  Future<void> updatePinCode(String confirmPin, String newPin) async {
    final existPinCode = await getPinCode();

    if (existPinCode == confirmPin) {
      _securityStorage.saveString('pin_code', newPin);
    } else {
      throw Exception('Invalid pin code');
    }
  }
}
