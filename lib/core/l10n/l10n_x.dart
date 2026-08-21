import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/domain/claim_status.dart';
import '../../shared/domain/document_type.dart';
import '../../shared/domain/med_schedule.dart';
import '../../shared/domain/timeline_event_type.dart';

export '../../l10n/app_localizations.dart';

/// Shorthand for reading localized strings in widgets:
/// `final l10n = context.l10n;`
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Enums own their presentation (mirroring the app-wide convention):
/// every user-facing enum exposes a localized label here, so no widget
/// ever switches over enum values to produce text.
extension DocumentTypeL10n on DocumentType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        DocumentType.labReport => l10n.docTypeLabReport,
        DocumentType.prescription => l10n.docTypePrescription,
        DocumentType.dischargeSummary => l10n.docTypeDischargeSummary,
        DocumentType.bill => l10n.docTypeBill,
        DocumentType.handwrittenNote => l10n.docTypeHandwrittenNote,
        DocumentType.scan => l10n.docTypeScan,
      };
}

extension TimelineEventTypeL10n on TimelineEventType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        TimelineEventType.admission => l10n.eventAdmission,
        TimelineEventType.procedure => l10n.eventProcedure,
        TimelineEventType.medicationChange => l10n.eventMedicationChange,
        TimelineEventType.dialysis => l10n.eventDialysis,
        TimelineEventType.labReport => l10n.eventLabReport,
        TimelineEventType.prescription => l10n.eventPrescription,
        TimelineEventType.doctorVisit => l10n.eventDoctorVisit,
        TimelineEventType.bill => l10n.eventBill,
        TimelineEventType.discharge => l10n.eventDischarge,
        TimelineEventType.symptom => l10n.eventSymptom,
        TimelineEventType.claim => l10n.eventClaim,
      };
}

extension MedFoodRelationL10n on MedFoodRelation {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MedFoodRelation.beforeFood => l10n.foodBeforeFood,
        MedFoodRelation.withFood => l10n.foodWithFood,
        MedFoodRelation.afterFood => l10n.foodAfterFood,
        MedFoodRelation.noRelation => l10n.foodNoRelation,
      };
}

extension MedTimeOfDayL10n on MedTimeOfDay {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MedTimeOfDay.morning => l10n.timeMorning,
        MedTimeOfDay.noon => l10n.timeNoon,
        MedTimeOfDay.night => l10n.timeNight,
      };
}

extension MedFrequencyL10n on MedFrequency {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MedFrequency.daily => l10n.freqDaily,
        MedFrequency.weekly => l10n.freqWeekly,
        MedFrequency.everyNDays => l10n.freqEveryNDays,
        MedFrequency.dialysisDaysOnly => l10n.freqDialysisDays,
      };
}

extension ClaimStatusL10n on ClaimStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ClaimStatus.draft => l10n.claimStatusDraft,
        ClaimStatus.submitted => l10n.claimStatusSubmitted,
        ClaimStatus.approved => l10n.claimStatusApproved,
        ClaimStatus.partiallySettled => l10n.claimStatusPartiallySettled,
        ClaimStatus.rejected => l10n.claimStatusRejected,
      };
}

/// Localized short weekday name for [DateTime.monday]..[DateTime.sunday].
String localizedWeekday(AppLocalizations l10n, int weekday) =>
    switch (weekday) {
      DateTime.monday => l10n.dayMon,
      DateTime.tuesday => l10n.dayTue,
      DateTime.wednesday => l10n.dayWed,
      DateTime.thursday => l10n.dayThu,
      DateTime.friday => l10n.dayFri,
      DateTime.saturday => l10n.daySat,
      _ => l10n.daySun,
    };
