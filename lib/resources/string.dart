export 'package:easy_localization/easy_localization.dart';

abstract class LKey {
  static const String appVersion = 'appVersion';
  static const String login = 'login';
  static const String location = 'location';
  static const String selectLocation = 'selectLocation';
  static const String from = 'from';
  static const String to = 'to';
  static const String readAll = 'readAll';
  static const String defaultKey = 'default';
  static const String notFoundData = 'notFoundData';
  static const String or = 'or';
  static const String lostConnectInternet = 'lostConnectInternet';
  static const String unknown = 'unknown';

  //questions
  static const String addSecurityQuestion = 'question.addSecurityQuestion';
  static const String addSecurityAnswer = 'question.answer';
  static const String whatIsYourFavoriteColor = 'question.whatIsYourFavoriteColor';
  static const String whatIsYourFavoriteFood = 'question.whatIsYourFavoriteFood';
  static const String whatIsYourFavoriteMovie = 'question.whatIsYourFavoriteMovie';

  // Toast
  static const String toastTitleError = 'toast.titleError';
  static const String toastTitleSuccess = 'toast.titleSuccess';
  static const String toastTitleInfo = 'toast.titleInfo';

  // Button Keys
  static const String buttonLogin = 'button.login';
  static const String buttonSignUp = 'button.signUp';
  static const String buttonLogout = 'button.logout';
  static const String buttonDontHaveAnAccount = 'button.dontHaveAnAccount';
  static const String buttonForgotPassword = 'button.forgotPassword';
  static const String buttonContinue = 'button.continue';
  static const String buttonRegister = 'button.register';
  static const String buttonNext = 'button.next';
  static const String buttonSkip = 'button.skip';
  static const String buttonGetStarted = 'button.getStarted';
  static const String buttonGoToHome = 'button.goToHome';
  static const String buttonDone = 'button.done';
  static const String buttonCancel = 'button.cancel';
  static const String buttonConfirm = 'button.confirm';
  static const String buttonYes = 'button.yes';
  static const String buttonNo = 'button.no';
  static const String buttonUnderstood = 'button.understood';
  static const String buttonFinish = 'button.finish';
  static const String buttonAdd = 'button.add';
  static const String buttonApply = 'button.apply';
  static const String buttonReject = 'button.reject';
  static const String buttonAccept = 'button.accept';
  static const String buttonRetry = 'button.retry';
  static const String buttonRequest = 'button.request';
  static const String buttonBackToHome = 'button.backToHome';
  static const String buttonDontAllow = 'button.dontAllow';
  static const String buttonAllow = 'button.allow';
  static const String buttonOke = 'button.oke';
  static const String buttonOpenSettings = 'button.openSettings';

  // User Keys
  static const String userRoleClient = 'user.role.client';
  static const String userRolePartner = 'user.role.partner';

  // Onboarding keys
  static const String onBoardingNext = 'onBoarding.next';
  static const String onBoardingSkip = 'onBoarding.skip';
  static const String onBoardingGetStarted = 'onBoarding.getStarted';
  static const String onBoardingAlreadyHaveAnAccount = 'onBoarding.alreadyHaveAnAccount';
  static const String onBoardingTitle = 'onBoarding.title';
  static const String onBoardingDescription = 'onBoarding.content';
  static const String onBoardingTitle1 = 'onBoarding.title1';
  static const String onBoardingDescription1 = 'onBoarding.content1';
  static const String onBoardingTitle2 = 'onBoarding.title2';
  static const String onBoardingDescription2 = 'onBoarding.content2';

  // Login Keys
  static const String loginTitle = 'login.title';
  //loginValidateMessageUserAccount
  static const String loginValidateMessageUserAccount = 'loginPage.message.loginFailed';

  // SignUp Keys
  static const String signUpSelectRole = 'signUp.selectRole';
  static const String signUpNewCustomerRegistration = 'signUp.newCustomerRegistration';
  static const String signUpTellUsAboutYourself = 'signUp.tellUsAboutYourself';
  static const String signUpFullName = 'signUp.fullName';
  static const String signUpEmail = 'signUp.email';
  static const String signUpPhoneNumber = 'signUp.phoneNumber';
  static const String signUpEmergencyContact = 'signUp.emergencyContact';
  static const String signUpReferralCode = 'signUp.referralCode';
  static const String signUpAllowLocation = 'signUp.allowLocation';
  static const String signUpSetUpYourPassword = 'signUp.setUpYourPassword';
  static const String signUpAStrongPasswordDescription = 'signUp.aStrongPasswordDescription';
  static const String signUpAccount = 'signUp.account';
  static const String signUpPassword = 'signUp.password';
  static const String signUpConfirmPassword = 'signUp.confirmPassword';
  static const String signUpCreateAccount = 'signUp.createAccount';

  static const String signUpValidateMessagePasswordLength = 'signUp.validateMessage.passwordLength';
  static const String signUpValidateMessageUppercaseLetter = 'signUp.validateMessage.uppercaseLetter';
  static const String signUpValidateMessageSpecialCharacter = 'signUp.validateMessage.specialCharacter';
  static const String signUpValidateMessageFieldIsRequired = 'signUp.validateMessage.required';
  static const String signUpValidateMessagePasswordMatch = 'signUp.validateMessage.passwordMatch';
  static const String signUpValidateMessageAdminExist = 'signUp.validateMessage.adminExist';

  // SignUp Keys - Partner
  static const String signUpNewPartnerRegistration = 'signUp.newPartnerRegistration';
  static const String signUpDocument = 'signUp.document';
  static const String signUpMoreInformation = 'signUp.moreInformation';
  static const String signUpDesiredAreaOfOperation = 'signUp.desiredAreaOfOperation';
  static const String signUpPrimaryLocation = 'signUp.primaryLocation';
  static const String signUpSecondaryLocation = 'signUp.secondaryLocation';
  static const String signUpIdentityDocument = 'signUp.identityDocument';
  static const String signUpLicense = 'signUp.license';
  static const String signUpPassport = 'signUp.passport';
  static const String signUpExtraInformation = 'signUp.extraInformation';
  static const String signUpProfessionalExperience = 'signUp.professionalExperience';
  static const String signUpAdditionalSkill = 'signUp.additionalSkill';
  static const String signUpUploadCertificationImage = 'signUp.uploadCertificationImage';
  static const String signUpBodyGuard = 'signUp.bodyguard';
  static const String signUpSecurityGuard = 'signUp.securityGuard';
  static const String signUpInvestigator = 'signUp.investigator';
  static const String signUpDriver = 'signUp.driver';
  static const String signUpSubmitRegistrationForm = 'signUp.submitRegistrationForm';
  static const String signUpYourRegistrationFormIsProcessing = 'signUp.yourRegistrationFormIsProcessing';
  static const String signUpYourRegistrationFormIsProcessingDescription =
      'signUp.yourRegistrationFormIsProcessingDescription';
  static const String signBenefitOfPartner = 'signUp.benefitOfPartner';
  static const String signUpUploadImage = 'signUp.uploadImage';
  static const String signUpAddImage = 'signUp.addImage';
  static const String signUpClientDescription = 'signUp.clientDescription';
  static const String signUpPartnerDescription = 'signUp.partnerDescription';
  static const String signUpValidateMessageUserAccount = 'signUp.validateMessage.validateAccount';

  // Verification Keys
  static const String verificationSelectMethod = 'signUp.verification.selectMethod';
  static const String verificationVerifyAccount = 'signUp.verification.verifyYourAccount';
  static const String verificationSendOTPMessage = 'signUp.verification.sendOTPMessage';
  static const String verificationWrongCode = 'signUp.verification.wrongCode';
  static const String verificationDidNotGetACode = 'signUp.verification.didNotGetACode';
  static const String verificationResendRequest = 'signUp.verification.resentRequest';
  static const String verificationRequestNewCode = 'signUp.verification.resentRequestNewCode';

  // Register Successfully Keys
  static const String registerSuccessfullyCongratulation = 'signUp.createSuccessfully';
  static const String registerSuccessfullyExplore = 'signUp.explore';

  // Forgot Password Keys
  static const String forgotPasswordTitle = 'forgotPassword.title';
  static const String forgotPasswordDescriptionPhone = 'forgotPassword.descriptionPhone';
  static const String forgotPasswordCheckYourSMS = 'forgotPassword.checkYourSMS';
  static const String forgotPasswordDescriptionPhoneVerificationInfo =
      'forgotPassword.descriptionPhoneVerificationInfo';
  static const String forgotPasswordDescriptionMail = 'forgotPassword.descriptionMail';
  static const String forgotPasswordCheckYourEmail = 'forgotPassword.checkYourEmail';
  static const String forgotPasswordDescriptionMailVerificationInfo = 'forgotPassword.descriptionMailVerificationInfo';
  static const String forgotPasswordCreateNewPassword = 'forgotPassword.createNewPassword';
  static const String forgotPasswordDescriptionCreateNewPassword = 'forgotPassword.descriptionCreateNewPassword';

  // TextField Keys
  static const String searchCountryRegion = 'textField.searchCountryRegion';

  // Home Keys
  static const String homeBottomTabHome = 'home.bottomTab.home';
  static const String homeBottomTabMyBooking = 'home.bottomTab.myBooking';
  static const String homeBottomTabNotification = 'home.bottomTab.notification';
  static const String homeBottomTabAccount = 'home.bottomTab.account';
  static const String homeBottomTabSchedule = 'home.bottomTab.schedule';
  static const String homeBottomTabChat = 'home.bottomTab.chat';
  static const String homeMyBookingEmpty = 'home.myBookingEmpty';
  static const String homeBooked = 'home.booked';
  static const String homeReserved = 'home.reserved';
  static const String bookServices = 'home.bookServices';
  static const String homeContinueBooking = 'home.continueBooking';
  static const String homeBookingDetail = 'home.bookingDetail';
  static const String homeWorkSchedule = 'home.workSchedule';
  static const String homeMySchedule = 'home.mySchedule';
  static const String homeMyScheduleEmpty = 'home.myScheduleEmpty';
  static const String homeMyScheduleDescription = 'home.myScheduleDescription';
  static const String homeYourLocation = 'home.yourLocation';
  static const String homeAllowMyLocation = 'home.allowMyLocation';
  static const String homeNoEventFound = 'home.noEventFound';
  static const String homeUpcomingEvent = 'home.upcomingEvent';
  static const String homeNoChatFound = 'home.noChatFound';
  static const String homeNoJobFound = 'home.noJobFound';
  static const String homeJobNearBy = 'home.jobNearBy';
  static const String homeSetUpWorkDay = 'home.setUpWorkDay';
  static const String homeAvailableDayTitle = 'home.availableDayTitle';
  static const String homeAppTutorialVideo = 'home.appTutorialVideo';

  // Account Keys
  static const String accountTheme = 'account.theme';
  static const String accountDarkMode = 'account.darkMode';
  static const String accountLightMode = 'account.lightMode';
  static const String accountSystemDefault = 'account.systemDefault';
  static const String accountLanguage = 'account.language';
  static const String accountPaymentMethod = 'account.paymentMethod';
  static const String accountCurrency = 'account.currency';
  static const String accountMyVouchers = 'account.myVouchers';
  static const String accountEmergencyNumber = 'account.emergencyNumber';
  static const String accountEmergencyContact = 'account.emergencyContact';
  static const String accountEmergencyNumberDescription = 'account.emergencyDescription';
  static const String accountSupportFaqs = 'account.supportFaqs';
  static const String accountLogOut = 'account.logOut';
  static const String accountDeactivate = 'account.deactivate';
  static const String accountDeactivateConfirmMessage = 'account.deactivateConfirmMessage';
  static const String accountConfirmLogOut = 'account.confirmLogOut';
  static const String accountCash = 'account.cash';
  static const String accountCreditCard = 'account.creditCard';
  static const String accountDebitCard = 'account.debitCard';
  static const String accountAddCreditCard = 'account.addCreditCard';
  static const String accountAddDebitCard = 'account.addDebitCard';
  static const String accountBankName = 'account.bankName';
  static const String accountAccountNumber = 'account.accountNumber';
  static const String accountOwnerName = 'account.ownerName';
  static const String accountNameOnCard = 'account.nameOnCard';
  static const String accountCcvCode = 'account.ccvCode';
  static const String accountExpiredDay = 'account.expiredDay';
  static const String accountSetDefaultCard = 'account.setDefaultCard';
  static const String accountUpdateChange = 'account.updateChange';
  static const String accountDeleteCard = 'account.deleteCard';
  static const String accountRemoveCard = 'account.removeCard';
  static const String accountDeleteCardConfirm = 'account.deleteCardConfirm';
  static const String accountKeepThisCard = 'account.keepThisCard';
  static const String accountYesImSure = 'account.yesImSure';
  static const String accountHello = 'account.hello';
  static const String accountRequestLogin = 'account.requestLogin';
  static const String accountRequestLoginDescription = 'account.requestLoginDescription';
  static const String accountMyCards = 'account.myCards';
  static const String accountAddNewCard = 'account.addNewCard';
  static const String accountAddPaymentMethod = 'account.addPaymentMethod';
  static const String accountNoCardFound = 'account.noCardFound';
  static const String accountAddCardSuccess = 'account.addCardSuccess';
  static const String accountDeleteCardSuccess = 'account.deleteCardSuccess';
  static const String accountUpdateCardSuccess = 'account.updateCardSuccess';
  static const String accountEditCard = 'account.editCard';
  static const String accountWithdrawIncome = 'account.withdrawIncome';
  static const String accountChooseCard = 'account.chooseCard';
  static const String accountAvailable = 'account.available';
  static const String accountMax = 'account.max';
  static const String accountYouWillReceive = 'account.youWillReceive';
  static const String accountWithdraw = 'account.withdraw';
  static const String accountIncome = 'account.income';

  // Message Keys
  static const String messageLoginError = 'message.loginError';
  static const String messageDefaultApiError = 'message.defaultApiError';
  static const String messageProfileUpdateSuccess = 'message.profileUpdateSuccess';
  static const String messageEmergencyNumberUpdateSuccess = 'message.emergencyNumberUpdateSuccess';
  static const String messageUpdatePasswordSuccess = 'message.updatePasswordSuccess';
  static const String messageNeedToVerify = 'message.needToVerifyAccount';
  static const String messageRequiredSelectLocationArea = 'message.requiredSelectLocationArea';
  static const String messageRequiredSelectPickupLocation = 'message.requiredSelectPickupLocation';
  static const String messageRequiredSelectArrivedLocation = 'message.requiredSelectArrivedLocation';
  static const String messageRequiredSelectTargetLocation = 'message.requiredSelectTargetLocation';
  static const String messageRequiredSelectStartTime = 'message.requiredSelectStartTime';
  static const String messageRequiredSelectEndTime = 'message.requiredSelectEndTime';
  static const String messageEndDateNeedToBeAfterStartDate = 'message.endDateNeedToBeAfterStartDate';
  static const String messageRequiredSelectAgentType = 'message.requiredSelectAgentType';
  static const String messageRequiredSetRequestedSecurityOrCarTotal = 'message.requiredSetRequestedSecurityOrCarTotal';
  static const String messageRequiredSetRequestedSecurityTotal = 'message.requiredSetRequestedSecurityTotal';
  static const String messageRequiredPermissionFailed = 'message.requiredPermissionFailed';
  static const String messageEmptyData = 'message.emptyData';
  static const String messageWithdrawSuccessfully = 'message.withdrawSuccessfully';
  static const String messageCustomerLocationNotFound = 'message.customerLocationNotFound';

  // Notifications
  static const String noNotificationFound = 'notification.noNotificationFound';

  //Dialog
  static const String dialogRequestLocationPermission = 'dialog.requestLocationPermission';
  static const String dialogRequestLocationPermissionDescription = 'dialog.requestLocationPermissionDescription';
  static const String dialogRequestLocationService = 'dialog.requestLocationService';
  static const String dialogRequestLocationServiceDescription = 'dialog.requestLocationServiceDescription';
  static const String dialogSettings = 'dialog.settings';
  static const String dialogOpenSettingsDescription = 'dialog.openSettingsDescription';
  static const String dialogRequiredLocation = 'dialog.requiredLocation';
  static const String dialogRequiredLocationDescription = 'dialog.requiredLocationDescription';
  static const String dialogRequiredUpdateApp = 'dialog.requiredUpdateApp';
  static const String dialogRequestPhotoPermission = 'dialog.requestPhotoPermission';
  static const String dialogRequestPhotoPermissionDescription = 'dialog.requestPhotoPermissionDescription';

  //Search Location
  static const String searchLocationRecent = 'searchLocation.recent';
  static const String searchLocationSearchResult = 'searchLocation.searchResult';
  static const String searchLocationChooseFromMap = 'searchLocation.chooseFromMap';

  //Chat
  static const String chatJoinChat = 'chat.joinChat';
  static const String chatTypeAMessage = 'chat.typeAMessage';
}
