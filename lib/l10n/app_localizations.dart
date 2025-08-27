import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';

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
    Locale('hi'),
    Locale('it')
  ];

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @tokens.
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get tokens;

  /// No description provided for @nfts.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get nfts;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @my_account.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get my_account;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pools.
  ///
  /// In en, this message translates to:
  /// **'Token Pools'**
  String get pools;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @developer_settings.
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get developer_settings;

  /// No description provided for @switch_network.
  ///
  /// In en, this message translates to:
  /// **'Switch Network'**
  String get switch_network;

  /// No description provided for @testnet.
  ///
  /// In en, this message translates to:
  /// **'Testnet'**
  String get testnet;

  /// No description provided for @mainnet.
  ///
  /// In en, this message translates to:
  /// **'Mainnet'**
  String get mainnet;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'NETWORK'**
  String get network;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @registering_on_network.
  ///
  /// In en, this message translates to:
  /// **'Registering on network'**
  String get registering_on_network;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get new_password;

  /// No description provided for @add_account.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get add_account;

  /// No description provided for @create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get create_new_account;

  /// No description provided for @import_account_from_pre_existing_seed.
  ///
  /// In en, this message translates to:
  /// **'From recovery phrase (seed/mnemonic)'**
  String get import_account_from_pre_existing_seed;

  /// No description provided for @copy_to_clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get copy_to_clipboard;

  /// No description provided for @please_write_down.
  ///
  /// In en, this message translates to:
  /// **'Please write down your wallet\'s mnemonic seed and keep it in a safe place. The mnemonic can be used to restore your wallet. Keep it carefully to not lose your assets.'**
  String get please_write_down;

  /// No description provided for @i_saved_mnemonic.
  ///
  /// In en, this message translates to:
  /// **'I have saved my recovery phrase (mnemonic/seed) safely.'**
  String get i_saved_mnemonic;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get next_step;

  /// No description provided for @generated_2_word.
  ///
  /// In en, this message translates to:
  /// **'GENERATED 12-WORD RECOVERY PHRASE (MNEMONIC): '**
  String get generated_2_word;

  /// No description provided for @existing_seed.
  ///
  /// In en, this message translates to:
  /// **'EXISTING 12 OR 24-WORD RECOVERY PHRASE(MNEMONIC):'**
  String get existing_seed;

  /// No description provided for @account_already_added.
  ///
  /// In en, this message translates to:
  /// **'This account has already been added'**
  String get account_already_added;

  /// No description provided for @descriptive_account_name.
  ///
  /// In en, this message translates to:
  /// **'A DESCRIPTIVE NAME FOR YOUR ACCOUNT'**
  String get descriptive_account_name;

  /// No description provided for @password_for_reef_app.
  ///
  /// In en, this message translates to:
  /// **'A PASSWORD FOR REEF APP'**
  String get password_for_reef_app;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get password_too_short;

  /// No description provided for @repetitive_password.
  ///
  /// In en, this message translates to:
  /// **'REPEAT PASSWORD FOR VERIFICATION'**
  String get repetitive_password;

  /// No description provided for @password_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_do_not_match;

  /// No description provided for @import_the_account.
  ///
  /// In en, this message translates to:
  /// **'Import the account'**
  String get import_the_account;

  /// No description provided for @add_the_account.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get add_the_account;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @incorrect_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Password'**
  String get incorrect_password;

  /// No description provided for @approve_domain_message.
  ///
  /// In en, this message translates to:
  /// **'Only approve this request if you trust the application. Approving gives the application access to the addresses of your accounts.'**
  String get approve_domain_message;

  /// No description provided for @auth_allow.
  ///
  /// In en, this message translates to:
  /// **'Yes, allow this application access'**
  String get auth_allow;

  /// No description provided for @auth_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get auth_reject;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @auth_url_list_del.
  ///
  /// In en, this message translates to:
  /// **'Delete Website'**
  String get auth_url_list_del;

  /// No description provided for @auth_url_list_no_website_yet.
  ///
  /// In en, this message translates to:
  /// **'No website request yet!'**
  String get auth_url_list_no_website_yet;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @bind_modal_connected.
  ///
  /// In en, this message translates to:
  /// **'Successfully connected to Reef EVM address'**
  String get bind_modal_connected;

  /// No description provided for @bind_modal_is_needed_for_transaction.
  ///
  /// In en, this message translates to:
  /// **'is needed for transaction fee.'**
  String get bind_modal_is_needed_for_transaction;

  /// No description provided for @bind_modal_coins_will_be_transferred.
  ///
  /// In en, this message translates to:
  /// **'Coins will be transfered from account:'**
  String get bind_modal_coins_will_be_transferred;

  /// No description provided for @bind_modal_start_using_reef_evm.
  ///
  /// In en, this message translates to:
  /// **'Start using Reef EVM smart contracts.'**
  String get bind_modal_start_using_reef_evm;

  /// No description provided for @bind_modal_first_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect EVM address for:'**
  String get bind_modal_first_connect;

  /// No description provided for @change_password_current_password.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PASSWORD'**
  String get change_password_current_password;

  /// No description provided for @change_password_password_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Password is incorrect'**
  String get change_password_password_incorrect;

  /// No description provided for @no_other_accounts.
  ///
  /// In en, this message translates to:
  /// **'No other accounts available'**
  String get no_other_accounts;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @click_on.
  ///
  /// In en, this message translates to:
  /// **'Click on'**
  String get click_on;

  /// No description provided for @to_create_account.
  ///
  /// In en, this message translates to:
  /// **'to create a new account'**
  String get to_create_account;

  /// No description provided for @reef_community_bond.
  ///
  /// In en, this message translates to:
  /// **'Reef community staking bond'**
  String get reef_community_bond;

  /// No description provided for @staking_closes_in.
  ///
  /// In en, this message translates to:
  /// **'Staking closes in'**
  String get staking_closes_in;

  /// No description provided for @bond_started_on.
  ///
  /// In en, this message translates to:
  /// **'Bond started on'**
  String get bond_started_on;

  /// No description provided for @funds_unlock_on.
  ///
  /// In en, this message translates to:
  /// **'Funds unlock on'**
  String get funds_unlock_on;

  /// No description provided for @bond_contract.
  ///
  /// In en, this message translates to:
  /// **'Bond Contract'**
  String get bond_contract;

  /// No description provided for @gen_12_word.
  ///
  /// In en, this message translates to:
  /// **'GENERATED 12-WORD MNEMONIC SEED:'**
  String get gen_12_word;

  /// No description provided for @sign_transaction.
  ///
  /// In en, this message translates to:
  /// **'Sign Transaction'**
  String get sign_transaction;

  /// No description provided for @decode.
  ///
  /// In en, this message translates to:
  /// **'Decode'**
  String get decode;

  /// No description provided for @you_disabled_this_dapp_domain.
  ///
  /// In en, this message translates to:
  /// **'You disabled this dApp domain'**
  String get you_disabled_this_dapp_domain;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'enable'**
  String get enable;

  /// No description provided for @reliable.
  ///
  /// In en, this message translates to:
  /// **'Reliable'**
  String get reliable;

  /// No description provided for @extensible.
  ///
  /// In en, this message translates to:
  /// **'Extensible'**
  String get extensible;

  /// No description provided for @efficient.
  ///
  /// In en, this message translates to:
  /// **'Efficient'**
  String get efficient;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @blockchain_for_defi.
  ///
  /// In en, this message translates to:
  /// **'Blockchain for DeFi, NFT and Gaming'**
  String get blockchain_for_defi;

  /// No description provided for @introducing_reef_chain.
  ///
  /// In en, this message translates to:
  /// **'Introducing Reef Chain'**
  String get introducing_reef_chain;

  /// No description provided for @reef_chain_desc.
  ///
  /// In en, this message translates to:
  /// **'Reef chain is an EVM compatible blockchain for DeFi. It is fast, scalable, has low transaction costs and does no wasteful mining. It is built with Substrate Framework and comes with on-chain governance.'**
  String get reef_chain_desc;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @no_account_currently.
  ///
  /// In en, this message translates to:
  /// **'No Account currently available, create or import an account to view your assets.'**
  String get no_account_currently;

  /// No description provided for @claim_evm_account.
  ///
  /// In en, this message translates to:
  /// **'Claim EVM Account'**
  String get claim_evm_account;

  /// No description provided for @transaction_details.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transaction_details;

  /// No description provided for @decoded_data.
  ///
  /// In en, this message translates to:
  /// **'Decoded Data'**
  String get decoded_data;

  /// No description provided for @sign_message.
  ///
  /// In en, this message translates to:
  /// **'Sign Message'**
  String get sign_message;

  /// No description provided for @scan_address.
  ///
  /// In en, this message translates to:
  /// **'Scan Address'**
  String get scan_address;

  /// No description provided for @address_can_not_be_empty.
  ///
  /// In en, this message translates to:
  /// **'Address cannot be empty'**
  String get address_can_not_be_empty;

  /// No description provided for @select_address.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get select_address;

  /// No description provided for @no_token_selected.
  ///
  /// In en, this message translates to:
  /// **'No token selected'**
  String get no_token_selected;

  /// No description provided for @send_to_address.
  ///
  /// In en, this message translates to:
  /// **'Send to address'**
  String get send_to_address;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @more_actions.
  ///
  /// In en, this message translates to:
  /// **'More Actions'**
  String get more_actions;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @reef_evm.
  ///
  /// In en, this message translates to:
  /// **'Reef EVM:'**
  String get reef_evm;

  /// No description provided for @connect_evm.
  ///
  /// In en, this message translates to:
  /// **'Connect EVM'**
  String get connect_evm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy_native_address.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get copy_native_address;

  /// No description provided for @copy_evm_address.
  ///
  /// In en, this message translates to:
  /// **'Copy Reef EVM Address'**
  String get copy_evm_address;

  /// No description provided for @native_address_qr.
  ///
  /// In en, this message translates to:
  /// **'Native Address QR'**
  String get native_address_qr;

  /// No description provided for @evm_address_qr.
  ///
  /// In en, this message translates to:
  /// **'EVM Address QR'**
  String get evm_address_qr;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @share_evm_qr.
  ///
  /// In en, this message translates to:
  /// **'Copy EVM Address'**
  String get share_evm_qr;

  /// No description provided for @share_address_qr.
  ///
  /// In en, this message translates to:
  /// **'Copy Native Address'**
  String get share_address_qr;

  /// No description provided for @select_account.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get select_account;

  /// No description provided for @go_to_home_on_account_switch.
  ///
  /// In en, this message translates to:
  /// **'Go to Home on Account Switch'**
  String get go_to_home_on_account_switch;

  /// No description provided for @restore_from_json.
  ///
  /// In en, this message translates to:
  /// **'From JSON file'**
  String get restore_from_json;

  /// No description provided for @import_from_qr_code.
  ///
  /// In en, this message translates to:
  /// **'From QR code'**
  String get import_from_qr_code;

  /// No description provided for @enter_password_for.
  ///
  /// In en, this message translates to:
  /// **'Enter Password for'**
  String get enter_password_for;

  /// No description provided for @export_account.
  ///
  /// In en, this message translates to:
  /// **'Export Account'**
  String get export_account;

  /// No description provided for @invalid_qr_code.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalid_qr_code;

  /// No description provided for @invalid_qr_msg1.
  ///
  /// In en, this message translates to:
  /// **'This is an invalid QR code!'**
  String get invalid_qr_msg1;

  /// No description provided for @invalid_qr_msg2.
  ///
  /// In en, this message translates to:
  /// **'You can know more about this QR code from the \'Scan QR\' option in Settings'**
  String get invalid_qr_msg2;

  /// No description provided for @get_qr_information.
  ///
  /// In en, this message translates to:
  /// **'Get QR Information'**
  String get get_qr_information;

  /// No description provided for @scan_from_image.
  ///
  /// In en, this message translates to:
  /// **'Scan from Image'**
  String get scan_from_image;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'contract'**
  String get contract;

  /// No description provided for @loading_pool_data.
  ///
  /// In en, this message translates to:
  /// **'Loading pool data'**
  String get loading_pool_data;

  /// No description provided for @no_pool_data.
  ///
  /// In en, this message translates to:
  /// **'No pool data'**
  String get no_pool_data;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @invalid_mnemonic_seed.
  ///
  /// In en, this message translates to:
  /// **'Invalid mnemonic seed'**
  String get invalid_mnemonic_seed;

  /// No description provided for @enable_biometric_authentication.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric authentication'**
  String get enable_biometric_authentication;

  /// No description provided for @authenticate_with_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Authenticate with biometrics'**
  String get authenticate_with_biometrics;

  /// No description provided for @delete_website_url.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the Website with URL'**
  String get delete_website_url;

  /// No description provided for @waiting_for_tx_to_complete.
  ///
  /// In en, this message translates to:
  /// **'Waiting for transaction to complete'**
  String get waiting_for_tx_to_complete;

  /// No description provided for @fund_tx_failed.
  ///
  /// In en, this message translates to:
  /// **'Fund transaction failed'**
  String get fund_tx_failed;

  /// No description provided for @evm_connect_transaction.
  ///
  /// In en, this message translates to:
  /// **'EVM connect transaction'**
  String get evm_connect_transaction;

  /// No description provided for @evm_is_connected.
  ///
  /// In en, this message translates to:
  /// **'EVM is connected'**
  String get evm_is_connected;

  /// No description provided for @select_account_for_funding.
  ///
  /// In en, this message translates to:
  /// **'Select account for funding'**
  String get select_account_for_funding;

  /// No description provided for @incorrect_password_entered.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Password Entered!'**
  String get incorrect_password_entered;

  /// No description provided for @export_custom_pass.
  ///
  /// In en, this message translates to:
  /// **'exporting with custom password!'**
  String get export_custom_pass;

  /// No description provided for @export_app_pass.
  ///
  /// In en, this message translates to:
  /// **'exporting with app password!'**
  String get export_app_pass;

  /// No description provided for @export_diff_pass.
  ///
  /// In en, this message translates to:
  /// **'Export with different password'**
  String get export_diff_pass;

  /// No description provided for @export_pass.
  ///
  /// In en, this message translates to:
  /// **'Export password'**
  String get export_pass;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @metadata_up_to_date.
  ///
  /// In en, this message translates to:
  /// **'Metadata is already up to date'**
  String get metadata_up_to_date;

  /// No description provided for @approve_metadata.
  ///
  /// In en, this message translates to:
  /// **'This approval will add the metadata to your mobile app, allowing future requests to be decoded using this metadata.'**
  String get approve_metadata;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @retrieving_video.
  ///
  /// In en, this message translates to:
  /// **'Retrieving video'**
  String get retrieving_video;

  /// No description provided for @unless_saved.
  ///
  /// In en, this message translates to:
  /// **'if you have not saved your recovery phrase (mnemonic).'**
  String get unless_saved;

  /// No description provided for @decoding_sign.
  ///
  /// In en, this message translates to:
  /// **'decoding signature data'**
  String get decoding_sign;

  /// No description provided for @copy_native.
  ///
  /// In en, this message translates to:
  /// **'Native address copied to clipboard.'**
  String get copy_native;

  /// No description provided for @evm_copy.
  ///
  /// In en, this message translates to:
  /// **'EVM address copied to clipboard.'**
  String get evm_copy;

  /// No description provided for @reef_only.
  ///
  /// In en, this message translates to:
  /// **'Use it ONLY on Reef Chain!'**
  String get reef_only;

  /// No description provided for @name_your_account.
  ///
  /// In en, this message translates to:
  /// **'Name your account'**
  String get name_your_account;

  /// No description provided for @account_imported_successfully.
  ///
  /// In en, this message translates to:
  /// **'Account imported succesfully!'**
  String get account_imported_successfully;

  /// No description provided for @the_pass_is_incorrect.
  ///
  /// In en, this message translates to:
  /// **'The password you entered is Incorrect!'**
  String get the_pass_is_incorrect;

  /// No description provided for @enter_same_pass.
  ///
  /// In en, this message translates to:
  /// **'Please enter the same password you entered while exporting this account. '**
  String get enter_same_pass;

  /// No description provided for @approximate_reef.
  ///
  /// In en, this message translates to:
  /// **'The amount of REEF displayed is an approximation of what you will receive. The final amount will be shown at the time of the transaction.'**
  String get approximate_reef;

  /// No description provided for @create_purchase.
  ///
  /// In en, this message translates to:
  /// **'Create a new purchase'**
  String get create_purchase;

  /// No description provided for @check_order_status.
  ///
  /// In en, this message translates to:
  /// **'Check order status'**
  String get check_order_status;

  /// No description provided for @completed_binance_purchase.
  ///
  /// In en, this message translates to:
  /// **'If you have completed your purchase on Binance Connect, your REEF balance will be updated after the transaction has been confirmed onchain.'**
  String get completed_binance_purchase;

  /// No description provided for @go_to_binance.
  ///
  /// In en, this message translates to:
  /// **'Go to Binance Connect'**
  String get go_to_binance;

  /// No description provided for @biometric_auth.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometric_auth;

  /// No description provided for @dont_send_funds_here.
  ///
  /// In en, this message translates to:
  /// **'don\'t send funds here'**
  String get dont_send_funds_here;

  /// No description provided for @insufficient_funds_fill_up.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Funds! Please fill up your Reef Wallet'**
  String get insufficient_funds_fill_up;

  /// No description provided for @changes_recorded.
  ///
  /// In en, this message translates to:
  /// **'Changes recorded'**
  String get changes_recorded;

  /// No description provided for @permanently_lose.
  ///
  /// In en, this message translates to:
  /// **'permanently lose'**
  String get permanently_lose;

  /// No description provided for @access_to.
  ///
  /// In en, this message translates to:
  /// **'access to'**
  String get access_to;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @scan_with_reef_app.
  ///
  /// In en, this message translates to:
  /// **'Scan with Reef App on another device to import.'**
  String get scan_with_reef_app;

  /// No description provided for @transaction_info.
  ///
  /// In en, this message translates to:
  /// **'Transaction Info'**
  String get transaction_info;

  /// No description provided for @send_tokens.
  ///
  /// In en, this message translates to:
  /// **'Send Tokens'**
  String get send_tokens;

  /// No description provided for @swap_tokens.
  ///
  /// In en, this message translates to:
  /// **'Swap Tokens'**
  String get swap_tokens;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'connecting...'**
  String get connecting;

  /// No description provided for @connection_stats.
  ///
  /// In en, this message translates to:
  /// **'Connection Stats'**
  String get connection_stats;

  /// No description provided for @sending_tx_to_nw.
  ///
  /// In en, this message translates to:
  /// **'Sending Transaction to the network ...'**
  String get sending_tx_to_nw;

  /// No description provided for @waiting_to_include_in_block.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be included in next Block...'**
  String get waiting_to_include_in_block;

  /// No description provided for @unreversible_finality.
  ///
  /// In en, this message translates to:
  /// **'After this transaction has unreversible finality.'**
  String get unreversible_finality;

  /// No description provided for @transaction_finalized.
  ///
  /// In en, this message translates to:
  /// **'Transaction Finalized'**
  String get transaction_finalized;

  /// No description provided for @sending_transaction.
  ///
  /// In en, this message translates to:
  /// **'Sending Transaction'**
  String get sending_transaction;

  /// No description provided for @adding_to_chain.
  ///
  /// In en, this message translates to:
  /// **'Adding to Chain'**
  String get adding_to_chain;

  /// No description provided for @sealing_block.
  ///
  /// In en, this message translates to:
  /// **'Sealing the Block'**
  String get sealing_block;

  /// No description provided for @generating_signature.
  ///
  /// In en, this message translates to:
  /// **'Generating Signature'**
  String get generating_signature;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @missing_destination.
  ///
  /// In en, this message translates to:
  /// **'Missing destination address'**
  String get missing_destination;

  /// No description provided for @recipient_not_binded.
  ///
  /// In en, this message translates to:
  /// **'Recipient EVM not binded'**
  String get recipient_not_binded;

  /// No description provided for @insert_amount.
  ///
  /// In en, this message translates to:
  /// **'Insert amount'**
  String get insert_amount;

  /// No description provided for @amount_too_high.
  ///
  /// In en, this message translates to:
  /// **'Amount too high'**
  String get amount_too_high;

  /// No description provided for @target_not_evm.
  ///
  /// In en, this message translates to:
  /// **'Target not EVM'**
  String get target_not_evm;

  /// No description provided for @enter_valid_address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid address'**
  String get enter_valid_address;

  /// No description provided for @unknown_address.
  ///
  /// In en, this message translates to:
  /// **'Unknown address'**
  String get unknown_address;

  /// No description provided for @sending_tx.
  ///
  /// In en, this message translates to:
  /// **'Signing transaction ...'**
  String get sending_tx;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending ...'**
  String get sending;

  /// No description provided for @minimum_80_reef.
  ///
  /// In en, this message translates to:
  /// **'Minimum balance 80 REEF'**
  String get minimum_80_reef;

  /// No description provided for @minimum_5_reef.
  ///
  /// In en, this message translates to:
  /// **'Minimum balance 5 REEF'**
  String get minimum_5_reef;

  /// No description provided for @evm_not_connected.
  ///
  /// In en, this message translates to:
  /// **'EVM not connected'**
  String get evm_not_connected;

  /// No description provided for @confirm_send.
  ///
  /// In en, this message translates to:
  /// **'Confirm Send'**
  String get confirm_send;

  /// No description provided for @not_valid.
  ///
  /// In en, this message translates to:
  /// **'Not Valid'**
  String get not_valid;

  /// No description provided for @allow_10_s.
  ///
  /// In en, this message translates to:
  /// **'Allow ~10s before restarting app.'**
  String get allow_10_s;

  /// No description provided for @restart_app.
  ///
  /// In en, this message translates to:
  /// **'Restart App'**
  String get restart_app;

  /// No description provided for @you_are_a_dev.
  ///
  /// In en, this message translates to:
  /// **'You are a developer now'**
  String get you_are_a_dev;

  /// No description provided for @more_times_to_enable.
  ///
  /// In en, this message translates to:
  /// **'more times to enable developer settings'**
  String get more_times_to_enable;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get tap;

  /// No description provided for @show_nft_info.
  ///
  /// In en, this message translates to:
  /// **'Show NFT info'**
  String get show_nft_info;

  /// No description provided for @contract_address.
  ///
  /// In en, this message translates to:
  /// **'Contract Address : '**
  String get contract_address;

  /// No description provided for @nft_id.
  ///
  /// In en, this message translates to:
  /// **'NFT ID : '**
  String get nft_id;

  /// No description provided for @fetching_nft_details.
  ///
  /// In en, this message translates to:
  /// **'Fetching NFT details...'**
  String get fetching_nft_details;

  /// No description provided for @send_nft.
  ///
  /// In en, this message translates to:
  /// **'Send NFT'**
  String get send_nft;

  /// No description provided for @scan_qr_code.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scan_qr_code;

  /// No description provided for @create_new_connection.
  ///
  /// In en, this message translates to:
  /// **'Create new connection'**
  String get create_new_connection;

  /// No description provided for @no_active_sessions.
  ///
  /// In en, this message translates to:
  /// **'No active sessions'**
  String get no_active_sessions;

  /// No description provided for @approveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Approving {amount} {tokenSymbol} to {recipientAddress}'**
  String approveTransaction(
      Object amount, Object recipientAddress, Object tokenSymbol);

  /// No description provided for @send_transaction.
  ///
  /// In en, this message translates to:
  /// **'Sending {amount} {symbol} to {to}'**
  String send_transaction(Object amount, Object symbol, Object to);

  /// No description provided for @swap_transaction.
  ///
  /// In en, this message translates to:
  /// **'Swapping {token1_amount} {token1_name} for {token2_amount} {token2_name}'**
  String swap_transaction(Object token1_amount, Object token1_name,
      Object token2_amount, Object token2_name);

  /// No description provided for @nft_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfering {amount} NFT with ID: {id} to {to}'**
  String nft_transfer(Object amount, Object id, Object to);

  /// No description provided for @sending_native_transaction.
  ///
  /// In en, this message translates to:
  /// **'Sending {value} to {dest} natively.'**
  String sending_native_transaction(Object dest, Object value);

  /// No description provided for @claiming_default_account.
  ///
  /// In en, this message translates to:
  /// **'Claiming default EVM Address'**
  String get claiming_default_account;
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
      <String>['en', 'hi', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
