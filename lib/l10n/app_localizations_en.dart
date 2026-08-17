// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KidneyCare';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get preparing => 'Preparing…';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get log => 'Log';

  @override
  String get open => 'Open';

  @override
  String get navHome => 'Home';

  @override
  String get navLabs => 'Labs';

  @override
  String get navDialysis => 'Dialysis';

  @override
  String get navMedicines => 'Medicines';

  @override
  String get navAsk => 'Ask';

  @override
  String get captureDocument => 'Capture a document';

  @override
  String get settingUpVault => 'Setting up the vault…';

  @override
  String get switchToLightTheme => 'Switch to light theme';

  @override
  String get switchToDarkTheme => 'Switch to dark theme';

  @override
  String get openSettings => 'Open settings';

  @override
  String get homeSearchHint => 'Search reports, medicines, doctors…';

  @override
  String needsAttention(int count) {
    return 'NEEDS ATTENTION · $count';
  }

  @override
  String get todaysDoses => 'Today\'s doses';

  @override
  String dosesGiven(int taken, int total) {
    return '$taken of $total given';
  }

  @override
  String get folders => 'Folders';

  @override
  String get allDocuments => 'All documents';

  @override
  String get recentRecords => 'Recent records';

  @override
  String get seeAll => 'See all';

  @override
  String get nextDialysis => 'NEXT DIALYSIS';

  @override
  String get notScheduled => 'Not scheduled';

  @override
  String inHours(int hours) {
    return 'in $hours h';
  }

  @override
  String get now => 'now';

  @override
  String get addScheduleHint => 'Add a dialysis schedule to see it here';

  @override
  String lastSession(String summary) {
    return 'last: $summary';
  }

  @override
  String get logSessionAction => 'Log session';

  @override
  String get logSymptomAction => 'Log symptom';

  @override
  String doseTaken(String medicine, String time) {
    return '$medicine at $time, taken — tap to undo';
  }

  @override
  String doseMark(String medicine, String time) {
    return '$medicine at $time, tap to mark taken';
  }

  @override
  String doseNext(String time) {
    return 'NEXT · $time';
  }

  @override
  String folderFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String folderSemantics(String name, int count) {
    return '$name folder, $count files';
  }

  @override
  String get vitalDryWeight => 'Dry weight';

  @override
  String get vitalHb => 'Hb g/dL';

  @override
  String get vitalPotassium => 'K⁺ mmol/L';

  @override
  String get vitalBpToday => 'BP today';

  @override
  String get vitalAlbumin => 'Albumin';

  @override
  String get vitalActiveMeds => 'Active meds';

  @override
  String get attentionBelowRecheck => 'below range — recheck due';

  @override
  String attentionFallingMonths(int months) {
    return 'falling $months months — recheck due';
  }

  @override
  String get attentionAboveDiet =>
      'above range — review diet with the care team';

  @override
  String abnormalSemantics(String label, String value) {
    return '$label $value, abnormal';
  }

  @override
  String get labs => 'Labs';

  @override
  String lastTest(String date) {
    return 'last test $date';
  }

  @override
  String get enterLabValuesManually => 'Enter lab values manually';

  @override
  String allValuesOn(String date) {
    return 'All values · $date';
  }

  @override
  String get noLabsTitle => 'No lab results yet';

  @override
  String get noLabsMessage =>
      'Capture a lab report, or type the values in yourself, to begin tracking trends.';

  @override
  String get enterValuesManually => 'Enter values manually';

  @override
  String get labsUnavailableTitle => 'Labs are unavailable';

  @override
  String get labsUnavailableMessage =>
      'The stored lab history could not be read. Please restart the app.';

  @override
  String get belowRange => 'below range';

  @override
  String get aboveRange => 'above range';

  @override
  String get steady => 'steady';

  @override
  String rangeCaption(String metric, String min, String max) {
    return '$metric · normal $min–$max · shaded = normal';
  }

  @override
  String get noReadingsYet => 'No readings yet';

  @override
  String showMetricChart(String metric) {
    return 'Show $metric chart';
  }

  @override
  String get enterLabValues => 'Enter lab values';

  @override
  String get enterLabValuesCopy =>
      'Type in the values from the report — leave anything blank that was not tested.';

  @override
  String changeUnit(String unit) {
    return 'Change unit, currently $unit';
  }

  @override
  String get reportDate => 'REPORT DATE';

  @override
  String changeReportDate(String date) {
    return 'Change report date, currently $date';
  }

  @override
  String get kidneyFunction => 'KIDNEY FUNCTION';

  @override
  String get bloodCounts => 'BLOOD COUNTS';

  @override
  String get vitalsGroup => 'VITALS';

  @override
  String normalRangeHint(String min, String max, String unit) {
    return 'normal $min–$max $unit';
  }

  @override
  String get saveToTimeline => 'Save to timeline';

  @override
  String get labValuesSaved => 'Lab values saved to the timeline';

  @override
  String get invalidNumber => 'One of the values is not a valid number.';

  @override
  String get medicines => 'Medicines';

  @override
  String nActive(int count) {
    return '$count active';
  }

  @override
  String get withFoodGroup => 'WITH FOOD';

  @override
  String get byTheClockGroup => 'BY THE CLOCK';

  @override
  String endedMedicinesCollapsed(int count) {
    return 'Ended medicines ($count)  ▾';
  }

  @override
  String get endedMedicinesExpanded => 'Ended medicines  ▴';

  @override
  String endedOn(String date) {
    return 'Ended $date';
  }

  @override
  String get ended => 'Ended';

  @override
  String get noMedicinesTitle => 'No medicines recorded';

  @override
  String get noMedicinesMessage =>
      'Capture a prescription, or add medicines yourself, to build the list.';

  @override
  String get addMedicineManually => 'Add a medicine manually';

  @override
  String get addAMedicine => 'Add a medicine';

  @override
  String get addMedicineCopy =>
      'For prescriptions given verbally or without a paper to photograph.';

  @override
  String get medicineStrength => 'MEDICINE & STRENGTH';

  @override
  String get medicineStrengthHint => 'e.g. Sevelamer 400 mg';

  @override
  String get pattern => 'PATTERN';

  @override
  String get purpose => 'PURPOSE';

  @override
  String get purposeHint => 'e.g. Phosphate binder';

  @override
  String get prescribedBy => 'PRESCRIBED BY';

  @override
  String get prescribedByHint => 'e.g. Dr. Menon';

  @override
  String get whenTaken => 'WHEN IS IT TAKEN?';

  @override
  String get timingCuesHint => 'Timing cues (shown as icons on the card)';

  @override
  String get instructions => 'INSTRUCTIONS';

  @override
  String get instructionsHint => 'e.g. with every meal';

  @override
  String get addMedicineButton => 'Add medicine';

  @override
  String get medicineAdded => 'Medicine added';

  @override
  String get enterMedicineName => 'Please enter the medicine name.';

  @override
  String get documents => 'Documents';

  @override
  String nScans(int count) {
    return '$count scans';
  }

  @override
  String get documentsSearchHint => 'Search by hospital, doctor, tag…';

  @override
  String get filterAll => 'All';

  @override
  String get noDocumentsTitle => 'No documents found';

  @override
  String get noDocumentsMessage =>
      'No reports match this view yet. Capture a prescription or lab report to begin building the patient\'s medical history.';

  @override
  String get documentsUnavailableTitle => 'Documents are unavailable';

  @override
  String get documentsUnavailableMessage =>
      'The stored library could not be read. Please restart the app.';

  @override
  String get documentNotFoundTitle => 'Document not found';

  @override
  String get documentNotFoundMessage =>
      'This record may have been removed from the vault.';

  @override
  String get extractedText => 'EXTRACTED TEXT';

  @override
  String get fillFrame => 'Fill the frame with the document';

  @override
  String get docInView => 'prescription / lab report\nin view';

  @override
  String get pickFromLibrary => 'Pick from photo library';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get adjustCorners => 'Adjust the corners';

  @override
  String get retake => 'Retake';

  @override
  String get usePhoto => 'Use photo';

  @override
  String get preparingPhoto => 'Preparing…';

  @override
  String get cropFailed =>
      'The image could not be cropped. Please retake the photo.';

  @override
  String get readingDocument => 'Reading the document';

  @override
  String extractReassurance(String name) {
    return 'Medicines are checked against $name\'s history. Nothing is saved until you review it.';
  }

  @override
  String get thePatient => 'the patient';

  @override
  String get reviewExtraction => 'Review extraction';

  @override
  String fieldsRead(int count) {
    return '$count fields read';
  }

  @override
  String fieldsNeedCheck(int unchecked, int total) {
    return '$unchecked of $total fields need a check before saving';
  }

  @override
  String get allFieldsChecked => 'All fields checked — ready to save';

  @override
  String get pleaseVerifyField => 'Please verify this field before saving.';

  @override
  String get checkedChip => '✓ checked';

  @override
  String percentCheck(int percent) {
    return '$percent% · check';
  }

  @override
  String get savedToTimeline => 'Saved to the timeline';

  @override
  String get ask => 'Ask';

  @override
  String searchesAllDocuments(int count) {
    return 'searches all $count documents';
  }

  @override
  String get askIntro =>
      'Ask anything about the medical history — medicines during an admission, lab trends, procedures. Answers cite the exact documents they come from.';

  @override
  String get askThinking => 'Thinking…';

  @override
  String get askSuggestion1 => 'When was Hb above 10?';

  @override
  String get askSuggestion2 =>
      'What antibiotics were given during the June admission?';

  @override
  String get askSuggestion3 => 'Show all dialysis catheter procedures';

  @override
  String get sources => 'SOURCES';

  @override
  String openSource(String title) {
    return 'Open source: $title';
  }

  @override
  String get confirmWithDoctor =>
      'Always confirm with the treating doctor before acting on this.';

  @override
  String get askInputHint => 'Ask about the history…';

  @override
  String get sendQuestion => 'Send question';

  @override
  String get timeline => 'Timeline';

  @override
  String get timelineEmptyTitle => 'The timeline is empty';

  @override
  String get timelineEmptyMessage =>
      'No reports have been added yet. Capture your first prescription to begin building the patient\'s medical history.';

  @override
  String get search => 'Search';

  @override
  String get globalSearchHint => 'Reports, medicines, doctors, hospitals…';

  @override
  String get searchVaultTitle => 'Search the whole vault';

  @override
  String get searchVaultMessage =>
      'Medicines, doctors, hospitals, lab values and every scanned document — results appear as you type.';

  @override
  String get searchUnavailableTitle => 'Search is unavailable';

  @override
  String get searchUnavailableMessage =>
      'Something went wrong while searching. Please try again.';

  @override
  String get nothingFoundTitle => 'Nothing found';

  @override
  String get nothingFoundMessage => 'No records match this search yet.';

  @override
  String get sectionDocuments => 'DOCUMENTS';

  @override
  String get sectionMedicines => 'MEDICINES';

  @override
  String get sectionTimeline => 'TIMELINE';

  @override
  String get settings => 'Settings';

  @override
  String get patientDetails => 'Patient details';

  @override
  String get patientDetailsSub => 'Name, condition, dialysis schedule';

  @override
  String get emergencyCardTitle => 'Emergency card';

  @override
  String get emergencyCardSub =>
      'Condition, blood group, allergies — ready to show or send';

  @override
  String get reminders => 'Reminders';

  @override
  String get remindersSub => 'Dose times and two hours before dialysis';

  @override
  String get visitSummary => 'Doctor-visit summary';

  @override
  String get visitSummarySub =>
      'A one-page PDF of medicines, labs and recent events';

  @override
  String get exportBackup => 'Export vault backup';

  @override
  String get exportBackupSub => 'Share the full record as a JSON file';

  @override
  String get encryptionTitle => 'On-device encryption';

  @override
  String get encryptionSub =>
      'The vault database is encrypted with SQLCipher; the key never leaves this device';

  @override
  String get language => 'Language';

  @override
  String get languageSub => 'Follows the device unless you choose';

  @override
  String get languageSystem => 'System';

  @override
  String get setUpVault => 'Set up the vault';

  @override
  String get setUpVaultCopy =>
      'A few details about the person you care for. Everything stays on this device, encrypted.';

  @override
  String get patientEditCopy => 'Changes apply across the whole vault.';

  @override
  String get fullName => 'FULL NAME';

  @override
  String get fullNameHint => 'e.g. N. Ramachandran';

  @override
  String get age => 'AGE';

  @override
  String get condition => 'CONDITION';

  @override
  String get dialysisSchedule => 'DIALYSIS SCHEDULE';

  @override
  String get tapTimeHint => 'Tap a time to change it — each day can differ';

  @override
  String sessionTimeOn(String day) {
    return 'Session time on $day';
  }

  @override
  String changeSessionTime(String day, String time) {
    return 'Change session time on $day, currently $time';
  }

  @override
  String get dialysisCentre => 'DIALYSIS CENTRE';

  @override
  String get dialysisCentreHint => 'e.g. Nephron Centre';

  @override
  String get dryWeightKgLabel => 'DRY WEIGHT (KG)';

  @override
  String get bloodGroup => 'BLOOD GROUP';

  @override
  String get allergies => 'ALLERGIES';

  @override
  String get allergiesHint => 'e.g. Penicillin — leave blank if none';

  @override
  String get emergencyContact => 'EMERGENCY CONTACT';

  @override
  String get emergencyContactHint => 'e.g. Aditya (son) · 98xxxxxx21';

  @override
  String get createVault => 'Create the vault';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get exploreSampleData => 'Explore with sample data instead';

  @override
  String get fillNameAge => 'Please fill in the name and a valid age.';

  @override
  String get dialysis => 'Dialysis';

  @override
  String nLogged(int count) {
    return '$count logged';
  }

  @override
  String get sessionHistory => 'Session history';

  @override
  String get noSessionsTitle => 'No sessions logged yet';

  @override
  String get noSessionsMessage =>
      'After each dialysis, log the session here — weights, fluid removed, and how it went.';

  @override
  String get logASession => 'Log a session';

  @override
  String get logSessionCopy =>
      'Today\'s dialysis, in the record. Fill what you know — everything except duration is optional.';

  @override
  String get sessionDate => 'SESSION DATE';

  @override
  String get sessionDateDialogTitle => 'Session date';

  @override
  String changeSessionDate(String date) {
    return 'Change session date, currently $date';
  }

  @override
  String get duration => 'DURATION';

  @override
  String get preWeightKgLabel => 'PRE WEIGHT (KG)';

  @override
  String get postWeightKgLabel => 'POST WEIGHT (KG)';

  @override
  String get ufRemoved => 'UF REMOVED (L)';

  @override
  String get bpSys => 'BP SYS';

  @override
  String get bpDia => 'BP DIA';

  @override
  String get howDidItGo => 'HOW DID IT GO?';

  @override
  String get orTypeNote => 'or type a note…';

  @override
  String get saveSession => 'Save session';

  @override
  String get sessionLogged => 'Session logged';

  @override
  String get logged => 'Logged';

  @override
  String get noteNoCramps => 'no cramps';

  @override
  String get noteCramps => 'cramps';

  @override
  String get noteBpDipped => 'BP dipped';

  @override
  String get noteFeltWeak => 'felt weak after';

  @override
  String get noteWentWell => 'went well';

  @override
  String get logASymptom => 'Log a symptom';

  @override
  String get logSymptomCopy =>
      'What you notice between sessions matters at the next appointment. Ten seconds now saves a forgotten detail later.';

  @override
  String get observed => 'OBSERVED';

  @override
  String get note => 'NOTE';

  @override
  String get symptomNoteHint =>
      'e.g. after climbing stairs, since yesterday evening…';

  @override
  String get notedOnTimeline => 'Noted on the timeline';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomSwelling => 'Swelling';

  @override
  String get symptomBreathlessness => 'Breathlessness';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomDizziness => 'Dizziness';

  @override
  String get symptomLowBp => 'Low BP';

  @override
  String get symptomFever => 'Fever';

  @override
  String get symptomItching => 'Itching';

  @override
  String get symptomPoorAppetite => 'Poor appetite';

  @override
  String get symptomChestDiscomfort => 'Chest discomfort';

  @override
  String get symptomAccessSitePain => 'Access site pain';

  @override
  String get emergencyCardCopy =>
      'For any hospital visit — the first minute of context, ready to show or send.';

  @override
  String get shareCard => 'Share card';

  @override
  String get allergiesLabel => 'ALLERGIES';

  @override
  String get noneKnown => 'None known';

  @override
  String get dialysisCentreLabel => 'DIALYSIS CENTRE';

  @override
  String get medicinesLabel => 'MEDICINES';

  @override
  String get emergencyContactLabel => 'EMERGENCY CONTACT';

  @override
  String get noPatientTitle => 'No patient details yet';

  @override
  String get noPatientMessage => 'Fill in the patient profile first.';

  @override
  String get docTypeLabReport => 'Lab report';

  @override
  String get docTypePrescription => 'Prescription';

  @override
  String get docTypeDischargeSummary => 'Discharge summary';

  @override
  String get docTypeBill => 'Bill';

  @override
  String get docTypeHandwrittenNote => 'Handwritten note';

  @override
  String get docTypeScan => 'Scan';

  @override
  String get eventAdmission => 'Admission';

  @override
  String get eventProcedure => 'Procedure';

  @override
  String get eventMedicationChange => 'Medication change';

  @override
  String get eventDialysis => 'Dialysis';

  @override
  String get eventLabReport => 'Lab report';

  @override
  String get eventPrescription => 'Prescription';

  @override
  String get eventDoctorVisit => 'Doctor visit';

  @override
  String get eventBill => 'Hospital bill';

  @override
  String get eventDischarge => 'Discharge summary';

  @override
  String get eventSymptom => 'Symptom';

  @override
  String get groupWithFood => 'With food';

  @override
  String get groupByClock => 'By the clock';

  @override
  String get groupWeekly => 'Weekly';

  @override
  String get cueMorning => 'Morning';

  @override
  String get cueNoon => 'Noon';

  @override
  String get cueNight => 'Night';

  @override
  String get cueBeforeFood => 'Before food';

  @override
  String get cueAfterFood => 'After food';

  @override
  String get cueWithFood => 'With food';

  @override
  String get cueDialysisDayOnly => 'Dialysis day only';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get folderLabReports => 'Lab reports';

  @override
  String get folderPrescriptions => 'Prescriptions';

  @override
  String get folderDischarge => 'Discharge';

  @override
  String get folderBills => 'Bills';

  @override
  String get reportDateDialogTitle => 'Report date';

  @override
  String confidenceVerified(int percent) {
    return 'Confidence $percent percent, verified';
  }

  @override
  String confidenceNeedsCheck(int percent) {
    return 'Confidence $percent percent, needs verification';
  }

  @override
  String get otherConditions => 'OTHER CONDITIONS';

  @override
  String get otherConditionsHint => 'anything else, comma separated';

  @override
  String get otherConditionsLabel => 'OTHER CONDITIONS';

  @override
  String get comorbidityDiabetes => 'Diabetes';

  @override
  String get comorbidityHypertension => 'Hypertension';

  @override
  String get comorbidityHeartDisease => 'Heart disease';

  @override
  String get comorbidityThyroid => 'Thyroid disorder';

  @override
  String get comorbidityPancreatitis => 'Chronic pancreatitis';

  @override
  String get geminiKeyTitle => 'Gemini API key';

  @override
  String get geminiKeySubOn => 'Key added — AI capture and Ask are on';

  @override
  String get geminiKeySubOff => 'Paste your own key to turn on AI features';

  @override
  String get geminiKeyHint => 'Paste your key here';

  @override
  String get geminiKeyHelp =>
      'Free at aistudio.google.com. Stored only on this device, in secure storage.';

  @override
  String get geminiKeyRemove => 'Remove key';

  @override
  String get eventClaim => 'Insurance claim';

  @override
  String get claimsTitle => 'Claims';

  @override
  String get claimsAction => 'Claims';

  @override
  String get claimsEmptyTitle => 'No claims yet';

  @override
  String get claimsEmpty =>
      'No claims yet. Bundle bills from the vault into a claim and track it to settlement.';

  @override
  String claimsYtdLine(String claimed, String recovered) {
    return '$claimed claimed · $recovered recovered this year';
  }

  @override
  String unclaimedBillsChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bills',
      one: 'bill',
    );
    return '$count unclaimed $_temp0';
  }

  @override
  String get claimSectionAttention => 'Needs attention';

  @override
  String get claimSectionInProgress => 'In progress';

  @override
  String get claimSectionHistory => 'Settled & rejected';

  @override
  String claimDocCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'documents',
      one: 'document',
    );
    return '$count $_temp0';
  }

  @override
  String get claimStatusDraft => 'Draft';

  @override
  String get claimStatusSubmitted => 'Submitted';

  @override
  String get claimStatusApproved => 'Approved';

  @override
  String get claimStatusPartiallySettled => 'Partially settled';

  @override
  String get claimStatusRejected => 'Rejected';

  @override
  String get claimNew => 'New claim';

  @override
  String get claimEdit => 'Edit claim';

  @override
  String get claimTitleLabel => 'Claim title';

  @override
  String get claimTitleHint => 'e.g. August dialysis and medicines';

  @override
  String get claimTitleRequired => 'Give the claim a short title.';

  @override
  String get claimPolicyLabel => 'Policy';

  @override
  String get claimPolicyNone => 'No policy';

  @override
  String get claimNoPolicyYet =>
      'Add your policy in Settings to enable deadline reminders.';

  @override
  String get claimPickDocuments => 'Attach documents';

  @override
  String get claimPickDocumentsSub => 'Unclaimed bills are pre-selected';

  @override
  String get claimDocumentsSection => 'Documents';

  @override
  String get claimChecklistSection => 'Checklist';

  @override
  String get claimChecklistAddHint => 'Add checklist item…';

  @override
  String get claimAmountClaimed => 'Claimed';

  @override
  String get claimAmountApproved => 'Approved';

  @override
  String get claimAmountHint => 'Amount in ₹';

  @override
  String get claimAmountInvalid => 'Enter a valid amount in rupees.';

  @override
  String get claimInsurerRefLabel => 'Insurer claim no.';

  @override
  String get claimNotesLabel => 'Notes';

  @override
  String get claimMarkSubmitted => 'Mark submitted';

  @override
  String get claimRecordOutcome => 'Record outcome';

  @override
  String get claimReopen => 'Reopen as draft';

  @override
  String get claimDelete => 'Delete claim';

  @override
  String get claimDeleteConfirm =>
      'Delete this claim? Its documents stay in the vault.';

  @override
  String get claimSubmittedOn => 'Submitted on';

  @override
  String get claimSettledOn => 'Settled on';

  @override
  String get claimCreatedOn => 'Created on';

  @override
  String get claimNoDocsError =>
      'Attach at least one document before submitting.';

  @override
  String get claimApprovedExceedsWarning =>
      'Approved amount is more than claimed — double-check the letter.';

  @override
  String get claimOutcomeApproved => 'Approved in full';

  @override
  String get claimOutcomePartial => 'Partially settled';

  @override
  String get claimOutcomeRejected => 'Rejected';

  @override
  String claimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$count $_temp0 left to claim';
  }

  @override
  String get claimOverdue => 'Past claim window';

  @override
  String claimAwaitingLong(int count) {
    return 'Submitted $count days ago — worth a follow-up call';
  }

  @override
  String claimGlanceTitle(int count) {
    return 'CLAIMS · $count';
  }

  @override
  String get policyTitle => 'Insurance policy';

  @override
  String get policySettingsSub => 'Insurer, policy number, claim window';

  @override
  String get policyInsurerLabel => 'Insurer';

  @override
  String get policyNumberLabel => 'Policy number';

  @override
  String get policyTpaLabel => 'TPA (optional)';

  @override
  String get policyWindowLabel => 'Claim window (days)';

  @override
  String get policyWindowInvalid =>
      'Enter the number of days bills stay claimable.';

  @override
  String get policyRequired => 'Insurer and policy number are required.';

  @override
  String get checklistClaimForm => 'Signed claim form';

  @override
  String get checklistOriginalBills => 'Original bills';

  @override
  String get checklistPrescriptionCopy => 'Prescription copy';

  @override
  String get checklistLabReports => 'Lab reports';

  @override
  String get checklistPolicyIdCopy => 'Policy & ID copy';
}
