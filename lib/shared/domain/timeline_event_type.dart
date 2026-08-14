/// Kind of event on the longitudinal medical timeline.
enum TimelineEventType {
  admission('Admission'),
  procedure('Procedure'),
  medicationChange('Medication change'),
  dialysis('Dialysis'),
  labReport('Lab report'),
  prescription('Prescription'),
  doctorVisit('Doctor visit'),
  bill('Hospital bill'),
  discharge('Discharge summary'),
  symptom('Symptom');

  const TimelineEventType(this.label);

  final String label;
}
