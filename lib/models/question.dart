class Question {
  final String id;
  final String question;
  final bool answer; // true = Verdadeiro, false = Falso
  final String explanation;
  final String category;
  final String source;

  const Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.explanation,
    this.category = 'Geral',
    this.source = 'PDF Oficial',
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Tolerant parser for answer: bool, string ("V", "F", "true", "false", "verdadeiro", "falso"), or int (1, 0)
    bool parsedAnswer = true;
    final rawAnswer = json['answer'] ?? json['resposta'] ?? json['gabarito'] ?? json['correct'];
    if (rawAnswer is bool) {
      parsedAnswer = rawAnswer;
    } else if (rawAnswer is num) {
      parsedAnswer = rawAnswer == 1;
    } else if (rawAnswer is String) {
      final normalized = rawAnswer.trim().toLowerCase();
      if (normalized == 'f' || normalized == 'false' || normalized == 'falso' || normalized == '0') {
        parsedAnswer = false;
      } else {
        parsedAnswer = true;
      }
    }

    final rawQuestion = json['question'] ?? json['pergunta'] ?? json['afirmacao'] ?? json['text'] ?? '';
    final rawExplanation = json['explanation'] ?? json['explicacao'] ?? json['justificativa'] ?? json['detalhe'] ?? '';
    final rawCategory = json['category'] ?? json['categoria'] ?? 'Geral';
    final rawSource = json['source'] ?? json['fonte'] ?? 'Personalizado';
    final rawId = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

    return Question(
      id: rawId,
      question: rawQuestion.toString().trim(),
      answer: parsedAnswer,
      explanation: rawExplanation.toString().trim(),
      category: rawCategory.toString().trim(),
      source: rawSource.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'explanation': explanation,
      'category': category,
      'source': source,
    };
  }

  Question copyWith({
    String? id,
    String? question,
    bool? answer,
    String? explanation,
    String? category,
    String? source,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      source: source ?? this.source,
    );
  }
}
