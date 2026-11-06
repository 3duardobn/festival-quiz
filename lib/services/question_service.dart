import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

class QuestionService {
  static const String _storageKey = 'festival_quiz_custom_questions';
  static final QuestionService _instance = QuestionService._internal();

  factory QuestionService() => _instance;
  QuestionService._internal();

  List<Question> _questions = [];
  bool _isLoaded = false;

  List<Question> get questions => List.unmodifiable(_questions);

  Future<void> init() async {
    if (_isLoaded) return;
    await loadQuestions();
  }

  Future<List<Question>> loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString(_storageKey);

    if (customJson != null && customJson.trim().isNotEmpty) {
      try {
        final parsed = parseQuestionsJson(customJson);
        if (parsed.isNotEmpty) {
          _questions = parsed;
          _isLoaded = true;
          return _questions;
        }
      } catch (e) {
        // Fallback to default asset if saved json was corrupted
      }
    }

    _questions = await _loadDefaultAssetQuestions();
    _isLoaded = true;
    return _questions;
  }

  Future<List<Question>> _loadDefaultAssetQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/default_questions.json');
      return parseQuestionsJson(jsonString);
    } catch (e) {
      // In case asset loading fails, provide fallback in memory
      return _getHardcodedFallbackQuestions();
    }
  }

  List<Question> parseQuestionsJson(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    List<dynamic> listToProcess = [];

    if (decoded is List) {
      listToProcess = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('questions') && decoded['questions'] is List) {
        listToProcess = decoded['questions'] as List;
      } else if (decoded.containsKey('perguntas') && decoded['perguntas'] is List) {
        listToProcess = decoded['perguntas'] as List;
      } else if (decoded.containsKey('categories') && decoded['categories'] is List) {
        for (var cat in decoded['categories']) {
          if (cat is Map && cat['questions'] is List) {
            listToProcess.addAll(cat['questions'] as List);
          }
        }
      } else {
        throw const FormatException('O JSON não contém uma lista de perguntas ("questions").');
      }
    } else {
      throw const FormatException('Formato de JSON inválido.');
    }

    final List<Question> result = [];
    for (int i = 0; i < listToProcess.length; i++) {
      final item = listToProcess[i];
      if (item is Map<String, dynamic>) {
        result.add(Question.fromJson(item));
      } else if (item is Map) {
        result.add(Question.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    if (result.isEmpty) {
      throw const FormatException('Nenhuma pergunta válida foi encontrada no JSON.');
    }

    return result;
  }

  Future<void> saveQuestions(List<Question> newQuestions) async {
    _questions = List.from(newQuestions);
    final prefs = await SharedPreferences.getInstance();
    final jsonExport = exportToJson(_questions);
    await prefs.setString(_storageKey, jsonExport);
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _questions = await _loadDefaultAssetQuestions();
  }

  String exportToJson([List<Question>? questionsToExport]) {
    final target = questionsToExport ?? _questions;
    final map = {
      'title': 'Desafio SignWriting - Quiz V ou F',
      'exportedAt': DateTime.now().toIso8601String(),
      'total': target.length,
      'questions': target.map((q) => q.toJson()).toList(),
    };
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }

  Future<void> addQuestion(Question question) async {
    final updated = List<Question>.from(_questions)..add(question);
    await saveQuestions(updated);
  }

  Future<void> updateQuestion(Question question) async {
    final updated = _questions.map((q) => q.id == question.id ? question : q).toList();
    await saveQuestions(updated);
  }

  Future<void> deleteQuestion(String id) async {
    final updated = _questions.where((q) => q.id != id).toList();
    await saveQuestions(updated);
  }

  List<Question> _getHardcodedFallbackQuestions() {
    return [
      const Question(
        id: 'sw_01',
        question: 'Valerie Sutton começou criando um sistema para registrar movimentos de dança.',
        answer: true,
        explanation: 'O primeiro sistema de Valerie Sutton foi desenvolvido para registrar movimentos de dança.',
        category: 'História do SignWriting',
        source: 'PDF Oficial - Afirmação 1',
      ),
      const Question(
        id: 'sw_02',
        question: 'A Escrita de Sinais foi criada originalmente no Brasil.',
        answer: false,
        explanation: 'O SignWriting surgiu na Dinamarca, em 1974.',
        category: 'História do SignWriting',
        source: 'PDF Oficial - Afirmação 2',
      ),
      const Question(
        id: 'sw_03',
        question: 'O SignWriting começou a ser desenvolvido para registrar línguas de sinais em 1974.',
        answer: true,
        explanation: '1974 é o ano associado à adaptação do sistema para registrar línguas de sinais.',
        category: 'História do SignWriting',
        source: 'PDF Oficial - Afirmação 3',
      ),
      const Question(
        id: 'sw_04',
        question: 'Valerie Sutton foi a criadora da Libras.',
        answer: false,
        explanation: 'Valerie Sutton criou o sistema de escrita SignWriting, não a Libras.',
        category: 'Conceitos & Libras',
        source: 'PDF Oficial - Afirmação 4',
      ),
      const Question(
        id: 'sw_05',
        question: 'A Escrita de Sinais representa somente os movimentos das mãos.',
        answer: false,
        explanation: 'O sistema também registra orientação, localização e elementos não manuais, como expressões faciais.',
        category: 'Parâmetros do SignWriting',
        source: 'PDF Oficial - Afirmação 5',
      ),
      const Question(
        id: 'sw_06',
        question: 'Expressões faciais e outros elementos do corpo também podem ser representados.',
        answer: true,
        explanation: 'Elementos não manuais podem fazer parte da representação.',
        category: 'Parâmetros do SignWriting',
        source: 'PDF Oficial - Afirmação 6',
      ),
      const Question(
        id: 'sw_07',
        question: 'A Escrita de Sinais foi introduzida no Brasil em 1996.',
        answer: true,
        explanation: 'A introdução do SignWriting no Brasil é geralmente situada em 1996.',
        category: 'SignWriting no Brasil',
        source: 'PDF Oficial - Afirmação 7',
      ),
      const Question(
        id: 'sw_08',
        question: 'O SignWriting permite registrar visualmente línguas de sinais.',
        answer: true,
        explanation: 'O sistema representa graficamente aspectos das línguas de sinais.',
        category: 'Conceitos & Libras',
        source: 'PDF Oficial - Afirmação 8',
      ),
    ];
  }
}
