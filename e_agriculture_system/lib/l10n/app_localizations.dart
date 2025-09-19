import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

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
    Locale('si'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'E-Agriculture System'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Good morning message for farmers
  ///
  /// In en, this message translates to:
  /// **'Good Morning, Farmer! 🌱'**
  String get goodMorningFarmer;

  /// Welcome message for buyers
  ///
  /// In en, this message translates to:
  /// **'Welcome, Buyer! 🛒'**
  String get welcomeBuyer;

  /// Farm management dashboard title
  ///
  /// In en, this message translates to:
  /// **'Farm Management'**
  String get farmManagement;

  /// Buyer marketplace dashboard title
  ///
  /// In en, this message translates to:
  /// **'Buyer Marketplace'**
  String get buyerMarketplace;

  /// Description for farm management
  ///
  /// In en, this message translates to:
  /// **'Manage your farm operations and sell your products'**
  String get manageFarmOperations;

  /// Description for buyer marketplace
  ///
  /// In en, this message translates to:
  /// **'Browse fresh products and manage your orders'**
  String get browseFreshProducts;

  /// Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Description for general dashboard
  ///
  /// In en, this message translates to:
  /// **'Manage your operations'**
  String get manageOperations;

  /// Marketplace feature
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Description for marketplace
  ///
  /// In en, this message translates to:
  /// **'Sell your products'**
  String get sellYourProducts;

  /// Order management feature
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// Description for order management
  ///
  /// In en, this message translates to:
  /// **'Manage incoming orders'**
  String get manageIncomingOrders;

  /// Daily updates feature
  ///
  /// In en, this message translates to:
  /// **'Daily Updates'**
  String get dailyUpdates;

  /// Description for daily updates
  ///
  /// In en, this message translates to:
  /// **'Advanced daily updates'**
  String get advancedDailyUpdates;

  /// Crop monitor feature
  ///
  /// In en, this message translates to:
  /// **'Crop Monitor'**
  String get cropMonitor;

  /// Description for crop monitor
  ///
  /// In en, this message translates to:
  /// **'Real-time crop health'**
  String get realtimeCropHealth;

  /// Weather forecast feature
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get weatherForecast;

  /// Description for weather forecast
  ///
  /// In en, this message translates to:
  /// **'10-day predictions'**
  String get tenDayPredictions;

  /// Market prices feature
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// Description for market prices
  ///
  /// In en, this message translates to:
  /// **'Live commodity rates'**
  String get liveCommodityRates;

  /// Expert chat feature
  ///
  /// In en, this message translates to:
  /// **'Expert Chat'**
  String get expertChat;

  /// Description for expert chat
  ///
  /// In en, this message translates to:
  /// **'AI farming assistant'**
  String get aiFarmingAssistant;

  /// Farm equipment feature
  ///
  /// In en, this message translates to:
  /// **'Farm Equipment'**
  String get farmEquipment;

  /// Description for farm equipment
  ///
  /// In en, this message translates to:
  /// **'Smart tool management'**
  String get smartToolManagement;

  /// Pest control feature
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pestControl;

  /// Description for pest control
  ///
  /// In en, this message translates to:
  /// **'Disease prevention'**
  String get diseasePrevention;

  /// Harvest planning feature
  ///
  /// In en, this message translates to:
  /// **'Harvest Planning'**
  String get harvestPlanning;

  /// Description for harvest planning
  ///
  /// In en, this message translates to:
  /// **'Optimize yield timing'**
  String get optimizeYieldTiming;

  /// Financial statement feature
  ///
  /// In en, this message translates to:
  /// **'Financial Statement'**
  String get financialStatement;

  /// Description for financial statement
  ///
  /// In en, this message translates to:
  /// **'Advanced financial management'**
  String get advancedFinancialManagement;

  /// Firestore data feature
  ///
  /// In en, this message translates to:
  /// **'Firestore Data'**
  String get firestoreData;

  /// Description for firestore data
  ///
  /// In en, this message translates to:
  /// **'View crops, harvests & equipment'**
  String get viewCropsHarvestsEquipment;

  /// Admin panel feature
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// Description for admin panel
  ///
  /// In en, this message translates to:
  /// **'Test & manage daily updates'**
  String get testManageDailyUpdates;

  /// My orders feature
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// Description for my orders
  ///
  /// In en, this message translates to:
  /// **'Track your purchases'**
  String get trackYourPurchases;

  /// Favorites feature
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Description for favorites
  ///
  /// In en, this message translates to:
  /// **'Saved products'**
  String get savedProducts;

  /// Search farmers feature
  ///
  /// In en, this message translates to:
  /// **'Search Farmers'**
  String get searchFarmers;

  /// Description for search farmers
  ///
  /// In en, this message translates to:
  /// **'Connect directly with producers'**
  String get connectDirectlyWithProducers;

  /// Delivery tracking feature
  ///
  /// In en, this message translates to:
  /// **'Delivery Tracking'**
  String get deliveryTracking;

  /// Description for delivery tracking
  ///
  /// In en, this message translates to:
  /// **'Track your shipments'**
  String get trackYourShipments;

  /// Support title
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Description for support
  ///
  /// In en, this message translates to:
  /// **'Get help & assistance'**
  String get getHelpAssistance;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Description for switching to light theme
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get switchToLightTheme;

  /// Description for switching to dark theme
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get switchToDarkTheme;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Sinhala language option
  ///
  /// In en, this message translates to:
  /// **'සිංහල'**
  String get sinhala;

  /// Logout action
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Login action
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register action
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Don't have account message
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Already have account message
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Sign up action
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign in action
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Add action
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Update action
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Search action
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter action
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Refresh action
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Back action
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next action
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous action
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Done action
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// OK action
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes action
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No action
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Today's summary title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// New updates count
  ///
  /// In en, this message translates to:
  /// **'5 new updates • 2 high priority'**
  String get newUpdates;

  /// Weather update title
  ///
  /// In en, this message translates to:
  /// **'Weather Update'**
  String get weatherUpdate;

  /// Market status title
  ///
  /// In en, this message translates to:
  /// **'Market Status'**
  String get marketStatus;

  /// Weather description for farmers
  ///
  /// In en, this message translates to:
  /// **'Sunny, 28°C - Perfect for farming activities'**
  String get sunnyPerfectFarming;

  /// Market status for buyers
  ///
  /// In en, this message translates to:
  /// **'Active marketplace with fresh products available'**
  String get activeMarketplace;

  /// Pest overview title
  ///
  /// In en, this message translates to:
  /// **'Pest Overview'**
  String get pestOverview;

  /// Critical severity level
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// High severity level
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Medium severity level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Low severity level
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Enhanced profile update feature
  ///
  /// In en, this message translates to:
  /// **'Enhanced Profile Update'**
  String get enhancedProfileUpdate;

  /// Description for enhanced profile update
  ///
  /// In en, this message translates to:
  /// **'Update with image upload & verification'**
  String get updateWithImageUpload;

  /// Notifications title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Description for notifications
  ///
  /// In en, this message translates to:
  /// **'Manage your notifications'**
  String get manageNotifications;

  /// Privacy title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Description for privacy
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get managePrivacySettings;

  /// About title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Description for about
  ///
  /// In en, this message translates to:
  /// **'App information and version'**
  String get appInfo;

  /// Help and support feature
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Description for help and support
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelp;

  /// Description for language selection
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// Message when updates are refreshed
  ///
  /// In en, this message translates to:
  /// **'Updates refreshed'**
  String get updatesRefreshed;

  /// Error message when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// Success message when profile is updated
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Confirmation message for logout
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// Additional information for logout confirmation
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your account.'**
  String get logoutConfirmation;

  /// Name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Phone field
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Address field
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Bio field
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Farmer user type
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// Buyer user type
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyer;

  /// User type field
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// Join date field
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get joinDate;

  /// Last active field
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get lastActive;

  /// Total orders field
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// Total products field
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// Rating field
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Reviews field
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Unverified status
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// Edit profile action
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// View profile action
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// Share profile action
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// Report user action
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// Block user action
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// Unblock user action
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// Send message action
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// Follow action
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Unfollow action
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// View all action
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// See more action
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// See less action
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No data available message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Try again action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Open action
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// View action
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Download action
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Upload action
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// Select action
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Deselect action
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get deselect;

  /// Clear action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Reset action
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Submit action
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Continue action
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Skip action
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Finish action
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Start action
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Stop action
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Pause action
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Resume action
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Play action
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Preferences title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Account title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Security title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Help title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Feedback title
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Contact title
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Terms title
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// Policy title
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get policy;

  /// Version title
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Build title
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// Copyright title
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get copyright;

  /// All rights reserved message
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get allRightsReserved;

  /// Payment title
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// Order summary title
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// Subtotal label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Shipping label
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// Tax label
  ///
  /// In en, this message translates to:
  /// **'Tax (VAT)'**
  String get tax;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Select payment method title
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// Payment details title
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// Bank name field
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// Account number field
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// Phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Wallet ID field
  ///
  /// In en, this message translates to:
  /// **'Wallet ID'**
  String get walletId;

  /// Reference field
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// Pay now button
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Buy now button
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// Quantity field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Delivery address field
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// Enter delivery address hint
  ///
  /// In en, this message translates to:
  /// **'Enter delivery address'**
  String get enterDeliveryAddress;

  /// Order notes field
  ///
  /// In en, this message translates to:
  /// **'Order Notes (Optional)'**
  String get orderNotes;

  /// Enter order notes hint
  ///
  /// In en, this message translates to:
  /// **'Enter any special instructions'**
  String get enterOrderNotes;

  /// Proceed to payment button
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// Payment successful message
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// Order confirmed message
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed and will be processed soon.'**
  String get orderConfirmed;

  /// Order ID label
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// Transaction ID label
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Cash on delivery payment method
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// Bank transfer payment method
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// Mobile payment method
  ///
  /// In en, this message translates to:
  /// **'Mobile Payment'**
  String get mobilePayment;

  /// Digital wallet payment method
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get digitalWallet;

  /// Credit card payment method
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// Debit card payment method
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get debitCard;

  /// Payment slip title
  ///
  /// In en, this message translates to:
  /// **'Payment Slip'**
  String get paymentSlip;

  /// Order details section title
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// Download receipt button text
  ///
  /// In en, this message translates to:
  /// **'Download Receipt'**
  String get downloadReceipt;

  /// Print receipt button text
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// Share payment slip button text
  ///
  /// In en, this message translates to:
  /// **'Share Payment Slip'**
  String get sharePaymentSlip;

  /// PDF generation loading text
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPDF;
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
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
