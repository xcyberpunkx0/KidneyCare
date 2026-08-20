import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'KidneyCare'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparing;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLabs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get navLabs;

  /// No description provided for @navDialysis.
  ///
  /// In en, this message translates to:
  /// **'Dialysis'**
  String get navDialysis;

  /// No description provided for @navMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get navMedicines;

  /// No description provided for @navAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get navAsk;

  /// No description provided for @captureDocument.
  ///
  /// In en, this message translates to:
  /// **'Capture a document'**
  String get captureDocument;

  /// No description provided for @settingUpVault.
  ///
  /// In en, this message translates to:
  /// **'Setting up the vault…'**
  String get settingUpVault;

  /// No description provided for @switchToLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get switchToLightTheme;

  /// No description provided for @switchToDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get switchToDarkTheme;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search reports, medicines, doctors…'**
  String get homeSearchHint;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'NEEDS ATTENTION · {count}'**
  String needsAttention(int count);

  /// No description provided for @todaysDoses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s doses'**
  String get todaysDoses;

  /// No description provided for @dosesGiven.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} given'**
  String dosesGiven(int taken, int total);

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @allDocuments.
  ///
  /// In en, this message translates to:
  /// **'All documents'**
  String get allDocuments;

  /// No description provided for @recentRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent records'**
  String get recentRecords;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @nextDialysis.
  ///
  /// In en, this message translates to:
  /// **'NEXT DIALYSIS'**
  String get nextDialysis;

  /// No description provided for @notScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get notScheduled;

  /// No description provided for @inHours.
  ///
  /// In en, this message translates to:
  /// **'in {hours} h'**
  String inHours(int hours);

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get now;

  /// No description provided for @addScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Add a dialysis schedule to see it here'**
  String get addScheduleHint;

  /// No description provided for @lastSession.
  ///
  /// In en, this message translates to:
  /// **'last: {summary}'**
  String lastSession(String summary);

  /// No description provided for @logSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Log session'**
  String get logSessionAction;

  /// No description provided for @logSymptomAction.
  ///
  /// In en, this message translates to:
  /// **'Log symptom'**
  String get logSymptomAction;

  /// No description provided for @doseTaken.
  ///
  /// In en, this message translates to:
  /// **'{medicine} at {time}, taken — tap to undo'**
  String doseTaken(String medicine, String time);

  /// No description provided for @doseMark.
  ///
  /// In en, this message translates to:
  /// **'{medicine} at {time}, tap to mark taken'**
  String doseMark(String medicine, String time);

  /// No description provided for @doseNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT · {time}'**
  String doseNext(String time);

  /// No description provided for @folderFiles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String folderFiles(int count);

  /// No description provided for @folderSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name} folder, {count} files'**
  String folderSemantics(String name, int count);

  /// No description provided for @vitalDryWeight.
  ///
  /// In en, this message translates to:
  /// **'Dry weight'**
  String get vitalDryWeight;

  /// No description provided for @vitalHb.
  ///
  /// In en, this message translates to:
  /// **'Hb g/dL'**
  String get vitalHb;

  /// No description provided for @vitalPotassium.
  ///
  /// In en, this message translates to:
  /// **'K⁺ mmol/L'**
  String get vitalPotassium;

  /// No description provided for @vitalBpToday.
  ///
  /// In en, this message translates to:
  /// **'BP today'**
  String get vitalBpToday;

  /// No description provided for @vitalAlbumin.
  ///
  /// In en, this message translates to:
  /// **'Albumin'**
  String get vitalAlbumin;

  /// No description provided for @vitalActiveMeds.
  ///
  /// In en, this message translates to:
  /// **'Active meds'**
  String get vitalActiveMeds;

  /// No description provided for @attentionBelowRecheck.
  ///
  /// In en, this message translates to:
  /// **'below range — recheck due'**
  String get attentionBelowRecheck;

  /// No description provided for @attentionFallingMonths.
  ///
  /// In en, this message translates to:
  /// **'falling {months} months — recheck due'**
  String attentionFallingMonths(int months);

  /// No description provided for @attentionAboveDiet.
  ///
  /// In en, this message translates to:
  /// **'above range — review diet with the care team'**
  String get attentionAboveDiet;

  /// No description provided for @abnormalSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} {value}, abnormal'**
  String abnormalSemantics(String label, String value);

  /// No description provided for @labs.
  ///
  /// In en, this message translates to:
  /// **'Labs'**
  String get labs;

  /// No description provided for @lastTest.
  ///
  /// In en, this message translates to:
  /// **'last test {date}'**
  String lastTest(String date);

  /// No description provided for @enterLabValuesManually.
  ///
  /// In en, this message translates to:
  /// **'Enter lab values manually'**
  String get enterLabValuesManually;

  /// No description provided for @allValuesOn.
  ///
  /// In en, this message translates to:
  /// **'All values · {date}'**
  String allValuesOn(String date);

  /// No description provided for @noLabsTitle.
  ///
  /// In en, this message translates to:
  /// **'No lab results yet'**
  String get noLabsTitle;

  /// No description provided for @noLabsMessage.
  ///
  /// In en, this message translates to:
  /// **'Capture a lab report, or type the values in yourself, to begin tracking trends.'**
  String get noLabsMessage;

  /// No description provided for @enterValuesManually.
  ///
  /// In en, this message translates to:
  /// **'Enter values manually'**
  String get enterValuesManually;

  /// No description provided for @labsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Labs are unavailable'**
  String get labsUnavailableTitle;

  /// No description provided for @labsUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The stored lab history could not be read. Please restart the app.'**
  String get labsUnavailableMessage;

  /// No description provided for @belowRange.
  ///
  /// In en, this message translates to:
  /// **'below range'**
  String get belowRange;

  /// No description provided for @aboveRange.
  ///
  /// In en, this message translates to:
  /// **'above range'**
  String get aboveRange;

  /// No description provided for @steady.
  ///
  /// In en, this message translates to:
  /// **'steady'**
  String get steady;

  /// No description provided for @rangeCaption.
  ///
  /// In en, this message translates to:
  /// **'{metric} · normal {min}–{max} · shaded = normal'**
  String rangeCaption(String metric, String min, String max);

  /// No description provided for @noReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get noReadingsYet;

  /// No description provided for @showMetricChart.
  ///
  /// In en, this message translates to:
  /// **'Show {metric} chart'**
  String showMetricChart(String metric);

  /// No description provided for @enterLabValues.
  ///
  /// In en, this message translates to:
  /// **'Enter lab values'**
  String get enterLabValues;

  /// No description provided for @enterLabValuesCopy.
  ///
  /// In en, this message translates to:
  /// **'Type in the values from the report — leave anything blank that was not tested.'**
  String get enterLabValuesCopy;

  /// No description provided for @changeUnit.
  ///
  /// In en, this message translates to:
  /// **'Change unit, currently {unit}'**
  String changeUnit(String unit);

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'REPORT DATE'**
  String get reportDate;

  /// No description provided for @changeReportDate.
  ///
  /// In en, this message translates to:
  /// **'Change report date, currently {date}'**
  String changeReportDate(String date);

  /// No description provided for @kidneyFunction.
  ///
  /// In en, this message translates to:
  /// **'KIDNEY FUNCTION'**
  String get kidneyFunction;

  /// No description provided for @bloodCounts.
  ///
  /// In en, this message translates to:
  /// **'BLOOD COUNTS'**
  String get bloodCounts;

  /// No description provided for @vitalsGroup.
  ///
  /// In en, this message translates to:
  /// **'VITALS'**
  String get vitalsGroup;

  /// No description provided for @normalRangeHint.
  ///
  /// In en, this message translates to:
  /// **'normal {min}–{max} {unit}'**
  String normalRangeHint(String min, String max, String unit);

  /// No description provided for @saveToTimeline.
  ///
  /// In en, this message translates to:
  /// **'Save to timeline'**
  String get saveToTimeline;

  /// No description provided for @labValuesSaved.
  ///
  /// In en, this message translates to:
  /// **'Lab values saved to the timeline'**
  String get labValuesSaved;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @nActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String nActive(int count);

  /// No description provided for @withFoodGroup.
  ///
  /// In en, this message translates to:
  /// **'WITH FOOD'**
  String get withFoodGroup;

  /// No description provided for @byTheClockGroup.
  ///
  /// In en, this message translates to:
  /// **'BY THE CLOCK'**
  String get byTheClockGroup;

  /// No description provided for @endedMedicinesCollapsed.
  ///
  /// In en, this message translates to:
  /// **'Ended medicines ({count})  ▾'**
  String endedMedicinesCollapsed(int count);

  /// No description provided for @endedMedicinesExpanded.
  ///
  /// In en, this message translates to:
  /// **'Ended medicines  ▴'**
  String get endedMedicinesExpanded;

  /// No description provided for @endedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String endedOn(String date);

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @noMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'No medicines recorded'**
  String get noMedicinesTitle;

  /// No description provided for @noMedicinesMessage.
  ///
  /// In en, this message translates to:
  /// **'Capture a prescription, or add medicines yourself, to build the list.'**
  String get noMedicinesMessage;

  /// No description provided for @addMedicineManually.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine manually'**
  String get addMedicineManually;

  /// No description provided for @addAMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add a medicine'**
  String get addAMedicine;

  /// No description provided for @addMedicineCopy.
  ///
  /// In en, this message translates to:
  /// **'For prescriptions given verbally or without a paper to photograph.'**
  String get addMedicineCopy;

  /// No description provided for @medicineStrength.
  ///
  /// In en, this message translates to:
  /// **'MEDICINE & STRENGTH'**
  String get medicineStrength;

  /// No description provided for @medicineStrengthHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sevelamer 400 mg'**
  String get medicineStrengthHint;

  /// No description provided for @pattern.
  ///
  /// In en, this message translates to:
  /// **'PATTERN'**
  String get pattern;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'PURPOSE'**
  String get purpose;

  /// No description provided for @purposeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Phosphate binder'**
  String get purposeHint;

  /// No description provided for @prescribedBy.
  ///
  /// In en, this message translates to:
  /// **'PRESCRIBED BY'**
  String get prescribedBy;

  /// No description provided for @prescribedByHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Menon'**
  String get prescribedByHint;

  /// No description provided for @whenTaken.
  ///
  /// In en, this message translates to:
  /// **'WHEN IS IT TAKEN?'**
  String get whenTaken;

  /// No description provided for @timingCuesHint.
  ///
  /// In en, this message translates to:
  /// **'Timing cues (shown as icons on the card)'**
  String get timingCuesHint;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'INSTRUCTIONS'**
  String get instructions;

  /// No description provided for @instructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. with every meal'**
  String get instructionsHint;

  /// No description provided for @addMedicineButton.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicineButton;

  /// No description provided for @medicineAdded.
  ///
  /// In en, this message translates to:
  /// **'Medicine added'**
  String get medicineAdded;

  /// No description provided for @enterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the medicine name.'**
  String get enterMedicineName;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @nScans.
  ///
  /// In en, this message translates to:
  /// **'{count} scans'**
  String nScans(int count);

  /// No description provided for @documentsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by hospital, doctor, tag…'**
  String get documentsSearchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get noDocumentsTitle;

  /// No description provided for @noDocumentsMessage.
  ///
  /// In en, this message translates to:
  /// **'No reports match this view yet. Capture a prescription or lab report to begin building the patient\'s medical history.'**
  String get noDocumentsMessage;

  /// No description provided for @documentsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents are unavailable'**
  String get documentsUnavailableTitle;

  /// No description provided for @documentsUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The stored library could not be read. Please restart the app.'**
  String get documentsUnavailableMessage;

  /// No description provided for @documentNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get documentNotFoundTitle;

  /// No description provided for @documentNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This record may have been removed from the vault.'**
  String get documentNotFoundMessage;

  /// No description provided for @extractedText.
  ///
  /// In en, this message translates to:
  /// **'EXTRACTED TEXT'**
  String get extractedText;

  /// No description provided for @fillFrame.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with the document'**
  String get fillFrame;

  /// No description provided for @docInView.
  ///
  /// In en, this message translates to:
  /// **'prescription / lab report\nin view'**
  String get docInView;

  /// No description provided for @pickFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Pick from photo library'**
  String get pickFromLibrary;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @adjustCorners.
  ///
  /// In en, this message translates to:
  /// **'Adjust the corners'**
  String get adjustCorners;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get usePhoto;

  /// No description provided for @preparingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparingPhoto;

  /// No description provided for @cropFailed.
  ///
  /// In en, this message translates to:
  /// **'The image could not be cropped. Please retake the photo.'**
  String get cropFailed;

  /// No description provided for @readingDocument.
  ///
  /// In en, this message translates to:
  /// **'Reading the document'**
  String get readingDocument;

  /// No description provided for @extractReassurance.
  ///
  /// In en, this message translates to:
  /// **'Medicines are checked against {name}\'s history. Nothing is saved until you review it.'**
  String extractReassurance(String name);

  /// No description provided for @thePatient.
  ///
  /// In en, this message translates to:
  /// **'the patient'**
  String get thePatient;

  /// No description provided for @reviewExtraction.
  ///
  /// In en, this message translates to:
  /// **'Review extraction'**
  String get reviewExtraction;

  /// No description provided for @fieldsRead.
  ///
  /// In en, this message translates to:
  /// **'{count} fields read'**
  String fieldsRead(int count);

  /// No description provided for @fieldsNeedCheck.
  ///
  /// In en, this message translates to:
  /// **'{unchecked} of {total} fields need a check before saving'**
  String fieldsNeedCheck(int unchecked, int total);

  /// No description provided for @allFieldsChecked.
  ///
  /// In en, this message translates to:
  /// **'All fields checked — ready to save'**
  String get allFieldsChecked;

  /// No description provided for @pleaseVerifyField.
  ///
  /// In en, this message translates to:
  /// **'Please verify this field before saving.'**
  String get pleaseVerifyField;

  /// No description provided for @checkedChip.
  ///
  /// In en, this message translates to:
  /// **'✓ checked'**
  String get checkedChip;

  /// No description provided for @percentCheck.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · check'**
  String percentCheck(int percent);

  /// No description provided for @savedToTimeline.
  ///
  /// In en, this message translates to:
  /// **'Saved to the timeline'**
  String get savedToTimeline;

  /// No description provided for @ask.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get ask;

  /// No description provided for @searchesAllDocuments.
  ///
  /// In en, this message translates to:
  /// **'searches all {count} documents'**
  String searchesAllDocuments(int count);

  /// No description provided for @askIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about the medical history — medicines during an admission, lab trends, procedures. Answers cite the exact documents they come from.'**
  String get askIntro;

  /// No description provided for @askThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get askThinking;

  /// No description provided for @askSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'When was Hb above 10?'**
  String get askSuggestion1;

  /// No description provided for @askSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'What antibiotics were given during the June admission?'**
  String get askSuggestion2;

  /// No description provided for @askSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Show all dialysis catheter procedures'**
  String get askSuggestion3;

  /// No description provided for @sources.
  ///
  /// In en, this message translates to:
  /// **'SOURCES'**
  String get sources;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open source: {title}'**
  String openSource(String title);

  /// No description provided for @confirmWithDoctor.
  ///
  /// In en, this message translates to:
  /// **'Always confirm with the treating doctor before acting on this.'**
  String get confirmWithDoctor;

  /// No description provided for @askInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about the history…'**
  String get askInputHint;

  /// No description provided for @sendQuestion.
  ///
  /// In en, this message translates to:
  /// **'Send question'**
  String get sendQuestion;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @timelineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The timeline is empty'**
  String get timelineEmptyTitle;

  /// No description provided for @timelineEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No reports have been added yet. Capture your first prescription to begin building the patient\'s medical history.'**
  String get timelineEmptyMessage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @globalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Reports, medicines, doctors, hospitals…'**
  String get globalSearchHint;

  /// No description provided for @searchVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Search the whole vault'**
  String get searchVaultTitle;

  /// No description provided for @searchVaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Medicines, doctors, hospitals, lab values and every scanned document — results appear as you type.'**
  String get searchVaultMessage;

  /// No description provided for @searchUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Search is unavailable'**
  String get searchUnavailableTitle;

  /// No description provided for @searchUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while searching. Please try again.'**
  String get searchUnavailableMessage;

  /// No description provided for @nothingFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFoundTitle;

  /// No description provided for @nothingFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No records match this search yet.'**
  String get nothingFoundMessage;

  /// No description provided for @sectionDocuments.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENTS'**
  String get sectionDocuments;

  /// No description provided for @sectionMedicines.
  ///
  /// In en, this message translates to:
  /// **'MEDICINES'**
  String get sectionMedicines;

  /// No description provided for @sectionTimeline.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE'**
  String get sectionTimeline;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get patientDetails;

  /// No description provided for @patientDetailsSub.
  ///
  /// In en, this message translates to:
  /// **'Name, condition, dialysis schedule'**
  String get patientDetailsSub;

  /// No description provided for @emergencyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency card'**
  String get emergencyCardTitle;

  /// No description provided for @emergencyCardSub.
  ///
  /// In en, this message translates to:
  /// **'Condition, blood group, allergies — ready to show or send'**
  String get emergencyCardSub;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersSub.
  ///
  /// In en, this message translates to:
  /// **'Dose times and two hours before dialysis'**
  String get remindersSub;

  /// No description provided for @visitSummary.
  ///
  /// In en, this message translates to:
  /// **'Doctor-visit summary'**
  String get visitSummary;

  /// No description provided for @visitSummarySub.
  ///
  /// In en, this message translates to:
  /// **'A one-page PDF of medicines, labs and recent events'**
  String get visitSummarySub;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export vault backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSub.
  ///
  /// In en, this message translates to:
  /// **'Share the full record as a JSON file'**
  String get exportBackupSub;

  /// No description provided for @encryptionTitle.
  ///
  /// In en, this message translates to:
  /// **'On-device encryption'**
  String get encryptionTitle;

  /// No description provided for @encryptionSub.
  ///
  /// In en, this message translates to:
  /// **'The vault database is encrypted with SQLCipher; the key never leaves this device'**
  String get encryptionSub;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSub.
  ///
  /// In en, this message translates to:
  /// **'Follows the device unless you choose'**
  String get languageSub;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @setUpVault.
  ///
  /// In en, this message translates to:
  /// **'Set up the vault'**
  String get setUpVault;

  /// No description provided for @setUpVaultCopy.
  ///
  /// In en, this message translates to:
  /// **'A few details about the person you care for. Everything stays on this device, encrypted.'**
  String get setUpVaultCopy;

  /// No description provided for @patientEditCopy.
  ///
  /// In en, this message translates to:
  /// **'Changes apply across the whole vault.'**
  String get patientEditCopy;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. N. Ramachandran'**
  String get fullNameHint;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'AGE'**
  String get age;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'CONDITION'**
  String get condition;

  /// No description provided for @dialysisSchedule.
  ///
  /// In en, this message translates to:
  /// **'DIALYSIS SCHEDULE'**
  String get dialysisSchedule;

  /// No description provided for @tapTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a time to change it — each day can differ'**
  String get tapTimeHint;

  /// No description provided for @sessionTimeOn.
  ///
  /// In en, this message translates to:
  /// **'Session time on {day}'**
  String sessionTimeOn(String day);

  /// No description provided for @changeSessionTime.
  ///
  /// In en, this message translates to:
  /// **'Change session time on {day}, currently {time}'**
  String changeSessionTime(String day, String time);

  /// No description provided for @dialysisCentre.
  ///
  /// In en, this message translates to:
  /// **'DIALYSIS CENTRE'**
  String get dialysisCentre;

  /// No description provided for @dialysisCentreHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nephron Centre'**
  String get dialysisCentreHint;

  /// No description provided for @dryWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'DRY WEIGHT (KG)'**
  String get dryWeightKgLabel;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'BLOOD GROUP'**
  String get bloodGroup;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'ALLERGIES'**
  String get allergies;

  /// No description provided for @allergiesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Penicillin — leave blank if none'**
  String get allergiesHint;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY CONTACT'**
  String get emergencyContact;

  /// No description provided for @emergencyContactHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aditya (son) · 98xxxxxx21'**
  String get emergencyContactHint;

  /// No description provided for @createVault.
  ///
  /// In en, this message translates to:
  /// **'Create the vault'**
  String get createVault;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @exploreSampleData.
  ///
  /// In en, this message translates to:
  /// **'Explore with sample data instead'**
  String get exploreSampleData;

  /// No description provided for @fillNameAge.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the name and a valid age.'**
  String get fillNameAge;

  /// No description provided for @dialysis.
  ///
  /// In en, this message translates to:
  /// **'Dialysis'**
  String get dialysis;

  /// No description provided for @nLogged.
  ///
  /// In en, this message translates to:
  /// **'{count} logged'**
  String nLogged(int count);

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get sessionHistory;

  /// No description provided for @noSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No sessions logged yet'**
  String get noSessionsTitle;

  /// No description provided for @noSessionsMessage.
  ///
  /// In en, this message translates to:
  /// **'After each dialysis, log the session here — weights, fluid removed, and how it went.'**
  String get noSessionsMessage;

  /// No description provided for @logASession.
  ///
  /// In en, this message translates to:
  /// **'Log a session'**
  String get logASession;

  /// No description provided for @logSessionCopy.
  ///
  /// In en, this message translates to:
  /// **'Today\'s dialysis, in the record. Fill what you know — everything except duration is optional.'**
  String get logSessionCopy;

  /// No description provided for @sessionDate.
  ///
  /// In en, this message translates to:
  /// **'SESSION DATE'**
  String get sessionDate;

  /// No description provided for @sessionDateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Session date'**
  String get sessionDateDialogTitle;

  /// No description provided for @changeSessionDate.
  ///
  /// In en, this message translates to:
  /// **'Change session date, currently {date}'**
  String changeSessionDate(String date);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get duration;

  /// No description provided for @preWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'PRE WEIGHT (KG)'**
  String get preWeightKgLabel;

  /// No description provided for @postWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'POST WEIGHT (KG)'**
  String get postWeightKgLabel;

  /// No description provided for @ufRemoved.
  ///
  /// In en, this message translates to:
  /// **'UF REMOVED (L)'**
  String get ufRemoved;

  /// No description provided for @bpSys.
  ///
  /// In en, this message translates to:
  /// **'BP SYS'**
  String get bpSys;

  /// No description provided for @bpDia.
  ///
  /// In en, this message translates to:
  /// **'BP DIA'**
  String get bpDia;

  /// No description provided for @howDidItGo.
  ///
  /// In en, this message translates to:
  /// **'HOW DID IT GO?'**
  String get howDidItGo;

  /// No description provided for @orTypeNote.
  ///
  /// In en, this message translates to:
  /// **'or type a note…'**
  String get orTypeNote;

  /// No description provided for @saveSession.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get saveSession;

  /// No description provided for @sessionLogged.
  ///
  /// In en, this message translates to:
  /// **'Session logged'**
  String get sessionLogged;

  /// No description provided for @logged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get logged;

  /// No description provided for @noteNoCramps.
  ///
  /// In en, this message translates to:
  /// **'no cramps'**
  String get noteNoCramps;

  /// No description provided for @noteCramps.
  ///
  /// In en, this message translates to:
  /// **'cramps'**
  String get noteCramps;

  /// No description provided for @noteBpDipped.
  ///
  /// In en, this message translates to:
  /// **'BP dipped'**
  String get noteBpDipped;

  /// No description provided for @noteFeltWeak.
  ///
  /// In en, this message translates to:
  /// **'felt weak after'**
  String get noteFeltWeak;

  /// No description provided for @noteWentWell.
  ///
  /// In en, this message translates to:
  /// **'went well'**
  String get noteWentWell;

  /// No description provided for @logASymptom.
  ///
  /// In en, this message translates to:
  /// **'Log a symptom'**
  String get logASymptom;

  /// No description provided for @logSymptomCopy.
  ///
  /// In en, this message translates to:
  /// **'What you notice between sessions matters at the next appointment. Ten seconds now saves a forgotten detail later.'**
  String get logSymptomCopy;

  /// No description provided for @observed.
  ///
  /// In en, this message translates to:
  /// **'OBSERVED'**
  String get observed;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get note;

  /// No description provided for @symptomNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. after climbing stairs, since yesterday evening…'**
  String get symptomNoteHint;

  /// No description provided for @notedOnTimeline.
  ///
  /// In en, this message translates to:
  /// **'Noted on the timeline'**
  String get notedOnTimeline;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomSwelling.
  ///
  /// In en, this message translates to:
  /// **'Swelling'**
  String get symptomSwelling;

  /// No description provided for @symptomBreathlessness.
  ///
  /// In en, this message translates to:
  /// **'Breathlessness'**
  String get symptomBreathlessness;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomDizziness.
  ///
  /// In en, this message translates to:
  /// **'Dizziness'**
  String get symptomDizziness;

  /// No description provided for @symptomLowBp.
  ///
  /// In en, this message translates to:
  /// **'Low BP'**
  String get symptomLowBp;

  /// No description provided for @symptomFever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get symptomFever;

  /// No description provided for @symptomItching.
  ///
  /// In en, this message translates to:
  /// **'Itching'**
  String get symptomItching;

  /// No description provided for @symptomPoorAppetite.
  ///
  /// In en, this message translates to:
  /// **'Poor appetite'**
  String get symptomPoorAppetite;

  /// No description provided for @symptomChestDiscomfort.
  ///
  /// In en, this message translates to:
  /// **'Chest discomfort'**
  String get symptomChestDiscomfort;

  /// No description provided for @symptomAccessSitePain.
  ///
  /// In en, this message translates to:
  /// **'Access site pain'**
  String get symptomAccessSitePain;

  /// No description provided for @emergencyCardCopy.
  ///
  /// In en, this message translates to:
  /// **'For any hospital visit — the first minute of context, ready to show or send.'**
  String get emergencyCardCopy;

  /// No description provided for @shareCard.
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get shareCard;

  /// No description provided for @allergiesLabel.
  ///
  /// In en, this message translates to:
  /// **'ALLERGIES'**
  String get allergiesLabel;

  /// No description provided for @noneKnown.
  ///
  /// In en, this message translates to:
  /// **'None known'**
  String get noneKnown;

  /// No description provided for @dialysisCentreLabel.
  ///
  /// In en, this message translates to:
  /// **'DIALYSIS CENTRE'**
  String get dialysisCentreLabel;

  /// No description provided for @medicinesLabel.
  ///
  /// In en, this message translates to:
  /// **'MEDICINES'**
  String get medicinesLabel;

  /// No description provided for @emergencyContactLabel.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY CONTACT'**
  String get emergencyContactLabel;

  /// No description provided for @noPatientTitle.
  ///
  /// In en, this message translates to:
  /// **'No patient details yet'**
  String get noPatientTitle;

  /// No description provided for @noPatientMessage.
  ///
  /// In en, this message translates to:
  /// **'Fill in the patient profile first.'**
  String get noPatientMessage;

  /// No description provided for @docTypeLabReport.
  ///
  /// In en, this message translates to:
  /// **'Lab report'**
  String get docTypeLabReport;

  /// No description provided for @docTypePrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get docTypePrescription;

  /// No description provided for @docTypeDischargeSummary.
  ///
  /// In en, this message translates to:
  /// **'Discharge summary'**
  String get docTypeDischargeSummary;

  /// No description provided for @docTypeBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get docTypeBill;

  /// No description provided for @docTypeHandwrittenNote.
  ///
  /// In en, this message translates to:
  /// **'Handwritten note'**
  String get docTypeHandwrittenNote;

  /// No description provided for @docTypeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get docTypeScan;

  /// No description provided for @eventAdmission.
  ///
  /// In en, this message translates to:
  /// **'Admission'**
  String get eventAdmission;

  /// No description provided for @eventProcedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get eventProcedure;

  /// No description provided for @eventMedicationChange.
  ///
  /// In en, this message translates to:
  /// **'Medication change'**
  String get eventMedicationChange;

  /// No description provided for @eventDialysis.
  ///
  /// In en, this message translates to:
  /// **'Dialysis'**
  String get eventDialysis;

  /// No description provided for @eventLabReport.
  ///
  /// In en, this message translates to:
  /// **'Lab report'**
  String get eventLabReport;

  /// No description provided for @eventPrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get eventPrescription;

  /// No description provided for @eventDoctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit'**
  String get eventDoctorVisit;

  /// No description provided for @eventBill.
  ///
  /// In en, this message translates to:
  /// **'Hospital bill'**
  String get eventBill;

  /// No description provided for @eventDischarge.
  ///
  /// In en, this message translates to:
  /// **'Discharge summary'**
  String get eventDischarge;

  /// No description provided for @eventSymptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get eventSymptom;

  /// No description provided for @groupWithFood.
  ///
  /// In en, this message translates to:
  /// **'With food'**
  String get groupWithFood;

  /// No description provided for @groupByClock.
  ///
  /// In en, this message translates to:
  /// **'By the clock'**
  String get groupByClock;

  /// No description provided for @groupWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get groupWeekly;

  /// No description provided for @cueMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get cueMorning;

  /// No description provided for @cueNoon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get cueNoon;

  /// No description provided for @cueNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get cueNight;

  /// No description provided for @cueBeforeFood.
  ///
  /// In en, this message translates to:
  /// **'Before food'**
  String get cueBeforeFood;

  /// No description provided for @cueAfterFood.
  ///
  /// In en, this message translates to:
  /// **'After food'**
  String get cueAfterFood;

  /// No description provided for @cueWithFood.
  ///
  /// In en, this message translates to:
  /// **'With food'**
  String get cueWithFood;

  /// No description provided for @cueDialysisDayOnly.
  ///
  /// In en, this message translates to:
  /// **'Dialysis day only'**
  String get cueDialysisDayOnly;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @folderLabReports.
  ///
  /// In en, this message translates to:
  /// **'Lab reports'**
  String get folderLabReports;

  /// No description provided for @folderPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get folderPrescriptions;

  /// No description provided for @folderDischarge.
  ///
  /// In en, this message translates to:
  /// **'Discharge'**
  String get folderDischarge;

  /// No description provided for @folderBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get folderBills;

  /// No description provided for @reportDateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Report date'**
  String get reportDateDialogTitle;

  /// No description provided for @confidenceVerified.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent} percent, verified'**
  String confidenceVerified(int percent);

  /// No description provided for @confidenceNeedsCheck.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent} percent, needs verification'**
  String confidenceNeedsCheck(int percent);

  /// No description provided for @otherConditions.
  ///
  /// In en, this message translates to:
  /// **'OTHER CONDITIONS'**
  String get otherConditions;

  /// No description provided for @otherConditionsHint.
  ///
  /// In en, this message translates to:
  /// **'anything else, comma separated'**
  String get otherConditionsHint;

  /// No description provided for @otherConditionsLabel.
  ///
  /// In en, this message translates to:
  /// **'OTHER CONDITIONS'**
  String get otherConditionsLabel;

  /// No description provided for @comorbidityDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get comorbidityDiabetes;

  /// No description provided for @comorbidityHypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get comorbidityHypertension;

  /// No description provided for @comorbidityHeartDisease.
  ///
  /// In en, this message translates to:
  /// **'Heart disease'**
  String get comorbidityHeartDisease;

  /// No description provided for @comorbidityThyroid.
  ///
  /// In en, this message translates to:
  /// **'Thyroid disorder'**
  String get comorbidityThyroid;

  /// No description provided for @comorbidityPancreatitis.
  ///
  /// In en, this message translates to:
  /// **'Chronic pancreatitis'**
  String get comorbidityPancreatitis;

  /// No description provided for @geminiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key'**
  String get geminiKeyTitle;

  /// No description provided for @geminiKeySubOn.
  ///
  /// In en, this message translates to:
  /// **'Key added — AI capture and Ask are on'**
  String get geminiKeySubOn;

  /// No description provided for @geminiKeySubOff.
  ///
  /// In en, this message translates to:
  /// **'Paste your own key to turn on AI features'**
  String get geminiKeySubOff;

  /// No description provided for @geminiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your key here'**
  String get geminiKeyHint;

  /// No description provided for @geminiKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Free at aistudio.google.com. Stored only on this device, in secure storage.'**
  String get geminiKeyHelp;

  /// No description provided for @geminiKeyRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove key'**
  String get geminiKeyRemove;

  /// No description provided for @eventClaim.
  ///
  /// In en, this message translates to:
  /// **'Insurance claim'**
  String get eventClaim;

  /// No description provided for @claimsTitle.
  ///
  /// In en, this message translates to:
  /// **'Claims'**
  String get claimsTitle;

  /// No description provided for @claimsAction.
  ///
  /// In en, this message translates to:
  /// **'Claims'**
  String get claimsAction;

  /// No description provided for @claimsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No claims yet'**
  String get claimsEmptyTitle;

  /// No description provided for @claimsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No claims yet. Bundle bills from the vault into a claim and track it to settlement.'**
  String get claimsEmpty;

  /// No description provided for @claimsYtdLine.
  ///
  /// In en, this message translates to:
  /// **'{claimed} claimed · {recovered} recovered this year'**
  String claimsYtdLine(String claimed, String recovered);

  /// No description provided for @unclaimedBillsChip.
  ///
  /// In en, this message translates to:
  /// **'{count} unclaimed {count, plural, =1{bill} other{bills}}'**
  String unclaimedBillsChip(int count);

  /// No description provided for @claimSectionAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get claimSectionAttention;

  /// No description provided for @claimSectionInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get claimSectionInProgress;

  /// No description provided for @claimSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Settled & rejected'**
  String get claimSectionHistory;

  /// No description provided for @claimDocCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{document} other{documents}}'**
  String claimDocCount(int count);

  /// No description provided for @claimStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get claimStatusDraft;

  /// No description provided for @claimStatusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get claimStatusSubmitted;

  /// No description provided for @claimStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get claimStatusApproved;

  /// No description provided for @claimStatusPartiallySettled.
  ///
  /// In en, this message translates to:
  /// **'Partially settled'**
  String get claimStatusPartiallySettled;

  /// No description provided for @claimStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get claimStatusRejected;

  /// No description provided for @claimNew.
  ///
  /// In en, this message translates to:
  /// **'New claim'**
  String get claimNew;

  /// No description provided for @claimEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit claim'**
  String get claimEdit;

  /// No description provided for @claimTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Claim title'**
  String get claimTitleLabel;

  /// No description provided for @claimTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. August dialysis and medicines'**
  String get claimTitleHint;

  /// No description provided for @claimTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the claim a short title.'**
  String get claimTitleRequired;

  /// No description provided for @claimPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get claimPolicyLabel;

  /// No description provided for @claimPolicyNone.
  ///
  /// In en, this message translates to:
  /// **'No policy'**
  String get claimPolicyNone;

  /// No description provided for @claimNoPolicyYet.
  ///
  /// In en, this message translates to:
  /// **'Add your policy in Settings to enable deadline reminders.'**
  String get claimNoPolicyYet;

  /// No description provided for @claimPickDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attach documents'**
  String get claimPickDocuments;

  /// No description provided for @claimPickDocumentsSub.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed bills are pre-selected'**
  String get claimPickDocumentsSub;

  /// No description provided for @claimDocumentsSection.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get claimDocumentsSection;

  /// No description provided for @claimChecklistSection.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get claimChecklistSection;

  /// No description provided for @claimChecklistAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add checklist item…'**
  String get claimChecklistAddHint;

  /// No description provided for @claimAmountClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimAmountClaimed;

  /// No description provided for @claimAmountApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get claimAmountApproved;

  /// No description provided for @claimAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount in ₹'**
  String get claimAmountHint;

  /// No description provided for @claimAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount in rupees.'**
  String get claimAmountInvalid;

  /// No description provided for @claimInsurerRefLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurer claim no.'**
  String get claimInsurerRefLabel;

  /// No description provided for @claimNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get claimNotesLabel;

  /// No description provided for @claimMarkSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Mark submitted'**
  String get claimMarkSubmitted;

  /// No description provided for @claimRecordOutcome.
  ///
  /// In en, this message translates to:
  /// **'Record outcome'**
  String get claimRecordOutcome;

  /// No description provided for @claimReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen as draft'**
  String get claimReopen;

  /// No description provided for @claimDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete claim'**
  String get claimDelete;

  /// No description provided for @claimDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this claim? Its documents stay in the vault.'**
  String get claimDeleteConfirm;

  /// No description provided for @claimSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on'**
  String get claimSubmittedOn;

  /// No description provided for @claimSettledOn.
  ///
  /// In en, this message translates to:
  /// **'Settled on'**
  String get claimSettledOn;

  /// No description provided for @claimCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get claimCreatedOn;

  /// No description provided for @claimNoDocsError.
  ///
  /// In en, this message translates to:
  /// **'Attach at least one document before submitting.'**
  String get claimNoDocsError;

  /// No description provided for @claimApprovedExceedsWarning.
  ///
  /// In en, this message translates to:
  /// **'Approved amount is more than claimed — double-check the letter.'**
  String get claimApprovedExceedsWarning;

  /// No description provided for @claimOutcomeApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved in full'**
  String get claimOutcomeApproved;

  /// No description provided for @claimOutcomePartial.
  ///
  /// In en, this message translates to:
  /// **'Partially settled'**
  String get claimOutcomePartial;

  /// No description provided for @claimOutcomeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get claimOutcomeRejected;

  /// No description provided for @claimDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{day} other{days}} left to claim'**
  String claimDaysLeft(int count);

  /// No description provided for @claimOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past claim window'**
  String get claimOverdue;

  /// No description provided for @claimAwaitingLong.
  ///
  /// In en, this message translates to:
  /// **'Submitted {count} days ago — worth a follow-up call'**
  String claimAwaitingLong(int count);

  /// No description provided for @claimGlanceTitle.
  ///
  /// In en, this message translates to:
  /// **'CLAIMS · {count}'**
  String claimGlanceTitle(int count);

  /// No description provided for @policyTitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance policy'**
  String get policyTitle;

  /// No description provided for @policySettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Insurer, policy number, claim window'**
  String get policySettingsSub;

  /// No description provided for @policyInsurerLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurer'**
  String get policyInsurerLabel;

  /// No description provided for @policyNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Policy number'**
  String get policyNumberLabel;

  /// No description provided for @policyTpaLabel.
  ///
  /// In en, this message translates to:
  /// **'TPA (optional)'**
  String get policyTpaLabel;

  /// No description provided for @policyWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'Claim window (days)'**
  String get policyWindowLabel;

  /// No description provided for @policyWindowInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of days bills stay claimable.'**
  String get policyWindowInvalid;

  /// No description provided for @policyRequired.
  ///
  /// In en, this message translates to:
  /// **'Insurer and policy number are required.'**
  String get policyRequired;

  /// No description provided for @checklistClaimForm.
  ///
  /// In en, this message translates to:
  /// **'Signed claim form'**
  String get checklistClaimForm;

  /// No description provided for @checklistOriginalBills.
  ///
  /// In en, this message translates to:
  /// **'Original bills'**
  String get checklistOriginalBills;

  /// No description provided for @checklistPrescriptionCopy.
  ///
  /// In en, this message translates to:
  /// **'Prescription copy'**
  String get checklistPrescriptionCopy;

  /// No description provided for @checklistLabReports.
  ///
  /// In en, this message translates to:
  /// **'Lab reports'**
  String get checklistLabReports;

  /// No description provided for @checklistPolicyIdCopy.
  ///
  /// In en, this message translates to:
  /// **'Policy & ID copy'**
  String get checklistPolicyIdCopy;

  /// No description provided for @labHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{metric} readings'**
  String labHistoryTitle(String metric);

  /// No description provided for @viewReadingHistory.
  ///
  /// In en, this message translates to:
  /// **'View {metric} history'**
  String viewReadingHistory(String metric);

  /// No description provided for @editReading.
  ///
  /// In en, this message translates to:
  /// **'Edit reading'**
  String get editReading;

  /// No description provided for @editReadingOn.
  ///
  /// In en, this message translates to:
  /// **'Edit reading of {date}'**
  String editReadingOn(String date);

  /// No description provided for @deleteReading.
  ///
  /// In en, this message translates to:
  /// **'Delete reading'**
  String get deleteReading;

  /// No description provided for @deleteReadingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reading? This cannot be undone.'**
  String get deleteReadingConfirm;

  /// No description provided for @editSession.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get editSession;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get deleteSession;

  /// No description provided for @deleteSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this session? The weight and BP values it recorded are removed too.'**
  String get deleteSessionConfirm;

  /// No description provided for @sessionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Session updated'**
  String get sessionUpdated;

  /// No description provided for @sessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get sessionDeleted;

  /// No description provided for @sessionActionsFor.
  ///
  /// In en, this message translates to:
  /// **'Session of {date}'**
  String sessionActionsFor(String date);

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// No description provided for @endMedicine.
  ///
  /// In en, this message translates to:
  /// **'Mark as ended'**
  String get endMedicine;

  /// No description provided for @medicineEnded.
  ///
  /// In en, this message translates to:
  /// **'Marked as ended'**
  String get medicineEnded;

  /// No description provided for @deleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete medicine'**
  String get deleteMedicine;

  /// No description provided for @deleteMedicineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this medicine completely? If it was really taken and then stopped, mark it as ended instead.'**
  String get deleteMedicineConfirm;

  /// No description provided for @medicineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Medicine updated'**
  String get medicineUpdated;

  /// No description provided for @medicineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Medicine deleted'**
  String get medicineDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @doseMarkedGiven.
  ///
  /// In en, this message translates to:
  /// **'{name} marked given'**
  String doseMarkedGiven(String name);

  /// No description provided for @doseMarkedNotGiven.
  ///
  /// In en, this message translates to:
  /// **'{name} marked not given'**
  String doseMarkedNotGiven(String name);

  /// No description provided for @repeatEveryDays.
  ///
  /// In en, this message translates to:
  /// **'GIVEN EVERY HOW MANY DAYS?'**
  String get repeatEveryDays;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String everyNDays(int n);

  /// No description provided for @nDaysChip.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String nDaysChip(int n);

  /// No description provided for @intervalGroup.
  ///
  /// In en, this message translates to:
  /// **'EVERY FEW DAYS'**
  String get intervalGroup;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @overdueByDays.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {n, plural, =1{1 day} other{{n} days}}'**
  String overdueByDays(int n);

  /// No description provided for @nextOnDate.
  ///
  /// In en, this message translates to:
  /// **'Next on {date}'**
  String nextOnDate(String date);

  /// No description provided for @givenToday.
  ///
  /// In en, this message translates to:
  /// **'Given today'**
  String get givenToday;

  /// No description provided for @markGivenToday.
  ///
  /// In en, this message translates to:
  /// **'Mark given today'**
  String get markGivenToday;

  /// No description provided for @medicinesDue.
  ///
  /// In en, this message translates to:
  /// **'MEDICINES DUE'**
  String get medicinesDue;

  /// No description provided for @markGivenSemantics.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} given today'**
  String markGivenSemantics(String name);

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @importDocuments.
  ///
  /// In en, this message translates to:
  /// **'Import documents'**
  String get importDocuments;

  /// No description provided for @importPhotos.
  ///
  /// In en, this message translates to:
  /// **'Import photos'**
  String get importPhotos;

  /// No description provided for @importPdfFiles.
  ///
  /// In en, this message translates to:
  /// **'Import PDF files'**
  String get importPdfFiles;

  /// No description provided for @importEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add scanned photos or PDF files.\nRecora will read each one for you.'**
  String get importEmptyMessage;

  /// No description provided for @nItemsToImport.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No documents} =1{1 document} other{{count} documents}}'**
  String nItemsToImport(int count);

  /// No description provided for @nSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String nSelected(int count);

  /// No description provided for @nPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String nPages(int count);

  /// No description provided for @combineIntoOneDocument.
  ///
  /// In en, this message translates to:
  /// **'Combine into one'**
  String get combineIntoOneDocument;

  /// No description provided for @ungroupPages.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get ungroupPages;

  /// No description provided for @removeDocument.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeDocument;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add more'**
  String get addMore;

  /// No description provided for @startImport.
  ///
  /// In en, this message translates to:
  /// **'Start import'**
  String get startImport;

  /// No description provided for @reviewingItemOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Reviewing {index} of {total}'**
  String reviewingItemOfTotal(int index, int total);

  /// No description provided for @skipDocument.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipDocument;

  /// No description provided for @saveAndNext.
  ///
  /// In en, this message translates to:
  /// **'Save & next'**
  String get saveAndNext;

  /// No description provided for @waitingForExtraction.
  ///
  /// In en, this message translates to:
  /// **'Reading this document…'**
  String get waitingForExtraction;

  /// No description provided for @extractionFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'This document could not be read'**
  String get extractionFailedTitle;

  /// No description provided for @retryExtraction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryExtraction;

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'Import finished'**
  String get importSummary;

  /// No description provided for @nDocumentsSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing saved} =1{1 document saved} other{{count} documents saved}}'**
  String nDocumentsSaved(int count);

  /// No description provided for @nDocumentsSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 skipped} other{{count} skipped}}'**
  String nDocumentsSkipped(int count);

  /// No description provided for @nDocumentsFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 failed} other{{count} failed}}'**
  String nDocumentsFailed(int count);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get importDone;
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
      <String>['en', 'hi'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
