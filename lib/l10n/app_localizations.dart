import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'VALORANT Crosshair Collection'**
  String get appTitle;

  /// No description provided for @tabList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get tabList;

  /// No description provided for @tabHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get tabHot;

  /// No description provided for @tabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tabInfo;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or description...'**
  String get searchHint;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No crosshairs yet!'**
  String get noData;

  /// No description provided for @shareYourCrosshair.
  ///
  /// In en, this message translates to:
  /// **'Share Your Crosshair'**
  String get shareYourCrosshair;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @crosshairCode.
  ///
  /// In en, this message translates to:
  /// **'Crosshair Code'**
  String get crosshairCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter unique code'**
  String get enterCode;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @selectCropImage.
  ///
  /// In en, this message translates to:
  /// **'Select & Crop Image'**
  String get selectCropImage;

  /// No description provided for @imageHint.
  ///
  /// In en, this message translates to:
  /// **'Image will be cropped to 1:1 ratio (square)'**
  String get imageHint;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'SHARE'**
  String get upload;

  /// No description provided for @uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'🚀 Upload successful!'**
  String get uploadSuccess;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get uploadError;

  /// No description provided for @codeExists.
  ///
  /// In en, this message translates to:
  /// **'❌ Code already exists! Please enter another code.'**
  String get codeExists;

  /// No description provided for @codeAvailable.
  ///
  /// In en, this message translates to:
  /// **'✅ Code is available!'**
  String get codeAvailable;

  /// No description provided for @fillNameCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter Name and Code!'**
  String get fillNameCode;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get deleteConfirm;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete crosshair '**
  String get deleteMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'🗑️ Deleted successfully!'**
  String get deleteSuccess;

  /// No description provided for @loginAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get loginAdmin;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @adminOnly.
  ///
  /// In en, this message translates to:
  /// **'🔒 Admin only'**
  String get adminOnly;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Incorrect username or password!'**
  String get loginFailed;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirm;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Logged out!'**
  String get logoutSuccess;

  /// No description provided for @adminDeleteOnly.
  ///
  /// In en, this message translates to:
  /// **'🔒 Please login as Admin to delete crosshair!'**
  String get adminDeleteOnly;

  /// No description provided for @adminMode.
  ///
  /// In en, this message translates to:
  /// **'🔑 Admin Mode - You can delete this crosshair'**
  String get adminMode;

  /// No description provided for @copySuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Copied code: '**
  String get copySuccess;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get likes;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (Beta)'**
  String get version;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'👤 Owner'**
  String get owner;

  /// No description provided for @nameOwner.
  ///
  /// In en, this message translates to:
  /// **'Vũ Thanh Lịch'**
  String get nameOwner;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @zalo.
  ///
  /// In en, this message translates to:
  /// **'Zalo'**
  String get zalo;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'💝 Support Development'**
  String get donate;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'📱 Scan QR code to support via MoMo'**
  String get scanQR;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'💳 Account Number: '**
  String get accountNumber;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'🏦 Bank: '**
  String get bank;

  /// No description provided for @accountHolder.
  ///
  /// In en, this message translates to:
  /// **'👤 Account Holder: '**
  String get accountHolder;

  /// No description provided for @copyAccount.
  ///
  /// In en, this message translates to:
  /// **'Copy Account Number'**
  String get copyAccount;

  /// No description provided for @copiedAccount.
  ///
  /// In en, this message translates to:
  /// **'✅ Copied account number!'**
  String get copiedAccount;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'📊 App Statistics'**
  String get stats;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get totalUsers;

  /// No description provided for @totalCrosshairs.
  ///
  /// In en, this message translates to:
  /// **'Total Crosshairs'**
  String get totalCrosshairs;

  /// No description provided for @totalLikes.
  ///
  /// In en, this message translates to:
  /// **'Total Likes'**
  String get totalLikes;

  /// No description provided for @refreshStats.
  ///
  /// In en, this message translates to:
  /// **'Refresh Stats'**
  String get refreshStats;

  /// No description provided for @statsUpdated.
  ///
  /// In en, this message translates to:
  /// **'🔄 Stats updated!'**
  String get statsUpdated;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: '**
  String get loadError;

  /// No description provided for @imageSelected.
  ///
  /// In en, this message translates to:
  /// **'Image selected'**
  String get imageSelected;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No image'**
  String get noImage;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter crosshair name'**
  String get enterName;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter short description'**
  String get enterDescription;

  /// No description provided for @loginAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get loginAdminTitle;

  /// No description provided for @adminLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get adminLogoutTitle;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @adminSettings.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminSettings;

  /// No description provided for @deleteCrosshair.
  ///
  /// In en, this message translates to:
  /// **'Delete Crosshair'**
  String get deleteCrosshair;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get areYouSure;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
