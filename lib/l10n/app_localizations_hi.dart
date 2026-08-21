// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'KidneyCare';

  @override
  String get save => 'सहेजें';

  @override
  String get saving => 'सहेजा जा रहा है…';

  @override
  String get preparing => 'तैयार हो रहा है…';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get log => 'दर्ज करें';

  @override
  String get open => 'खोलें';

  @override
  String get navHome => 'होम';

  @override
  String get navLabs => 'जाँचें';

  @override
  String get navDialysis => 'डायलिसिस';

  @override
  String get navMedicines => 'दवाइयाँ';

  @override
  String get navAsk => 'पूछें';

  @override
  String get captureDocument => 'दस्तावेज़ की फ़ोटो लें';

  @override
  String get settingUpVault => 'वॉल्ट तैयार हो रहा है…';

  @override
  String get switchToLightTheme => 'लाइट थीम पर जाएँ';

  @override
  String get switchToDarkTheme => 'डार्क थीम पर जाएँ';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get homeSearchHint => 'रिपोर्ट, दवा, डॉक्टर खोजें…';

  @override
  String needsAttention(int count) {
    return 'ध्यान दें · $count';
  }

  @override
  String get todaysDoses => 'आज की खुराकें';

  @override
  String dosesGiven(int taken, int total) {
    return '$total में से $taken दी गईं';
  }

  @override
  String get folders => 'फ़ोल्डर';

  @override
  String get allDocuments => 'सभी दस्तावेज़';

  @override
  String get recentRecords => 'हाल के रिकॉर्ड';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get nextDialysis => 'अगला डायलिसिस';

  @override
  String get notScheduled => 'निर्धारित नहीं';

  @override
  String inHours(int hours) {
    return '$hours घंटे में';
  }

  @override
  String get now => 'अभी';

  @override
  String get addScheduleHint => 'डायलिसिस का समय जोड़ें, यहाँ दिखेगा';

  @override
  String lastSession(String summary) {
    return 'पिछला: $summary';
  }

  @override
  String get logSessionAction => 'सेशन दर्ज करें';

  @override
  String get logSymptomAction => 'लक्षण दर्ज करें';

  @override
  String doseTaken(String medicine, String time) {
    return '$medicine, $time — दी गई, हटाने के लिए दबाएँ';
  }

  @override
  String doseMark(String medicine, String time) {
    return '$medicine, $time — दी गई दर्ज करने के लिए दबाएँ';
  }

  @override
  String doseNext(String time) {
    return 'अगली · $time';
  }

  @override
  String folderFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ाइलें',
      one: '1 फ़ाइल',
    );
    return '$_temp0';
  }

  @override
  String folderSemantics(String name, int count) {
    return '$name फ़ोल्डर, $count फ़ाइलें';
  }

  @override
  String get vitalDryWeight => 'ड्राई वज़न';

  @override
  String get vitalHb => 'Hb g/dL';

  @override
  String get vitalPotassium => 'K⁺ mmol/L';

  @override
  String get vitalBpToday => 'आज का BP';

  @override
  String get vitalAlbumin => 'एल्ब्युमिन';

  @override
  String get vitalActiveMeds => 'चालू दवाएँ';

  @override
  String get attentionBelowRecheck => 'सीमा से कम — दोबारा जाँच कराएँ';

  @override
  String attentionFallingMonths(int months) {
    return '$months महीनों से गिर रहा — दोबारा जाँच कराएँ';
  }

  @override
  String get attentionAboveDiet => 'सीमा से अधिक — डॉक्टर से आहार पर सलाह लें';

  @override
  String abnormalSemantics(String label, String value) {
    return '$label $value, असामान्य';
  }

  @override
  String get labs => 'जाँचें';

  @override
  String lastTest(String date) {
    return 'पिछली जाँच $date';
  }

  @override
  String get enterLabValuesManually => 'जाँच के आँकड़े खुद भरें';

  @override
  String allValuesOn(String date) {
    return 'सभी आँकड़े · $date';
  }

  @override
  String get noLabsTitle => 'अभी कोई जाँच नहीं';

  @override
  String get noLabsMessage =>
      'रिपोर्ट की फ़ोटो लें या आँकड़े खुद भरें — रुझान यहीं दिखेंगे।';

  @override
  String get enterValuesManually => 'आँकड़े खुद भरें';

  @override
  String get labsUnavailableTitle => 'जाँचें उपलब्ध नहीं';

  @override
  String get labsUnavailableMessage =>
      'सहेजी गई जाँचें पढ़ी नहीं जा सकीं। ऐप दोबारा खोलें।';

  @override
  String get belowRange => 'सीमा से कम';

  @override
  String get aboveRange => 'सीमा से अधिक';

  @override
  String get steady => 'स्थिर';

  @override
  String rangeCaption(String metric, String min, String max) {
    return '$metric · सामान्य $min–$max · छायांकित = सामान्य';
  }

  @override
  String get noReadingsYet => 'अभी कोई रीडिंग नहीं';

  @override
  String showMetricChart(String metric) {
    return '$metric का चार्ट देखें';
  }

  @override
  String get enterLabValues => 'जाँच के आँकड़े भरें';

  @override
  String get enterLabValuesCopy =>
      'रिपोर्ट से आँकड़े भरें — जो जाँच नहीं हुई उसे खाली छोड़ दें।';

  @override
  String changeUnit(String unit) {
    return 'यूनिट बदलें, अभी $unit';
  }

  @override
  String get reportDate => 'रिपोर्ट की तारीख़';

  @override
  String changeReportDate(String date) {
    return 'रिपोर्ट की तारीख़ बदलें, अभी $date';
  }

  @override
  String get kidneyFunction => 'किडनी फ़ंक्शन';

  @override
  String get bloodCounts => 'ब्लड काउंट';

  @override
  String get vitalsGroup => 'वाइटल्स';

  @override
  String normalRangeHint(String min, String max, String unit) {
    return 'सामान्य $min–$max $unit';
  }

  @override
  String get saveToTimeline => 'टाइमलाइन में सहेजें';

  @override
  String get labValuesSaved => 'आँकड़े टाइमलाइन में सहेज दिए गए';

  @override
  String get invalidNumber => 'सही संख्या लिखें';

  @override
  String get medicines => 'दवाइयाँ';

  @override
  String nActive(int count) {
    return '$count चालू';
  }

  @override
  String get withFoodGroup => 'खाने के साथ';

  @override
  String get byTheClockGroup => 'समय से';

  @override
  String endedMedicinesCollapsed(int count) {
    return 'बंद दवाएँ ($count)  ▾';
  }

  @override
  String get endedMedicinesExpanded => 'बंद दवाएँ  ▴';

  @override
  String endedOn(String date) {
    return 'बंद हुई $date';
  }

  @override
  String get ended => 'बंद';

  @override
  String get noMedicinesTitle => 'कोई दवा दर्ज नहीं';

  @override
  String get noMedicinesMessage => 'पर्ची की फ़ोटो लें या दवाएँ खुद जोड़ें।';

  @override
  String get addMedicineManually => 'दवा खुद जोड़ें';

  @override
  String get addAMedicine => 'दवा जोड़ें';

  @override
  String get addMedicineCopy => 'जब पर्ची न हो या डॉक्टर ने मौखिक बताया हो।';

  @override
  String get medicineStrength => 'दवा और मात्रा';

  @override
  String get medicineStrengthHint => 'जैसे Sevelamer 400 mg';

  @override
  String get pattern => 'पैटर्न';

  @override
  String get purpose => 'किसलिए';

  @override
  String get purposeHint => 'जैसे फ़ॉस्फ़ेट बाइंडर';

  @override
  String get prescribedBy => 'किस डॉक्टर ने दी';

  @override
  String get prescribedByHint => 'जैसे डॉ. मेनन';

  @override
  String get whenTaken => 'कब लेनी है?';

  @override
  String get timingCuesHint => 'समय के संकेत (कार्ड पर आइकन बनते हैं)';

  @override
  String get instructions => 'निर्देश';

  @override
  String get instructionsHint => 'जैसे हर खाने के साथ';

  @override
  String get addMedicineButton => 'दवा जोड़ें';

  @override
  String get medicineAdded => 'दवा जोड़ दी गई';

  @override
  String get enterMedicineName => 'कृपया दवा का नाम भरें।';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String nScans(int count) {
    return '$count स्कैन';
  }

  @override
  String get documentsSearchHint => 'अस्पताल, डॉक्टर, टैग से खोजें…';

  @override
  String get filterAll => 'सभी';

  @override
  String get noDocumentsTitle => 'कोई दस्तावेज़ नहीं मिला';

  @override
  String get noDocumentsMessage =>
      'अभी यहाँ कुछ नहीं है। पर्ची या रिपोर्ट की फ़ोटो लेकर इतिहास बनाना शुरू करें।';

  @override
  String get documentsUnavailableTitle => 'दस्तावेज़ उपलब्ध नहीं';

  @override
  String get documentsUnavailableMessage =>
      'सहेजे गए दस्तावेज़ पढ़े नहीं जा सके। ऐप दोबारा खोलें।';

  @override
  String get documentNotFoundTitle => 'दस्तावेज़ नहीं मिला';

  @override
  String get documentNotFoundMessage =>
      'यह रिकॉर्ड शायद वॉल्ट से हटा दिया गया है।';

  @override
  String get extractedText => 'निकाला गया टेक्स्ट';

  @override
  String get shareDocument => 'दस्तावेज़ साझा करें';

  @override
  String get whatIsThisDocument => 'यह कौन-सा दस्तावेज़ है?';

  @override
  String get typePickAiHint =>
      'लैब रिपोर्ट AI से पढ़ी जाती हैं ताकि वैल्यू चार्ट में आ जाएँ। बाकी सब जैसा फ़ोटो लिया गया वैसा ही रखा जाता है।';

  @override
  String get aiReadBadge => 'AI पढ़ेगा';

  @override
  String get manualDetailsHint =>
      'जैसा फ़ोटो लिया गया वैसा ही रखा जाएगा — कुछ भी पढ़ा या बदला नहीं जाता।';

  @override
  String get docTitleLabel => 'शीर्षक';

  @override
  String get docTitleHint => 'जैसे डॉ. मेहता का पर्चा';

  @override
  String get docDoctorOptionalLabel => 'डॉक्टर (वैकल्पिक)';

  @override
  String get docDateLabel => 'दस्तावेज़ की तारीख़';

  @override
  String get saveDocument => 'वॉल्ट में सहेजें';

  @override
  String get changeDocType => 'दस्तावेज़ का प्रकार बदलें';

  @override
  String get applyTypeToAll => 'सभी पेजों पर लागू करें';

  @override
  String get fillFrame => 'दस्तावेज़ को फ़्रेम में पूरा रखें';

  @override
  String get docInView => 'पर्ची / जाँच रिपोर्ट\nफ़्रेम में रखें';

  @override
  String get pickFromLibrary => 'गैलरी से चुनें';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get adjustCorners => 'कोने ठीक करें';

  @override
  String get retake => 'दोबारा लें';

  @override
  String get usePhoto => 'फ़ोटो इस्तेमाल करें';

  @override
  String get preparingPhoto => 'तैयार हो रहा है…';

  @override
  String get cropFailed => 'फ़ोटो क्रॉप नहीं हो सकी। कृपया दोबारा लें।';

  @override
  String get readingDocument => 'दस्तावेज़ पढ़ा जा रहा है';

  @override
  String extractReassurance(String name) {
    return 'दवाओं का मिलान $name के इतिहास से किया जाता है। आपकी जाँच के बिना कुछ सहेजा नहीं जाएगा।';
  }

  @override
  String get thePatient => 'मरीज़';

  @override
  String get reviewExtraction => 'निकाली गई जानकारी जाँचें';

  @override
  String fieldsRead(int count) {
    return '$count फ़ील्ड पढ़ी गईं';
  }

  @override
  String fieldsNeedCheck(int unchecked, int total) {
    return '$total में से $unchecked फ़ील्ड जाँचनी बाकी हैं';
  }

  @override
  String get allFieldsChecked => 'सब जाँच लिया — सहेजने के लिए तैयार';

  @override
  String get pleaseVerifyField => 'सहेजने से पहले इसे जाँच लें।';

  @override
  String get checkedChip => '✓ जाँचा गया';

  @override
  String percentCheck(int percent) {
    return '$percent% · जाँचें';
  }

  @override
  String get savedToTimeline => 'टाइमलाइन में सहेज दिया गया';

  @override
  String get ask => 'पूछें';

  @override
  String searchesAllDocuments(int count) {
    return 'सभी $count दस्तावेज़ों में खोजता है';
  }

  @override
  String get askIntro =>
      'इतिहास के बारे में कुछ भी पूछें — किस भर्ती में कौन-सी दवा मिली, जाँच के रुझान, प्रक्रियाएँ। हर जवाब के साथ स्रोत दस्तावेज़ भी दिखते हैं।';

  @override
  String get askThinking => 'सोच रहा है…';

  @override
  String get askSuggestion1 => 'Hb कब 10 से ऊपर था?';

  @override
  String get askSuggestion2 => 'जून की भर्ती में कौन-सी एंटीबायोटिक मिली थीं?';

  @override
  String get askSuggestion3 => 'डायलिसिस कैथेटर की सभी प्रक्रियाएँ दिखाओ';

  @override
  String get sources => 'स्रोत';

  @override
  String openSource(String title) {
    return 'स्रोत खोलें: $title';
  }

  @override
  String get confirmWithDoctor =>
      'किसी भी क़दम से पहले इलाज कर रहे डॉक्टर से ज़रूर पुष्टि करें।';

  @override
  String get askInputHint => 'इतिहास के बारे में पूछें…';

  @override
  String get sendQuestion => 'सवाल भेजें';

  @override
  String get timeline => 'टाइमलाइन';

  @override
  String get timelineEmptyTitle => 'टाइमलाइन खाली है';

  @override
  String get timelineEmptyMessage =>
      'अभी कोई रिपोर्ट नहीं जुड़ी। पहली पर्ची की फ़ोटो लेकर इतिहास बनाना शुरू करें।';

  @override
  String get search => 'खोज';

  @override
  String get globalSearchHint => 'रिपोर्ट, दवा, डॉक्टर, अस्पताल…';

  @override
  String get searchVaultTitle => 'पूरे वॉल्ट में खोजें';

  @override
  String get searchVaultMessage =>
      'दवाएँ, डॉक्टर, अस्पताल, जाँच के आँकड़े और हर स्कैन — लिखते ही नतीजे दिखते हैं।';

  @override
  String get searchUnavailableTitle => 'खोज उपलब्ध नहीं';

  @override
  String get searchUnavailableMessage =>
      'खोज में कुछ गड़बड़ हुई। कृपया दोबारा कोशिश करें।';

  @override
  String get nothingFoundTitle => 'कुछ नहीं मिला';

  @override
  String get nothingFoundMessage => 'इस खोज से कोई रिकॉर्ड मेल नहीं खाता।';

  @override
  String get sectionDocuments => 'दस्तावेज़';

  @override
  String get sectionMedicines => 'दवाइयाँ';

  @override
  String get sectionTimeline => 'टाइमलाइन';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get patientDetails => 'मरीज़ की जानकारी';

  @override
  String get patientDetailsSub => 'नाम, बीमारी, डायलिसिस का समय';

  @override
  String get emergencyCardTitle => 'आपातकालीन कार्ड';

  @override
  String get emergencyCardSub =>
      'बीमारी, ब्लड ग्रुप, एलर्जी — दिखाने या भेजने के लिए तैयार';

  @override
  String get reminders => 'याद दिलाएँ';

  @override
  String get remindersSub => 'दवा के समय और डायलिसिस से दो घंटे पहले';

  @override
  String get visitSummary => 'डॉक्टर विज़िट सारांश';

  @override
  String get visitSummarySub =>
      'दवाओं, जाँचों और हाल की घटनाओं का एक पन्ने का PDF';

  @override
  String get exportBackup => 'वॉल्ट का बैकअप निकालें';

  @override
  String get exportBackupSub => 'पूरा रिकॉर्ड JSON फ़ाइल के रूप में भेजें';

  @override
  String get encryptionTitle => 'डिवाइस पर एन्क्रिप्शन';

  @override
  String get encryptionSub =>
      'वॉल्ट का डेटाबेस SQLCipher से एन्क्रिप्टेड है; चाबी इसी डिवाइस पर रहती है';

  @override
  String get language => 'भाषा';

  @override
  String get languageSub => 'जब तक आप न चुनें, डिवाइस की भाषा चलेगी';

  @override
  String get languageSystem => 'सिस्टम';

  @override
  String get setUpVault => 'वॉल्ट बनाएँ';

  @override
  String get setUpVaultCopy =>
      'जिनकी देखभाल करते हैं, उनके बारे में कुछ जानकारी। सब कुछ इसी डिवाइस पर, एन्क्रिप्टेड रहता है।';

  @override
  String get patientEditCopy => 'बदलाव पूरे वॉल्ट पर लागू होते हैं।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get fullNameHint => 'जैसे एन. रामचंद्रन';

  @override
  String get age => 'उम्र';

  @override
  String get condition => 'बीमारी';

  @override
  String get dialysisSchedule => 'डायलिसिस का समय';

  @override
  String get tapTimeHint => 'समय बदलने के लिए दबाएँ — हर दिन अलग हो सकता है';

  @override
  String sessionTimeOn(String day) {
    return '$day का सेशन समय';
  }

  @override
  String changeSessionTime(String day, String time) {
    return '$day का सेशन समय बदलें, अभी $time';
  }

  @override
  String get dialysisCentre => 'डायलिसिस केंद्र';

  @override
  String get dialysisCentreHint => 'जैसे नेफ्रॉन सेंटर';

  @override
  String get dryWeightKgLabel => 'ड्राई वज़न (किग्रा)';

  @override
  String get bloodGroup => 'ब्लड ग्रुप';

  @override
  String get allergies => 'एलर्जी';

  @override
  String get allergiesHint => 'जैसे पेनिसिलिन — न हो तो खाली छोड़ें';

  @override
  String get emergencyContact => 'आपातकालीन संपर्क';

  @override
  String get emergencyContactHint => 'जैसे आदित्य (बेटा) · 98xxxxxx21';

  @override
  String get createVault => 'वॉल्ट बनाएँ';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get exploreSampleData => 'पहले नमूना डेटा देखें';

  @override
  String get fillNameAge => 'कृपया नाम और सही उम्र भरें।';

  @override
  String get dialysis => 'डायलिसिस';

  @override
  String nLogged(int count) {
    return '$count दर्ज';
  }

  @override
  String get sessionHistory => 'सेशन इतिहास';

  @override
  String get noSessionsTitle => 'अभी कोई सेशन दर्ज नहीं';

  @override
  String get noSessionsMessage =>
      'हर डायलिसिस के बाद यहाँ दर्ज करें — वज़न, निकाला गया पानी, और कैसा रहा।';

  @override
  String get logASession => 'सेशन दर्ज करें';

  @override
  String get logSessionCopy =>
      'आज का डायलिसिस, रिकॉर्ड में। जो पता है भरें — अवधि के अलावा सब वैकल्पिक है।';

  @override
  String get sessionDate => 'सेशन की तारीख़';

  @override
  String get sessionDateDialogTitle => 'सेशन की तारीख़';

  @override
  String changeSessionDate(String date) {
    return 'सेशन की तारीख़ बदलें, अभी $date';
  }

  @override
  String get duration => 'अवधि';

  @override
  String get preWeightKgLabel => 'पहले का वज़न (किग्रा)';

  @override
  String get postWeightKgLabel => 'बाद का वज़न (किग्रा)';

  @override
  String get ufRemoved => 'निकाला पानी (ली)';

  @override
  String get bpSys => 'BP ऊपरी';

  @override
  String get bpDia => 'BP निचला';

  @override
  String get howDidItGo => 'कैसा रहा?';

  @override
  String get orTypeNote => 'या नोट लिखें…';

  @override
  String get saveSession => 'सेशन सहेजें';

  @override
  String get sessionLogged => 'सेशन दर्ज हो गया';

  @override
  String get logged => 'दर्ज';

  @override
  String get noteNoCramps => 'ऐंठन नहीं';

  @override
  String get noteCramps => 'ऐंठन हुई';

  @override
  String get noteBpDipped => 'BP गिरा';

  @override
  String get noteFeltWeak => 'बाद में कमज़ोरी';

  @override
  String get noteWentWell => 'अच्छा रहा';

  @override
  String get logASymptom => 'लक्षण दर्ज करें';

  @override
  String get logSymptomCopy =>
      'सेशनों के बीच जो दिखे, वह अगली विज़िट में काम आता है। दस सेकंड अभी, भूली बात बाद में नहीं।';

  @override
  String get observed => 'क्या दिखा';

  @override
  String get note => 'नोट';

  @override
  String get symptomNoteHint => 'जैसे सीढ़ी चढ़ने पर, कल शाम से…';

  @override
  String get notedOnTimeline => 'टाइमलाइन में दर्ज हो गया';

  @override
  String get symptomFatigue => 'थकान';

  @override
  String get symptomCramps => 'ऐंठन';

  @override
  String get symptomSwelling => 'सूजन';

  @override
  String get symptomBreathlessness => 'साँस फूलना';

  @override
  String get symptomNausea => 'मितली';

  @override
  String get symptomDizziness => 'चक्कर';

  @override
  String get symptomLowBp => 'कम BP';

  @override
  String get symptomFever => 'बुख़ार';

  @override
  String get symptomItching => 'खुजली';

  @override
  String get symptomPoorAppetite => 'भूख कम';

  @override
  String get symptomChestDiscomfort => 'सीने में बेचैनी';

  @override
  String get symptomAccessSitePain => 'फिस्टुला जगह दर्द';

  @override
  String get emergencyCardCopy =>
      'किसी भी अस्पताल विज़िट के लिए — पहले मिनट की ज़रूरी जानकारी, दिखाने या भेजने के लिए तैयार।';

  @override
  String get shareCard => 'कार्ड भेजें';

  @override
  String get allergiesLabel => 'एलर्जी';

  @override
  String get noneKnown => 'कोई ज्ञात नहीं';

  @override
  String get dialysisCentreLabel => 'डायलिसिस केंद्र';

  @override
  String get medicinesLabel => 'दवाइयाँ';

  @override
  String get emergencyContactLabel => 'आपातकालीन संपर्क';

  @override
  String get noPatientTitle => 'मरीज़ की जानकारी नहीं';

  @override
  String get noPatientMessage => 'पहले मरीज़ की प्रोफ़ाइल भरें।';

  @override
  String get docTypeLabReport => 'जाँच रिपोर्ट';

  @override
  String get docTypePrescription => 'पर्ची';

  @override
  String get docTypeDischargeSummary => 'डिस्चार्ज सारांश';

  @override
  String get docTypeBill => 'बिल';

  @override
  String get docTypeHandwrittenNote => 'हस्तलिखित नोट';

  @override
  String get docTypeScan => 'स्कैन';

  @override
  String get eventAdmission => 'भर्ती';

  @override
  String get eventProcedure => 'प्रक्रिया';

  @override
  String get eventMedicationChange => 'दवा में बदलाव';

  @override
  String get eventDialysis => 'डायलिसिस';

  @override
  String get eventLabReport => 'जाँच रिपोर्ट';

  @override
  String get eventPrescription => 'पर्ची';

  @override
  String get eventDoctorVisit => 'डॉक्टर विज़िट';

  @override
  String get eventBill => 'अस्पताल बिल';

  @override
  String get eventDischarge => 'डिस्चार्ज सारांश';

  @override
  String get eventSymptom => 'लक्षण';

  @override
  String get groupWithFood => 'खाने के साथ';

  @override
  String get groupByClock => 'समय से';

  @override
  String get groupWeekly => 'साप्ताहिक';

  @override
  String get cueMorning => 'सुबह';

  @override
  String get cueNoon => 'दोपहर';

  @override
  String get cueNight => 'रात';

  @override
  String get cueBeforeFood => 'खाने से पहले';

  @override
  String get cueAfterFood => 'खाने के बाद';

  @override
  String get cueWithFood => 'खाने के साथ';

  @override
  String get cueDialysisDayOnly => 'सिर्फ़ डायलिसिस के दिन';

  @override
  String get dayMon => 'सोम';

  @override
  String get dayTue => 'मंगल';

  @override
  String get dayWed => 'बुध';

  @override
  String get dayThu => 'गुरु';

  @override
  String get dayFri => 'शुक्र';

  @override
  String get daySat => 'शनि';

  @override
  String get daySun => 'रवि';

  @override
  String get folderLabReports => 'जाँच रिपोर्टें';

  @override
  String get folderPrescriptions => 'पर्चियाँ';

  @override
  String get folderDischarge => 'डिस्चार्ज';

  @override
  String get folderBills => 'बिल';

  @override
  String get reportDateDialogTitle => 'रिपोर्ट की तारीख़';

  @override
  String confidenceVerified(int percent) {
    return 'विश्वसनीयता $percent प्रतिशत, जाँची गई';
  }

  @override
  String confidenceNeedsCheck(int percent) {
    return 'विश्वसनीयता $percent प्रतिशत, जाँचनी बाकी';
  }

  @override
  String get otherConditions => 'अन्य बीमारियाँ';

  @override
  String get otherConditionsHint => 'और कुछ हो तो, कॉमा से अलग करें';

  @override
  String get otherConditionsLabel => 'अन्य बीमारियाँ';

  @override
  String get comorbidityDiabetes => 'डायबिटीज़';

  @override
  String get comorbidityHypertension => 'हाई BP';

  @override
  String get comorbidityHeartDisease => 'दिल की बीमारी';

  @override
  String get comorbidityThyroid => 'थायरॉइड';

  @override
  String get comorbidityPancreatitis => 'क्रोनिक पैंक्रियेटाइटिस';

  @override
  String get geminiKeyTitle => 'Gemini API कुंजी';

  @override
  String get geminiKeySubOn => 'कुंजी जुड़ गई — AI सुविधाएँ चालू हैं';

  @override
  String get geminiKeySubOff =>
      'AI सुविधाएँ चालू करने के लिए अपनी कुंजी चिपकाएँ';

  @override
  String get geminiKeyHint => 'अपनी कुंजी यहाँ चिपकाएँ';

  @override
  String get geminiKeyHelp =>
      'aistudio.google.com पर मुफ़्त मिलती है। सिर्फ़ इसी डिवाइस के सुरक्षित स्टोरेज में रहती है।';

  @override
  String get geminiKeyRemove => 'कुंजी हटाएँ';

  @override
  String get eventClaim => 'बीमा क्लेम';

  @override
  String get claimsTitle => 'क्लेम';

  @override
  String get claimsAction => 'क्लेम';

  @override
  String get claimsEmptyTitle => 'अभी कोई क्लेम नहीं';

  @override
  String get claimsEmpty =>
      'अभी कोई क्लेम नहीं। वॉल्ट के बिलों को एक क्लेम में जोड़ें और निपटान तक ट्रैक करें।';

  @override
  String claimsYtdLine(String claimed, String recovered) {
    return 'इस साल $claimed क्लेम किया · $recovered वापस मिला';
  }

  @override
  String unclaimedBillsChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'बिल',
      one: 'बिल',
    );
    return '$count बिना क्लेम $_temp0';
  }

  @override
  String get claimSectionAttention => 'ध्यान चाहिए';

  @override
  String get claimSectionInProgress => 'प्रगति में';

  @override
  String get claimSectionHistory => 'निपटाए और अस्वीकृत';

  @override
  String claimDocCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दस्तावेज़',
      one: 'दस्तावेज़',
    );
    return '$count $_temp0';
  }

  @override
  String get claimStatusDraft => 'ड्राफ़्ट';

  @override
  String get claimStatusSubmitted => 'जमा किया गया';

  @override
  String get claimStatusApproved => 'स्वीकृत';

  @override
  String get claimStatusPartiallySettled => 'आंशिक रूप से निपटाया';

  @override
  String get claimStatusRejected => 'अस्वीकृत';

  @override
  String get claimNew => 'नया क्लेम';

  @override
  String get claimEdit => 'क्लेम बदलें';

  @override
  String get claimTitleLabel => 'क्लेम का शीर्षक';

  @override
  String get claimTitleHint => 'जैसे अगस्त डायलिसिस और दवाइयाँ';

  @override
  String get claimTitleRequired => 'क्लेम को एक छोटा शीर्षक दें।';

  @override
  String get claimPolicyLabel => 'पॉलिसी';

  @override
  String get claimPolicyNone => 'कोई पॉलिसी नहीं';

  @override
  String get claimNoPolicyYet =>
      'समय-सीमा रिमाइंडर के लिए सेटिंग्स में अपनी पॉलिसी जोड़ें।';

  @override
  String get claimPickDocuments => 'दस्तावेज़ जोड़ें';

  @override
  String get claimPickDocumentsSub => 'बिना क्लेम वाले बिल पहले से चुने हैं';

  @override
  String get claimDocumentsSection => 'दस्तावेज़';

  @override
  String get claimChecklistSection => 'चेकलिस्ट';

  @override
  String get claimChecklistAddHint => 'चेकलिस्ट आइटम जोड़ें…';

  @override
  String get claimAmountClaimed => 'क्लेम किया';

  @override
  String get claimAmountApproved => 'स्वीकृत';

  @override
  String get claimAmountHint => 'राशि ₹ में';

  @override
  String get claimAmountInvalid => 'रुपये में सही राशि लिखें।';

  @override
  String get claimInsurerRefLabel => 'बीमा क्लेम नंबर';

  @override
  String get claimNotesLabel => 'नोट';

  @override
  String get claimMarkSubmitted => 'जमा किया चिह्नित करें';

  @override
  String get claimRecordOutcome => 'नतीजा दर्ज करें';

  @override
  String get claimReopen => 'फिर से ड्राफ़्ट करें';

  @override
  String get claimDelete => 'क्लेम हटाएँ';

  @override
  String get claimDeleteConfirm =>
      'यह क्लेम हटाएँ? दस्तावेज़ वॉल्ट में बने रहेंगे।';

  @override
  String get claimSubmittedOn => 'जमा करने की तारीख़';

  @override
  String get claimSettledOn => 'निपटान की तारीख़';

  @override
  String get claimCreatedOn => 'बनाने की तारीख़';

  @override
  String get claimNoDocsError =>
      'जमा करने से पहले कम से कम एक दस्तावेज़ जोड़ें।';

  @override
  String get claimApprovedExceedsWarning =>
      'स्वीकृत राशि क्लेम से ज़्यादा है — पत्र फिर से जाँचें।';

  @override
  String get claimOutcomeApproved => 'पूरा स्वीकृत';

  @override
  String get claimOutcomePartial => 'आंशिक रूप से निपटाया';

  @override
  String get claimOutcomeRejected => 'अस्वीकृत';

  @override
  String claimDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन',
      one: 'दिन',
    );
    return 'क्लेम के लिए $count $_temp0 बाक़ी';
  }

  @override
  String get claimOverdue => 'क्लेम की समय-सीमा निकल गई';

  @override
  String claimAwaitingLong(int count) {
    return '$count दिन पहले जमा किया — फ़ॉलो-अप कॉल करें';
  }

  @override
  String claimGlanceTitle(int count) {
    return 'क्लेम · $count';
  }

  @override
  String get policyTitle => 'बीमा पॉलिसी';

  @override
  String get policySettingsSub => 'बीमा कंपनी, पॉलिसी नंबर, क्लेम अवधि';

  @override
  String get policyInsurerLabel => 'बीमा कंपनी';

  @override
  String get policyNumberLabel => 'पॉलिसी नंबर';

  @override
  String get policyTpaLabel => 'TPA (वैकल्पिक)';

  @override
  String get policyWindowLabel => 'क्लेम अवधि (दिन)';

  @override
  String get policyWindowInvalid =>
      'बिल कितने दिन क्लेम हो सकते हैं, वह संख्या लिखें।';

  @override
  String get policyRequired => 'बीमा कंपनी और पॉलिसी नंबर ज़रूरी हैं।';

  @override
  String get checklistClaimForm => 'हस्ताक्षरित क्लेम फ़ॉर्म';

  @override
  String get checklistOriginalBills => 'मूल बिल';

  @override
  String get checklistPrescriptionCopy => 'पर्चे की कॉपी';

  @override
  String get checklistLabReports => 'लैब रिपोर्ट';

  @override
  String get checklistPolicyIdCopy => 'पॉलिसी और पहचान-पत्र की कॉपी';

  @override
  String labHistoryTitle(String metric) {
    return '$metric की रीडिंग';
  }

  @override
  String viewReadingHistory(String metric) {
    return '$metric का इतिहास देखें';
  }

  @override
  String get editReading => 'रीडिंग बदलें';

  @override
  String editReadingOn(String date) {
    return '$date की रीडिंग बदलें';
  }

  @override
  String get deleteReading => 'रीडिंग हटाएँ';

  @override
  String get deleteReadingConfirm =>
      'यह रीडिंग हटाएँ? इसे वापस नहीं लाया जा सकता।';

  @override
  String get editSession => 'सत्र बदलें';

  @override
  String get deleteSession => 'सत्र हटाएँ';

  @override
  String get deleteSessionConfirm =>
      'यह सत्र हटाएँ? इसके साथ दर्ज वज़न और BP रीडिंग भी हट जाएँगी।';

  @override
  String get sessionUpdated => 'सत्र अपडेट हुआ';

  @override
  String get sessionDeleted => 'सत्र हटा दिया गया';

  @override
  String sessionActionsFor(String date) {
    return '$date का सत्र';
  }

  @override
  String get editMedicine => 'दवा बदलें';

  @override
  String get endMedicine => 'बंद हुई दर्ज करें';

  @override
  String get medicineEnded => 'बंद हुई दर्ज की गई';

  @override
  String get deleteMedicine => 'दवा हटाएँ';

  @override
  String get deleteMedicineConfirm =>
      'यह दवा पूरी तरह हटाएँ? अगर यह सच में ली जाती थी और अब बंद है, तो इसे बंद हुई दर्ज करें।';

  @override
  String get medicineUpdated => 'दवा अपडेट हुई';

  @override
  String get medicineDeleted => 'दवा हटा दी गई';

  @override
  String get undo => 'वापस लें';

  @override
  String doseMarkedGiven(String name) {
    return '$name — दी गई दर्ज हुई';
  }

  @override
  String doseMarkedNotGiven(String name) {
    return '$name — नहीं दी गई दर्ज हुई';
  }

  @override
  String get repeatEveryDays => 'कितने दिनों में दी जाती है?';

  @override
  String everyNDays(int n) {
    return 'हर $n दिन में';
  }

  @override
  String nDaysChip(int n) {
    return '$n दिन';
  }

  @override
  String get intervalGroup => 'हर कुछ दिनों में';

  @override
  String get dueToday => 'आज देनी है';

  @override
  String overdueByDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n दिन',
      one: '1 दिन',
    );
    return '$_temp0 देर हो चुकी';
  }

  @override
  String nextOnDate(String date) {
    return 'अगली $date को';
  }

  @override
  String get givenToday => 'आज दे दी गई';

  @override
  String get markGivenToday => 'आज दी गई दर्ज करें';

  @override
  String get medicinesDue => 'देनी हैं ये दवाइयाँ';

  @override
  String markGivenSemantics(String name) {
    return '$name आज दी गई दर्ज करें';
  }

  @override
  String get moreOptions => 'और विकल्प';

  @override
  String get importDocuments => 'दस्तावेज़ इम्पोर्ट करें';

  @override
  String get importPhotos => 'फ़ोटो इम्पोर्ट करें';

  @override
  String get importPdfFiles => 'PDF फ़ाइलें इम्पोर्ट करें';

  @override
  String get importEmptyMessage =>
      'स्कैन की गई फ़ोटो या PDF फ़ाइलें जोड़ें।\nRecora लैब रिपोर्ट पढ़ता है; बाकी दस्तावेज़ जैसे हैं वैसे ही रखे जाते हैं।';

  @override
  String nItemsToImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दस्तावेज़',
      one: '1 दस्तावेज़',
      zero: 'कोई दस्तावेज़ नहीं',
    );
    return '$_temp0';
  }

  @override
  String nSelected(int count) {
    return '$count चुने गए';
  }

  @override
  String nPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पेज',
      one: '1 पेज',
    );
    return '$_temp0';
  }

  @override
  String get combineIntoOneDocument => 'एक दस्तावेज़ बनाएँ';

  @override
  String get ungroupPages => 'अलग करें';

  @override
  String get removeDocument => 'हटाएँ';

  @override
  String get addMore => 'और जोड़ें';

  @override
  String get startImport => 'इम्पोर्ट शुरू करें';

  @override
  String reviewingItemOfTotal(int index, int total) {
    return '$total में से $index की जाँच';
  }

  @override
  String get skipDocument => 'छोड़ें';

  @override
  String get saveAndNext => 'सहेजें और आगे';

  @override
  String get waitingForExtraction => 'यह दस्तावेज़ पढ़ा जा रहा है…';

  @override
  String get extractionFailedTitle => 'यह दस्तावेज़ पढ़ा नहीं जा सका';

  @override
  String get retryExtraction => 'फिर कोशिश करें';

  @override
  String get importSummary => 'इम्पोर्ट पूरा हुआ';

  @override
  String nDocumentsSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दस्तावेज़ सहेजे गए',
      one: '1 दस्तावेज़ सहेजा गया',
      zero: 'कुछ सहेजा नहीं गया',
    );
    return '$_temp0';
  }

  @override
  String nDocumentsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count छोड़े गए',
      one: '1 छोड़ा गया',
    );
    return '$_temp0';
  }

  @override
  String nDocumentsFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count विफल',
      one: '1 विफल',
    );
    return '$_temp0';
  }

  @override
  String get importDone => 'हो गया';
}
