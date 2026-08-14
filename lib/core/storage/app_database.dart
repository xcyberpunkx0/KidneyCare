import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import '../../shared/domain/document_type.dart';
import '../../shared/domain/med_schedule.dart';
import '../../shared/domain/timeline_event_type.dart';
import '../services/vault_key_store.dart';
import 'daos/chat_dao.dart';
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
    Medications,
    LabResults,
    TimelineEvents,
    Doses,
    ChatMessages,
    DialysisSessions,
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

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
          await m.addColumn(
              dialysisSessions, dialysisSessions.durationHours);
        }
        if (from < 5) {
          await m.addColumn(patients, patients.comorbidities);
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
            open.overrideFor(
                OperatingSystem.android, openCipherOnAndroid);
          }
        },
        setup: (database) {
          // Must be the first statement on the connection.
          database.execute("PRAGMA key = '$key';");
          // Fail loudly if a plain SQLite build was linked by mistake —
          // medical data must never be written unencrypted.
          final version =
              database.select('PRAGMA cipher_version;');
          if (version.isEmpty) {
            throw StateError(
                'SQLCipher is unavailable; refusing to open the vault '
                'unencrypted.');
          }
        },
      );
    });
  }
}
