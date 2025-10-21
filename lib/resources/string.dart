export 'package:easy_localization/easy_localization.dart';

abstract class LKey {
  static const String appTitle = 'appTitle';
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
  static const String splashWelcomeBack = 'splash.welcomeBack';
  static const String splashLoading = 'splash.loading';
  static const String imagePickerCamera = 'imagePicker.camera';
  static const String imagePickerGallery = 'imagePicker.gallery';
  static const String imagePickerProduct = 'imagePicker.product';
  static const String imagePickerSourceTitle = 'imagePicker.sourceTitle';
  static const String scannerTitle = 'scanner.title';
  static const String scannerCameraError = 'scanner.cameraError';
  static const String scannerCameraPermissionDenied =
      'scanner.cameraPermissionDenied';
  static const String scannerCameraPermissionPermanentlyDenied =
      'scanner.cameraPermissionPermanentlyDenied';
  static const String scannerCameraUnsupported = 'scanner.cameraUnsupported';
  static const String scannerCameraGeneric = 'scanner.cameraGeneric';
  static const String scannerGallerySuccess = 'scanner.gallerySuccess';
  static const String scannerGalleryFailure = 'scanner.galleryFailure';
  static const String scannerTestTooltip = 'scanner.test.tooltip';
  static const String scannerTestTitle = 'scanner.test.title';
  static const String scannerTestInstruction = 'scanner.test.instruction';
  static const String scannerTestInputLabel = 'scanner.test.inputLabel';
  static const String scannerTestInputHint = 'scanner.test.inputHint';
  static const String scannerTestAction = 'scanner.test.action';
  static const String scannerScanningHint = 'scanner.scanningHint';
  static const String scannerNoDisplayValue = 'scanner.noDisplayValue';
  //questions
  static const String addSecurityQuestion = 'question.addSecurityQuestion';
  static const String addSecurityAnswer = 'question.answer';
  static const String whatIsYourFavoriteColor =
      'question.whatIsYourFavoriteColor';
  static const String whatIsYourFavoriteFood =
      'question.whatIsYourFavoriteFood';
  static const String whatIsYourFavoriteMovie =
      'question.whatIsYourFavoriteMovie';
  static const String messagePinCodeUpdatedSuccessfully =
      'message.pinCodeUpdatedSuccessfully';
  static const String messageIncorrectPinCode = 'message.incorrectPinCode';
  static const String wrongPinCode = 'wrongPinCode';
  static const String forgotPinCode = 'forgotPinCode';
  static const String enterPinCode = 'enterPinCode';

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
  static const String buttonReset = 'button.reset';
  static const String buttonReject = 'button.reject';
  static const String buttonAccept = 'button.accept';
  static const String buttonRetry = 'button.retry';
  static const String buttonSave = 'button.save';
  static const String buttonClose = 'button.close';
  static const String buttonUndo = 'button.undo';
  static const String buttonRequest = 'button.request';
  static const String buttonBackToHome = 'button.backToHome';
  static const String buttonDontAllow = 'button.dontAllow';
  static const String buttonAllow = 'button.allow';
  static const String buttonOke = 'button.oke';
  static const String buttonOpenSettings = 'button.openSettings';
  static const String buttonSelect = 'button.select';
  static const String buttonDelete = 'button.delete';

  // User Keys
  static const String userRoleClient = 'user.role.client';
  static const String userRolePartner = 'user.role.partner';

  // Onboarding keys
  static const String onBoardingNext = 'onBoarding.next';
  static const String onBoardingSkip = 'onBoarding.skip';
  static const String onBoardingGetStarted = 'onBoarding.getStarted';
  static const String onBoardingPrevious = 'onBoarding.previous';
  static const String onBoardingAlreadyHaveAnAccount =
      'onBoarding.alreadyHaveAnAccount';
  static const String onBoardingTitle = 'onBoarding.title';
  static const String onBoardingDescription = 'onBoarding.content';
  static const String onBoardingTitle1 = 'onBoarding.title1';
  static const String onBoardingDescription1 = 'onBoarding.content1';
  static const String onBoardingTitle2 = 'onBoarding.title2';
  static const String onBoardingDescription2 = 'onBoarding.content2';

  // Login Keys
  static const String loginTitle = 'login.title';
  //loginValidateMessageUserAccount
  static const String loginValidateMessageUserAccount =
      'loginPage.message.loginFailed';
  static const String loginUserNotFound = 'loginPage.error.userNotFound';

  // SignUp Keys
  static const String signUpSelectRole = 'signUp.selectRole';
  static const String signUpNewCustomerRegistration =
      'signUp.newCustomerRegistration';
  static const String signUpTellUsAboutYourself = 'signUp.tellUsAboutYourself';
  static const String signUpFullName = 'signUp.fullName';
  static const String signUpEmail = 'signUp.email';
  static const String signUpPhoneNumber = 'signUp.phoneNumber';
  static const String signUpEmergencyContact = 'signUp.emergencyContact';
  static const String signUpReferralCode = 'signUp.referralCode';
  static const String signUpAllowLocation = 'signUp.allowLocation';
  static const String signUpSetUpYourPassword = 'signUp.setUpYourPassword';
  static const String signUpAStrongPasswordDescription =
      'signUp.aStrongPasswordDescription';
  static const String signUpAccount = 'signUp.account';
  static const String signUpPassword = 'signUp.password';
  static const String signUpConfirmPassword = 'signUp.confirmPassword';
  static const String signUpCreateAccount = 'signUp.createAccount';

  static const String signUpValidateMessagePasswordLength =
      'signUp.validateMessage.passwordLength';
  static const String signUpValidateMessageUppercaseLetter =
      'signUp.validateMessage.uppercaseLetter';
  static const String signUpValidateMessageSpecialCharacter =
      'signUp.validateMessage.specialCharacter';
  static const String signUpValidateMessageFieldIsRequired =
      'signUp.validateMessage.required';
  static const String signUpValidateMessagePasswordMatch =
      'signUp.validateMessage.passwordMatch';
  static const String signUpValidateMessageAdminExist =
      'signUp.validateMessage.adminExist';

  // SignUp Keys - Partner
  static const String signUpNewPartnerRegistration =
      'signUp.newPartnerRegistration';
  static const String signUpDocument = 'signUp.document';
  static const String signUpMoreInformation = 'signUp.moreInformation';
  static const String signUpDesiredAreaOfOperation =
      'signUp.desiredAreaOfOperation';
  static const String signUpPrimaryLocation = 'signUp.primaryLocation';
  static const String signUpSecondaryLocation = 'signUp.secondaryLocation';
  static const String signUpIdentityDocument = 'signUp.identityDocument';
  static const String signUpLicense = 'signUp.license';
  static const String signUpPassport = 'signUp.passport';
  static const String signUpExtraInformation = 'signUp.extraInformation';
  static const String signUpProfessionalExperience =
      'signUp.professionalExperience';
  static const String signUpAdditionalSkill = 'signUp.additionalSkill';
  static const String signUpUploadCertificationImage =
      'signUp.uploadCertificationImage';
  static const String signUpBodyGuard = 'signUp.bodyguard';
  static const String signUpSecurityGuard = 'signUp.securityGuard';
  static const String signUpInvestigator = 'signUp.investigator';
  static const String signUpDriver = 'signUp.driver';
  static const String signUpSubmitRegistrationForm =
      'signUp.submitRegistrationForm';
  static const String signUpYourRegistrationFormIsProcessing =
      'signUp.yourRegistrationFormIsProcessing';
  static const String signUpYourRegistrationFormIsProcessingDescription =
      'signUp.yourRegistrationFormIsProcessingDescription';
  static const String signBenefitOfPartner = 'signUp.benefitOfPartner';
  static const String signUpUploadImage = 'signUp.uploadImage';
  static const String signUpAddImage = 'signUp.addImage';
  static const String signUpClientDescription = 'signUp.clientDescription';
  static const String signUpPartnerDescription = 'signUp.partnerDescription';
  static const String signUpValidateMessageUserAccount =
      'signUp.validateMessage.validateAccount';

  // Verification Keys
  static const String verificationSelectMethod =
      'signUp.verification.selectMethod';
  static const String verificationVerifyAccount =
      'signUp.verification.verifyYourAccount';
  static const String verificationSendOTPMessage =
      'signUp.verification.sendOTPMessage';
  static const String verificationWrongCode = 'signUp.verification.wrongCode';
  static const String verificationDidNotGetACode =
      'signUp.verification.didNotGetACode';
  static const String verificationResendRequest =
      'signUp.verification.resentRequest';
  static const String verificationRequestNewCode =
      'signUp.verification.resentRequestNewCode';

  // Register Successfully Keys
  static const String registerSuccessfullyCongratulation =
      'signUp.createSuccessfully';
  static const String registerSuccessfullyExplore = 'signUp.explore';

  // Forgot Password Keys
  static const String forgotPasswordTitle = 'forgotPassword.title';
  static const String forgotPasswordDescriptionPhone =
      'forgotPassword.descriptionPhone';
  static const String forgotPasswordCheckYourSMS =
      'forgotPassword.checkYourSMS';
  static const String forgotPasswordDescriptionPhoneVerificationInfo =
      'forgotPassword.descriptionPhoneVerificationInfo';
  static const String forgotPasswordDescriptionMail =
      'forgotPassword.descriptionMail';
  static const String forgotPasswordCheckYourEmail =
      'forgotPassword.checkYourEmail';
  static const String forgotPasswordDescriptionMailVerificationInfo =
      'forgotPassword.descriptionMailVerificationInfo';
  static const String forgotPasswordCreateNewPassword =
      'forgotPassword.createNewPassword';
  static const String forgotPasswordDescriptionCreateNewPassword =
      'forgotPassword.descriptionCreateNewPassword';

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
  static const String homeMenuPermissionsError = 'home.menu.permissionsError';
  static const String homeMenuNoPermissionMessage =
      'home.menu.noPermissionMessage';
  static const String homeMenuGreeting = 'home.menu.greeting';
  static const String homeMenuReorderTooltip = 'home.menu.reorderTooltip';
  static const String homeMenuReorderTitle = 'home.menu.reorderTitle';
  static const String homeMenuReorderDescription =
      'home.menu.reorderDescription';
  static const String homeMenuReorderReset = 'home.menu.reorderReset';
  static const String homeMenuReorderPositionLabel =
      'home.menu.reorderPositionLabel';
  static const String homeMenuGroupProductManagement =
      'home.menu.group.productManagement';
  static const String homeMenuGroupPriceOrder = 'home.menu.group.priceOrder';
  static const String homeMenuGroupSystemAdministration =
      'home.menu.group.systemAdministration';
  static const String homeMenuGroupDataManagement =
      'home.menu.group.dataManagement';
  static const String homeMenuItemProducts = 'home.menu.item.products';
  static const String homeMenuItemInventory = 'home.menu.item.inventory';
  static const String homeMenuItemCategories = 'home.menu.item.categories';
  static const String homeMenuItemUnits = 'home.menu.item.units';
  static const String homeMenuItemExpiry = 'home.menu.item.expiry';
  static const String homeMenuItemPricing = 'home.menu.item.pricing';
  static const String homeMenuItemCreateOrder = 'home.menu.item.createOrder';
  static const String homeMenuItemOrderList = 'home.menu.item.orderList';
  static const String homeMenuItemUserManagement =
      'home.menu.item.userManagement';
  static const String homeMenuItemReports = 'home.menu.item.reports';
  static const String homeMenuItemCreateSampleData =
      'home.menu.item.createSampleData';
  static const String homeMenuItemImportData = 'home.menu.item.importData';
  static const String homeMenuItemExportData = 'home.menu.item.exportData';
  static const String homeMenuItemDeleteData = 'home.menu.item.deleteData';
  static const String homeMenuPositionLabel = 'home.menu.reorderPositionLabel';
  static const String homeMenuReorderSaved = 'home.menu.reorderSaved';
  static const String homeMenuUnauthenticatedTitle =
      'home.menu.unauthenticatedTitle';
  static const String homeMenuUnauthenticatedMessage =
      'home.menu.unauthenticatedMessage';

  // Permissions
  static const String permissionsLoadFailed = 'permissions.loadFailed';
  static const String permissionsLoadFailedWithError =
      'permissions.loadFailedWithError';

  // Common
  static const String commonErrorWithMessage = 'common.errorWithMessage';
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
  static const String languageEnglish = 'languageName.english';
  static const String languageVietnamese = 'languageName.vietnamese';
  static const String settingDataManagement = 'setting.dataManagement';
  static const String settingCreateFromSample = 'setting.createFromSample';
  static const String settingExportData = 'setting.exportData';
  static const String settingDeleteData = 'setting.deleteData';
  static const String settingAboutApp = 'setting.aboutApp';
  static const String settingUserGuide = 'setting.userGuide';
  static const String settingFeedback = 'setting.feedback';
  static const String settingFeedbackSubtitle = 'setting.feedbackSubtitle';
  static const String settingReviewApp = 'setting.reviewApp';
  static const String settingReplayOnboarding = 'setting.replayOnboarding';
  static const String settingReplayOnboardingSubtitle =
      'setting.replayOnboardingSubtitle';
  static const String settingResetOnboardingSuccess =
      'setting.resetOnboardingSuccess';
  static const String settingResetOnboardingError =
      'setting.resetOnboardingError';
  static const String settingPreferences = 'setting.preferences';
  static const String feedbackTitle = 'feedback.title';
  static const String feedbackDescription = 'feedback.description';
  static const String feedbackTypeLabel = 'feedback.type.label';
  static const String feedbackTypeHint = 'feedback.type.hint';
  static const String feedbackTypeBug = 'feedback.type.bug';
  static const String feedbackTypeFeature = 'feedback.type.feature';
  static const String feedbackTypeOther = 'feedback.type.other';
  static const String feedbackTypePickerTitle = 'feedback.type.pickerTitle';
  static const String feedbackTitleLabel = 'feedback.form.titleLabel';
  static const String feedbackTitleHint = 'feedback.form.titleHint';
  static const String feedbackContactLabel = 'feedback.form.contactLabel';
  static const String feedbackContactHint = 'feedback.form.contactHint';
  static const String feedbackContentLabel = 'feedback.form.contentLabel';
  static const String feedbackContentHint = 'feedback.form.contentHint';
  static const String feedbackSubmit = 'feedback.form.submit';
  static const String feedbackSubmitting = 'feedback.form.submitting';
  static const String feedbackErrorEmptyContent = 'feedback.error.emptyContent';
  static const String feedbackMailSubject = 'feedback.mail.subject';
  static const String feedbackMailSendDate = 'feedback.mail.sendDate';
  static const String feedbackMailVersion = 'feedback.mail.version';
  static const String feedbackMailType = 'feedback.mail.type';
  static const String feedbackMailTitle = 'feedback.mail.title';
  static const String feedbackMailContact = 'feedback.mail.contact';
  static const String feedbackMailContent = 'feedback.mail.content';
  static const String feedbackEmailOpenError = 'feedback.toast.openEmailError';
  static const String feedbackEmailOpenSuccess =
      'feedback.toast.openEmailSuccess';
  static const String feedbackPrepareError = 'feedback.toast.prepareError';
  static const String authDefaultAdminTitle = 'auth.defaultAdmin.title';
  static const String authDefaultAdminWelcome = 'auth.defaultAdmin.welcome';
  static const String authDefaultAdminDefaultAccount =
      'auth.defaultAdmin.defaultAccount';
  static const String authDefaultAdminUsername = 'auth.defaultAdmin.username';
  static const String authDefaultAdminPassword = 'auth.defaultAdmin.password';
  static const String authDefaultAdminSecurityQuestion =
      'auth.defaultAdmin.securityQuestion';
  static const String authDefaultAdminSecurityAnswer =
      'auth.defaultAdmin.securityAnswer';
  static const String authDefaultAdminInstruction =
      'auth.defaultAdmin.instruction';
  static const String authDefaultAdminUnderstood =
      'auth.defaultAdmin.understood';
  static const String authGuestImportSuccess = 'auth.guest.importSuccess';
  static const String authGuestImportPartial = 'auth.guest.importPartial';
  static const String authGuestName = 'auth.guest.name';
  static const String authRestartTitle = 'auth.restart.title';
  static const String authRestartMessage = 'auth.restart.message';
  static const String guardPermissionDenied = 'guard.permissionDenied';
  static const String guardPermissionCheckFailed =
      'guard.permissionCheckFailed';
  static const String productLotExpired = 'product.lot.expired';
  static const String productLotExpiresToday = 'product.lot.expiresToday';
  static const String productLotRemainingDays = 'product.lot.remainingDays';
  static const String productLotExpiryLabel = 'product.lot.expiryLabel';
  static const String productLotManufactureLabel =
      'product.lot.manufactureLabel';
  static const String notFoundNoData = 'notFound.noData';
  static const String onboardingSlideWelcomeTitle =
      'onBoarding.slide.welcome.title';
  static const String onboardingSlideWelcomeDescription =
      'onBoarding.slide.welcome.description';
  static const String onboardingSlideWelcomeSubtitle =
      'onBoarding.slide.welcome.subtitle';
  static const String onboardingSlideFeaturesTitle =
      'onBoarding.slide.features.title';
  static const String onboardingSlideFeaturesDescription =
      'onBoarding.slide.features.description';
  static const String onboardingSlideFeaturesSubtitle =
      'onBoarding.slide.features.subtitle';
  static const String onboardingSlideDataTitle = 'onBoarding.slide.data.title';
  static const String onboardingSlideDataDescription =
      'onBoarding.slide.data.description';
  static const String onboardingSlideDataSubtitle =
      'onBoarding.slide.data.subtitle';
  static const String checkPermissionLoadFailed = 'check.permissionLoadFailed';
  static const String checkPermissionViewDenied = 'check.permissionViewDenied';
  static const String checkCheckedProductsTitle = 'check.checkedProductsTitle';
  static const String checkCheckedProductsCount = 'check.checkedProductsCount';
  static const String checkCheckedProductsEmpty = 'check.checkedProductsEmpty';
  static const String checkCheckedProductsScanPrompt =
      'check.checkedProductsScanPrompt';
  static const String checkCheckedProductsNoEdit =
      'check.checkedProductsNoEdit';
  static const String checkSearchProduct = 'check.searchProduct';
  static const String checkCompleteSession = 'check.completeSession';
  static const String checkScanError = 'check.scanError';
  static const String checkGenericError = 'check.genericError';
  static const String checkQuantityExpected = 'check.quantityExpected';
  static const String checkQuantityActual = 'check.quantityActual';
  static const String inputEnterQuantity = 'input.enterQuantity';
  static const String searchPlaceholder = 'search.placeholder';
  static const String searchNoResults = 'search.noResults';
  static const String searchAddNew = 'search.addNew';
  static const String userAccessBlockedRegistrationSuccessTitle =
      'userAccessBlocked.registrationSuccessTitle';
  static const String userAccessBlockedBlockedTitle =
      'userAccessBlocked.blockedTitle';
  static const String userAccessBlockedRegistrationDescription =
      'userAccessBlocked.registrationDescription';
  static const String userAccessBlockedBlockedDescription =
      'userAccessBlocked.blockedDescription';
  static const String userAccessBlockedContactAdmin =
      'userAccessBlocked.contactAdmin';
  static const String userAccessBlockedUnderstood =
      'userAccessBlocked.understood';
  static const String orderCreateTitle = 'order.create.title';
  static const String orderCreateSaveDraft = 'order.create.saveDraft';
  static const String orderCreateSubmit = 'order.create.submit';
  static const String orderCreateOrdersListTooltip =
      'order.create.ordersListTooltip';
  static const String orderCreateProductsTitle = 'order.create.productsTitle';
  static const String orderCreateProductsEmpty = 'order.create.productsEmpty';
  static const String orderCreateAddProduct = 'order.create.addProduct';
  static const String orderCreateScanProduct = 'order.create.scanProduct';
  static const String orderCreateScanNotFound = 'order.create.scanNotFound';
  static const String orderCustomerSectionTitle = 'order.customer.sectionTitle';
  static const String orderCustomerName = 'order.customer.name';
  static const String orderCustomerContact = 'order.customer.contact';
  static const String orderCommonNotSet = 'order.common.notSet';
  static const String orderNoteTitle = 'order.note.title';
  static const String orderNotePlaceholder = 'order.note.placeholder';
  static const String orderPaymentTitle = 'order.payment.title';
  static const String orderPaymentTotalQuantity = 'order.payment.totalQuantity';
  static const String orderPaymentTotalAmount = 'order.payment.totalAmount';
  static const String orderProductsAddedSuccess = 'order.products.addedSuccess';
  static const String orderCustomerDialogTitle = 'order.customer.dialogTitle';
  static const String orderCustomerNameLabel = 'order.customer.nameLabel';
  static const String orderCustomerContactLabel = 'order.customer.contactLabel';
  static const String orderCustomerValidation = 'order.customer.validation';
  static const String orderDetailTitle = 'order.detail.title';
  static const String orderDetailInfoSectionTitle =
      'order.detail.infoSectionTitle';
  static const String orderDetailCode = 'order.detail.code';
  static const String orderDetailTotalQuantity = 'order.detail.totalQuantity';
  static const String orderDetailTotalAmount = 'order.detail.totalAmount';
  static const String orderDetailCustomerName = 'order.detail.customerName';
  static const String orderDetailCustomerContact =
      'order.detail.customerContact';
  static const String orderDetailNote = 'order.detail.note';
  static const String orderDetailProductsTitle = 'order.detail.productsTitle';
  static const String orderActionEdit = 'order.action.edit';
  static const String orderActionComplete = 'order.action.complete';
  static const String orderActionCancel = 'order.action.cancel';
  static const String orderWarningQuantityExceedsStock =
      'order.warning.quantityExceedsStock';
  static const String orderLabelInventory = 'order.label.inventory';
  static const String orderLabelPrice = 'order.label.price';
  static const String orderLabelOrderQuantity = 'order.label.orderQuantity';
  static const String orderLabelLineTotal = 'order.label.lineTotal';
  static const String orderCreateSuccess = 'order.toast.createSuccess';
  static const String orderDraftSuccess = 'order.toast.draftSuccess';
  static const String orderDraftError = 'order.toast.draftError';
  static const String orderCompleteSuccess = 'order.toast.completeSuccess';
  static const String orderCancelSuccess = 'order.toast.cancelSuccess';
  static const String orderDeleteSuccess = 'order.toast.deleteSuccess';
  static const String orderActionConfirmTitle = 'order.action.confirmTitle';
  static const String orderActionCancelTitle = 'order.action.cancelTitle';
  static const String orderActionDeleteTitle = 'order.action.deleteTitle';
  static const String orderActionConfirmMessage = 'order.action.confirmMessage';
  static const String orderActionCancelMessage = 'order.action.cancelMessage';
  static const String orderActionDeleteMessage = 'order.action.deleteMessage';
  static const String orderStatusDraft = 'order.status.draft';
  static const String orderStatusConfirmed = 'order.status.confirmed';
  static const String orderStatusDone = 'order.status.done';
  static const String orderStatusCancelled = 'order.status.cancelled';
  static const String orderListTitle = 'order.list.title';
  static const String orderListPermissionDenied = 'order.list.permissionDenied';
  static const String orderListSettingsTooltip = 'order.list.settingsTooltip';
  static const String orderListSettingsTitle = 'order.list.settingsTitle';
  static const String orderListSettingsLoadError =
      'order.list.settingsLoadError';
  static const String orderListToggleConfirmTitle =
      'order.list.toggle.confirmTitle';
  static const String orderListToggleConfirmDescription =
      'order.list.toggle.confirmDescription';
  static const String orderListToggleCancelTitle =
      'order.list.toggle.cancelTitle';
  static const String orderListToggleCancelDescription =
      'order.list.toggle.cancelDescription';
  static const String orderListToggleDeleteTitle =
      'order.list.toggle.deleteTitle';
  static const String orderListToggleDeleteDescription =
      'order.list.toggle.deleteDescription';
  static const String orderListSettingsReset = 'order.list.settingsReset';
  static const String orderListOrderCode = 'order.list.orderCode';
  static const String orderListCustomer = 'order.list.customer';
  static const String orderListContact = 'order.list.contact';
  static const String orderListProductsLabel = 'order.list.productsLabel';
  static const String orderListQuantityLabel = 'order.list.quantityLabel';
  static const String orderListTotalLabel = 'order.list.totalLabel';
  static const String orderListNoteLabel = 'order.list.noteLabel';
  static const String orderListActionComplete = 'order.list.action.complete';
  static const String orderListActionCancel = 'order.list.action.cancel';
  static const String orderListEmptyDraft = 'order.list.empty.draft';
  static const String orderListEmptyConfirmed = 'order.list.empty.confirmed';
  static const String orderListEmptyDone = 'order.list.empty.done';
  static const String orderListEmptyCancelled = 'order.list.empty.cancelled';
  static const String orderListCreateHint = 'order.list.createHint';
  static const String orderListContactAdmin = 'order.list.contactAdmin';
  static const String productCreateSuccess = 'product.create.success';
  static const String productCreateErrorTitle = 'product.create.errorTitle';
  static const String productCreateErrorMessage = 'product.create.errorMessage';
  static const String productCreateErrorFallback =
      'product.create.errorFallback';
  static const String productUpdateSuccess = 'product.update.success';
  static const String productUpdateErrorTitle = 'product.update.errorTitle';
  static const String productUpdateErrorMessage = 'product.update.errorMessage';
  static const String productUpdateErrorFallback =
      'product.update.errorFallback';
  static const String productDetailLoadError = 'product.detail.loadError';
  static const String productDetailBarcodeTitle = 'product.detail.barcodeTitle';
  static const String productDetailBarcodeCopied =
      'product.detail.barcodeCopied';
  static const String productDetailBarcodeCopy = 'product.detail.barcodeCopy';
  static const String productDetailBarcodeSaveInfo =
      'product.detail.barcodeSaveInfo';
  static const String productDetailBarcodeSave = 'product.detail.barcodeSave';
  static const String productDetailBarcodeEmpty = 'product.detail.barcodeEmpty';
  static const String productDetailBarcodeQrTitle =
      'product.detail.barcodeQrTitle';
  static const String productDetailBarcodeQrError =
      'product.detail.barcodeQrError';
  static const String productDetailBackTooltip = 'product.detail.backTooltip';
  static const String productDetailEditTooltip = 'product.detail.editTooltip';
  static const String productDetailShareTooltip = 'product.detail.shareTooltip';
  static const String productDetailPriceLabel = 'product.detail.priceLabel';
  static const String productDetailPriceEmpty = 'product.detail.priceEmpty';
  static const String productDetailPriceError = 'product.detail.priceError';
  static const String productDetailInventoryLabel =
      'product.detail.inventoryLabel';
  static const String productDetailCategoryLabel =
      'product.detail.categoryLabel';
  static const String productDetailUnitLabel = 'product.detail.unitLabel';
  static const String productDetailExpiryTrackingWarning =
      'product.detail.expiryTrackingWarning';
  static const String productDetailDescriptionTitle =
      'product.detail.descriptionTitle';
  static const String productDetailTransactionHistory =
      'product.detail.transactionHistory';
  static const String productDetailTransactionEmpty =
      'product.detail.transactionEmpty';
  static const String productDetailTransactionError =
      'product.detail.transactionError';
  static const String productDetailLotSectionTitle =
      'product.detail.lotSectionTitle';
  static const String productDetailTransactionCategoryCreate =
      'product.detail.transactionCategory.create';
  static const String productDetailTransactionCategoryUpdate =
      'product.detail.transactionCategory.update';
  static const String productDetailTransactionCategoryLotUpdate =
      'product.detail.transactionCategory.lotUpdate';
  static const String productDetailTransactionCategoryStockIn =
      'product.detail.transactionCategory.stockIn';
  static const String productDetailTransactionCategoryStockOut =
      'product.detail.transactionCategory.stockOut';
  static const String productDetailTransactionCategoryCheck =
      'product.detail.transactionCategory.check';
  static const String productDetailTransactionCategoryTransfer =
      'product.detail.transactionCategory.transfer';
  static const String productDetailTransactionCategoryCancelOrder =
      'product.detail.transactionCategory.cancelOrder';
  static const String productDetailTransactionCategoryCreateOrder =
      'product.detail.transactionCategory.createOrder';
  static const String productSortNameAsc = 'product.sort.nameAsc';
  static const String productSortNameDesc = 'product.sort.nameDesc';
  static const String productSortQuantityAsc = 'product.sort.quantityAsc';
  static const String productSortQuantityDesc = 'product.sort.quantityDesc';
  static const String productSortDefault = 'product.sort.default';
  static const String productTimeYesterday = 'product.time.yesterday';
  static const String productTimeToday = 'product.time.today';
  static const String productTimeLast7Days = 'product.time.last7Days';
  static const String productTimeLast30Days = 'product.time.last30Days';
  static const String productTimeLast90Days = 'product.time.last90Days';
  static const String productTimeCustom = 'product.time.custom';
  static const String productTimeNone = 'product.time.none';
  static const String productListTitle = 'product.list.title';
  static const String productListPermissionDenied =
      'product.list.permissionDenied';
  static const String productListSearchHint = 'product.list.searchHint';
  static const String productListSearchTooltip = 'product.list.searchTooltip';
  static const String productListFilterTooltip = 'product.list.filterTooltip';
  static const String productListSortLabel = 'product.list.sortLabel';
  static const String productListCreatedFilter = 'product.list.createdFilter';
  static const String productListUpdatedFilter = 'product.list.updatedFilter';
  static const String productListClearFilters = 'product.list.clearFilters';
  static const String productListLoadedStatus = 'product.list.loadedStatus';
  static const String productListEmpty = 'product.list.empty';
  static const String productFilterTitle = 'product.filter.title';
  static const String productFilterSortSection = 'product.filter.section.sort';
  static const String productFilterTimeSection = 'product.filter.section.time';
  static const String productFilterTimeCreatedTab =
      'product.filter.time.createdTab';
  static const String productFilterTimeUpdatedTab =
      'product.filter.time.updatedTab';
  static const String productFilterTimeSelectPrompt =
      'product.filter.time.selectPrompt';
  static const String productFilterCategorySection =
      'product.filter.section.category';
  static const String productFilterCategoryEmpty =
      'product.filter.category.empty';
  static const String productFilterCategoryAll = 'product.filter.category.all';
  static const String productFilterCategoryError =
      'product.filter.category.error';
  static const String productFilterUnitSection = 'product.filter.section.unit';
  static const String productFilterUnitEmpty = 'product.filter.unit.empty';
  static const String productFilterUnitAll = 'product.filter.unit.all';
  static const String productFilterUnitError = 'product.filter.unit.error';
  static const String productExpirySummaryTitle =
      'product.expiry.summary.title';
  static const String productExpirySummaryExpired =
      'product.expiry.summary.expired';
  static const String productExpirySummaryExpiringSoon =
      'product.expiry.summary.expiringSoon';
  static const String productExpirySummaryDaysHint =
      'product.expiry.summary.daysHint';
  static const String productExpirySummaryActionRequired =
      'product.expiry.summary.actionRequired';
  static const String productExpiryPageTitle = 'product.expiry.page.title';
  static const String productExpirySearchHint =
      'product.expiry.page.searchHint';
  static const String productExpiryTabExpired =
      'product.expiry.page.tab.expired';
  static const String productExpiryTabExpiringSoon =
      'product.expiry.page.tab.expiringSoon';
  static const String productExpiryTabAll = 'product.expiry.page.tab.all';
  static const String productExpiryFilterTracking =
      'product.expiry.page.filter.tracking';
  static const String productExpiryFilterNonTracking =
      'product.expiry.page.filter.nonTracking';
  static const String productExpiryEmptyTracking =
      'product.expiry.page.empty.tracking';
  static const String productExpiryEmptyNonTracking =
      'product.expiry.page.empty.nonTracking';
  static const String productExpiryItemQuantity =
      'product.expiry.page.item.quantity';
  static const String productExpiryItemEarliest =
      'product.expiry.page.item.earliest';
  static const String productExpiryItemNoLot = 'product.expiry.page.item.noLot';
  static const String productExpiryItemNoTracking =
      'product.expiry.page.item.noTracking';
  static const String productExpiryLabelExpired =
      'product.expiry.label.expired';
  static const String productExpiryLabelToday = 'product.expiry.label.today';
  static const String productExpiryLabelDays = 'product.expiry.label.days';

  static const String productFormCreateTitle = 'product.form.createTitle';
  static const String productFormEditTitle = 'product.form.editTitle';
  static const String productFormValidationRequired =
      'product.form.validationRequired';
  static const String productFormPermissionDenied =
      'product.form.permissionDenied';
  static const String productFormFieldNameLabel =
      'product.form.fields.nameLabel';
  static const String productFormFieldNameHint = 'product.form.fields.nameHint';
  static const String productFormFieldQuantityLabel =
      'product.form.fields.quantityLabel';
  static const String productFormFieldExpiryLabel =
      'product.form.fields.expiryLabel';
  static const String productFormFieldSkuLabel = 'product.form.fields.skuLabel';
  static const String productFormFieldCategoryLabel =
      'product.form.fields.categoryLabel';
  static const String productFormFieldUnitLabel =
      'product.form.fields.unitLabel';
  static const String productFormFieldImagesLabel =
      'product.form.fields.imagesLabel';
  static const String productFormFieldImagesAdd =
      'product.form.fields.imagesAdd';
  static const String productFormFieldNoteLabel =
      'product.form.fields.noteLabel';
  static const String productFormFieldNoteHint = 'product.form.fields.noteHint';
  static const String productFormExpiryTrackingLabel =
      'product.form.expiry.trackingLabel';
  static const String productFormExpiryTrackingDescription =
      'product.form.expiry.trackingDescription';
  static const String productFormInventoryTotalLots =
      'product.form.inventory.totalLots';
  static const String productFormInventoryEmpty =
      'product.form.inventory.empty';
  static const String productFormInventoryLotTitle =
      'product.form.inventory.lotTitle';
  static const String productFormInventoryRemoveLot =
      'product.form.inventory.removeLot';
  static const String productFormInventoryQuantityLabel =
      'product.form.inventory.quantityLabel';
  static const String productFormInventoryExpiryLabel =
      'product.form.inventory.expiryLabel';
  static const String productFormInventoryManufactureLabel =
      'product.form.inventory.manufactureLabel';
  static const String productFormInventoryChooseDate =
      'product.form.inventory.chooseDate';
  static const String productFormInventoryAddLot =
      'product.form.inventory.addLot';
  static const String productFormValidationNoLot =
      'product.form.validation.noLot';
  static const String productFormValidationMissingExpiry =
      'product.form.validation.missingExpiry';
  static const String productFormValidationLotQuantity =
      'product.form.validation.lotQuantity';
  static const String productFormValidationManufactureAfterExpiry =
      'product.form.validation.manufactureAfterExpiry';
  static const String productFormValidationDuplicateLot =
      'product.form.validation.duplicateLot';
  static const String productFormSkuPlaceholderTitle =
      'product.form.sku.placeholderTitle';
  static const String productFormSkuInputHint = 'product.form.sku.inputHint';
  static const String productFormSkuScanBarcode =
      'product.form.sku.scanBarcode';
  static const String productFormSkuScanAction = 'product.form.sku.scanAction';
  static const String productFormSkuRandom = 'product.form.sku.random';
  static const String productFormSkuQrPlaceholder =
      'product.form.sku.qrPlaceholder';
  static const String productFormSkuQrError = 'product.form.sku.qrError';
  static const String productFormSkuDownloadError =
      'product.form.sku.downloadError';
  static const String productFormSkuDownloadSuccess =
      'product.form.sku.downloadSuccess';
  static const String productFormSkuDownloadButton =
      'product.form.sku.downloadButton';
  static const String productFormMediaSelectImageTitle =
      'product.form.media.selectImageTitle';
  static const String productFormAddCategory = 'product.form.addCategory';
  static const String productFormAddUnit = 'product.form.addUnit';
  static const String configPriceListTitle = 'configPrice.list.title';
  static const String configPriceListSearchHint = 'configPrice.list.searchHint';
  static const String configPriceListSearchTooltip =
      'configPrice.list.searchTooltip';
  static const String configPriceListLoadedStatus =
      'configPrice.list.loadedStatus';
  static const String configPriceListCostLabel = 'configPrice.list.costLabel';
  static const String configPriceListSellingLabel =
      'configPrice.list.sellingLabel';
  static const String configPriceListNotSet = 'configPrice.list.notSet';
  static const String configPriceListProfitLabel =
      'configPrice.list.profitLabel';
  static const String configPriceFormSellingPreview =
      'configPrice.form.sellingPreview';
  static const String configPriceFormPurchasePreview =
      'configPrice.form.purchasePreview';
  static const String configPriceFormSellingLabel =
      'configPrice.form.sellingLabel';
  static const String configPriceFormPurchaseLabel =
      'configPrice.form.purchaseLabel';
  static const String configPriceFormSaving = 'configPrice.form.saving';
  static const String reportPageTitle = 'report.page.title';
  static const String reportTabOverview = 'report.page.tab.overview';
  static const String reportTabOrders = 'report.page.tab.orders';
  static const String reportTabInventory = 'report.page.tab.inventory';
  static const String reportSummaryRevenue = 'report.summary.revenue';
  static const String reportSummaryTotalOrders = 'report.summary.totalOrders';
  static const String reportSummaryProductsSold = 'report.summary.productsSold';
  static const String reportSummaryQuantitySold = 'report.summary.quantitySold';
  static const String reportChartRevenueByDay = 'report.chart.revenueByDay';
  static const String reportChartRevenueByCategory =
      'report.chart.revenueByCategory';
  static const String reportChartTopSellingProducts =
      'report.chart.topSellingProducts';
  static const String dataManagementImportTitle = 'dataManagement.import.title';
  static const String dataManagementImportFormatsTitle =
      'dataManagement.import.formatsTitle';
  static const String dataManagementImportFormatJsonl =
      'dataManagement.import.formatJsonl';
  static const String dataManagementImportFormatCsv =
      'dataManagement.import.formatCsv';
  static const String dataManagementImportFormatXlsx =
      'dataManagement.import.formatXlsx';
  static const String dataManagementImportFormatNote =
      'dataManagement.import.formatNote';
  static const String dataManagementImportButtonSelect =
      'dataManagement.import.buttonSelect';
  static const String dataManagementImportResultSuccess =
      'dataManagement.import.resultSuccess';
  static const String dataManagementImportResultInvalid =
      'dataManagement.import.resultInvalid';
  static const String dataManagementImportResultUnsupported =
      'dataManagement.import.resultUnsupported';
  static const String dataManagementImportNote = 'dataManagement.import.note';
  static const String dataManagementExportTitle = 'dataManagement.export.title';
  static const String dataManagementExportInfoTitle =
      'dataManagement.export.infoTitle';
  static const String dataManagementExportInfoDescription =
      'dataManagement.export.infoDescription';
  static const String dataManagementExportInfoJsonl =
      'dataManagement.export.infoJsonl';
  static const String dataManagementExportInfoCsv =
      'dataManagement.export.infoCsv';
  static const String dataManagementExportInfoBackup =
      'dataManagement.export.infoBackup';
  static const String dataManagementExportInfoTip =
      'dataManagement.export.infoTip';
  static const String dataManagementExportInfoStorageTitle =
      'dataManagement.export.infoStorageTitle';
  static const String dataManagementExportInfoStoragePathAndroid =
      'dataManagement.export.infoStoragePathAndroid';
  static const String dataManagementExportInfoStoragePathIos =
      'dataManagement.export.infoStoragePathIos';
  static const String dataManagementExportProductsTitle =
      'dataManagement.export.products.title';
  static const String dataManagementExportProductsDescription =
      'dataManagement.export.products.description';
  static const String dataManagementExportCategoriesTitle =
      'dataManagement.export.categories.title';
  static const String dataManagementExportCategoriesDescription =
      'dataManagement.export.categories.description';
  static const String dataManagementExportUnitsTitle =
      'dataManagement.export.units.title';
  static const String dataManagementExportUnitsDescription =
      'dataManagement.export.units.description';
  static const String dataManagementExportOrdersTitle =
      'dataManagement.export.orders.title';
  static const String dataManagementExportOrdersDescription =
      'dataManagement.export.orders.description';
  static const String dataManagementExportBackupTitle =
      'dataManagement.export.backup.title';
  static const String dataManagementExportBackupDescription =
      'dataManagement.export.backup.description';
  static const String dataManagementExportBackupButton =
      'dataManagement.export.backup.button';
  static const String dataManagementDeleteTitle = 'dataManagement.delete.title';
  static const String dataManagementDeleteWarningTitle =
      'dataManagement.delete.warningTitle';
  static const String dataManagementDeleteWarningDescription =
      'dataManagement.delete.warningDescription';
  static const String dataManagementDeleteWarningBackup =
      'dataManagement.delete.warningBackup';
  static const String dataManagementDeleteWarningIrreversible =
      'dataManagement.delete.warningIrreversible';
  static const String dataManagementDeleteWarningDuration =
      'dataManagement.delete.warningDuration';
  static const String dataManagementDeleteLevelLow =
      'dataManagement.delete.level.low';
  static const String dataManagementDeleteLevelMedium =
      'dataManagement.delete.level.medium';
  static const String dataManagementDeleteLevelHigh =
      'dataManagement.delete.level.high';
  static const String dataManagementDeleteLevelLabel =
      'dataManagement.delete.level.label';
  static const String dataManagementDeleteProductsTitle =
      'dataManagement.delete.products.title';
  static const String dataManagementDeleteProductsDescription =
      'dataManagement.delete.products.description';
  static const String dataManagementDeleteCategoriesTitle =
      'dataManagement.delete.categories.title';
  static const String dataManagementDeleteCategoriesDescription =
      'dataManagement.delete.categories.description';
  static const String dataManagementDeleteUnitsTitle =
      'dataManagement.delete.units.title';
  static const String dataManagementDeleteUnitsDescription =
      'dataManagement.delete.units.description';
  static const String dataManagementDeleteOrdersTitle =
      'dataManagement.delete.orders.title';
  static const String dataManagementDeleteOrdersDescription =
      'dataManagement.delete.orders.description';
  static const String dataManagementDeleteStocktakeTitle =
      'dataManagement.delete.stocktake.title';
  static const String dataManagementDeleteStocktakeDescription =
      'dataManagement.delete.stocktake.description';
  static const String dataManagementDeleteTransactionsTitle =
      'dataManagement.delete.transactions.title';
  static const String dataManagementDeleteTransactionsDescription =
      'dataManagement.delete.transactions.description';
  static const String dataManagementDeleteAllTitle =
      'dataManagement.delete.all.title';
  static const String dataManagementDeleteAllDescription =
      'dataManagement.delete.all.description';
  static const String dataManagementDeleteAllButton =
      'dataManagement.delete.all.button';
  static const String dataManagementDeleteActionButton =
      'dataManagement.delete.actionButton';
  static const String dataManagementSampleTitle = 'dataManagement.sample.title';
  static const String dataManagementSampleTestTooltip =
      'dataManagement.sample.testTooltip';
  static const String dataManagementSampleChooseTitle =
      'dataManagement.sample.chooseTitle';
  static const String dataManagementSampleChooseDescription =
      'dataManagement.sample.chooseDescription';
  static const String dataManagementProductSelectionErrorNone =
      'dataManagement.productSelection.errorNone';
  static const String dataManagementProductSelectionLoadingErrorTitle =
      'dataManagement.productSelection.loadingErrorTitle';
  static const String dataManagementProductSelectionRetry =
      'dataManagement.productSelection.retry';
  static const String dataManagementProductSelectionStatsProducts =
      'dataManagement.productSelection.statsProducts';
  static const String dataManagementProductSelectionStatsSelected =
      'dataManagement.productSelection.statsSelected';
  static const String dataManagementProductSelectionStatsQuantity =
      'dataManagement.productSelection.statsQuantity';
  static const String dataManagementProductSelectionTooltipSelectAll =
      'dataManagement.productSelection.tooltipSelectAll';
  static const String dataManagementProductSelectionTooltipDeselectAll =
      'dataManagement.productSelection.tooltipDeselectAll';
  static const String dataManagementProductSelectionButtonEmpty =
      'dataManagement.productSelection.buttonEmpty';
  static const String dataManagementProductSelectionButtonSelected =
      'dataManagement.productSelection.buttonSelected';
  static const String dataManagementImportTestTitle =
      'dataManagement.test.title';
  static const String dataManagementImportTestSectionTitle =
      'dataManagement.test.sectionTitle';
  static const String dataManagementImportTestSectionDescription =
      'dataManagement.test.sectionDescription';
  static const String dataManagementImportTestSuccessFull =
      'dataManagement.test.successFull';
  static const String dataManagementImportTestSuccessFullDescription =
      'dataManagement.test.successFullDescription';
  static const String dataManagementImportTestPartial =
      'dataManagement.test.partial';
  static const String dataManagementImportTestPartialDescription =
      'dataManagement.test.partialDescription';
  static const String dataManagementImportTestFailed =
      'dataManagement.test.failed';
  static const String dataManagementImportTestFailedDescription =
      'dataManagement.test.failedDescription';
  static const String dataManagementImportTestValidationSuccess =
      'dataManagement.test.validationSuccess';
  static const String dataManagementImportTestValidationSuccessDescription =
      'dataManagement.test.validationSuccessDescription';
  static const String dataManagementImportTestValidationWarning =
      'dataManagement.test.validationWarning';
  static const String dataManagementImportTestValidationWarningDescription =
      'dataManagement.test.validationWarningDescription';
  static const String dataManagementImportTestValidationError =
      'dataManagement.test.validationError';
  static const String dataManagementImportTestValidationErrorDescription =
      'dataManagement.test.validationErrorDescription';
  static const String dataManagementImportTestFlow = 'dataManagement.test.flow';
  static const String dataManagementImportTestFlowDescription =
      'dataManagement.test.flowDescription';
  static const String dataManagementImportTestDeleteTitle =
      'dataManagement.test.deleteTitle';
  static const String dataManagementImportTestDeleteDescription =
      'dataManagement.test.deleteDescription';
  static const String dataManagementImportTestDeleteNavigation =
      'dataManagement.test.deleteNavigation';
  static const String dataManagementImportTestDeleteNavigationDescription =
      'dataManagement.test.deleteNavigationDescription';
  static const String dataManagementImportValidationTitle =
      'dataManagement.validation.title';
  static const String dataManagementImportValidationStatusSuccess =
      'dataManagement.validation.statusSuccess';
  static const String dataManagementImportValidationStatusWarning =
      'dataManagement.validation.statusWarning';
  static const String dataManagementImportValidationStatusError =
      'dataManagement.validation.statusError';
  static const String dataManagementImportValidationSummaryTitle =
      'dataManagement.validation.summaryTitle';
  static const String dataManagementImportValidationSummaryTotal =
      'dataManagement.validation.summaryTotal';
  static const String dataManagementImportValidationSummaryValid =
      'dataManagement.validation.summaryValid';
  static const String dataManagementImportValidationSummaryWarnings =
      'dataManagement.validation.summaryWarnings';
  static const String dataManagementImportValidationSummaryErrors =
      'dataManagement.validation.summaryErrors';
  static const String dataManagementImportValidationErrorsTitle =
      'dataManagement.validation.errorsTitle';
  static const String dataManagementImportValidationWarningsTitle =
      'dataManagement.validation.warningsTitle';
  static const String dataManagementImportValidationCancel =
      'dataManagement.validation.cancel';
  static const String dataManagementImportValidationProceed =
      'dataManagement.validation.proceed';
  static const String dataManagementImportValidationHasErrors =
      'dataManagement.validation.hasErrors';
  static const String dataManagementImportResultTitle =
      'dataManagement.importResult.title';
  static const String dataManagementImportResultSummaryTitle =
      'dataManagement.importResult.summaryTitle';
  static const String dataManagementImportResultSummaryTotal =
      'dataManagement.importResult.summaryTotal';
  static const String dataManagementImportResultSummarySuccess =
      'dataManagement.importResult.summarySuccess';
  static const String dataManagementImportResultSummaryFailed =
      'dataManagement.importResult.summaryFailed';
  static const String dataManagementImportResultSummaryDuration =
      'dataManagement.importResult.summaryDuration';
  static const String dataManagementImportResultErrorsTitle =
      'dataManagement.importResult.errorsTitle';
  static const String dataManagementImportResultWarningsTitle =
      'dataManagement.importResult.warningsTitle';
  static const String dataManagementImportResultClose =
      'dataManagement.importResult.close';
  static const String dataManagementImportResultRetry =
      'dataManagement.importResult.retry';
  static const String categoryPageTitle = 'category.page.title';
  static const String categoryPagePermissionDenied =
      'category.page.permissionDenied';
  static const String categoryPageEmpty = 'category.page.empty';
  static const String categoryFormNameLabel = 'category.form.nameLabel';
  static const String categoryFormNameHint = 'category.form.nameHint';
  static const String categoryFormDescriptionLabel =
      'category.form.descriptionLabel';
  static const String categoryFormDescriptionHint =
      'category.form.descriptionHint';
  static const String categoryFormNameRequired = 'category.form.nameRequired';
  static const String categoryFormUpdateError = 'category.form.updateError';
  static const String categoryCreateSuccess = 'category.toast.createSuccess';
  static const String categoryCreateError = 'category.toast.createError';
  static const String categoryUpdateSuccess = 'category.toast.updateSuccess';
  static const String categoryUpdateError = 'category.toast.updateError';
  static const String categoryDeleteSuccess = 'category.toast.deleteSuccess';
  static const String categoryDeleteError = 'category.toast.deleteError';
  static const String categoryBulkDeleteSuccess =
      'category.toast.bulkDeleteSuccess';
  static const String categoryBulkDeleteError =
      'category.toast.bulkDeleteError';
  static const String categoryNoSelection = 'category.toast.noSelection';
  static const String unitPageTitle = 'unit.page.title';
  static const String unitPagePermissionDenied = 'unit.page.permissionDenied';
  static const String unitPageEmpty = 'unit.page.empty';
  static const String unitFormNameLabel = 'unit.form.nameLabel';
  static const String unitFormNameHint = 'unit.form.nameHint';
  static const String unitFormDescriptionLabel = 'unit.form.descriptionLabel';
  static const String unitFormDescriptionHint = 'unit.form.descriptionHint';
  static const String unitFormNameRequired = 'unit.form.nameRequired';
  static const String unitFormUpdateError = 'unit.form.updateError';
  static const String unitCreateSuccess = 'unit.toast.createSuccess';
  static const String unitCreateError = 'unit.toast.createError';
  static const String unitUpdateSuccess = 'unit.toast.updateSuccess';
  static const String unitUpdateError = 'unit.toast.updateError';
  static const String unitDeleteSuccess = 'unit.toast.deleteSuccess';
  static const String unitDeleteError = 'unit.toast.deleteError';
  static const String unitNoSelection = 'unit.toast.noSelection';
  static const String unitFetchError = 'unit.toast.fetchError';
  static const String checkStatusMatch = 'check.status.match';
  static const String checkStatusSurplus = 'check.status.surplus';
  static const String checkStatusShortage = 'check.status.shortage';
  static const String checkStatusUnknown = 'check.status.unknown';
  static const String checkProductAddSuccess = 'check.product.addSuccess';
  static const String checkProductUpdateSuccess = 'check.product.updateSuccess';
  static const String checkSessionUpdateSuccess = 'check.session.updateSuccess';
  static const String checkSessionUpdateError = 'check.session.updateError';
  static const String checkSessionDeleteSuccess = 'check.session.deleteSuccess';
  static const String checkSessionDeleteError = 'check.session.deleteError';
  static const String checkSessionPageTitle = 'check.sessionList.title';
  static const String checkSessionPermissionDenied =
      'check.sessionList.permissionDenied';
  static const String checkSessionTabActive = 'check.sessionList.tab.active';
  static const String checkSessionTabCompleted =
      'check.sessionList.tab.completed';
  static const String checkSessionCreatedByLabel =
      'check.sessionList.createdBy';
  static const String checkSessionDateLabel = 'check.sessionList.date';
  static const String checkSessionDeleteConfirmTitle =
      'check.sessionList.deleteConfirmTitle';
  static const String checkSessionDeleteConfirmMessage =
      'check.sessionList.deleteConfirmMessage';
  static const String checkSessionEmptyActive = 'check.sessionList.emptyActive';
  static const String checkSessionEmptyCompleted =
      'check.sessionList.emptyCompleted';
  static const String checkSessionCreateError = 'check.sessionList.createError';
  static const String checkSessionCreateTitle = 'check.sessionCreate.title';
  static const String checkSessionCreateDefaultName =
      'check.sessionCreate.defaultName';
  static const String checkSessionCreateNameLabel =
      'check.sessionCreate.nameLabel';
  static const String checkSessionCreateNameHint =
      'check.sessionCreate.nameHint';
  static const String checkSessionCreateCreatedByLabel =
      'check.sessionCreate.createdByLabel';
  static const String checkSessionCreateCreatedByHint =
      'check.sessionCreate.createdByHint';
  static const String checkSessionCreateNoteLabel =
      'check.sessionCreate.noteLabel';
  static const String checkSessionCreateNoteHint =
      'check.sessionCreate.noteHint';
  static const String checkSessionCreateSubmit = 'check.sessionCreate.submit';
  static const String checkSessionCreateValidationRequired =
      'check.sessionCreate.validationRequired';
  static const String checkSessionCreateDefaultCreator =
      'check.sessionCreate.defaultCreator';
  static const String checkSessionDetailTitle = 'check.sessionDetail.title';
  static const String checkSessionDetailName = 'check.sessionDetail.name';
  static const String checkSessionDetailCreatedBy =
      'check.sessionDetail.createdBy';
  static const String checkSessionDetailCreatedAt =
      'check.sessionDetail.createdAt';
  static const String checkSessionDetailStatus = 'check.sessionDetail.status';
  static const String checkSessionDetailNote = 'check.sessionDetail.note';
  static const String checkSessionStatusInProgress =
      'check.sessionStatus.inProgress';
  static const String checkSessionStatusCompleted =
      'check.sessionStatus.completed';
  static const String checkInventorySystemQuantityLabel =
      'check.inventory.systemQuantityLabel';
  static const String checkInventoryCountQuantity =
      'check.inventory.countQuantity';
  static const String checkInventoryNoteLabel = 'check.inventory.noteLabel';
  static const String checkInventoryNoteHint = 'check.inventory.noteHint';
  static const String checkInventoryLotsEmpty = 'check.inventory.lotsEmpty';
  static const String checkInventoryLotTitle = 'check.inventory.lotTitle';
  static const String checkInventoryLotSystemTag =
      'check.inventory.lotSystemTag';
  static const String checkInventoryLotRemoveTooltip =
      'check.inventory.lotRemoveTooltip';
  static const String checkInventoryLotExpected = 'check.inventory.lotExpected';
  static const String checkInventoryLotExpiry = 'check.inventory.lotExpiry';
  static const String checkInventoryLotActualLabel =
      'check.inventory.lotActualLabel';
  static const String checkInventoryLotExpiryLabel =
      'check.inventory.lotExpiryLabel';
  static const String checkInventoryLotManufactureLabel =
      'check.inventory.lotManufactureLabel';
  static const String checkInventoryLotAddButton =
      'check.inventory.lotAddButton';
  static const String checkInventoryLotSummaryTitle =
      'check.inventory.lotSummaryTitle';
  static const String checkInventoryValidationNoLot =
      'check.inventory.validation.noLot';
  static const String checkInventoryValidationNegative =
      'check.inventory.validation.negative';
  static const String checkInventoryValidationDuplicate =
      'check.inventory.validation.duplicate';
  static const String userManagementTitle = 'user.management.title';
  static const String userManagementRefreshTooltip = 'user.management.refresh';
  static const String userManagementStatsTotal = 'user.management.stats.total';
  static const String userManagementStatsActiveLocked =
      'user.management.stats.activeLocked';
  static const String userManagementEmptyTitle = 'user.management.empty.title';
  static const String userManagementEmptyDescription =
      'user.management.empty.description';
  static const String userManagementEmptyHint = 'user.management.empty.hint';
  static const String userManagementEmptyCta = 'user.management.empty.cta';
  static const String userManagementStatusActive =
      'user.management.status.active';
  static const String userManagementStatusLocked =
      'user.management.status.locked';
  static const String userManagementInfoId = 'user.management.info.id';
  static const String userManagementInfoLastLogin =
      'user.management.info.lastLogin';
  static const String userManagementInfoCreatedAt =
      'user.management.info.createdAt';
  static const String userManagementActionLock = 'user.management.actions.lock';
  static const String userManagementActionActivate =
      'user.management.actions.activate';
  static const String userManagementActionPermissions =
      'user.management.actions.permissions';
  static const String userManagementDialogActivateTitle =
      'user.management.dialog.activateTitle';
  static const String userManagementDialogLockTitle =
      'user.management.dialog.lockTitle';
  static const String userManagementDialogActivateMessage =
      'user.management.dialog.activateMessage';
  static const String userManagementDialogLockMessage =
      'user.management.dialog.lockMessage';
  static const String userManagementDialogConfirmActivate =
      'user.management.dialog.confirmActivate';
  static const String userManagementDialogConfirmLock =
      'user.management.dialog.confirmLock';
  static const String userManagementErrorLoad = 'user.management.error.load';
  static const String configPriceInvalidNumber =
      'configPrice.error.invalidNumber';
  static const String configPriceSaveError = 'configPrice.error.saveFailed';
  static const String userActivateSuccess = 'user.toast.activateSuccess';
  static const String userDeactivateSuccess = 'user.toast.deactivateSuccess';
  static const String userToggleActionActivate = 'user.toast.actionActivate';
  static const String userToggleActionDeactivate =
      'user.toast.actionDeactivate';
  static const String userToggleError = 'user.toast.toggleError';
  static const String accountPaymentMethod = 'account.paymentMethod';
  static const String accountCurrency = 'account.currency.label';
  static const String accountCurrencyVnd = 'account.currency.vnd';
  static const String accountCurrencyUsd = 'account.currency.usd';
  static const String accountMyVouchers = 'account.myVouchers';
  static const String accountEmergencyNumber = 'account.emergencyNumber';
  static const String accountEmergencyContact = 'account.emergencyContact';
  static const String accountEmergencyNumberDescription =
      'account.emergencyDescription';
  static const String accountSupportFaqs = 'account.supportFaqs';
  static const String accountLogOut = 'account.logOut';
  static const String accountDeactivate = 'account.deactivate';
  static const String accountDeactivateConfirmMessage =
      'account.deactivateConfirmMessage';
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
  static const String accountRequestLoginDescription =
      'account.requestLoginDescription';
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
  static const String messageProfileUpdateSuccess =
      'message.profileUpdateSuccess';
  static const String messageEmergencyNumberUpdateSuccess =
      'message.emergencyNumberUpdateSuccess';
  static const String messageUpdatePasswordSuccess =
      'message.updatePasswordSuccess';
  static const String messageNeedToVerify = 'message.needToVerifyAccount';
  static const String messageRequiredSelectLocationArea =
      'message.requiredSelectLocationArea';
  static const String messageRequiredSelectPickupLocation =
      'message.requiredSelectPickupLocation';
  static const String messageRequiredSelectArrivedLocation =
      'message.requiredSelectArrivedLocation';
  static const String messageRequiredSelectTargetLocation =
      'message.requiredSelectTargetLocation';
  static const String messageRequiredSelectStartTime =
      'message.requiredSelectStartTime';
  static const String messageRequiredSelectEndTime =
      'message.requiredSelectEndTime';
  static const String messageEndDateNeedToBeAfterStartDate =
      'message.endDateNeedToBeAfterStartDate';
  static const String messageRequiredSelectAgentType =
      'message.requiredSelectAgentType';
  static const String messageRequiredSetRequestedSecurityOrCarTotal =
      'message.requiredSetRequestedSecurityOrCarTotal';
  static const String messageRequiredSetRequestedSecurityTotal =
      'message.requiredSetRequestedSecurityTotal';
  static const String messageRequiredPermissionFailed =
      'message.requiredPermissionFailed';
  static const String messageEmptyData = 'message.emptyData';
  static const String messageWithdrawSuccessfully =
      'message.withdrawSuccessfully';
  static const String messageCustomerLocationNotFound =
      'message.customerLocationNotFound';

  // Notifications
  static const String noNotificationFound = 'notification.noNotificationFound';

  //Dialog
  static const String dialogRequestLocationPermission =
      'dialog.requestLocationPermission';
  static const String dialogRequestLocationPermissionDescription =
      'dialog.requestLocationPermissionDescription';
  static const String dialogRequestLocationService =
      'dialog.requestLocationService';
  static const String dialogRequestLocationServiceDescription =
      'dialog.requestLocationServiceDescription';
  static const String dialogSettings = 'dialog.settings';
  static const String dialogOpenSettingsDescription =
      'dialog.openSettingsDescription';
  static const String dialogRequiredLocation = 'dialog.requiredLocation';
  static const String dialogRequiredLocationDescription =
      'dialog.requiredLocationDescription';
  static const String dialogRequiredUpdateApp = 'dialog.requiredUpdateApp';
  static const String dialogRequestPhotoPermission =
      'dialog.requestPhotoPermission';
  static const String dialogRequestPhotoPermissionDescription =
      'dialog.requestPhotoPermissionDescription';

  //Search Location
  static const String searchLocationRecent = 'searchLocation.recent';
  static const String searchLocationSearchResult =
      'searchLocation.searchResult';
  static const String searchLocationChooseFromMap =
      'searchLocation.chooseFromMap';

  //Chat
  static const String chatJoinChat = 'chat.joinChat';
  static const String chatTypeAMessage = 'chat.typeAMessage';
  static const String setting = 'setting.title';
  static const String settingTheme = 'setting.theme';
  static const String settingDarkMode = 'setting.darkMode';
  static const String settingLightMode = 'setting.lightMode';
  static const String settingSystemDefault = 'setting.systemDefault';
  static const String settingLanguage = 'setting.language';
  static const String settingChangePassword = 'setting.changePassword';
  static const String settingLogout = 'setting.logout';
  static const String settingAccount = 'setting.account';
}
