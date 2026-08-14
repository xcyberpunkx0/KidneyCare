import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/ask_message.dart';
import '../../domain/repositories/ask_repository.dart';
import '../datasources/gemini_ask_datasource.dart';

class AskRepositoryImpl implements AskRepository {
  AskRepositoryImpl(this._datasource, this._db);

  final GeminiAskDatasource _datasource;
  final AppDatabase _db;

  static const _uuid = Uuid();

  @override
  Stream<List<AskMessage>> watchMessages() {
    return _db.chatDao.watchAll().map((rows) => [
          for (final row in rows)
            AskMessage(
              id: row.id,
              isUser: row.role == 'user',
              content: row.content,
              createdAt: row.createdAt,
              citations: _decodeCitations(row.citationsJson),
            ),
        ]);
  }

  List<AskCitation> _decodeCitations(String json) {
    final raw = jsonDecode(json);
    if (raw is! List) return const [];
    return [
      for (final item in raw.whereType<Map<String, dynamic>>())
        AskCitation.fromJson(item),
    ];
  }

  @override
  Future<Result<void>> ask(String question) {
    return Result.guard(() async {
      await _db.chatDao.insert(ChatMessagesCompanion(
        id: Value(_uuid.v4()),
        role: const Value('user'),
        content: Value(question),
        createdAt: Value(DateTime.now()),
      ));

      final reply = await _datasource.ask(
        question: question,
        patient: await _db.patientDao.getPatient(),
        documents: await _db.documentDao.watchAll().first,
        medications: [
          ...await _db.medicationDao.watchActive().first,
          ...await _db.medicationDao.watchEnded().first,
        ],
        labs: await _db.labDao.getAll(),
      );

      final citations = <AskCitation>[];
      for (final id in reply.citedDocumentIds) {
        final doc = await _db.documentDao.getById(id);
        if (doc == null) continue;
        citations.add(AskCitation(
          documentId: doc.id,
          title: doc.title,
          subtitle: [
            if (doc.hospital.isNotEmpty) doc.hospital
            else if (doc.doctor.isNotEmpty) doc.doctor,
            doc.documentDate.monthDay,
          ].join(' · '),
        ));
      }

      await _db.chatDao.insert(ChatMessagesCompanion(
        id: Value(_uuid.v4()),
        role: const Value('assistant'),
        content: Value(reply.answer),
        citationsJson: Value(
          jsonEncode([for (final c in citations) c.toJson()]),
        ),
        createdAt: Value(DateTime.now()),
      ));
    });
  }
}

final askRepositoryProvider = Provider<AskRepository>((ref) {
  return AskRepositoryImpl(
    ref.watch(geminiAskDatasourceProvider),
    ref.watch(databaseProvider),
  );
});

final askMessagesProvider = StreamProvider<List<AskMessage>>((ref) {
  return ref.watch(askRepositoryProvider).watchMessages();
});
