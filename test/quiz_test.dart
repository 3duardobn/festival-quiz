import 'package:flutter_test/flutter_test.dart';
import 'package:festival_quiz/models/question.dart';
import 'package:festival_quiz/models/player.dart';
import 'package:festival_quiz/services/question_service.dart';
import 'package:flutter/material.dart';

void main() {
  group('Question Model & JSON Parsing', () {
    test('Parses question from JSON with boolean answer', () {
      final json = {
        'id': 'test_1',
        'question': 'O SignWriting começou a ser desenvolvido em 1974.',
        'answer': true,
        'explanation': '1974 é o ano associado à adaptação.',
        'category': 'História',
        'source': 'PDF Oficial',
      };
      final q = Question.fromJson(json);
      expect(q.id, 'test_1');
      expect(q.question, 'O SignWriting começou a ser desenvolvido em 1974.');
      expect(q.answer, isTrue);
      expect(q.category, 'História');
    });

    test('Parses question with string answer "F" or "false" tolerant parsing', () {
      final jsonF = {
        'question': 'A Escrita de Sinais foi criada no Brasil.',
        'resposta': 'F',
        'explicacao': 'Surgiu na Dinamarca.',
      };
      final q = Question.fromJson(jsonF);
      expect(q.answer, isFalse);
      expect(q.explanation, 'Surgiu na Dinamarca.');
    });

    test('QuestionService parses json string with array', () {
      const raw = '''
      [
        {
          "question": "Valerie Sutton criou o DanceWriting em 1966.",
          "answer": true,
          "explanation": "Correto"
        },
        {
          "question": "Valerie Sutton criou a Libras.",
          "answer": false,
          "explanation": "Ela criou o SignWriting."
        }
      ]
      ''';
      final service = QuestionService();
      final list = service.parseQuestionsJson(raw);
      expect(list.length, 2);
      expect(list[0].answer, isTrue);
      expect(list[1].answer, isFalse);
    });
  });

  group('Player Model & Scoring Logic', () {
    test('Scores points with speed bonus and streaks correctly', () {
      final player = Player(
        id: 1,
        name: 'Eduardo',
        color: Colors.blue,
        icon: Icons.person,
      );

      // Question 1: answered fast (2000ms out of 10000ms)
      final pts1 = player.registerAnswer(
        answer: true,
        isCorrect: true,
        responseTimeMs: 2000,
        maxTimeMs: 10000,
        speedBonus: true,
      );
      expect(pts1, greaterThan(100)); // 100 + speed bonus
      expect(player.score, pts1);
      expect(player.streak, 1);
      expect(player.correctCount, 1);

      // Question 2: correct again -> streak 2
      player.registerAnswer(
        answer: false,
        isCorrect: true,
        responseTimeMs: 1000,
        maxTimeMs: 10000,
        speedBonus: true,
      );
      expect(player.streak, 2);

      // Question 3: wrong answer resets streak
      player.registerAnswer(
        answer: true,
        isCorrect: false,
        responseTimeMs: 5000,
        maxTimeMs: 10000,
        speedBonus: true,
      );
      expect(player.streak, 0);
      expect(player.wrongCount, 1);
    });
  });
}
