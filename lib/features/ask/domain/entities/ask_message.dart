/// A cited source document attached to an assistant answer.
class AskCitation {
  const AskCitation({
    required this.documentId,
    required this.title,
    required this.subtitle,
  });

  final String documentId;
  final String title;
  final String subtitle;

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'title': title,
        'subtitle': subtitle,
      };

  factory AskCitation.fromJson(Map<String, dynamic> json) => AskCitation(
        documentId: json['documentId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
      );
}

/// One message in the Ask conversation.
class AskMessage {
  const AskMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.createdAt,
    this.citations = const [],
  });

  final String id;
  final bool isUser;
  final String content;
  final DateTime createdAt;
  final List<AskCitation> citations;
}
