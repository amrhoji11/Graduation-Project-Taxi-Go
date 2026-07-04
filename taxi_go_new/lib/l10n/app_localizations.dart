import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TaxiGo'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to sign in with a one-time code.'**
  String get loginSubtitle;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'599123456'**
  String get loginPhoneHint;

  /// No description provided for @loginSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginSendOtp;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get loginNoAccount;

  /// No description provided for @loginEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get loginEnterPhone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get settingsChangePhone;

  /// No description provided for @settingsContactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Contact TaxiGo (WhatsApp)'**
  String get settingsContactWhatsapp;

  /// No description provided for @settingsCallSupport.
  ///
  /// In en, this message translates to:
  /// **'Call TaxiGo support'**
  String get settingsCallSupport;

  /// No description provided for @settingsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get settingsNotAvailable;

  /// No description provided for @settingsNoneLoaded.
  ///
  /// In en, this message translates to:
  /// **'No settings loaded yet'**
  String get settingsNoneLoaded;

  /// No description provided for @settingsLoadAction.
  ///
  /// In en, this message translates to:
  /// **'Load Settings'**
  String get settingsLoadAction;

  /// No description provided for @settingsCouldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get settingsCouldNotOpenWhatsapp;

  /// No description provided for @settingsCouldNotCall.
  ///
  /// In en, this message translates to:
  /// **'Could not start call'**
  String get settingsCouldNotCall;

  /// No description provided for @settingsNewPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'New phone number'**
  String get settingsNewPhoneNumber;

  /// No description provided for @settingsOtpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP code'**
  String get settingsOtpCode;

  /// No description provided for @settingsSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get settingsSendCode;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get commonPhone;

  /// No description provided for @commonAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get commonAddress;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get commonLatitude;

  /// No description provided for @commonLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get commonLongitude;

  /// No description provided for @commonReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get commonReason;

  /// No description provided for @commonReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get commonReasonOptional;

  /// No description provided for @commonDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get commonInactive;

  /// No description provided for @commonBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get commonBlocked;

  /// No description provided for @commonAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get commonAssign;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get commonEditProfile;

  /// No description provided for @commonDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get commonDriver;

  /// No description provided for @commonPassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get commonPassenger;

  /// No description provided for @commonVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get commonVehicle;

  /// No description provided for @commonTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get commonTrips;

  /// No description provided for @commonRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get commonRating;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonFailedToLoadDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load details'**
  String get commonFailedToLoadDetails;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authIAmA.
  ///
  /// In en, this message translates to:
  /// **'I am a'**
  String get authIAmA;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// No description provided for @authAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get authAddressOptional;

  /// No description provided for @authNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'First and last name must be at least 3 characters'**
  String get authNameTooShort;

  /// No description provided for @authConfirmRegistration.
  ///
  /// In en, this message translates to:
  /// **'Confirm registration'**
  String get authConfirmRegistration;

  /// No description provided for @authEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get authEnterVerificationCode;

  /// No description provided for @authCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to'**
  String get authCodeSentTo;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get authEnterOtp;

  /// No description provided for @authVerifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get authVerifyOtpTitle;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get commonPickup;

  /// No description provided for @commonDropoff.
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get commonDropoff;

  /// No description provided for @commonTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get commonTrip;

  /// No description provided for @commonPassengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get commonPassengers;

  /// No description provided for @commonMyTripsReport.
  ///
  /// In en, this message translates to:
  /// **'My Trips Report'**
  String get commonMyTripsReport;

  /// No description provided for @commonCompletedTripsSummary.
  ///
  /// In en, this message translates to:
  /// **'Completed trips summary'**
  String get commonCompletedTripsSummary;

  /// No description provided for @commonProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get commonProfileUpdated;

  /// No description provided for @commonFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get commonFailedToLoad;

  /// No description provided for @passengerHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Passenger Home'**
  String get passengerHomeTitle;

  /// No description provided for @passengerActiveTrip.
  ///
  /// In en, this message translates to:
  /// **'Active trip'**
  String get passengerActiveTrip;

  /// No description provided for @passengerWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get passengerWhatToDo;

  /// No description provided for @passengerBookRide.
  ///
  /// In en, this message translates to:
  /// **'Book Ride'**
  String get passengerBookRide;

  /// No description provided for @passengerBookRideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new taxi order'**
  String get passengerBookRideSubtitle;

  /// No description provided for @passengerMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get passengerMyOrders;

  /// No description provided for @passengerMyOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your ride history'**
  String get passengerMyOrdersSubtitle;

  /// No description provided for @passengerOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get passengerOrdersEmptyTitle;

  /// No description provided for @passengerOrdersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your ride history will show up here.'**
  String get passengerOrdersEmptySubtitle;

  /// No description provided for @passengerOrdersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load orders'**
  String get passengerOrdersLoadError;

  /// No description provided for @passengerMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get passengerMyProfile;

  /// No description provided for @createOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get createOrderTitle;

  /// No description provided for @createOrderPickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Pickup address'**
  String get createOrderPickupAddress;

  /// No description provided for @createOrderInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get createOrderInvalidNumber;

  /// No description provided for @createOrderPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get createOrderPickOnMap;

  /// No description provided for @createOrderUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get createOrderUseCurrentLocation;

  /// No description provided for @createOrderSpecifyDropoffNow.
  ///
  /// In en, this message translates to:
  /// **'Specify dropoff now'**
  String get createOrderSpecifyDropoffNow;

  /// No description provided for @createOrderDropoffOptionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional - can be set later'**
  String get createOrderDropoffOptionalSubtitle;

  /// No description provided for @createOrderDropoffAddress.
  ///
  /// In en, this message translates to:
  /// **'Dropoff address'**
  String get createOrderDropoffAddress;

  /// No description provided for @createOrderScheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get createOrderScheduleForLater;

  /// No description provided for @createOrderScheduleOff.
  ///
  /// In en, this message translates to:
  /// **'Off - ride starts now'**
  String get createOrderScheduleOff;

  /// No description provided for @createOrderPickupAt.
  ///
  /// In en, this message translates to:
  /// **'Pickup at'**
  String get createOrderPickupAt;

  /// No description provided for @createOrderPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get createOrderPickDateTime;

  /// No description provided for @createOrderChangeDateTime.
  ///
  /// In en, this message translates to:
  /// **'Change date & time'**
  String get createOrderChangeDateTime;

  /// No description provided for @createOrderTripPreferences.
  ///
  /// In en, this message translates to:
  /// **'Trip preferences'**
  String get createOrderTripPreferences;

  /// No description provided for @createOrderPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get createOrderPriority;

  /// No description provided for @createOrderNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get createOrderNormal;

  /// No description provided for @createOrderUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get createOrderUrgent;

  /// No description provided for @createOrderVehicleSizeOptional.
  ///
  /// In en, this message translates to:
  /// **'Vehicle size (optional)'**
  String get createOrderVehicleSizeOptional;

  /// No description provided for @createOrderAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get createOrderAny;

  /// No description provided for @createOrderPickScheduleSnack.
  ///
  /// In en, this message translates to:
  /// **'Please pick a date and time for the ride'**
  String get createOrderPickScheduleSnack;

  /// No description provided for @createOrderScheduledPastSnack.
  ///
  /// In en, this message translates to:
  /// **'Scheduled time cannot be in the past'**
  String get createOrderScheduledPastSnack;

  /// No description provided for @createOrderSelectPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Select pickup location'**
  String get createOrderSelectPickupLocation;

  /// No description provided for @createOrderSelectDropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Select dropoff location'**
  String get createOrderSelectDropoffLocation;

  /// No description provided for @orderDetailCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderDetailCancelTitle;

  /// No description provided for @orderDetailCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get orderDetailCancelConfirm;

  /// No description provided for @orderDetailRateDriver.
  ///
  /// In en, this message translates to:
  /// **'Rate driver'**
  String get orderDetailRateDriver;

  /// No description provided for @orderDetailCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get orderDetailCommentOptional;

  /// No description provided for @orderDetailFileComplaint.
  ///
  /// In en, this message translates to:
  /// **'File a complaint'**
  String get orderDetailFileComplaint;

  /// No description provided for @orderDetailAgainst.
  ///
  /// In en, this message translates to:
  /// **'Against'**
  String get orderDetailAgainst;

  /// No description provided for @orderDetailOrderHash.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get orderDetailOrderHash;

  /// No description provided for @orderDetailScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get orderDetailScheduled;

  /// No description provided for @orderDetailYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating:'**
  String get orderDetailYourRating;

  /// No description provided for @orderDetailYesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get orderDetailYesCancel;

  /// No description provided for @ratingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Trip'**
  String get ratingScreenTitle;

  /// No description provided for @ratingScreenDriverPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your driver'**
  String get ratingScreenDriverPrefix;

  /// No description provided for @ratingScreenStarsLabel.
  ///
  /// In en, this message translates to:
  /// **'How was your driver?'**
  String get ratingScreenStarsLabel;

  /// No description provided for @ratingScreenStarsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a star rating'**
  String get ratingScreenStarsRequired;

  /// No description provided for @ratingScreenAlreadyRated.
  ///
  /// In en, this message translates to:
  /// **'You already rated this trip'**
  String get ratingScreenAlreadyRated;

  /// No description provided for @ratingScreenReportIssueToggle.
  ///
  /// In en, this message translates to:
  /// **'I\'d like to report a problem'**
  String get ratingScreenReportIssueToggle;

  /// No description provided for @ratingScreenReportIssueHint.
  ///
  /// In en, this message translates to:
  /// **'Optional - let us know if something went wrong'**
  String get ratingScreenReportIssueHint;

  /// No description provided for @ratingScreenDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get ratingScreenDescriptionRequired;

  /// No description provided for @ratingScreenSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get ratingScreenSubmit;

  /// No description provided for @ratingScreenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your feedback was submitted.'**
  String get ratingScreenSuccess;

  /// No description provided for @ratingScreenTimeWindowNote.
  ///
  /// In en, this message translates to:
  /// **'You can rate this trip within 30 minutes of it ending.'**
  String get ratingScreenTimeWindowNote;

  /// No description provided for @reportCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed trips'**
  String get reportCompletedTrips;

  /// No description provided for @reportAvgRatingGiven.
  ///
  /// In en, this message translates to:
  /// **'Average rating given'**
  String get reportAvgRatingGiven;

  /// No description provided for @reportNoCompletedTrips.
  ///
  /// In en, this message translates to:
  /// **'No completed trips'**
  String get reportNoCompletedTrips;

  /// No description provided for @reportNoDataInRange.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this date range yet.'**
  String get reportNoDataInRange;

  /// No description provided for @commonNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNA;

  /// No description provided for @mapConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get mapConfirmLocation;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get commonReject;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @driverDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get driverDashboardTitle;

  /// No description provided for @driverReturningToOffice.
  ///
  /// In en, this message translates to:
  /// **'Returning to office'**
  String get driverReturningToOffice;

  /// No description provided for @driverImBack.
  ///
  /// In en, this message translates to:
  /// **'I\'m back (Go active)'**
  String get driverImBack;

  /// No description provided for @driverGoInactive.
  ///
  /// In en, this message translates to:
  /// **'Go inactive'**
  String get driverGoInactive;

  /// No description provided for @driverGoActive.
  ///
  /// In en, this message translates to:
  /// **'Go active'**
  String get driverGoActive;

  /// No description provided for @driverQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get driverQuickActions;

  /// No description provided for @driverQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Queue'**
  String get driverQueueTitle;

  /// No description provided for @driverQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go online and receive ride offers'**
  String get driverQueueSubtitle;

  /// No description provided for @driverVehicleInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle info and personal details'**
  String get driverVehicleInfoSubtitle;

  /// No description provided for @driverNewTripOffer.
  ///
  /// In en, this message translates to:
  /// **'New Trip Offer'**
  String get driverNewTripOffer;

  /// No description provided for @driverOfferPickupPrefix.
  ///
  /// In en, this message translates to:
  /// **'Pickup:'**
  String get driverOfferPickupPrefix;

  /// No description provided for @driverOfferDropoffPrefix.
  ///
  /// In en, this message translates to:
  /// **'Dropoff:'**
  String get driverOfferDropoffPrefix;

  /// No description provided for @driverOfferPassengersPrefix.
  ///
  /// In en, this message translates to:
  /// **'Passengers:'**
  String get driverOfferPassengersPrefix;

  /// No description provided for @driverQueueStatus.
  ///
  /// In en, this message translates to:
  /// **'Queue Status'**
  String get driverQueueStatus;

  /// No description provided for @driverWaitingForOrders.
  ///
  /// In en, this message translates to:
  /// **'Waiting for orders'**
  String get driverWaitingForOrders;

  /// No description provided for @driverAvailableForTrips.
  ///
  /// In en, this message translates to:
  /// **'You are now available for trips'**
  String get driverAvailableForTrips;

  /// No description provided for @driverEnterQueueToReceive.
  ///
  /// In en, this message translates to:
  /// **'Enter the queue to receive trips'**
  String get driverEnterQueueToReceive;

  /// No description provided for @driverAlreadyInQueue.
  ///
  /// In en, this message translates to:
  /// **'Already In Queue'**
  String get driverAlreadyInQueue;

  /// No description provided for @driverEnterQueue.
  ///
  /// In en, this message translates to:
  /// **'Enter Queue'**
  String get driverEnterQueue;

  /// No description provided for @driverCancelTrip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get driverCancelTrip;

  /// No description provided for @driverConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancel'**
  String get driverConfirmCancel;

  /// No description provided for @driverTripHash.
  ///
  /// In en, this message translates to:
  /// **'Trip #'**
  String get driverTripHash;

  /// No description provided for @driverTripStatus.
  ///
  /// In en, this message translates to:
  /// **'Trip status'**
  String get driverTripStatus;

  /// No description provided for @driverStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get driverStartTrip;

  /// No description provided for @driverStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get driverStops;

  /// No description provided for @driverArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get driverArrived;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driverProfileTitle;

  /// No description provided for @driverTripsReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips Report'**
  String get driverTripsReportTitle;

  /// No description provided for @driverNoReportYet.
  ///
  /// In en, this message translates to:
  /// **'No report loaded yet'**
  String get driverNoReportYet;

  /// No description provided for @driverLoadReport.
  ///
  /// In en, this message translates to:
  /// **'Load Report'**
  String get driverLoadReport;

  /// No description provided for @driverAverageRating.
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get driverAverageRating;

  /// No description provided for @driverNoCompletedTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No completed trips yet'**
  String get driverNoCompletedTripsYet;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @commonPhonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get commonPhonePrefix;

  /// No description provided for @commonAddressPrefix.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get commonAddressPrefix;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonNoVehicle.
  ///
  /// In en, this message translates to:
  /// **'No vehicle'**
  String get commonNoVehicle;

  /// No description provided for @commonNoRatingsYet.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get commonNoRatingsYet;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get commonTotal;

  /// No description provided for @commonEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA: {value}'**
  String commonEtaLabel(String value);

  /// No description provided for @commonDistanceTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {value}'**
  String commonDistanceTotalLabel(String value);

  /// No description provided for @commonDistanceCoveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Covered: {value}'**
  String commonDistanceCoveredLabel(String value);

  /// No description provided for @commonDistanceRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {value}'**
  String commonDistanceRemainingLabel(String value);

  /// No description provided for @commonCompletedWord.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get commonCompletedWord;

  /// No description provided for @commonCancelledWord.
  ///
  /// In en, this message translates to:
  /// **'cancelled'**
  String get commonCancelledWord;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminManageFleet.
  ///
  /// In en, this message translates to:
  /// **'Manage your fleet'**
  String get adminManageFleet;

  /// No description provided for @adminFleetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drivers, vehicles, orders and trips at a glance.'**
  String get adminFleetSubtitle;

  /// No description provided for @adminDrivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get adminDrivers;

  /// No description provided for @adminDriverApprovals.
  ///
  /// In en, this message translates to:
  /// **'Driver Approvals'**
  String get adminDriverApprovals;

  /// No description provided for @adminVehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get adminVehicles;

  /// No description provided for @adminPassengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get adminPassengers;

  /// No description provided for @adminOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get adminOrders;

  /// No description provided for @adminTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get adminTrips;

  /// No description provided for @adminCurrentTripsLive.
  ///
  /// In en, this message translates to:
  /// **'Current Trips (Live)'**
  String get adminCurrentTripsLive;

  /// No description provided for @adminTopDrivers.
  ///
  /// In en, this message translates to:
  /// **'Top Drivers'**
  String get adminTopDrivers;

  /// No description provided for @adminComplaintsViolations.
  ///
  /// In en, this message translates to:
  /// **'Complaints & Violations'**
  String get adminComplaintsViolations;

  /// No description provided for @adminDeleteDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Driver'**
  String get adminDeleteDriverTitle;

  /// No description provided for @adminDeletePassengerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Passenger'**
  String get adminDeletePassengerTitle;

  /// No description provided for @adminConfirmDeletePrefix.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get adminConfirmDeletePrefix;

  /// No description provided for @adminManageDrivers.
  ///
  /// In en, this message translates to:
  /// **'Manage Drivers'**
  String get adminManageDrivers;

  /// No description provided for @adminManagePassengers.
  ///
  /// In en, this message translates to:
  /// **'Manage Passengers'**
  String get adminManagePassengers;

  /// No description provided for @adminNoDriversFound.
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get adminNoDriversFound;

  /// No description provided for @adminNoDriversLoaded.
  ///
  /// In en, this message translates to:
  /// **'No drivers loaded yet'**
  String get adminNoDriversLoaded;

  /// No description provided for @adminLoadDrivers.
  ///
  /// In en, this message translates to:
  /// **'Load Drivers'**
  String get adminLoadDrivers;

  /// No description provided for @adminNoPassengersFound.
  ///
  /// In en, this message translates to:
  /// **'No passengers found'**
  String get adminNoPassengersFound;

  /// No description provided for @adminNoPassengersLoaded.
  ///
  /// In en, this message translates to:
  /// **'No passengers loaded yet'**
  String get adminNoPassengersLoaded;

  /// No description provided for @adminLoadPassengers.
  ///
  /// In en, this message translates to:
  /// **'Load Passengers'**
  String get adminLoadPassengers;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @adminApproveDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve Driver'**
  String get adminApproveDriverTitle;

  /// No description provided for @adminApprovePrefix.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprovePrefix;

  /// No description provided for @adminApproveSuffix.
  ///
  /// In en, this message translates to:
  /// **'as a driver?'**
  String get adminApproveSuffix;

  /// No description provided for @adminRejectPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminRejectPrefix;

  /// No description provided for @adminPendingApprovalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Driver Approvals'**
  String get adminPendingApprovalsTitle;

  /// No description provided for @adminNoPendingDrivers.
  ///
  /// In en, this message translates to:
  /// **'No pending drivers'**
  String get adminNoPendingDrivers;

  /// No description provided for @adminNoDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'No data loaded yet'**
  String get adminNoDataLoaded;

  /// No description provided for @adminLoadPendingDrivers.
  ///
  /// In en, this message translates to:
  /// **'Load Pending Drivers'**
  String get adminLoadPendingDrivers;

  /// No description provided for @adminCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed orders'**
  String get adminCompletedOrders;

  /// No description provided for @adminJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get adminJoined;

  /// No description provided for @commonApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get commonApprove;

  /// No description provided for @adminNoAssignableDrivers.
  ///
  /// In en, this message translates to:
  /// **'No assignable drivers available right now'**
  String get adminNoAssignableDrivers;

  /// No description provided for @adminAssignDriverToOrder.
  ///
  /// In en, this message translates to:
  /// **'Assign driver to Order #'**
  String get adminAssignDriverToOrder;

  /// No description provided for @adminOrderFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get adminOrderFromPrefix;

  /// No description provided for @adminOrderToPrefix.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get adminOrderToPrefix;

  /// No description provided for @adminOrderRatingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rating:'**
  String get adminOrderRatingPrefix;

  /// No description provided for @adminNoOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get adminNoOrdersFound;

  /// No description provided for @adminNoOrdersLoaded.
  ///
  /// In en, this message translates to:
  /// **'No orders loaded yet'**
  String get adminNoOrdersLoaded;

  /// No description provided for @adminLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Load Orders'**
  String get adminLoadOrders;

  /// No description provided for @adminAssignDriverButton.
  ///
  /// In en, this message translates to:
  /// **'Assign driver'**
  String get adminAssignDriverButton;

  /// No description provided for @adminNoTripsFound.
  ///
  /// In en, this message translates to:
  /// **'No trips found'**
  String get adminNoTripsFound;

  /// No description provided for @adminNoTripsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No trips loaded yet'**
  String get adminNoTripsLoaded;

  /// No description provided for @adminLoadTrips.
  ///
  /// In en, this message translates to:
  /// **'Load Trips'**
  String get adminLoadTrips;

  /// No description provided for @adminCurrentTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Trips'**
  String get adminCurrentTripsTitle;

  /// No description provided for @adminNoActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'No active trips right now'**
  String get adminNoActiveTrips;

  /// No description provided for @adminProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Profile'**
  String get adminProfileTitle;

  /// No description provided for @adminNoDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get adminNoDataFound;

  /// No description provided for @adminCompletedTripsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed Trips:'**
  String get adminCompletedTripsLabel;

  /// No description provided for @adminAvgRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating:'**
  String get adminAvgRatingLabel;

  /// No description provided for @adminViolationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Violations:'**
  String get adminViolationsLabel;

  /// No description provided for @vehicleNoApprovedDrivers.
  ///
  /// In en, this message translates to:
  /// **'No approved drivers available. Approve a driver first.'**
  String get vehicleNoApprovedDrivers;

  /// No description provided for @vehicleAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get vehicleAddTitle;

  /// No description provided for @vehicleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get vehicleEditTitle;

  /// No description provided for @vehicleDriverApprovedOnly.
  ///
  /// In en, this message translates to:
  /// **'Driver (approved only)'**
  String get vehicleDriverApprovedOnly;

  /// No description provided for @vehiclePlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get vehiclePlateNumber;

  /// No description provided for @vehicleMakeHint.
  ///
  /// In en, this message translates to:
  /// **'Make (e.g. Kia)'**
  String get vehicleMakeHint;

  /// No description provided for @commonModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get commonModel;

  /// No description provided for @commonColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get commonColor;

  /// No description provided for @vehicleSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get vehicleSeats;

  /// No description provided for @vehicleYearOptional.
  ///
  /// In en, this message translates to:
  /// **'Year (optional)'**
  String get vehicleYearOptional;

  /// No description provided for @vehicleSize.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Size'**
  String get vehicleSize;

  /// No description provided for @vehicleFillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields (plate, model, color, seats)'**
  String get vehicleFillRequiredFields;

  /// No description provided for @vehicleSelectDriverForVehicle.
  ///
  /// In en, this message translates to:
  /// **'Please select a driver for this vehicle'**
  String get vehicleSelectDriverForVehicle;

  /// No description provided for @vehicleAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Vehicle'**
  String get vehicleAssignTitle;

  /// No description provided for @vehicleSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Please select a driver'**
  String get vehicleSelectDriver;

  /// No description provided for @vehicleManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Vehicles'**
  String get vehicleManageTitle;

  /// No description provided for @vehicleNoVehiclesFound.
  ///
  /// In en, this message translates to:
  /// **'No vehicles found'**
  String get vehicleNoVehiclesFound;

  /// No description provided for @vehicleNoVehiclesLoaded.
  ///
  /// In en, this message translates to:
  /// **'No vehicles loaded yet'**
  String get vehicleNoVehiclesLoaded;

  /// No description provided for @vehicleLoadVehicles.
  ///
  /// In en, this message translates to:
  /// **'Load Vehicles'**
  String get vehicleLoadVehicles;

  /// No description provided for @vehicleSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seats:'**
  String get vehicleSeatsLabel;

  /// No description provided for @vehicleSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size:'**
  String get vehicleSizeLabel;

  /// No description provided for @vehicleDriverNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get vehicleDriverNotAssigned;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @vehicleUnassign.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get vehicleUnassign;

  /// No description provided for @vehicleChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get vehicleChangeStatus;

  /// No description provided for @violationResolveComplaint.
  ///
  /// In en, this message translates to:
  /// **'Resolve Complaint'**
  String get violationResolveComplaint;

  /// No description provided for @violationCreateAgainstDriver.
  ///
  /// In en, this message translates to:
  /// **'Create violation against driver'**
  String get violationCreateAgainstDriver;

  /// No description provided for @violationType.
  ///
  /// In en, this message translates to:
  /// **'Violation Type'**
  String get violationType;

  /// No description provided for @violationReason.
  ///
  /// In en, this message translates to:
  /// **'Violation Reason'**
  String get violationReason;

  /// No description provided for @commonResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get commonResolve;

  /// No description provided for @adminComplaintsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get adminComplaintsTabLabel;

  /// No description provided for @adminViolationsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Violations'**
  String get adminViolationsTabLabel;

  /// No description provided for @adminNoComplaintsFound.
  ///
  /// In en, this message translates to:
  /// **'No complaints found'**
  String get adminNoComplaintsFound;

  /// No description provided for @adminNoComplaintsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No complaints loaded yet'**
  String get adminNoComplaintsLoaded;

  /// No description provided for @adminLoadComplaints.
  ///
  /// In en, this message translates to:
  /// **'Load Complaints'**
  String get adminLoadComplaints;

  /// No description provided for @adminNoViolationsFound.
  ///
  /// In en, this message translates to:
  /// **'No violations found'**
  String get adminNoViolationsFound;

  /// No description provided for @adminNoViolationsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No violations loaded yet'**
  String get adminNoViolationsLoaded;

  /// No description provided for @adminLoadViolations.
  ///
  /// In en, this message translates to:
  /// **'Load Violations'**
  String get adminLoadViolations;

  /// No description provided for @adminReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reason:'**
  String get adminReasonPrefix;

  /// No description provided for @userStatusDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get userStatusDeactivateTitle;

  /// No description provided for @userStatusActivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate account'**
  String get userStatusActivateTitle;

  /// No description provided for @userStatusDeactivateConfirm.
  ///
  /// In en, this message translates to:
  /// **'This account will no longer be able to use the app until reactivated. Continue?'**
  String get userStatusDeactivateConfirm;

  /// No description provided for @userStatusActivateConfirm.
  ///
  /// In en, this message translates to:
  /// **'This account will be able to use the app again. Continue?'**
  String get userStatusActivateConfirm;

  /// No description provided for @userStatusDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get userStatusDeactivate;

  /// No description provided for @userStatusActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get userStatusActivate;

  /// No description provided for @userStatusUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock account'**
  String get userStatusUnblockTitle;

  /// No description provided for @userStatusUnblockConfirm.
  ///
  /// In en, this message translates to:
  /// **'This account will be able to log in again. Continue?'**
  String get userStatusUnblockConfirm;

  /// No description provided for @userStatusUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get userStatusUnblock;

  /// No description provided for @userStatusBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block account'**
  String get userStatusBlockTitle;

  /// No description provided for @userStatusDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get userStatusDuration;

  /// No description provided for @userStatusOneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get userStatusOneDay;

  /// No description provided for @userStatusSevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get userStatusSevenDays;

  /// No description provided for @userStatusThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get userStatusThirtyDays;

  /// No description provided for @userStatusPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent (until unblocked)'**
  String get userStatusPermanent;

  /// No description provided for @userStatusBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get userStatusBlock;

  /// No description provided for @userStatusNotBlocked.
  ///
  /// In en, this message translates to:
  /// **'Not blocked'**
  String get userStatusNotBlocked;

  /// No description provided for @notificationsTitleWithCount.
  ///
  /// In en, this message translates to:
  /// **'Notifications ({count})'**
  String notificationsTitleWithCount(int count);

  /// No description provided for @notificationsReadAll.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get notificationsReadAll;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsRead;

  /// No description provided for @notifRateTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate your trip'**
  String get notifRateTripTitle;

  /// No description provided for @notifRateTripBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip has ended. Tap to rate your driver.'**
  String get notifRateTripBody;

  /// No description provided for @notifMessageReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get notifMessageReceivedTitle;

  /// No description provided for @notifTripAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip assigned'**
  String get notifTripAssignedTitle;

  /// No description provided for @notifTripAssignedBody.
  ///
  /// In en, this message translates to:
  /// **'A trip has been assigned to you.'**
  String get notifTripAssignedBody;

  /// No description provided for @notifDriverArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver arrived'**
  String get notifDriverArrivedTitle;

  /// No description provided for @notifDriverArrivedBody.
  ///
  /// In en, this message translates to:
  /// **'Your driver has arrived at the pickup location.'**
  String get notifDriverArrivedBody;

  /// No description provided for @notifTripStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip started'**
  String get notifTripStartedTitle;

  /// No description provided for @notifTripStartedBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip is now on the way.'**
  String get notifTripStartedBody;

  /// No description provided for @notifTripCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip completed'**
  String get notifTripCompletedTitle;

  /// No description provided for @notifTripCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your trip has been completed.'**
  String get notifTripCompletedBody;

  /// No description provided for @notifDriverCancelledTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get notifDriverCancelledTripTitle;

  /// No description provided for @notifDriverCancelledTripBody.
  ///
  /// In en, this message translates to:
  /// **'The trip was cancelled by the driver. We\'re searching for another one.'**
  String get notifDriverCancelledTripBody;

  /// No description provided for @notifNewTripOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'New trip request'**
  String get notifNewTripOfferTitle;

  /// No description provided for @notifNewTripOfferBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new trip request waiting.'**
  String get notifNewTripOfferBody;

  /// No description provided for @notifDriverRejectedTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Searching for another driver'**
  String get notifDriverRejectedTripTitle;

  /// No description provided for @notifDriverRejectedTripBody.
  ///
  /// In en, this message translates to:
  /// **'The driver declined this trip. We\'re searching for someone else.'**
  String get notifDriverRejectedTripBody;

  /// No description provided for @notifDriverAcceptedTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver assigned'**
  String get notifDriverAcceptedTripTitle;

  /// No description provided for @notifDriverAcceptedTripBody.
  ///
  /// In en, this message translates to:
  /// **'A driver has accepted your trip and is on the way.'**
  String get notifDriverAcceptedTripBody;

  /// No description provided for @notifPickedUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup confirmed'**
  String get notifPickedUpTitle;

  /// No description provided for @notifPickedUpBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re on your way to your destination.'**
  String get notifPickedUpBody;

  /// No description provided for @notifOrderCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order received'**
  String get notifOrderCreatedTitle;

  /// No description provided for @notifOrderCreatedBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re searching for the nearest driver for you.'**
  String get notifOrderCreatedBody;

  /// No description provided for @notifOrderCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notifOrderCancelledTitle;

  /// No description provided for @notifOrderCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Your order has been cancelled.'**
  String get notifOrderCancelledBody;

  /// No description provided for @notifOrderNeedsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Order needs review'**
  String get notifOrderNeedsReviewTitle;

  /// No description provided for @notifOrderNeedsReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Your order needs office review.'**
  String get notifOrderNeedsReviewBody;

  /// No description provided for @notifOrderReviewedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order reviewed'**
  String get notifOrderReviewedTitle;

  /// No description provided for @notifOrderReviewedBody.
  ///
  /// In en, this message translates to:
  /// **'Your order has been reviewed.'**
  String get notifOrderReviewedBody;

  /// No description provided for @notifNoDriverFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No driver available'**
  String get notifNoDriverFoundTitle;

  /// No description provided for @notifNoDriverFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find an available driver right now. Please try again shortly.'**
  String get notifNoDriverFoundBody;

  /// No description provided for @notifDelayWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delay notice'**
  String get notifDelayWarningTitle;

  /// No description provided for @notifDelayWarningBody.
  ///
  /// In en, this message translates to:
  /// **'There\'s a delay with your trip.'**
  String get notifDelayWarningBody;

  /// No description provided for @notifDriverApprovalPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver approval pending'**
  String get notifDriverApprovalPendingTitle;

  /// No description provided for @notifDriverApprovalPendingBody.
  ///
  /// In en, this message translates to:
  /// **'A new driver is waiting for approval.'**
  String get notifDriverApprovalPendingBody;

  /// No description provided for @notifDriverApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re approved!'**
  String get notifDriverApprovedTitle;

  /// No description provided for @notifDriverApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your driver application has been approved.'**
  String get notifDriverApprovedBody;

  /// No description provided for @notifDriverRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application rejected'**
  String get notifDriverRejectedTitle;

  /// No description provided for @notifDriverRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your driver application was not approved.'**
  String get notifDriverRejectedBody;

  /// No description provided for @notifDriverEnteredQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver entered the queue'**
  String get notifDriverEnteredQueueTitle;

  /// No description provided for @notifDriverEnteredQueueBody.
  ///
  /// In en, this message translates to:
  /// **'A driver has entered the office queue.'**
  String get notifDriverEnteredQueueBody;

  /// No description provided for @notifDriverLeftQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver left the queue'**
  String get notifDriverLeftQueueTitle;

  /// No description provided for @notifDriverLeftQueueBody.
  ///
  /// In en, this message translates to:
  /// **'A driver has left the office queue.'**
  String get notifDriverLeftQueueBody;

  /// No description provided for @notifViolationTitle.
  ///
  /// In en, this message translates to:
  /// **'Violation recorded'**
  String get notifViolationTitle;

  /// No description provided for @notifViolationBody.
  ///
  /// In en, this message translates to:
  /// **'A violation has been recorded on your account.'**
  String get notifViolationBody;

  /// No description provided for @notifComplaintTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint update'**
  String get notifComplaintTitle;

  /// No description provided for @notifComplaintBody.
  ///
  /// In en, this message translates to:
  /// **'There\'s an update on a complaint.'**
  String get notifComplaintBody;

  /// No description provided for @complaintsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Complaint'**
  String get complaintsCreateTitle;

  /// No description provided for @complaintsOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get complaintsOrderId;

  /// No description provided for @complaintsFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get complaintsFillAllFields;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @complaintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaintsTitle;

  /// No description provided for @complaintsNoComplaintsFound.
  ///
  /// In en, this message translates to:
  /// **'No complaints found'**
  String get complaintsNoComplaintsFound;

  /// No description provided for @complaintsNoComplaintsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No complaints loaded yet'**
  String get complaintsNoComplaintsLoaded;

  /// No description provided for @complaintsLoadComplaints.
  ///
  /// In en, this message translates to:
  /// **'Load Complaints'**
  String get complaintsLoadComplaints;

  /// No description provided for @complaintsOrderIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Order ID:'**
  String get complaintsOrderIdPrefix;

  /// No description provided for @favLocAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Favorite Location'**
  String get favLocAddTitle;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @favLocFillFieldsCorrectly.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields correctly'**
  String get favLocFillFieldsCorrectly;

  /// No description provided for @favLocTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Locations'**
  String get favLocTitle;

  /// No description provided for @favLocNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No favorite locations found'**
  String get favLocNoneFound;

  /// No description provided for @favLocLoadAction.
  ///
  /// In en, this message translates to:
  /// **'Load Favorite Locations'**
  String get favLocLoadAction;

  /// No description provided for @favLocLatPrefix.
  ///
  /// In en, this message translates to:
  /// **'Lat:'**
  String get favLocLatPrefix;

  /// No description provided for @favLocLngPrefix.
  ///
  /// In en, this message translates to:
  /// **'Lng:'**
  String get favLocLngPrefix;

  /// No description provided for @driverLocationErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get driverLocationErrorPrefix;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your ride, on demand'**
  String get splashTagline;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route Not Found'**
  String get routeNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
