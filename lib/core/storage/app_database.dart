import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import '../../shared/domain/claim_status.dart';
import '../../shared/domain/document_type.dart';
import '../../shared/domain/med_schedule.dart';
import '../../shared/domain/timeline_event_type.dart';
import '../services/vault_key_store.dart';
import 'daos/chat_dao.dart';
import 'daos/claim_dao.dart';
import 'daos/dialysis_dao.dart';
import 'daos/document_dao.dart';
import 'daos/dose_dao.dart';
import 'daos/lab_dao.dart';
import 'daos/medication_dao.dart';
import 'daos/patient_dao.dart';
import 'daos/timeline_dao.dart';
import 'seed/demo_seed.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Patients,
    Documents,
    DocumentPages,
    Medications,
    LabResults,
    TimelineEvents,
    Doses,
    ChatMessages,
    DialysisSessions,
    InsurancePolicies,
    Claims,
    ClaimDocuments,
    ClaimChecklistItems,
  ],
  daos: [
    PatientDao,
    DocumentDao,
    MedicationDao,
    LabDao,
    TimelineDao,
    DoseDao,
    ChatDao,
    DialysisDao,
    ClaimDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(patients, patients.scheduleJson);
        }
        if (from < 3) {
          await m.addColumn(patients, patients.bloodGroup);
          await m.addColumn(patients, patients.allergies);
          await m.addColumn(patients, patients.emergencyContact);
        }
        if (from < 4) {
          await m.addColumn(dialysisSessions, dialysisSessions.durationHours);
        }
        if (from < 5) {
          await m.addColumn(patients, patients.comorbidities);
        }
        if (from < 6) {
          await m.createTable(insurancePolicies);
          await m.createTable(claims);
          await m.createTable(claimDocuments);
          await m.createTable(claimChecklistItems);
        }
        if (from < 7) {
          await m.addColumn(medications, medications.intervalDays);
          await m.addColumn(medications, medications.lastGivenOn);
        }
        if (from < 8) {
          await m.createTable(documentPages);
        }
        if (from < 9) {
          // The old schedule (group + timing cues) becomes three
          // independent axes: food relation, time of day, frequency.
          await m.addColumn(medications, medications.foodRelation);
          await m.addColumn(medications, medications.timeOfDayJson);
          await m.addColumn(medications, medications.frequency);

          final rows = await customSelect(
            'SELECT id, schedule_group, timing_cues_json, interval_days '
            'FROM medications',
          ).get();
          for (final row in rows) {
            final group = row.read<String>('schedule_group');
            final cues =
                (jsonDecode(row.read<String>('timing_cues_json')) as List)
                    .cast<String>();
            final intervalDays = row.read<int?>('interval_days');

            final String food;
            if (cues.contains('beforeFood')) {
              food = 'beforeFood';
            } else if (cues.contains('afterFood')) {
              food = 'afterFood';
            } else if (cues.contains('withFood') || group == 'withFood') {
              food = 'withFood';
            } else {
              food = 'noRelation';
            }

            final timesOfDay = [
              for (final cue in cues)
                if (cue == 'morning' || cue == 'noon' || cue == 'night') cue,
            ];

            // dialysisDayOnly outranks the weekly group: the EPO shot
            // was stored as weekly + dialysis cue with no interval.
            final String frequency;
            if (cues.contains('dialysisDayOnly')) {
              frequency = 'dialysisDaysOnly';
            } else if (group == 'weekly') {
              frequency = intervalDays != null ? 'everyNDays' : 'weekly';
            } else {
              frequency = 'daily';
            }

            await customStatement(
              'UPDATE medications SET food_relation = ?, '
              'time_of_day_json = ?, frequency = ? WHERE id = ?',
              [
                food,
                jsonEncode(timesOfDay),
                frequency,
                row.read<String>('id'),
              ],
            );
          }

          // Rebuild the table without schedule_group / timing_cues_json.
          // ignore: experimental_member_use
          await m.alterTable(TableMigration(medications));
        }
      },
    );
  }

  /// Populates the vault with sample history. Only ever invoked from the
  /// onboarding "explore with sample data" action — a real patient's vault
  /// starts empty.
  Future<void> seedDemo() => seedDemoData(this);

  /// Opens the SQLCipher-encrypted database. The key lives in the
  /// platform's secure storage and never touches the vault file.
  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      }

      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, 'recora.db'));
      final key = await VaultKeyStore.obtainKey();

      return NativeDatabase.createInBackground(
        file,
        // Runs inside the database isolate — overrides set on the main
        // isolate do not carry over, so the SQLCipher library must be
        // wired up here.
        isolateSetup: () {
          if (Platform.isAndroid) {
            open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
          }
        },
        setup: (database) {
          // Must be the first statement on the connection.
          database.execute("PRAGMA key = '$key';");
          // Fail loudly if a plain SQLite build was linked by mistake —
          // medical data must never be written unencrypted.
          final version = database.select('PRAGMA cipher_version;');
          if (version.isEmpty) {
            throw StateError(
              'SQLCipher is unavailable; refusing to open the vault '
              'unencrypted.',
            );
          }
        },
      );
    });
  }
}
