// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialsMeta = const VerificationMeta(
    'initials',
  );
  @override
  late final GeneratedColumn<String> initials = GeneratedColumn<String>(
    'initials',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionSummaryMeta = const VerificationMeta(
    'conditionSummary',
  );
  @override
  late final GeneratedColumn<String> conditionSummary = GeneratedColumn<String>(
    'condition_summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dialysisCenterMeta = const VerificationMeta(
    'dialysisCenter',
  );
  @override
  late final GeneratedColumn<String> dialysisCenter = GeneratedColumn<String>(
    'dialysis_center',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dryWeightKgMeta = const VerificationMeta(
    'dryWeightKg',
  );
  @override
  late final GeneratedColumn<double> dryWeightKg = GeneratedColumn<double>(
    'dry_weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dryWeightDeltaKgMeta = const VerificationMeta(
    'dryWeightDeltaKg',
  );
  @override
  late final GeneratedColumn<double> dryWeightDeltaKg = GeneratedColumn<double>(
    'dry_weight_delta_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scheduleJsonMeta = const VerificationMeta(
    'scheduleJson',
  );
  @override
  late final GeneratedColumn<String> scheduleJson = GeneratedColumn<String>(
    'schedule_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _bloodGroupMeta = const VerificationMeta(
    'bloodGroup',
  );
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
    'blood_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _allergiesMeta = const VerificationMeta(
    'allergies',
  );
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
    'allergies',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emergencyContactMeta = const VerificationMeta(
    'emergencyContact',
  );
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
    'emergency_contact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _comorbiditiesMeta = const VerificationMeta(
    'comorbidities',
  );
  @override
  late final GeneratedColumn<String> comorbidities = GeneratedColumn<String>(
    'comorbidities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    initials,
    age,
    conditionSummary,
    dialysisCenter,
    dryWeightKg,
    dryWeightDeltaKg,
    scheduleJson,
    bloodGroup,
    allergies,
    emergencyContact,
    comorbidities,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Patient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initials')) {
      context.handle(
        _initialsMeta,
        initials.isAcceptableOrUnknown(data['initials']!, _initialsMeta),
      );
    } else if (isInserting) {
      context.missing(_initialsMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('condition_summary')) {
      context.handle(
        _conditionSummaryMeta,
        conditionSummary.isAcceptableOrUnknown(
          data['condition_summary']!,
          _conditionSummaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionSummaryMeta);
    }
    if (data.containsKey('dialysis_center')) {
      context.handle(
        _dialysisCenterMeta,
        dialysisCenter.isAcceptableOrUnknown(
          data['dialysis_center']!,
          _dialysisCenterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dialysisCenterMeta);
    }
    if (data.containsKey('dry_weight_kg')) {
      context.handle(
        _dryWeightKgMeta,
        dryWeightKg.isAcceptableOrUnknown(
          data['dry_weight_kg']!,
          _dryWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dryWeightKgMeta);
    }
    if (data.containsKey('dry_weight_delta_kg')) {
      context.handle(
        _dryWeightDeltaKgMeta,
        dryWeightDeltaKg.isAcceptableOrUnknown(
          data['dry_weight_delta_kg']!,
          _dryWeightDeltaKgMeta,
        ),
      );
    }
    if (data.containsKey('schedule_json')) {
      context.handle(
        _scheduleJsonMeta,
        scheduleJson.isAcceptableOrUnknown(
          data['schedule_json']!,
          _scheduleJsonMeta,
        ),
      );
    }
    if (data.containsKey('blood_group')) {
      context.handle(
        _bloodGroupMeta,
        bloodGroup.isAcceptableOrUnknown(data['blood_group']!, _bloodGroupMeta),
      );
    }
    if (data.containsKey('allergies')) {
      context.handle(
        _allergiesMeta,
        allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta),
      );
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
        _emergencyContactMeta,
        emergencyContact.isAcceptableOrUnknown(
          data['emergency_contact']!,
          _emergencyContactMeta,
        ),
      );
    }
    if (data.containsKey('comorbidities')) {
      context.handle(
        _comorbiditiesMeta,
        comorbidities.isAcceptableOrUnknown(
          data['comorbidities']!,
          _comorbiditiesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      initials: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}initials'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      conditionSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_summary'],
      )!,
      dialysisCenter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dialysis_center'],
      )!,
      dryWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dry_weight_kg'],
      )!,
      dryWeightDeltaKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dry_weight_delta_kg'],
      )!,
      scheduleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_json'],
      )!,
      bloodGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_group'],
      )!,
      allergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergies'],
      )!,
      emergencyContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact'],
      )!,
      comorbidities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comorbidities'],
      )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String name;
  final String initials;
  final int age;
  final String conditionSummary;
  final String dialysisCenter;
  final double dryWeightKg;
  final double dryWeightDeltaKg;

  /// Dialysis schedule as JSON: weekday (1=Mon..7=Sun) → start time in
  /// minutes past midnight, e.g. {"1":420,"4":1035} for Mon 7:00 AM and
  /// Thu 5:15 PM.
  final String scheduleJson;

  /// Emergency-card details.
  final String bloodGroup;
  final String allergies;
  final String emergencyContact;

  /// Comma-separated other conditions, e.g.
  /// "Diabetes, Hypertension, Chronic pancreatitis". Kept in English so
  /// emergency staff and reports read them unambiguously.
  final String comorbidities;
  const Patient({
    required this.id,
    required this.name,
    required this.initials,
    required this.age,
    required this.conditionSummary,
    required this.dialysisCenter,
    required this.dryWeightKg,
    required this.dryWeightDeltaKg,
    required this.scheduleJson,
    required this.bloodGroup,
    required this.allergies,
    required this.emergencyContact,
    required this.comorbidities,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['initials'] = Variable<String>(initials);
    map['age'] = Variable<int>(age);
    map['condition_summary'] = Variable<String>(conditionSummary);
    map['dialysis_center'] = Variable<String>(dialysisCenter);
    map['dry_weight_kg'] = Variable<double>(dryWeightKg);
    map['dry_weight_delta_kg'] = Variable<double>(dryWeightDeltaKg);
    map['schedule_json'] = Variable<String>(scheduleJson);
    map['blood_group'] = Variable<String>(bloodGroup);
    map['allergies'] = Variable<String>(allergies);
    map['emergency_contact'] = Variable<String>(emergencyContact);
    map['comorbidities'] = Variable<String>(comorbidities);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      name: Value(name),
      initials: Value(initials),
      age: Value(age),
      conditionSummary: Value(conditionSummary),
      dialysisCenter: Value(dialysisCenter),
      dryWeightKg: Value(dryWeightKg),
      dryWeightDeltaKg: Value(dryWeightDeltaKg),
      scheduleJson: Value(scheduleJson),
      bloodGroup: Value(bloodGroup),
      allergies: Value(allergies),
      emergencyContact: Value(emergencyContact),
      comorbidities: Value(comorbidities),
    );
  }

  factory Patient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      initials: serializer.fromJson<String>(json['initials']),
      age: serializer.fromJson<int>(json['age']),
      conditionSummary: serializer.fromJson<String>(json['conditionSummary']),
      dialysisCenter: serializer.fromJson<String>(json['dialysisCenter']),
      dryWeightKg: serializer.fromJson<double>(json['dryWeightKg']),
      dryWeightDeltaKg: serializer.fromJson<double>(json['dryWeightDeltaKg']),
      scheduleJson: serializer.fromJson<String>(json['scheduleJson']),
      bloodGroup: serializer.fromJson<String>(json['bloodGroup']),
      allergies: serializer.fromJson<String>(json['allergies']),
      emergencyContact: serializer.fromJson<String>(json['emergencyContact']),
      comorbidities: serializer.fromJson<String>(json['comorbidities']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'initials': serializer.toJson<String>(initials),
      'age': serializer.toJson<int>(age),
      'conditionSummary': serializer.toJson<String>(conditionSummary),
      'dialysisCenter': serializer.toJson<String>(dialysisCenter),
      'dryWeightKg': serializer.toJson<double>(dryWeightKg),
      'dryWeightDeltaKg': serializer.toJson<double>(dryWeightDeltaKg),
      'scheduleJson': serializer.toJson<String>(scheduleJson),
      'bloodGroup': serializer.toJson<String>(bloodGroup),
      'allergies': serializer.toJson<String>(allergies),
      'emergencyContact': serializer.toJson<String>(emergencyContact),
      'comorbidities': serializer.toJson<String>(comorbidities),
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    String? initials,
    int? age,
    String? conditionSummary,
    String? dialysisCenter,
    double? dryWeightKg,
    double? dryWeightDeltaKg,
    String? scheduleJson,
    String? bloodGroup,
    String? allergies,
    String? emergencyContact,
    String? comorbidities,
  }) => Patient(
    id: id ?? this.id,
    name: name ?? this.name,
    initials: initials ?? this.initials,
    age: age ?? this.age,
    conditionSummary: conditionSummary ?? this.conditionSummary,
    dialysisCenter: dialysisCenter ?? this.dialysisCenter,
    dryWeightKg: dryWeightKg ?? this.dryWeightKg,
    dryWeightDeltaKg: dryWeightDeltaKg ?? this.dryWeightDeltaKg,
    scheduleJson: scheduleJson ?? this.scheduleJson,
    bloodGroup: bloodGroup ?? this.bloodGroup,
    allergies: allergies ?? this.allergies,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    comorbidities: comorbidities ?? this.comorbidities,
  );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      initials: data.initials.present ? data.initials.value : this.initials,
      age: data.age.present ? data.age.value : this.age,
      conditionSummary: data.conditionSummary.present
          ? data.conditionSummary.value
          : this.conditionSummary,
      dialysisCenter: data.dialysisCenter.present
          ? data.dialysisCenter.value
          : this.dialysisCenter,
      dryWeightKg: data.dryWeightKg.present
          ? data.dryWeightKg.value
          : this.dryWeightKg,
      dryWeightDeltaKg: data.dryWeightDeltaKg.present
          ? data.dryWeightDeltaKg.value
          : this.dryWeightDeltaKg,
      scheduleJson: data.scheduleJson.present
          ? data.scheduleJson.value
          : this.scheduleJson,
      bloodGroup: data.bloodGroup.present
          ? data.bloodGroup.value
          : this.bloodGroup,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      comorbidities: data.comorbidities.present
          ? data.comorbidities.value
          : this.comorbidities,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('initials: $initials, ')
          ..write('age: $age, ')
          ..write('conditionSummary: $conditionSummary, ')
          ..write('dialysisCenter: $dialysisCenter, ')
          ..write('dryWeightKg: $dryWeightKg, ')
          ..write('dryWeightDeltaKg: $dryWeightDeltaKg, ')
          ..write('scheduleJson: $scheduleJson, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('allergies: $allergies, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('comorbidities: $comorbidities')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    initials,
    age,
    conditionSummary,
    dialysisCenter,
    dryWeightKg,
    dryWeightDeltaKg,
    scheduleJson,
    bloodGroup,
    allergies,
    emergencyContact,
    comorbidities,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.name == this.name &&
          other.initials == this.initials &&
          other.age == this.age &&
          other.conditionSummary == this.conditionSummary &&
          other.dialysisCenter == this.dialysisCenter &&
          other.dryWeightKg == this.dryWeightKg &&
          other.dryWeightDeltaKg == this.dryWeightDeltaKg &&
          other.scheduleJson == this.scheduleJson &&
          other.bloodGroup == this.bloodGroup &&
          other.allergies == this.allergies &&
          other.emergencyContact == this.emergencyContact &&
          other.comorbidities == this.comorbidities);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> initials;
  final Value<int> age;
  final Value<String> conditionSummary;
  final Value<String> dialysisCenter;
  final Value<double> dryWeightKg;
  final Value<double> dryWeightDeltaKg;
  final Value<String> scheduleJson;
  final Value<String> bloodGroup;
  final Value<String> allergies;
  final Value<String> emergencyContact;
  final Value<String> comorbidities;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.initials = const Value.absent(),
    this.age = const Value.absent(),
    this.conditionSummary = const Value.absent(),
    this.dialysisCenter = const Value.absent(),
    this.dryWeightKg = const Value.absent(),
    this.dryWeightDeltaKg = const Value.absent(),
    this.scheduleJson = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.allergies = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.comorbidities = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String name,
    required String initials,
    required int age,
    required String conditionSummary,
    required String dialysisCenter,
    required double dryWeightKg,
    this.dryWeightDeltaKg = const Value.absent(),
    this.scheduleJson = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.allergies = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.comorbidities = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       initials = Value(initials),
       age = Value(age),
       conditionSummary = Value(conditionSummary),
       dialysisCenter = Value(dialysisCenter),
       dryWeightKg = Value(dryWeightKg);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? initials,
    Expression<int>? age,
    Expression<String>? conditionSummary,
    Expression<String>? dialysisCenter,
    Expression<double>? dryWeightKg,
    Expression<double>? dryWeightDeltaKg,
    Expression<String>? scheduleJson,
    Expression<String>? bloodGroup,
    Expression<String>? allergies,
    Expression<String>? emergencyContact,
    Expression<String>? comorbidities,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (initials != null) 'initials': initials,
      if (age != null) 'age': age,
      if (conditionSummary != null) 'condition_summary': conditionSummary,
      if (dialysisCenter != null) 'dialysis_center': dialysisCenter,
      if (dryWeightKg != null) 'dry_weight_kg': dryWeightKg,
      if (dryWeightDeltaKg != null) 'dry_weight_delta_kg': dryWeightDeltaKg,
      if (scheduleJson != null) 'schedule_json': scheduleJson,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (allergies != null) 'allergies': allergies,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (comorbidities != null) 'comorbidities': comorbidities,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? initials,
    Value<int>? age,
    Value<String>? conditionSummary,
    Value<String>? dialysisCenter,
    Value<double>? dryWeightKg,
    Value<double>? dryWeightDeltaKg,
    Value<String>? scheduleJson,
    Value<String>? bloodGroup,
    Value<String>? allergies,
    Value<String>? emergencyContact,
    Value<String>? comorbidities,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      age: age ?? this.age,
      conditionSummary: conditionSummary ?? this.conditionSummary,
      dialysisCenter: dialysisCenter ?? this.dialysisCenter,
      dryWeightKg: dryWeightKg ?? this.dryWeightKg,
      dryWeightDeltaKg: dryWeightDeltaKg ?? this.dryWeightDeltaKg,
      scheduleJson: scheduleJson ?? this.scheduleJson,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      comorbidities: comorbidities ?? this.comorbidities,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (initials.present) {
      map['initials'] = Variable<String>(initials.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (conditionSummary.present) {
      map['condition_summary'] = Variable<String>(conditionSummary.value);
    }
    if (dialysisCenter.present) {
      map['dialysis_center'] = Variable<String>(dialysisCenter.value);
    }
    if (dryWeightKg.present) {
      map['dry_weight_kg'] = Variable<double>(dryWeightKg.value);
    }
    if (dryWeightDeltaKg.present) {
      map['dry_weight_delta_kg'] = Variable<double>(dryWeightDeltaKg.value);
    }
    if (scheduleJson.present) {
      map['schedule_json'] = Variable<String>(scheduleJson.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (comorbidities.present) {
      map['comorbidities'] = Variable<String>(comorbidities.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('initials: $initials, ')
          ..write('age: $age, ')
          ..write('conditionSummary: $conditionSummary, ')
          ..write('dialysisCenter: $dialysisCenter, ')
          ..write('dryWeightKg: $dryWeightKg, ')
          ..write('dryWeightDeltaKg: $dryWeightDeltaKg, ')
          ..write('scheduleJson: $scheduleJson, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('allergies: $allergies, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('comorbidities: $comorbidities, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DocumentType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DocumentType>($DocumentsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hospitalMeta = const VerificationMeta(
    'hospital',
  );
  @override
  late final GeneratedColumn<String> hospital = GeneratedColumn<String>(
    'hospital',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doctorMeta = const VerificationMeta('doctor');
  @override
  late final GeneratedColumn<String> doctor = GeneratedColumn<String>(
    'doctor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _documentDateMeta = const VerificationMeta(
    'documentDate',
  );
  @override
  late final GeneratedColumn<DateTime> documentDate = GeneratedColumn<DateTime>(
    'document_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalPathMeta = const VerificationMeta(
    'originalPath',
  );
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
    'original_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _previewPathMeta = const VerificationMeta(
    'previewPath',
  );
  @override
  late final GeneratedColumn<String> previewPath = GeneratedColumn<String>(
    'preview_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    hospital,
    doctor,
    documentDate,
    capturedAt,
    originalPath,
    previewPath,
    ocrText,
    tagsJson,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('hospital')) {
      context.handle(
        _hospitalMeta,
        hospital.isAcceptableOrUnknown(data['hospital']!, _hospitalMeta),
      );
    }
    if (data.containsKey('doctor')) {
      context.handle(
        _doctorMeta,
        doctor.isAcceptableOrUnknown(data['doctor']!, _doctorMeta),
      );
    }
    if (data.containsKey('document_date')) {
      context.handle(
        _documentDateMeta,
        documentDate.isAcceptableOrUnknown(
          data['document_date']!,
          _documentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentDateMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('original_path')) {
      context.handle(
        _originalPathMeta,
        originalPath.isAcceptableOrUnknown(
          data['original_path']!,
          _originalPathMeta,
        ),
      );
    }
    if (data.containsKey('preview_path')) {
      context.handle(
        _previewPathMeta,
        previewPath.isAcceptableOrUnknown(
          data['preview_path']!,
          _previewPathMeta,
        ),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $DocumentsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      hospital: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hospital'],
      )!,
      doctor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor'],
      )!,
      documentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}document_date'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      originalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_path'],
      )!,
      previewPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_path'],
      )!,
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DocumentType, String, String> $convertertype =
      const EnumNameConverter<DocumentType>(DocumentType.values);
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final DocumentType type;
  final String title;
  final String hospital;
  final String doctor;
  final DateTime documentDate;
  final DateTime capturedAt;
  final String originalPath;
  final String previewPath;
  final String ocrText;
  final String tagsJson;
  final String note;
  const Document({
    required this.id,
    required this.type,
    required this.title,
    required this.hospital,
    required this.doctor,
    required this.documentDate,
    required this.capturedAt,
    required this.originalPath,
    required this.previewPath,
    required this.ocrText,
    required this.tagsJson,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>(
        $DocumentsTable.$convertertype.toSql(type),
      );
    }
    map['title'] = Variable<String>(title);
    map['hospital'] = Variable<String>(hospital);
    map['doctor'] = Variable<String>(doctor);
    map['document_date'] = Variable<DateTime>(documentDate);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['original_path'] = Variable<String>(originalPath);
    map['preview_path'] = Variable<String>(previewPath);
    map['ocr_text'] = Variable<String>(ocrText);
    map['tags_json'] = Variable<String>(tagsJson);
    map['note'] = Variable<String>(note);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      hospital: Value(hospital),
      doctor: Value(doctor),
      documentDate: Value(documentDate),
      capturedAt: Value(capturedAt),
      originalPath: Value(originalPath),
      previewPath: Value(previewPath),
      ocrText: Value(ocrText),
      tagsJson: Value(tagsJson),
      note: Value(note),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      type: $DocumentsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      hospital: serializer.fromJson<String>(json['hospital']),
      doctor: serializer.fromJson<String>(json['doctor']),
      documentDate: serializer.fromJson<DateTime>(json['documentDate']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      originalPath: serializer.fromJson<String>(json['originalPath']),
      previewPath: serializer.fromJson<String>(json['previewPath']),
      ocrText: serializer.fromJson<String>(json['ocrText']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $DocumentsTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'hospital': serializer.toJson<String>(hospital),
      'doctor': serializer.toJson<String>(doctor),
      'documentDate': serializer.toJson<DateTime>(documentDate),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'originalPath': serializer.toJson<String>(originalPath),
      'previewPath': serializer.toJson<String>(previewPath),
      'ocrText': serializer.toJson<String>(ocrText),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'note': serializer.toJson<String>(note),
    };
  }

  Document copyWith({
    String? id,
    DocumentType? type,
    String? title,
    String? hospital,
    String? doctor,
    DateTime? documentDate,
    DateTime? capturedAt,
    String? originalPath,
    String? previewPath,
    String? ocrText,
    String? tagsJson,
    String? note,
  }) => Document(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    hospital: hospital ?? this.hospital,
    doctor: doctor ?? this.doctor,
    documentDate: documentDate ?? this.documentDate,
    capturedAt: capturedAt ?? this.capturedAt,
    originalPath: originalPath ?? this.originalPath,
    previewPath: previewPath ?? this.previewPath,
    ocrText: ocrText ?? this.ocrText,
    tagsJson: tagsJson ?? this.tagsJson,
    note: note ?? this.note,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      hospital: data.hospital.present ? data.hospital.value : this.hospital,
      doctor: data.doctor.present ? data.doctor.value : this.doctor,
      documentDate: data.documentDate.present
          ? data.documentDate.value
          : this.documentDate,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      previewPath: data.previewPath.present
          ? data.previewPath.value
          : this.previewPath,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('hospital: $hospital, ')
          ..write('doctor: $doctor, ')
          ..write('documentDate: $documentDate, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('originalPath: $originalPath, ')
          ..write('previewPath: $previewPath, ')
          ..write('ocrText: $ocrText, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    hospital,
    doctor,
    documentDate,
    capturedAt,
    originalPath,
    previewPath,
    ocrText,
    tagsJson,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.hospital == this.hospital &&
          other.doctor == this.doctor &&
          other.documentDate == this.documentDate &&
          other.capturedAt == this.capturedAt &&
          other.originalPath == this.originalPath &&
          other.previewPath == this.previewPath &&
          other.ocrText == this.ocrText &&
          other.tagsJson == this.tagsJson &&
          other.note == this.note);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<DocumentType> type;
  final Value<String> title;
  final Value<String> hospital;
  final Value<String> doctor;
  final Value<DateTime> documentDate;
  final Value<DateTime> capturedAt;
  final Value<String> originalPath;
  final Value<String> previewPath;
  final Value<String> ocrText;
  final Value<String> tagsJson;
  final Value<String> note;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.hospital = const Value.absent(),
    this.doctor = const Value.absent(),
    this.documentDate = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.previewPath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required DocumentType type,
    required String title,
    this.hospital = const Value.absent(),
    this.doctor = const Value.absent(),
    required DateTime documentDate,
    required DateTime capturedAt,
    this.originalPath = const Value.absent(),
    this.previewPath = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       documentDate = Value(documentDate),
       capturedAt = Value(capturedAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? hospital,
    Expression<String>? doctor,
    Expression<DateTime>? documentDate,
    Expression<DateTime>? capturedAt,
    Expression<String>? originalPath,
    Expression<String>? previewPath,
    Expression<String>? ocrText,
    Expression<String>? tagsJson,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (hospital != null) 'hospital': hospital,
      if (doctor != null) 'doctor': doctor,
      if (documentDate != null) 'document_date': documentDate,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (originalPath != null) 'original_path': originalPath,
      if (previewPath != null) 'preview_path': previewPath,
      if (ocrText != null) 'ocr_text': ocrText,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<DocumentType>? type,
    Value<String>? title,
    Value<String>? hospital,
    Value<String>? doctor,
    Value<DateTime>? documentDate,
    Value<DateTime>? capturedAt,
    Value<String>? originalPath,
    Value<String>? previewPath,
    Value<String>? ocrText,
    Value<String>? tagsJson,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      hospital: hospital ?? this.hospital,
      doctor: doctor ?? this.doctor,
      documentDate: documentDate ?? this.documentDate,
      capturedAt: capturedAt ?? this.capturedAt,
      originalPath: originalPath ?? this.originalPath,
      previewPath: previewPath ?? this.previewPath,
      ocrText: ocrText ?? this.ocrText,
      tagsJson: tagsJson ?? this.tagsJson,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $DocumentsTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (hospital.present) {
      map['hospital'] = Variable<String>(hospital.value);
    }
    if (doctor.present) {
      map['doctor'] = Variable<String>(doctor.value);
    }
    if (documentDate.present) {
      map['document_date'] = Variable<DateTime>(documentDate.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (previewPath.present) {
      map['preview_path'] = Variable<String>(previewPath.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('hospital: $hospital, ')
          ..write('doctor: $doctor, ')
          ..write('documentDate: $documentDate, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('originalPath: $originalPath, ')
          ..write('previewPath: $previewPath, ')
          ..write('ocrText: $ocrText, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<String> dose = GeneratedColumn<String>(
    'dose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyCodeMeta = const VerificationMeta(
    'frequencyCode',
  );
  @override
  late final GeneratedColumn<String> frequencyCode = GeneratedColumn<String>(
    'frequency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doctorMeta = const VerificationMeta('doctor');
  @override
  late final GeneratedColumn<String> doctor = GeneratedColumn<String>(
    'doctor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedScheduleGroup, String>
  scheduleGroup = GeneratedColumn<String>(
    'schedule_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MedScheduleGroup>($MedicationsTable.$converterscheduleGroup);
  static const VerificationMeta _timingCuesJsonMeta = const VerificationMeta(
    'timingCuesJson',
  );
  @override
  late final GeneratedColumn<String> timingCuesJson = GeneratedColumn<String>(
    'timing_cues_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _scheduleNoteMeta = const VerificationMeta(
    'scheduleNote',
  );
  @override
  late final GeneratedColumn<String> scheduleNote = GeneratedColumn<String>(
    'schedule_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changeNoteMeta = const VerificationMeta(
    'changeNote',
  );
  @override
  late final GeneratedColumn<String> changeNote = GeneratedColumn<String>(
    'change_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _changeDateMeta = const VerificationMeta(
    'changeDate',
  );
  @override
  late final GeneratedColumn<DateTime> changeDate = GeneratedColumn<DateTime>(
    'change_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceDocumentIdMeta = const VerificationMeta(
    'sourceDocumentId',
  );
  @override
  late final GeneratedColumn<String> sourceDocumentId = GeneratedColumn<String>(
    'source_document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    dose,
    frequencyCode,
    purpose,
    doctor,
    scheduleGroup,
    timingCuesJson,
    scheduleNote,
    startDate,
    endDate,
    changeNote,
    changeDate,
    sourceDocumentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose')) {
      context.handle(
        _doseMeta,
        dose.isAcceptableOrUnknown(data['dose']!, _doseMeta),
      );
    } else if (isInserting) {
      context.missing(_doseMeta);
    }
    if (data.containsKey('frequency_code')) {
      context.handle(
        _frequencyCodeMeta,
        frequencyCode.isAcceptableOrUnknown(
          data['frequency_code']!,
          _frequencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyCodeMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('doctor')) {
      context.handle(
        _doctorMeta,
        doctor.isAcceptableOrUnknown(data['doctor']!, _doctorMeta),
      );
    }
    if (data.containsKey('timing_cues_json')) {
      context.handle(
        _timingCuesJsonMeta,
        timingCuesJson.isAcceptableOrUnknown(
          data['timing_cues_json']!,
          _timingCuesJsonMeta,
        ),
      );
    }
    if (data.containsKey('schedule_note')) {
      context.handle(
        _scheduleNoteMeta,
        scheduleNote.isAcceptableOrUnknown(
          data['schedule_note']!,
          _scheduleNoteMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('change_note')) {
      context.handle(
        _changeNoteMeta,
        changeNote.isAcceptableOrUnknown(data['change_note']!, _changeNoteMeta),
      );
    }
    if (data.containsKey('change_date')) {
      context.handle(
        _changeDateMeta,
        changeDate.isAcceptableOrUnknown(data['change_date']!, _changeDateMeta),
      );
    }
    if (data.containsKey('source_document_id')) {
      context.handle(
        _sourceDocumentIdMeta,
        sourceDocumentId.isAcceptableOrUnknown(
          data['source_document_id']!,
          _sourceDocumentIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose'],
      )!,
      frequencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_code'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      doctor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor'],
      )!,
      scheduleGroup: $MedicationsTable.$converterscheduleGroup.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_group'],
        )!,
      ),
      timingCuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timing_cues_json'],
      )!,
      scheduleNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_note'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      changeNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_note'],
      )!,
      changeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}change_date'],
      ),
      sourceDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_document_id'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedScheduleGroup, String, String>
  $converterscheduleGroup = const EnumNameConverter<MedScheduleGroup>(
    MedScheduleGroup.values,
  );
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final String name;
  final String dose;
  final String frequencyCode;
  final String purpose;
  final String doctor;
  final MedScheduleGroup scheduleGroup;
  final String timingCuesJson;
  final String scheduleNote;
  final DateTime startDate;
  final DateTime? endDate;
  final String changeNote;
  final DateTime? changeDate;
  final String? sourceDocumentId;
  const Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.frequencyCode,
    required this.purpose,
    required this.doctor,
    required this.scheduleGroup,
    required this.timingCuesJson,
    required this.scheduleNote,
    required this.startDate,
    this.endDate,
    required this.changeNote,
    this.changeDate,
    this.sourceDocumentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['dose'] = Variable<String>(dose);
    map['frequency_code'] = Variable<String>(frequencyCode);
    map['purpose'] = Variable<String>(purpose);
    map['doctor'] = Variable<String>(doctor);
    {
      map['schedule_group'] = Variable<String>(
        $MedicationsTable.$converterscheduleGroup.toSql(scheduleGroup),
      );
    }
    map['timing_cues_json'] = Variable<String>(timingCuesJson);
    map['schedule_note'] = Variable<String>(scheduleNote);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['change_note'] = Variable<String>(changeNote);
    if (!nullToAbsent || changeDate != null) {
      map['change_date'] = Variable<DateTime>(changeDate);
    }
    if (!nullToAbsent || sourceDocumentId != null) {
      map['source_document_id'] = Variable<String>(sourceDocumentId);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      dose: Value(dose),
      frequencyCode: Value(frequencyCode),
      purpose: Value(purpose),
      doctor: Value(doctor),
      scheduleGroup: Value(scheduleGroup),
      timingCuesJson: Value(timingCuesJson),
      scheduleNote: Value(scheduleNote),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      changeNote: Value(changeNote),
      changeDate: changeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(changeDate),
      sourceDocumentId: sourceDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDocumentId),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dose: serializer.fromJson<String>(json['dose']),
      frequencyCode: serializer.fromJson<String>(json['frequencyCode']),
      purpose: serializer.fromJson<String>(json['purpose']),
      doctor: serializer.fromJson<String>(json['doctor']),
      scheduleGroup: $MedicationsTable.$converterscheduleGroup.fromJson(
        serializer.fromJson<String>(json['scheduleGroup']),
      ),
      timingCuesJson: serializer.fromJson<String>(json['timingCuesJson']),
      scheduleNote: serializer.fromJson<String>(json['scheduleNote']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      changeNote: serializer.fromJson<String>(json['changeNote']),
      changeDate: serializer.fromJson<DateTime?>(json['changeDate']),
      sourceDocumentId: serializer.fromJson<String?>(json['sourceDocumentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dose': serializer.toJson<String>(dose),
      'frequencyCode': serializer.toJson<String>(frequencyCode),
      'purpose': serializer.toJson<String>(purpose),
      'doctor': serializer.toJson<String>(doctor),
      'scheduleGroup': serializer.toJson<String>(
        $MedicationsTable.$converterscheduleGroup.toJson(scheduleGroup),
      ),
      'timingCuesJson': serializer.toJson<String>(timingCuesJson),
      'scheduleNote': serializer.toJson<String>(scheduleNote),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'changeNote': serializer.toJson<String>(changeNote),
      'changeDate': serializer.toJson<DateTime?>(changeDate),
      'sourceDocumentId': serializer.toJson<String?>(sourceDocumentId),
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dose,
    String? frequencyCode,
    String? purpose,
    String? doctor,
    MedScheduleGroup? scheduleGroup,
    String? timingCuesJson,
    String? scheduleNote,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    String? changeNote,
    Value<DateTime?> changeDate = const Value.absent(),
    Value<String?> sourceDocumentId = const Value.absent(),
  }) => Medication(
    id: id ?? this.id,
    name: name ?? this.name,
    dose: dose ?? this.dose,
    frequencyCode: frequencyCode ?? this.frequencyCode,
    purpose: purpose ?? this.purpose,
    doctor: doctor ?? this.doctor,
    scheduleGroup: scheduleGroup ?? this.scheduleGroup,
    timingCuesJson: timingCuesJson ?? this.timingCuesJson,
    scheduleNote: scheduleNote ?? this.scheduleNote,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    changeNote: changeNote ?? this.changeNote,
    changeDate: changeDate.present ? changeDate.value : this.changeDate,
    sourceDocumentId: sourceDocumentId.present
        ? sourceDocumentId.value
        : this.sourceDocumentId,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dose: data.dose.present ? data.dose.value : this.dose,
      frequencyCode: data.frequencyCode.present
          ? data.frequencyCode.value
          : this.frequencyCode,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      doctor: data.doctor.present ? data.doctor.value : this.doctor,
      scheduleGroup: data.scheduleGroup.present
          ? data.scheduleGroup.value
          : this.scheduleGroup,
      timingCuesJson: data.timingCuesJson.present
          ? data.timingCuesJson.value
          : this.timingCuesJson,
      scheduleNote: data.scheduleNote.present
          ? data.scheduleNote.value
          : this.scheduleNote,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      changeNote: data.changeNote.present
          ? data.changeNote.value
          : this.changeNote,
      changeDate: data.changeDate.present
          ? data.changeDate.value
          : this.changeDate,
      sourceDocumentId: data.sourceDocumentId.present
          ? data.sourceDocumentId.value
          : this.sourceDocumentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dose: $dose, ')
          ..write('frequencyCode: $frequencyCode, ')
          ..write('purpose: $purpose, ')
          ..write('doctor: $doctor, ')
          ..write('scheduleGroup: $scheduleGroup, ')
          ..write('timingCuesJson: $timingCuesJson, ')
          ..write('scheduleNote: $scheduleNote, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('changeNote: $changeNote, ')
          ..write('changeDate: $changeDate, ')
          ..write('sourceDocumentId: $sourceDocumentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    dose,
    frequencyCode,
    purpose,
    doctor,
    scheduleGroup,
    timingCuesJson,
    scheduleNote,
    startDate,
    endDate,
    changeNote,
    changeDate,
    sourceDocumentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.name == this.name &&
          other.dose == this.dose &&
          other.frequencyCode == this.frequencyCode &&
          other.purpose == this.purpose &&
          other.doctor == this.doctor &&
          other.scheduleGroup == this.scheduleGroup &&
          other.timingCuesJson == this.timingCuesJson &&
          other.scheduleNote == this.scheduleNote &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.changeNote == this.changeNote &&
          other.changeDate == this.changeDate &&
          other.sourceDocumentId == this.sourceDocumentId);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> dose;
  final Value<String> frequencyCode;
  final Value<String> purpose;
  final Value<String> doctor;
  final Value<MedScheduleGroup> scheduleGroup;
  final Value<String> timingCuesJson;
  final Value<String> scheduleNote;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String> changeNote;
  final Value<DateTime?> changeDate;
  final Value<String?> sourceDocumentId;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dose = const Value.absent(),
    this.frequencyCode = const Value.absent(),
    this.purpose = const Value.absent(),
    this.doctor = const Value.absent(),
    this.scheduleGroup = const Value.absent(),
    this.timingCuesJson = const Value.absent(),
    this.scheduleNote = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.changeNote = const Value.absent(),
    this.changeDate = const Value.absent(),
    this.sourceDocumentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String name,
    required String dose,
    required String frequencyCode,
    required String purpose,
    this.doctor = const Value.absent(),
    required MedScheduleGroup scheduleGroup,
    this.timingCuesJson = const Value.absent(),
    this.scheduleNote = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.changeNote = const Value.absent(),
    this.changeDate = const Value.absent(),
    this.sourceDocumentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       dose = Value(dose),
       frequencyCode = Value(frequencyCode),
       purpose = Value(purpose),
       scheduleGroup = Value(scheduleGroup),
       startDate = Value(startDate);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? dose,
    Expression<String>? frequencyCode,
    Expression<String>? purpose,
    Expression<String>? doctor,
    Expression<String>? scheduleGroup,
    Expression<String>? timingCuesJson,
    Expression<String>? scheduleNote,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? changeNote,
    Expression<DateTime>? changeDate,
    Expression<String>? sourceDocumentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dose != null) 'dose': dose,
      if (frequencyCode != null) 'frequency_code': frequencyCode,
      if (purpose != null) 'purpose': purpose,
      if (doctor != null) 'doctor': doctor,
      if (scheduleGroup != null) 'schedule_group': scheduleGroup,
      if (timingCuesJson != null) 'timing_cues_json': timingCuesJson,
      if (scheduleNote != null) 'schedule_note': scheduleNote,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (changeNote != null) 'change_note': changeNote,
      if (changeDate != null) 'change_date': changeDate,
      if (sourceDocumentId != null) 'source_document_id': sourceDocumentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? dose,
    Value<String>? frequencyCode,
    Value<String>? purpose,
    Value<String>? doctor,
    Value<MedScheduleGroup>? scheduleGroup,
    Value<String>? timingCuesJson,
    Value<String>? scheduleNote,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<String>? changeNote,
    Value<DateTime?>? changeDate,
    Value<String?>? sourceDocumentId,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      frequencyCode: frequencyCode ?? this.frequencyCode,
      purpose: purpose ?? this.purpose,
      doctor: doctor ?? this.doctor,
      scheduleGroup: scheduleGroup ?? this.scheduleGroup,
      timingCuesJson: timingCuesJson ?? this.timingCuesJson,
      scheduleNote: scheduleNote ?? this.scheduleNote,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      changeNote: changeNote ?? this.changeNote,
      changeDate: changeDate ?? this.changeDate,
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dose.present) {
      map['dose'] = Variable<String>(dose.value);
    }
    if (frequencyCode.present) {
      map['frequency_code'] = Variable<String>(frequencyCode.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (doctor.present) {
      map['doctor'] = Variable<String>(doctor.value);
    }
    if (scheduleGroup.present) {
      map['schedule_group'] = Variable<String>(
        $MedicationsTable.$converterscheduleGroup.toSql(scheduleGroup.value),
      );
    }
    if (timingCuesJson.present) {
      map['timing_cues_json'] = Variable<String>(timingCuesJson.value);
    }
    if (scheduleNote.present) {
      map['schedule_note'] = Variable<String>(scheduleNote.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (changeNote.present) {
      map['change_note'] = Variable<String>(changeNote.value);
    }
    if (changeDate.present) {
      map['change_date'] = Variable<DateTime>(changeDate.value);
    }
    if (sourceDocumentId.present) {
      map['source_document_id'] = Variable<String>(sourceDocumentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dose: $dose, ')
          ..write('frequencyCode: $frequencyCode, ')
          ..write('purpose: $purpose, ')
          ..write('doctor: $doctor, ')
          ..write('scheduleGroup: $scheduleGroup, ')
          ..write('timingCuesJson: $timingCuesJson, ')
          ..write('scheduleNote: $scheduleNote, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('changeNote: $changeNote, ')
          ..write('changeDate: $changeDate, ')
          ..write('sourceDocumentId: $sourceDocumentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LabResultsTable extends LabResults
    with TableInfo<$LabResultsTable, LabResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricCodeMeta = const VerificationMeta(
    'metricCode',
  );
  @override
  late final GeneratedColumn<String> metricCode = GeneratedColumn<String>(
    'metric_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    metricCode,
    value,
    takenAt,
    documentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lab_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<LabResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('metric_code')) {
      context.handle(
        _metricCodeMeta,
        metricCode.isAcceptableOrUnknown(data['metric_code']!, _metricCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricCodeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LabResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LabResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      metricCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_code'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
    );
  }

  @override
  $LabResultsTable createAlias(String alias) {
    return $LabResultsTable(attachedDatabase, alias);
  }
}

class LabResult extends DataClass implements Insertable<LabResult> {
  final String id;
  final String metricCode;
  final double value;
  final DateTime takenAt;
  final String? documentId;
  const LabResult({
    required this.id,
    required this.metricCode,
    required this.value,
    required this.takenAt,
    this.documentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['metric_code'] = Variable<String>(metricCode);
    map['value'] = Variable<double>(value);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    return map;
  }

  LabResultsCompanion toCompanion(bool nullToAbsent) {
    return LabResultsCompanion(
      id: Value(id),
      metricCode: Value(metricCode),
      value: Value(value),
      takenAt: Value(takenAt),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
    );
  }

  factory LabResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LabResult(
      id: serializer.fromJson<String>(json['id']),
      metricCode: serializer.fromJson<String>(json['metricCode']),
      value: serializer.fromJson<double>(json['value']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      documentId: serializer.fromJson<String?>(json['documentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'metricCode': serializer.toJson<String>(metricCode),
      'value': serializer.toJson<double>(value),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'documentId': serializer.toJson<String?>(documentId),
    };
  }

  LabResult copyWith({
    String? id,
    String? metricCode,
    double? value,
    DateTime? takenAt,
    Value<String?> documentId = const Value.absent(),
  }) => LabResult(
    id: id ?? this.id,
    metricCode: metricCode ?? this.metricCode,
    value: value ?? this.value,
    takenAt: takenAt ?? this.takenAt,
    documentId: documentId.present ? documentId.value : this.documentId,
  );
  LabResult copyWithCompanion(LabResultsCompanion data) {
    return LabResult(
      id: data.id.present ? data.id.value : this.id,
      metricCode: data.metricCode.present
          ? data.metricCode.value
          : this.metricCode,
      value: data.value.present ? data.value.value : this.value,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LabResult(')
          ..write('id: $id, ')
          ..write('metricCode: $metricCode, ')
          ..write('value: $value, ')
          ..write('takenAt: $takenAt, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, metricCode, value, takenAt, documentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LabResult &&
          other.id == this.id &&
          other.metricCode == this.metricCode &&
          other.value == this.value &&
          other.takenAt == this.takenAt &&
          other.documentId == this.documentId);
}

class LabResultsCompanion extends UpdateCompanion<LabResult> {
  final Value<String> id;
  final Value<String> metricCode;
  final Value<double> value;
  final Value<DateTime> takenAt;
  final Value<String?> documentId;
  final Value<int> rowid;
  const LabResultsCompanion({
    this.id = const Value.absent(),
    this.metricCode = const Value.absent(),
    this.value = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.documentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabResultsCompanion.insert({
    required String id,
    required String metricCode,
    required double value,
    required DateTime takenAt,
    this.documentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       metricCode = Value(metricCode),
       value = Value(value),
       takenAt = Value(takenAt);
  static Insertable<LabResult> custom({
    Expression<String>? id,
    Expression<String>? metricCode,
    Expression<double>? value,
    Expression<DateTime>? takenAt,
    Expression<String>? documentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (metricCode != null) 'metric_code': metricCode,
      if (value != null) 'value': value,
      if (takenAt != null) 'taken_at': takenAt,
      if (documentId != null) 'document_id': documentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? metricCode,
    Value<double>? value,
    Value<DateTime>? takenAt,
    Value<String?>? documentId,
    Value<int>? rowid,
  }) {
    return LabResultsCompanion(
      id: id ?? this.id,
      metricCode: metricCode ?? this.metricCode,
      value: value ?? this.value,
      takenAt: takenAt ?? this.takenAt,
      documentId: documentId ?? this.documentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (metricCode.present) {
      map['metric_code'] = Variable<String>(metricCode.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabResultsCompanion(')
          ..write('id: $id, ')
          ..write('metricCode: $metricCode, ')
          ..write('value: $value, ')
          ..write('takenAt: $takenAt, ')
          ..write('documentId: $documentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineEventsTable extends TimelineEvents
    with TableInfo<$TimelineEventsTable, TimelineEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimelineEventType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TimelineEventType>($TimelineEventsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    subtitle,
    occurredAt,
    documentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $TimelineEventsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
    );
  }

  @override
  $TimelineEventsTable createAlias(String alias) {
    return $TimelineEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TimelineEventType, String, String> $convertertype =
      const EnumNameConverter<TimelineEventType>(TimelineEventType.values);
}

class TimelineEvent extends DataClass implements Insertable<TimelineEvent> {
  final String id;
  final TimelineEventType type;
  final String title;
  final String subtitle;
  final DateTime occurredAt;
  final String? documentId;
  const TimelineEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.occurredAt,
    this.documentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>(
        $TimelineEventsTable.$convertertype.toSql(type),
      );
    }
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    return map;
  }

  TimelineEventsCompanion toCompanion(bool nullToAbsent) {
    return TimelineEventsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      subtitle: Value(subtitle),
      occurredAt: Value(occurredAt),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
    );
  }

  factory TimelineEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEvent(
      id: serializer.fromJson<String>(json['id']),
      type: $TimelineEventsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      documentId: serializer.fromJson<String?>(json['documentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $TimelineEventsTable.$convertertype.toJson(type),
      ),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'documentId': serializer.toJson<String?>(documentId),
    };
  }

  TimelineEvent copyWith({
    String? id,
    TimelineEventType? type,
    String? title,
    String? subtitle,
    DateTime? occurredAt,
    Value<String?> documentId = const Value.absent(),
  }) => TimelineEvent(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    occurredAt: occurredAt ?? this.occurredAt,
    documentId: documentId.present ? documentId.value : this.documentId,
  );
  TimelineEvent copyWithCompanion(TimelineEventsCompanion data) {
    return TimelineEvent(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEvent(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('documentId: $documentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, title, subtitle, occurredAt, documentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEvent &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.occurredAt == this.occurredAt &&
          other.documentId == this.documentId);
}

class TimelineEventsCompanion extends UpdateCompanion<TimelineEvent> {
  final Value<String> id;
  final Value<TimelineEventType> type;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<DateTime> occurredAt;
  final Value<String?> documentId;
  final Value<int> rowid;
  const TimelineEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.documentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineEventsCompanion.insert({
    required String id,
    required TimelineEventType type,
    required String title,
    this.subtitle = const Value.absent(),
    required DateTime occurredAt,
    this.documentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       title = Value(title),
       occurredAt = Value(occurredAt);
  static Insertable<TimelineEvent> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<DateTime>? occurredAt,
    Expression<String>? documentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (documentId != null) 'document_id': documentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineEventsCompanion copyWith({
    Value<String>? id,
    Value<TimelineEventType>? type,
    Value<String>? title,
    Value<String>? subtitle,
    Value<DateTime>? occurredAt,
    Value<String?>? documentId,
    Value<int>? rowid,
  }) {
    return TimelineEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      occurredAt: occurredAt ?? this.occurredAt,
      documentId: documentId ?? this.documentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TimelineEventsTable.$convertertype.toSql(type.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('documentId: $documentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DosesTable extends Doses with TableInfo<$DosesTable, Dose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationLabelMeta = const VerificationMeta(
    'medicationLabel',
  );
  @override
  late final GeneratedColumn<String> medicationLabel = GeneratedColumn<String>(
    'medication_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeLabelMeta = const VerificationMeta(
    'timeLabel',
  );
  @override
  late final GeneratedColumn<String> timeLabel = GeneratedColumn<String>(
    'time_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledOnMeta = const VerificationMeta(
    'scheduledOn',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledOn = GeneratedColumn<DateTime>(
    'scheduled_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenMeta = const VerificationMeta('taken');
  @override
  late final GeneratedColumn<bool> taken = GeneratedColumn<bool>(
    'taken',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("taken" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    medicationLabel,
    timeLabel,
    sortOrder,
    scheduledOn,
    taken,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('medication_label')) {
      context.handle(
        _medicationLabelMeta,
        medicationLabel.isAcceptableOrUnknown(
          data['medication_label']!,
          _medicationLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationLabelMeta);
    }
    if (data.containsKey('time_label')) {
      context.handle(
        _timeLabelMeta,
        timeLabel.isAcceptableOrUnknown(data['time_label']!, _timeLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_timeLabelMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('scheduled_on')) {
      context.handle(
        _scheduledOnMeta,
        scheduledOn.isAcceptableOrUnknown(
          data['scheduled_on']!,
          _scheduledOnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledOnMeta);
    }
    if (data.containsKey('taken')) {
      context.handle(
        _takenMeta,
        taken.isAcceptableOrUnknown(data['taken']!, _takenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      medicationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_label'],
      )!,
      timeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_label'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      scheduledOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_on'],
      )!,
      taken: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}taken'],
      )!,
    );
  }

  @override
  $DosesTable createAlias(String alias) {
    return $DosesTable(attachedDatabase, alias);
  }
}

class Dose extends DataClass implements Insertable<Dose> {
  final String id;
  final String medicationId;
  final String medicationLabel;
  final String timeLabel;
  final int sortOrder;
  final DateTime scheduledOn;
  final bool taken;
  const Dose({
    required this.id,
    required this.medicationId,
    required this.medicationLabel,
    required this.timeLabel,
    required this.sortOrder,
    required this.scheduledOn,
    required this.taken,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medication_id'] = Variable<String>(medicationId);
    map['medication_label'] = Variable<String>(medicationLabel);
    map['time_label'] = Variable<String>(timeLabel);
    map['sort_order'] = Variable<int>(sortOrder);
    map['scheduled_on'] = Variable<DateTime>(scheduledOn);
    map['taken'] = Variable<bool>(taken);
    return map;
  }

  DosesCompanion toCompanion(bool nullToAbsent) {
    return DosesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      medicationLabel: Value(medicationLabel),
      timeLabel: Value(timeLabel),
      sortOrder: Value(sortOrder),
      scheduledOn: Value(scheduledOn),
      taken: Value(taken),
    );
  }

  factory Dose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dose(
      id: serializer.fromJson<String>(json['id']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      medicationLabel: serializer.fromJson<String>(json['medicationLabel']),
      timeLabel: serializer.fromJson<String>(json['timeLabel']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      scheduledOn: serializer.fromJson<DateTime>(json['scheduledOn']),
      taken: serializer.fromJson<bool>(json['taken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationId': serializer.toJson<String>(medicationId),
      'medicationLabel': serializer.toJson<String>(medicationLabel),
      'timeLabel': serializer.toJson<String>(timeLabel),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'scheduledOn': serializer.toJson<DateTime>(scheduledOn),
      'taken': serializer.toJson<bool>(taken),
    };
  }

  Dose copyWith({
    String? id,
    String? medicationId,
    String? medicationLabel,
    String? timeLabel,
    int? sortOrder,
    DateTime? scheduledOn,
    bool? taken,
  }) => Dose(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    medicationLabel: medicationLabel ?? this.medicationLabel,
    timeLabel: timeLabel ?? this.timeLabel,
    sortOrder: sortOrder ?? this.sortOrder,
    scheduledOn: scheduledOn ?? this.scheduledOn,
    taken: taken ?? this.taken,
  );
  Dose copyWithCompanion(DosesCompanion data) {
    return Dose(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      medicationLabel: data.medicationLabel.present
          ? data.medicationLabel.value
          : this.medicationLabel,
      timeLabel: data.timeLabel.present ? data.timeLabel.value : this.timeLabel,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      scheduledOn: data.scheduledOn.present
          ? data.scheduledOn.value
          : this.scheduledOn,
      taken: data.taken.present ? data.taken.value : this.taken,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dose(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('medicationLabel: $medicationLabel, ')
          ..write('timeLabel: $timeLabel, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('scheduledOn: $scheduledOn, ')
          ..write('taken: $taken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    medicationLabel,
    timeLabel,
    sortOrder,
    scheduledOn,
    taken,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dose &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.medicationLabel == this.medicationLabel &&
          other.timeLabel == this.timeLabel &&
          other.sortOrder == this.sortOrder &&
          other.scheduledOn == this.scheduledOn &&
          other.taken == this.taken);
}

class DosesCompanion extends UpdateCompanion<Dose> {
  final Value<String> id;
  final Value<String> medicationId;
  final Value<String> medicationLabel;
  final Value<String> timeLabel;
  final Value<int> sortOrder;
  final Value<DateTime> scheduledOn;
  final Value<bool> taken;
  final Value<int> rowid;
  const DosesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.medicationLabel = const Value.absent(),
    this.timeLabel = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.scheduledOn = const Value.absent(),
    this.taken = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DosesCompanion.insert({
    required String id,
    required String medicationId,
    required String medicationLabel,
    required String timeLabel,
    required int sortOrder,
    required DateTime scheduledOn,
    this.taken = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicationId = Value(medicationId),
       medicationLabel = Value(medicationLabel),
       timeLabel = Value(timeLabel),
       sortOrder = Value(sortOrder),
       scheduledOn = Value(scheduledOn);
  static Insertable<Dose> custom({
    Expression<String>? id,
    Expression<String>? medicationId,
    Expression<String>? medicationLabel,
    Expression<String>? timeLabel,
    Expression<int>? sortOrder,
    Expression<DateTime>? scheduledOn,
    Expression<bool>? taken,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (medicationLabel != null) 'medication_label': medicationLabel,
      if (timeLabel != null) 'time_label': timeLabel,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (scheduledOn != null) 'scheduled_on': scheduledOn,
      if (taken != null) 'taken': taken,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DosesCompanion copyWith({
    Value<String>? id,
    Value<String>? medicationId,
    Value<String>? medicationLabel,
    Value<String>? timeLabel,
    Value<int>? sortOrder,
    Value<DateTime>? scheduledOn,
    Value<bool>? taken,
    Value<int>? rowid,
  }) {
    return DosesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationLabel: medicationLabel ?? this.medicationLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      sortOrder: sortOrder ?? this.sortOrder,
      scheduledOn: scheduledOn ?? this.scheduledOn,
      taken: taken ?? this.taken,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (medicationLabel.present) {
      map['medication_label'] = Variable<String>(medicationLabel.value);
    }
    if (timeLabel.present) {
      map['time_label'] = Variable<String>(timeLabel.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (scheduledOn.present) {
      map['scheduled_on'] = Variable<DateTime>(scheduledOn.value);
    }
    if (taken.present) {
      map['taken'] = Variable<bool>(taken.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DosesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('medicationLabel: $medicationLabel, ')
          ..write('timeLabel: $timeLabel, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('scheduledOn: $scheduledOn, ')
          ..write('taken: $taken, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationsJsonMeta = const VerificationMeta(
    'citationsJson',
  );
  @override
  late final GeneratedColumn<String> citationsJson = GeneratedColumn<String>(
    'citations_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    content,
    citationsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('citations_json')) {
      context.handle(
        _citationsJsonMeta,
        citationsJson.isAcceptableOrUnknown(
          data['citations_json']!,
          _citationsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      citationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citations_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String role;
  final String content;
  final String citationsJson;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.citationsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['citations_json'] = Variable<String>(citationsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      citationsJson: Value(citationsJson),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      citationsJson: serializer.fromJson<String>(json['citationsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'citationsJson': serializer.toJson<String>(citationsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    String? citationsJson,
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    citationsJson: citationsJson ?? this.citationsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      citationsJson: data.citationsJson.present
          ? data.citationsJson.value
          : this.citationsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('citationsJson: $citationsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content, citationsJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.citationsJson == this.citationsJson &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> content;
  final Value<String> citationsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.citationsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String role,
    required String content,
    this.citationsJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? citationsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (citationsJson != null) 'citations_json': citationsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String>? content,
    Value<String>? citationsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      citationsJson: citationsJson ?? this.citationsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (citationsJson.present) {
      map['citations_json'] = Variable<String>(citationsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('citationsJson: $citationsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DialysisSessionsTable extends DialysisSessions
    with TableInfo<$DialysisSessionsTable, DialysisSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DialysisSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _centerMeta = const VerificationMeta('center');
  @override
  late final GeneratedColumn<String> center = GeneratedColumn<String>(
    'center',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ultrafiltrationLMeta = const VerificationMeta(
    'ultrafiltrationL',
  );
  @override
  late final GeneratedColumn<double> ultrafiltrationL = GeneratedColumn<double>(
    'ultrafiltration_l',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preWeightKgMeta = const VerificationMeta(
    'preWeightKg',
  );
  @override
  late final GeneratedColumn<double> preWeightKg = GeneratedColumn<double>(
    'pre_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postWeightKgMeta = const VerificationMeta(
    'postWeightKg',
  );
  @override
  late final GeneratedColumn<double> postWeightKg = GeneratedColumn<double>(
    'post_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationHoursMeta = const VerificationMeta(
    'durationHours',
  );
  @override
  late final GeneratedColumn<double> durationHours = GeneratedColumn<double>(
    'duration_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduledAt,
    completed,
    center,
    ultrafiltrationL,
    preWeightKg,
    postWeightKg,
    durationHours,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dialysis_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DialysisSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('center')) {
      context.handle(
        _centerMeta,
        center.isAcceptableOrUnknown(data['center']!, _centerMeta),
      );
    }
    if (data.containsKey('ultrafiltration_l')) {
      context.handle(
        _ultrafiltrationLMeta,
        ultrafiltrationL.isAcceptableOrUnknown(
          data['ultrafiltration_l']!,
          _ultrafiltrationLMeta,
        ),
      );
    }
    if (data.containsKey('pre_weight_kg')) {
      context.handle(
        _preWeightKgMeta,
        preWeightKg.isAcceptableOrUnknown(
          data['pre_weight_kg']!,
          _preWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('post_weight_kg')) {
      context.handle(
        _postWeightKgMeta,
        postWeightKg.isAcceptableOrUnknown(
          data['post_weight_kg']!,
          _postWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('duration_hours')) {
      context.handle(
        _durationHoursMeta,
        durationHours.isAcceptableOrUnknown(
          data['duration_hours']!,
          _durationHoursMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DialysisSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DialysisSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      center: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}center'],
      )!,
      ultrafiltrationL: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ultrafiltration_l'],
      ),
      preWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pre_weight_kg'],
      ),
      postWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}post_weight_kg'],
      ),
      durationHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_hours'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $DialysisSessionsTable createAlias(String alias) {
    return $DialysisSessionsTable(attachedDatabase, alias);
  }
}

class DialysisSession extends DataClass implements Insertable<DialysisSession> {
  final String id;
  final DateTime scheduledAt;
  final bool completed;
  final String center;
  final double? ultrafiltrationL;
  final double? preWeightKg;
  final double? postWeightKg;
  final double? durationHours;
  final String note;
  const DialysisSession({
    required this.id,
    required this.scheduledAt,
    required this.completed,
    required this.center,
    this.ultrafiltrationL,
    this.preWeightKg,
    this.postWeightKg,
    this.durationHours,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['completed'] = Variable<bool>(completed);
    map['center'] = Variable<String>(center);
    if (!nullToAbsent || ultrafiltrationL != null) {
      map['ultrafiltration_l'] = Variable<double>(ultrafiltrationL);
    }
    if (!nullToAbsent || preWeightKg != null) {
      map['pre_weight_kg'] = Variable<double>(preWeightKg);
    }
    if (!nullToAbsent || postWeightKg != null) {
      map['post_weight_kg'] = Variable<double>(postWeightKg);
    }
    if (!nullToAbsent || durationHours != null) {
      map['duration_hours'] = Variable<double>(durationHours);
    }
    map['note'] = Variable<String>(note);
    return map;
  }

  DialysisSessionsCompanion toCompanion(bool nullToAbsent) {
    return DialysisSessionsCompanion(
      id: Value(id),
      scheduledAt: Value(scheduledAt),
      completed: Value(completed),
      center: Value(center),
      ultrafiltrationL: ultrafiltrationL == null && nullToAbsent
          ? const Value.absent()
          : Value(ultrafiltrationL),
      preWeightKg: preWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(preWeightKg),
      postWeightKg: postWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(postWeightKg),
      durationHours: durationHours == null && nullToAbsent
          ? const Value.absent()
          : Value(durationHours),
      note: Value(note),
    );
  }

  factory DialysisSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DialysisSession(
      id: serializer.fromJson<String>(json['id']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      completed: serializer.fromJson<bool>(json['completed']),
      center: serializer.fromJson<String>(json['center']),
      ultrafiltrationL: serializer.fromJson<double?>(json['ultrafiltrationL']),
      preWeightKg: serializer.fromJson<double?>(json['preWeightKg']),
      postWeightKg: serializer.fromJson<double?>(json['postWeightKg']),
      durationHours: serializer.fromJson<double?>(json['durationHours']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'completed': serializer.toJson<bool>(completed),
      'center': serializer.toJson<String>(center),
      'ultrafiltrationL': serializer.toJson<double?>(ultrafiltrationL),
      'preWeightKg': serializer.toJson<double?>(preWeightKg),
      'postWeightKg': serializer.toJson<double?>(postWeightKg),
      'durationHours': serializer.toJson<double?>(durationHours),
      'note': serializer.toJson<String>(note),
    };
  }

  DialysisSession copyWith({
    String? id,
    DateTime? scheduledAt,
    bool? completed,
    String? center,
    Value<double?> ultrafiltrationL = const Value.absent(),
    Value<double?> preWeightKg = const Value.absent(),
    Value<double?> postWeightKg = const Value.absent(),
    Value<double?> durationHours = const Value.absent(),
    String? note,
  }) => DialysisSession(
    id: id ?? this.id,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    completed: completed ?? this.completed,
    center: center ?? this.center,
    ultrafiltrationL: ultrafiltrationL.present
        ? ultrafiltrationL.value
        : this.ultrafiltrationL,
    preWeightKg: preWeightKg.present ? preWeightKg.value : this.preWeightKg,
    postWeightKg: postWeightKg.present ? postWeightKg.value : this.postWeightKg,
    durationHours: durationHours.present
        ? durationHours.value
        : this.durationHours,
    note: note ?? this.note,
  );
  DialysisSession copyWithCompanion(DialysisSessionsCompanion data) {
    return DialysisSession(
      id: data.id.present ? data.id.value : this.id,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      completed: data.completed.present ? data.completed.value : this.completed,
      center: data.center.present ? data.center.value : this.center,
      ultrafiltrationL: data.ultrafiltrationL.present
          ? data.ultrafiltrationL.value
          : this.ultrafiltrationL,
      preWeightKg: data.preWeightKg.present
          ? data.preWeightKg.value
          : this.preWeightKg,
      postWeightKg: data.postWeightKg.present
          ? data.postWeightKg.value
          : this.postWeightKg,
      durationHours: data.durationHours.present
          ? data.durationHours.value
          : this.durationHours,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DialysisSession(')
          ..write('id: $id, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completed: $completed, ')
          ..write('center: $center, ')
          ..write('ultrafiltrationL: $ultrafiltrationL, ')
          ..write('preWeightKg: $preWeightKg, ')
          ..write('postWeightKg: $postWeightKg, ')
          ..write('durationHours: $durationHours, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduledAt,
    completed,
    center,
    ultrafiltrationL,
    preWeightKg,
    postWeightKg,
    durationHours,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DialysisSession &&
          other.id == this.id &&
          other.scheduledAt == this.scheduledAt &&
          other.completed == this.completed &&
          other.center == this.center &&
          other.ultrafiltrationL == this.ultrafiltrationL &&
          other.preWeightKg == this.preWeightKg &&
          other.postWeightKg == this.postWeightKg &&
          other.durationHours == this.durationHours &&
          other.note == this.note);
}

class DialysisSessionsCompanion extends UpdateCompanion<DialysisSession> {
  final Value<String> id;
  final Value<DateTime> scheduledAt;
  final Value<bool> completed;
  final Value<String> center;
  final Value<double?> ultrafiltrationL;
  final Value<double?> preWeightKg;
  final Value<double?> postWeightKg;
  final Value<double?> durationHours;
  final Value<String> note;
  final Value<int> rowid;
  const DialysisSessionsCompanion({
    this.id = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.center = const Value.absent(),
    this.ultrafiltrationL = const Value.absent(),
    this.preWeightKg = const Value.absent(),
    this.postWeightKg = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DialysisSessionsCompanion.insert({
    required String id,
    required DateTime scheduledAt,
    this.completed = const Value.absent(),
    this.center = const Value.absent(),
    this.ultrafiltrationL = const Value.absent(),
    this.preWeightKg = const Value.absent(),
    this.postWeightKg = const Value.absent(),
    this.durationHours = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduledAt = Value(scheduledAt);
  static Insertable<DialysisSession> custom({
    Expression<String>? id,
    Expression<DateTime>? scheduledAt,
    Expression<bool>? completed,
    Expression<String>? center,
    Expression<double>? ultrafiltrationL,
    Expression<double>? preWeightKg,
    Expression<double>? postWeightKg,
    Expression<double>? durationHours,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completed != null) 'completed': completed,
      if (center != null) 'center': center,
      if (ultrafiltrationL != null) 'ultrafiltration_l': ultrafiltrationL,
      if (preWeightKg != null) 'pre_weight_kg': preWeightKg,
      if (postWeightKg != null) 'post_weight_kg': postWeightKg,
      if (durationHours != null) 'duration_hours': durationHours,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DialysisSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? scheduledAt,
    Value<bool>? completed,
    Value<String>? center,
    Value<double?>? ultrafiltrationL,
    Value<double?>? preWeightKg,
    Value<double?>? postWeightKg,
    Value<double?>? durationHours,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return DialysisSessionsCompanion(
      id: id ?? this.id,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completed: completed ?? this.completed,
      center: center ?? this.center,
      ultrafiltrationL: ultrafiltrationL ?? this.ultrafiltrationL,
      preWeightKg: preWeightKg ?? this.preWeightKg,
      postWeightKg: postWeightKg ?? this.postWeightKg,
      durationHours: durationHours ?? this.durationHours,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (center.present) {
      map['center'] = Variable<String>(center.value);
    }
    if (ultrafiltrationL.present) {
      map['ultrafiltration_l'] = Variable<double>(ultrafiltrationL.value);
    }
    if (preWeightKg.present) {
      map['pre_weight_kg'] = Variable<double>(preWeightKg.value);
    }
    if (postWeightKg.present) {
      map['post_weight_kg'] = Variable<double>(postWeightKg.value);
    }
    if (durationHours.present) {
      map['duration_hours'] = Variable<double>(durationHours.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DialysisSessionsCompanion(')
          ..write('id: $id, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completed: $completed, ')
          ..write('center: $center, ')
          ..write('ultrafiltrationL: $ultrafiltrationL, ')
          ..write('preWeightKg: $preWeightKg, ')
          ..write('postWeightKg: $postWeightKg, ')
          ..write('durationHours: $durationHours, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $LabResultsTable labResults = $LabResultsTable(this);
  late final $TimelineEventsTable timelineEvents = $TimelineEventsTable(this);
  late final $DosesTable doses = $DosesTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $DialysisSessionsTable dialysisSessions = $DialysisSessionsTable(
    this,
  );
  late final PatientDao patientDao = PatientDao(this as AppDatabase);
  late final DocumentDao documentDao = DocumentDao(this as AppDatabase);
  late final MedicationDao medicationDao = MedicationDao(this as AppDatabase);
  late final LabDao labDao = LabDao(this as AppDatabase);
  late final TimelineDao timelineDao = TimelineDao(this as AppDatabase);
  late final DoseDao doseDao = DoseDao(this as AppDatabase);
  late final ChatDao chatDao = ChatDao(this as AppDatabase);
  late final DialysisDao dialysisDao = DialysisDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    documents,
    medications,
    labResults,
    timelineEvents,
    doses,
    chatMessages,
    dialysisSessions,
  ];
}

typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      required String id,
      required String name,
      required String initials,
      required int age,
      required String conditionSummary,
      required String dialysisCenter,
      required double dryWeightKg,
      Value<double> dryWeightDeltaKg,
      Value<String> scheduleJson,
      Value<String> bloodGroup,
      Value<String> allergies,
      Value<String> emergencyContact,
      Value<String> comorbidities,
      Value<int> rowid,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> initials,
      Value<int> age,
      Value<String> conditionSummary,
      Value<String> dialysisCenter,
      Value<double> dryWeightKg,
      Value<double> dryWeightDeltaKg,
      Value<String> scheduleJson,
      Value<String> bloodGroup,
      Value<String> allergies,
      Value<String> emergencyContact,
      Value<String> comorbidities,
      Value<int> rowid,
    });

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get initials => $composableBuilder(
    column: $table.initials,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionSummary => $composableBuilder(
    column: $table.conditionSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dialysisCenter => $composableBuilder(
    column: $table.dialysisCenter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dryWeightKg => $composableBuilder(
    column: $table.dryWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dryWeightDeltaKg => $composableBuilder(
    column: $table.dryWeightDeltaKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comorbidities => $composableBuilder(
    column: $table.comorbidities,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get initials => $composableBuilder(
    column: $table.initials,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionSummary => $composableBuilder(
    column: $table.conditionSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dialysisCenter => $composableBuilder(
    column: $table.dialysisCenter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dryWeightKg => $composableBuilder(
    column: $table.dryWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dryWeightDeltaKg => $composableBuilder(
    column: $table.dryWeightDeltaKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comorbidities => $composableBuilder(
    column: $table.comorbidities,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get initials =>
      $composableBuilder(column: $table.initials, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get conditionSummary => $composableBuilder(
    column: $table.conditionSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dialysisCenter => $composableBuilder(
    column: $table.dialysisCenter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dryWeightKg => $composableBuilder(
    column: $table.dryWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dryWeightDeltaKg => $composableBuilder(
    column: $table.dryWeightDeltaKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleJson => $composableBuilder(
    column: $table.scheduleJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comorbidities => $composableBuilder(
    column: $table.comorbidities,
    builder: (column) => column,
  );
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          Patient,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
          Patient,
          PrefetchHooks Function()
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> initials = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String> conditionSummary = const Value.absent(),
                Value<String> dialysisCenter = const Value.absent(),
                Value<double> dryWeightKg = const Value.absent(),
                Value<double> dryWeightDeltaKg = const Value.absent(),
                Value<String> scheduleJson = const Value.absent(),
                Value<String> bloodGroup = const Value.absent(),
                Value<String> allergies = const Value.absent(),
                Value<String> emergencyContact = const Value.absent(),
                Value<String> comorbidities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                name: name,
                initials: initials,
                age: age,
                conditionSummary: conditionSummary,
                dialysisCenter: dialysisCenter,
                dryWeightKg: dryWeightKg,
                dryWeightDeltaKg: dryWeightDeltaKg,
                scheduleJson: scheduleJson,
                bloodGroup: bloodGroup,
                allergies: allergies,
                emergencyContact: emergencyContact,
                comorbidities: comorbidities,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String initials,
                required int age,
                required String conditionSummary,
                required String dialysisCenter,
                required double dryWeightKg,
                Value<double> dryWeightDeltaKg = const Value.absent(),
                Value<String> scheduleJson = const Value.absent(),
                Value<String> bloodGroup = const Value.absent(),
                Value<String> allergies = const Value.absent(),
                Value<String> emergencyContact = const Value.absent(),
                Value<String> comorbidities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                name: name,
                initials: initials,
                age: age,
                conditionSummary: conditionSummary,
                dialysisCenter: dialysisCenter,
                dryWeightKg: dryWeightKg,
                dryWeightDeltaKg: dryWeightDeltaKg,
                scheduleJson: scheduleJson,
                bloodGroup: bloodGroup,
                allergies: allergies,
                emergencyContact: emergencyContact,
                comorbidities: comorbidities,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      Patient,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
      Patient,
      PrefetchHooks Function()
    >;
typedef $$DocumentsTableCreateCompanionBuilder =
    DocumentsCompanion Function({
      required String id,
      required DocumentType type,
      required String title,
      Value<String> hospital,
      Value<String> doctor,
      required DateTime documentDate,
      required DateTime capturedAt,
      Value<String> originalPath,
      Value<String> previewPath,
      Value<String> ocrText,
      Value<String> tagsJson,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$DocumentsTableUpdateCompanionBuilder =
    DocumentsCompanion Function({
      Value<String> id,
      Value<DocumentType> type,
      Value<String> title,
      Value<String> hospital,
      Value<String> doctor,
      Value<DateTime> documentDate,
      Value<DateTime> capturedAt,
      Value<String> originalPath,
      Value<String> previewPath,
      Value<String> ocrText,
      Value<String> tagsJson,
      Value<String> note,
      Value<int> rowid,
    });

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DocumentType, DocumentType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hospital => $composableBuilder(
    column: $table.hospital,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctor => $composableBuilder(
    column: $table.doctor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewPath => $composableBuilder(
    column: $table.previewPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hospital => $composableBuilder(
    column: $table.hospital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctor => $composableBuilder(
    column: $table.doctor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewPath => $composableBuilder(
    column: $table.previewPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DocumentType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get hospital =>
      $composableBuilder(column: $table.hospital, builder: (column) => column);

  GeneratedColumn<String> get doctor =>
      $composableBuilder(column: $table.doctor, builder: (column) => column);

  GeneratedColumn<DateTime> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previewPath => $composableBuilder(
    column: $table.previewPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
          Document,
          PrefetchHooks Function()
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DocumentType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> hospital = const Value.absent(),
                Value<String> doctor = const Value.absent(),
                Value<DateTime> documentDate = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String> originalPath = const Value.absent(),
                Value<String> previewPath = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                type: type,
                title: title,
                hospital: hospital,
                doctor: doctor,
                documentDate: documentDate,
                capturedAt: capturedAt,
                originalPath: originalPath,
                previewPath: previewPath,
                ocrText: ocrText,
                tagsJson: tagsJson,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DocumentType type,
                required String title,
                Value<String> hospital = const Value.absent(),
                Value<String> doctor = const Value.absent(),
                required DateTime documentDate,
                required DateTime capturedAt,
                Value<String> originalPath = const Value.absent(),
                Value<String> previewPath = const Value.absent(),
                Value<String> ocrText = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                type: type,
                title: title,
                hospital: hospital,
                doctor: doctor,
                documentDate: documentDate,
                capturedAt: capturedAt,
                originalPath: originalPath,
                previewPath: previewPath,
                ocrText: ocrText,
                tagsJson: tagsJson,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, BaseReferences<_$AppDatabase, $DocumentsTable, Document>),
      Document,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required String name,
      required String dose,
      required String frequencyCode,
      required String purpose,
      Value<String> doctor,
      required MedScheduleGroup scheduleGroup,
      Value<String> timingCuesJson,
      Value<String> scheduleNote,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<String> changeNote,
      Value<DateTime?> changeDate,
      Value<String?> sourceDocumentId,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> dose,
      Value<String> frequencyCode,
      Value<String> purpose,
      Value<String> doctor,
      Value<MedScheduleGroup> scheduleGroup,
      Value<String> timingCuesJson,
      Value<String> scheduleNote,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<String> changeNote,
      Value<DateTime?> changeDate,
      Value<String?> sourceDocumentId,
      Value<int> rowid,
    });

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyCode => $composableBuilder(
    column: $table.frequencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctor => $composableBuilder(
    column: $table.doctor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedScheduleGroup, MedScheduleGroup, String>
  get scheduleGroup => $composableBuilder(
    column: $table.scheduleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get timingCuesJson => $composableBuilder(
    column: $table.timingCuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleNote => $composableBuilder(
    column: $table.scheduleNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeNote => $composableBuilder(
    column: $table.changeNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changeDate => $composableBuilder(
    column: $table.changeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyCode => $composableBuilder(
    column: $table.frequencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctor => $composableBuilder(
    column: $table.doctor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleGroup => $composableBuilder(
    column: $table.scheduleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timingCuesJson => $composableBuilder(
    column: $table.timingCuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleNote => $composableBuilder(
    column: $table.scheduleNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeNote => $composableBuilder(
    column: $table.changeNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changeDate => $composableBuilder(
    column: $table.changeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dose =>
      $composableBuilder(column: $table.dose, builder: (column) => column);

  GeneratedColumn<String> get frequencyCode => $composableBuilder(
    column: $table.frequencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get doctor =>
      $composableBuilder(column: $table.doctor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedScheduleGroup, String>
  get scheduleGroup => $composableBuilder(
    column: $table.scheduleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timingCuesJson => $composableBuilder(
    column: $table.timingCuesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleNote => $composableBuilder(
    column: $table.scheduleNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get changeNote => $composableBuilder(
    column: $table.changeNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changeDate => $composableBuilder(
    column: $table.changeDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceDocumentId => $composableBuilder(
    column: $table.sourceDocumentId,
    builder: (column) => column,
  );
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (
            Medication,
            BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
          ),
          Medication,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dose = const Value.absent(),
                Value<String> frequencyCode = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> doctor = const Value.absent(),
                Value<MedScheduleGroup> scheduleGroup = const Value.absent(),
                Value<String> timingCuesJson = const Value.absent(),
                Value<String> scheduleNote = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> changeNote = const Value.absent(),
                Value<DateTime?> changeDate = const Value.absent(),
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                dose: dose,
                frequencyCode: frequencyCode,
                purpose: purpose,
                doctor: doctor,
                scheduleGroup: scheduleGroup,
                timingCuesJson: timingCuesJson,
                scheduleNote: scheduleNote,
                startDate: startDate,
                endDate: endDate,
                changeNote: changeNote,
                changeDate: changeDate,
                sourceDocumentId: sourceDocumentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String dose,
                required String frequencyCode,
                required String purpose,
                Value<String> doctor = const Value.absent(),
                required MedScheduleGroup scheduleGroup,
                Value<String> timingCuesJson = const Value.absent(),
                Value<String> scheduleNote = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> changeNote = const Value.absent(),
                Value<DateTime?> changeDate = const Value.absent(),
                Value<String?> sourceDocumentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                dose: dose,
                frequencyCode: frequencyCode,
                purpose: purpose,
                doctor: doctor,
                scheduleGroup: scheduleGroup,
                timingCuesJson: timingCuesJson,
                scheduleNote: scheduleNote,
                startDate: startDate,
                endDate: endDate,
                changeNote: changeNote,
                changeDate: changeDate,
                sourceDocumentId: sourceDocumentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (
        Medication,
        BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
      ),
      Medication,
      PrefetchHooks Function()
    >;
typedef $$LabResultsTableCreateCompanionBuilder =
    LabResultsCompanion Function({
      required String id,
      required String metricCode,
      required double value,
      required DateTime takenAt,
      Value<String?> documentId,
      Value<int> rowid,
    });
typedef $$LabResultsTableUpdateCompanionBuilder =
    LabResultsCompanion Function({
      Value<String> id,
      Value<String> metricCode,
      Value<double> value,
      Value<DateTime> takenAt,
      Value<String?> documentId,
      Value<int> rowid,
    });

class $$LabResultsTableFilterComposer
    extends Composer<_$AppDatabase, $LabResultsTable> {
  $$LabResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricCode => $composableBuilder(
    column: $table.metricCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabResultsTable> {
  $$LabResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricCode => $composableBuilder(
    column: $table.metricCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabResultsTable> {
  $$LabResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get metricCode => $composableBuilder(
    column: $table.metricCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );
}

class $$LabResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabResultsTable,
          LabResult,
          $$LabResultsTableFilterComposer,
          $$LabResultsTableOrderingComposer,
          $$LabResultsTableAnnotationComposer,
          $$LabResultsTableCreateCompanionBuilder,
          $$LabResultsTableUpdateCompanionBuilder,
          (
            LabResult,
            BaseReferences<_$AppDatabase, $LabResultsTable, LabResult>,
          ),
          LabResult,
          PrefetchHooks Function()
        > {
  $$LabResultsTableTableManager(_$AppDatabase db, $LabResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> metricCode = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabResultsCompanion(
                id: id,
                metricCode: metricCode,
                value: value,
                takenAt: takenAt,
                documentId: documentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String metricCode,
                required double value,
                required DateTime takenAt,
                Value<String?> documentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabResultsCompanion.insert(
                id: id,
                metricCode: metricCode,
                value: value,
                takenAt: takenAt,
                documentId: documentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabResultsTable,
      LabResult,
      $$LabResultsTableFilterComposer,
      $$LabResultsTableOrderingComposer,
      $$LabResultsTableAnnotationComposer,
      $$LabResultsTableCreateCompanionBuilder,
      $$LabResultsTableUpdateCompanionBuilder,
      (LabResult, BaseReferences<_$AppDatabase, $LabResultsTable, LabResult>),
      LabResult,
      PrefetchHooks Function()
    >;
typedef $$TimelineEventsTableCreateCompanionBuilder =
    TimelineEventsCompanion Function({
      required String id,
      required TimelineEventType type,
      required String title,
      Value<String> subtitle,
      required DateTime occurredAt,
      Value<String?> documentId,
      Value<int> rowid,
    });
typedef $$TimelineEventsTableUpdateCompanionBuilder =
    TimelineEventsCompanion Function({
      Value<String> id,
      Value<TimelineEventType> type,
      Value<String> title,
      Value<String> subtitle,
      Value<DateTime> occurredAt,
      Value<String?> documentId,
      Value<int> rowid,
    });

class $$TimelineEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TimelineEventType, TimelineEventType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimelineEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimelineEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineEventsTable> {
  $$TimelineEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TimelineEventType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );
}

class $$TimelineEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineEventsTable,
          TimelineEvent,
          $$TimelineEventsTableFilterComposer,
          $$TimelineEventsTableOrderingComposer,
          $$TimelineEventsTableAnnotationComposer,
          $$TimelineEventsTableCreateCompanionBuilder,
          $$TimelineEventsTableUpdateCompanionBuilder,
          (
            TimelineEvent,
            BaseReferences<_$AppDatabase, $TimelineEventsTable, TimelineEvent>,
          ),
          TimelineEvent,
          PrefetchHooks Function()
        > {
  $$TimelineEventsTableTableManager(
    _$AppDatabase db,
    $TimelineEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<TimelineEventType> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineEventsCompanion(
                id: id,
                type: type,
                title: title,
                subtitle: subtitle,
                occurredAt: occurredAt,
                documentId: documentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required TimelineEventType type,
                required String title,
                Value<String> subtitle = const Value.absent(),
                required DateTime occurredAt,
                Value<String?> documentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineEventsCompanion.insert(
                id: id,
                type: type,
                title: title,
                subtitle: subtitle,
                occurredAt: occurredAt,
                documentId: documentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimelineEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineEventsTable,
      TimelineEvent,
      $$TimelineEventsTableFilterComposer,
      $$TimelineEventsTableOrderingComposer,
      $$TimelineEventsTableAnnotationComposer,
      $$TimelineEventsTableCreateCompanionBuilder,
      $$TimelineEventsTableUpdateCompanionBuilder,
      (
        TimelineEvent,
        BaseReferences<_$AppDatabase, $TimelineEventsTable, TimelineEvent>,
      ),
      TimelineEvent,
      PrefetchHooks Function()
    >;
typedef $$DosesTableCreateCompanionBuilder =
    DosesCompanion Function({
      required String id,
      required String medicationId,
      required String medicationLabel,
      required String timeLabel,
      required int sortOrder,
      required DateTime scheduledOn,
      Value<bool> taken,
      Value<int> rowid,
    });
typedef $$DosesTableUpdateCompanionBuilder =
    DosesCompanion Function({
      Value<String> id,
      Value<String> medicationId,
      Value<String> medicationLabel,
      Value<String> timeLabel,
      Value<int> sortOrder,
      Value<DateTime> scheduledOn,
      Value<bool> taken,
      Value<int> rowid,
    });

class $$DosesTableFilterComposer extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationLabel => $composableBuilder(
    column: $table.medicationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeLabel => $composableBuilder(
    column: $table.timeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get taken => $composableBuilder(
    column: $table.taken,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DosesTableOrderingComposer
    extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationLabel => $composableBuilder(
    column: $table.medicationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeLabel => $composableBuilder(
    column: $table.timeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get taken => $composableBuilder(
    column: $table.taken,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DosesTable> {
  $$DosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicationLabel => $composableBuilder(
    column: $table.medicationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeLabel =>
      $composableBuilder(column: $table.timeLabel, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledOn => $composableBuilder(
    column: $table.scheduledOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get taken =>
      $composableBuilder(column: $table.taken, builder: (column) => column);
}

class $$DosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DosesTable,
          Dose,
          $$DosesTableFilterComposer,
          $$DosesTableOrderingComposer,
          $$DosesTableAnnotationComposer,
          $$DosesTableCreateCompanionBuilder,
          $$DosesTableUpdateCompanionBuilder,
          (Dose, BaseReferences<_$AppDatabase, $DosesTable, Dose>),
          Dose,
          PrefetchHooks Function()
        > {
  $$DosesTableTableManager(_$AppDatabase db, $DosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<String> medicationLabel = const Value.absent(),
                Value<String> timeLabel = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> scheduledOn = const Value.absent(),
                Value<bool> taken = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DosesCompanion(
                id: id,
                medicationId: medicationId,
                medicationLabel: medicationLabel,
                timeLabel: timeLabel,
                sortOrder: sortOrder,
                scheduledOn: scheduledOn,
                taken: taken,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicationId,
                required String medicationLabel,
                required String timeLabel,
                required int sortOrder,
                required DateTime scheduledOn,
                Value<bool> taken = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DosesCompanion.insert(
                id: id,
                medicationId: medicationId,
                medicationLabel: medicationLabel,
                timeLabel: timeLabel,
                sortOrder: sortOrder,
                scheduledOn: scheduledOn,
                taken: taken,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DosesTable,
      Dose,
      $$DosesTableFilterComposer,
      $$DosesTableOrderingComposer,
      $$DosesTableAnnotationComposer,
      $$DosesTableCreateCompanionBuilder,
      $$DosesTableUpdateCompanionBuilder,
      (Dose, BaseReferences<_$AppDatabase, $DosesTable, Dose>),
      Dose,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String role,
      required String content,
      Value<String> citationsJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> role,
      Value<String> content,
      Value<String> citationsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get citationsJson => $composableBuilder(
    column: $table.citationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get citationsJson => $composableBuilder(
    column: $table.citationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get citationsJson => $composableBuilder(
    column: $table.citationsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> citationsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                role: role,
                content: content,
                citationsJson: citationsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String role,
                required String content,
                Value<String> citationsJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                role: role,
                content: content,
                citationsJson: citationsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$DialysisSessionsTableCreateCompanionBuilder =
    DialysisSessionsCompanion Function({
      required String id,
      required DateTime scheduledAt,
      Value<bool> completed,
      Value<String> center,
      Value<double?> ultrafiltrationL,
      Value<double?> preWeightKg,
      Value<double?> postWeightKg,
      Value<double?> durationHours,
      Value<String> note,
      Value<int> rowid,
    });
typedef $$DialysisSessionsTableUpdateCompanionBuilder =
    DialysisSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> scheduledAt,
      Value<bool> completed,
      Value<String> center,
      Value<double?> ultrafiltrationL,
      Value<double?> preWeightKg,
      Value<double?> postWeightKg,
      Value<double?> durationHours,
      Value<String> note,
      Value<int> rowid,
    });

class $$DialysisSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $DialysisSessionsTable> {
  $$DialysisSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get center => $composableBuilder(
    column: $table.center,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ultrafiltrationL => $composableBuilder(
    column: $table.ultrafiltrationL,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preWeightKg => $composableBuilder(
    column: $table.preWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get postWeightKg => $composableBuilder(
    column: $table.postWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationHours => $composableBuilder(
    column: $table.durationHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DialysisSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DialysisSessionsTable> {
  $$DialysisSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get center => $composableBuilder(
    column: $table.center,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ultrafiltrationL => $composableBuilder(
    column: $table.ultrafiltrationL,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preWeightKg => $composableBuilder(
    column: $table.preWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get postWeightKg => $composableBuilder(
    column: $table.postWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationHours => $composableBuilder(
    column: $table.durationHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DialysisSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DialysisSessionsTable> {
  $$DialysisSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get center =>
      $composableBuilder(column: $table.center, builder: (column) => column);

  GeneratedColumn<double> get ultrafiltrationL => $composableBuilder(
    column: $table.ultrafiltrationL,
    builder: (column) => column,
  );

  GeneratedColumn<double> get preWeightKg => $composableBuilder(
    column: $table.preWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get postWeightKg => $composableBuilder(
    column: $table.postWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get durationHours => $composableBuilder(
    column: $table.durationHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DialysisSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DialysisSessionsTable,
          DialysisSession,
          $$DialysisSessionsTableFilterComposer,
          $$DialysisSessionsTableOrderingComposer,
          $$DialysisSessionsTableAnnotationComposer,
          $$DialysisSessionsTableCreateCompanionBuilder,
          $$DialysisSessionsTableUpdateCompanionBuilder,
          (
            DialysisSession,
            BaseReferences<
              _$AppDatabase,
              $DialysisSessionsTable,
              DialysisSession
            >,
          ),
          DialysisSession,
          PrefetchHooks Function()
        > {
  $$DialysisSessionsTableTableManager(
    _$AppDatabase db,
    $DialysisSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DialysisSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DialysisSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DialysisSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String> center = const Value.absent(),
                Value<double?> ultrafiltrationL = const Value.absent(),
                Value<double?> preWeightKg = const Value.absent(),
                Value<double?> postWeightKg = const Value.absent(),
                Value<double?> durationHours = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DialysisSessionsCompanion(
                id: id,
                scheduledAt: scheduledAt,
                completed: completed,
                center: center,
                ultrafiltrationL: ultrafiltrationL,
                preWeightKg: preWeightKg,
                postWeightKg: postWeightKg,
                durationHours: durationHours,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime scheduledAt,
                Value<bool> completed = const Value.absent(),
                Value<String> center = const Value.absent(),
                Value<double?> ultrafiltrationL = const Value.absent(),
                Value<double?> preWeightKg = const Value.absent(),
                Value<double?> postWeightKg = const Value.absent(),
                Value<double?> durationHours = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DialysisSessionsCompanion.insert(
                id: id,
                scheduledAt: scheduledAt,
                completed: completed,
                center: center,
                ultrafiltrationL: ultrafiltrationL,
                preWeightKg: preWeightKg,
                postWeightKg: postWeightKg,
                durationHours: durationHours,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DialysisSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DialysisSessionsTable,
      DialysisSession,
      $$DialysisSessionsTableFilterComposer,
      $$DialysisSessionsTableOrderingComposer,
      $$DialysisSessionsTableAnnotationComposer,
      $$DialysisSessionsTableCreateCompanionBuilder,
      $$DialysisSessionsTableUpdateCompanionBuilder,
      (
        DialysisSession,
        BaseReferences<_$AppDatabase, $DialysisSessionsTable, DialysisSession>,
      ),
      DialysisSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$LabResultsTableTableManager get labResults =>
      $$LabResultsTableTableManager(_db, _db.labResults);
  $$TimelineEventsTableTableManager get timelineEvents =>
      $$TimelineEventsTableTableManager(_db, _db.timelineEvents);
  $$DosesTableTableManager get doses =>
      $$DosesTableTableManager(_db, _db.doses);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$DialysisSessionsTableTableManager get dialysisSessions =>
      $$DialysisSessionsTableTableManager(_db, _db.dialysisSessions);
}
