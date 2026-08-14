import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [ChatMessages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Stream<List<ChatMessage>> watchAll() {
    final query = select(chatMessages)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.watch();
  }

  Future<void> insert(ChatMessagesCompanion entry) {
    return into(chatMessages).insert(entry);
  }

  Future<void> clear() => delete(chatMessages).go();
}
