/// How a medication's doses relate to meals and time of day.
enum MedScheduleGroup {
  withFood('With food'),
  byClock('By the clock'),
  weekly('Weekly');

  const MedScheduleGroup(this.label);

  final String label;
}

/// Timing cue icons shown on medication cards.
enum MedTimingCue {
  morning('Morning'),
  noon('Noon'),
  night('Night'),
  beforeFood('Before food'),
  afterFood('After food'),
  withFood('With food'),
  dialysisDayOnly('Dialysis day only');

  const MedTimingCue(this.label);

  final String label;
}
