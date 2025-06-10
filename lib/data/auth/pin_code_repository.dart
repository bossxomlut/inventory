import '../../../core/persistence/security_storage.dart';
import '../../../domain/index.dart';
import '../../../domain/repositories/auth/pin_code_repository.dart';
import '../../../shared_widgets/index.dart';

class PinCodeRepositoryImpl extends PinCodeRepository {
  PinCodeRepositoryImpl(this._securityStorage);

  final SecurityStorage _securityStorage;

  static const String _pinCodeKey = 'pin_code';

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
  Future<void> savePinCode(SecurityQuestionEntity securityQuestionEntity, String answer, String pin) {
    return Future.wait([
      _securityStorage.saveString(_pinCodeKey, pin),
      _securityStorage.saveInt('security_question', securityQuestionEntity.id),
      _securityStorage.saveString('security_answer', answer),
    ]);
  }

  @override
  Future<String> getPinCode() {
    return _securityStorage.getString(_pinCodeKey).then(
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
      _securityStorage.saveString(_pinCodeKey, newPin);
    } else {
      throw Exception('Invalid pin code');
    }
  }

  @override
  void logout() {
    _securityStorage.remove(_pinCodeKey);
    _securityStorage.remove('security_question');
    _securityStorage.remove('security_answer');
  }

  @override
  void listenPinCodeChange(Function(String? pin) callback) {
    _securityStorage.addListener(_pinCodeKey, (String? value) {
      callback(value);
    });
  }

  @override
  void removePinCodeListener() {
    _securityStorage.removeListener(_pinCodeKey);
  }
}
