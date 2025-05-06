export 'package:easy_localization/easy_localization.dart';

String get nullPlaceHolder => '---';

abstract class LKey {
  static const String answer = 'answer';
  static const String darkMode = 'darkMode';
  static const String enterPinCode = 'enterPinCode';
  static const String error = 'error';
  static const String finish = 'finish';
  static const String copied = 'copied';
  static const String forgotPinCode = 'forgotPinCode';
  static const String home = 'home';
  static const String language = 'language';
  static const String logout = 'logout';
  static const String next = 'next';
  static const String search = 'search';
  static const String searchByProvince = 'searchByProvince';
  static const String securityQuestion = 'securityQuestion';
  static const String setSecurityQuestionDescription = 'setSecurityQuestionDescription';
  static const String setUpPinCode = 'setUpPinCode';
  static const String settings = 'settings';
  static const String success = 'success';
  static const String processing = 'processing';
  static const String updatePinCode = 'updatePinCode';
  static const String wrongPinCode = 'wrongPinCode';
  static const String enterCurrentPinCode = 'enterCurrentPinCode';
  static const String enterNewPinCode = 'enterNewPinCode';
  static const String update = 'update';
  static const String certificate = 'certificate';
  static const String certificates = 'certificates';
  static const String other = 'other';
  static const String all = 'all';
  static const String notFoundData = 'notFoundData';
  static const String ok = 'ok';
  static const String yes = 'yes';
  static const String cancel = 'cancel';
  static const String tryAgain = 'tryAgain';
  static const String delete = 'delete';
  //

  //message
  static const String messageInvalidSecurityQuestion = 'message.invalidSecurityQuestion';
  static const String messagePinCodeSetSuccessfully = 'message.pinCodeSetSuccessfully';
  static const String messageEditLandCertificateSuccessfully = 'message.editLandCertificateSuccessfully';
  static const String messageAddLandCertificateSuccessfully = 'message.addLandCertificateSuccessfully';
  static const String messageHaveAnErrorDescription = 'message.haveAnErrorDescription';
  static const String messageProcessingDescription = 'message.processingDescription';
  static const String messageDeleteItemConfirmDescription = 'message.deleteItemConfirmDescription';
  static const String messagePinCodeUpdatedSuccessfully = 'message.pinCodeUpdatedSuccessfully';
  static const String messageIncorrectPinCode = 'message.incorrectPinCode';

  //language
  static const String english = 'lang.en';
  static const String vietnamese = 'lang.vi';

  //questions
  static const String whatIsYourFavoriteColor = 'question.whatIsYourFavoriteColor';
  static const String whatIsYourFavoriteFood = 'question.whatIsYourFavoriteFood';
  static const String whatIsYourFavoriteMovie = 'question.whatIsYourFavoriteMovie';

  static const String pinCodeEncryptDescription = 'pinCodeEncryptDescription';
  static const String securityCode = 'securityCode';

  static const String addLandCertificatePage = 'addLandCertificatePage';

  //Add Land Certificate

  static const String addLandCertificate = '$addLandCertificatePage.addLandCertificate';
  static const String editLandCertificate = '$addLandCertificatePage.editLandCertificate';
  static const String viewLandCertificate = '$addLandCertificatePage.viewLandCertificate';

  static const String sectionsLandInfo = '$addLandCertificatePage.sections.landInfo';
  static const String sectionsLandCertificateImage = '$addLandCertificatePage.sections.landCertificateImage';
  static const String sectionsAddress = '$addLandCertificatePage.sections.address';
  static const String sectionsPurchaseDetails = '$addLandCertificatePage.sections.purchaseDetails';
  static const String sectionsSaleDetails = '$addLandCertificatePage.sections.saleDetails';
  static const String sectionsLandPlot = '$addLandCertificatePage.sections.landPlot';
  static const String sectionsArea = '$addLandCertificatePage.sections.area';
  static const String sectionsTax = '$addLandCertificatePage.sections.tax';
  static const String sectionsNote = '$addLandCertificatePage.sections.note';

  static const String fieldsNameDescription = '$addLandCertificatePage.fields.nameDescription';
  static const String fieldsLandCertificateImageTitle = '$addLandCertificatePage.fields.landCertificateImageTitle';
  static const String fieldsProvinceCity = '$addLandCertificatePage.fields.provinceCity';
  static const String fieldsDistrict = '$addLandCertificatePage.fields.district';
  static const String fieldsWard = '$addLandCertificatePage.fields.ward';
  static const String fieldsSpecificAddress = '$addLandCertificatePage.fields.specificAddress';
  static const String fieldsPurchaseDate = '$addLandCertificatePage.fields.purchaseDate';
  static const String fieldsPurchasePrice = '$addLandCertificatePage.fields.purchasePrice';
  static const String fieldsSaleDate = '$addLandCertificatePage.fields.saleDate';
  static const String fieldsSalePrice = '$addLandCertificatePage.fields.salePrice';
  static const String fieldsLandPlotNumber = '$addLandCertificatePage.fields.landPlotNumber';
  static const String fieldsMapNumber = '$addLandCertificatePage.fields.mapNumber';
  static const String fieldsAreaSize = '$addLandCertificatePage.fields.areaSize';
  static const String fieldsUsageForm = '$addLandCertificatePage.fields.usageForm';
  static const String fieldsUsagePurpose = '$addLandCertificatePage.fields.usagePurpose';
  static const String fieldsUsageDuration = '$addLandCertificatePage.fields.usageDuration';
  static const String fieldsResidentialLand = '$addLandCertificatePage.fields.residentialLand';
  static const String fieldsPerennialTrees = '$addLandCertificatePage.fields.perennialTrees';
  static const String fieldsTaxRenewalTime = '$addLandCertificatePage.fields.taxRenewalTime';
  static const String fieldsTaxPaymentDeadline = '$addLandCertificatePage.fields.taxPaymentDeadline';
  static const String fieldsDetails = '$addLandCertificatePage.fields.details';

  static const String actionsSave = '$addLandCertificatePage.actions.save';
}
