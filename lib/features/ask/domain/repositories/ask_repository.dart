import '../../../../core/utils/result.dart';
import '../entities/ask_message.dart';

/// The Ask-AI conversation over the patient's entire history.
abstract interface class AskRepository {
  Stream<List<AskMessage>> watchMessages();

  /// Stores the question, queries the model with full vault context, and
  /// stores the cited answer.
  Future<Result<void>> ask(String question);
}
