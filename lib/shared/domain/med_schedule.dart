// A medication's schedule is three independent answers:
// how it relates to food, which parts of the day it is taken,
// and how often.

/// FOOD & MEDICINE — how a dose relates to meals.
enum MedFoodRelation { beforeFood, withFood, afterFood, noRelation }

/// TIME OF DAY — which parts of the day doses fall in (multi-select).
enum MedTimeOfDay { morning, noon, night }

/// HOW OFTEN — the repeat pattern. [everyNDays] pairs with
/// Medications.intervalDays.
enum MedFrequency { daily, weekly, everyNDays, dialysisDaysOnly }
