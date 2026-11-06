import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../theme/app_theme.dart';

class QuestionManagerScreen extends StatefulWidget {
  const QuestionManagerScreen({super.key});

  @override
  State<QuestionManagerScreen> createState() => _QuestionManagerScreenState();
}

class _QuestionManagerScreenState extends State<QuestionManagerScreen> {
  final QuestionService _questionService = QuestionService();
  bool _isLoading = true;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final list = await _questionService.loadQuestions();
    if (mounted) {
      setState(() {
        _questions = List.from(list);
        _isLoading = false;
      });
    }
  }

  Future<void> _showImportJsonDialog() async {
    final TextEditingController jsonController = TextEditingController();
    String? validationMessage;
    int? detectedCount;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          void validate(String text) {
            if (text.trim().isEmpty) {
              setDialogState(() {
                validationMessage = null;
                detectedCount = null;
              });
              return;
            }
            try {
              final parsed = _questionService.parseQuestionsJson(text);
              setDialogState(() {
                detectedCount = parsed.length;
                validationMessage = '✅ Formato válido! $detectedCount perguntas detectadas.';
              });
            } catch (e) {
              setDialogState(() {
                detectedCount = null;
                validationMessage = '❌ Erro de validação: ${e.toString()}';
              });
            }
          }

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.data_object_rounded, color: AppTheme.primaryIndigo),
                SizedBox(width: 8),
                Text('Importar Perguntas JSON'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Cole aqui o JSON contendo as perguntas no formato [ { "question": "...", "answer": true, "explanation": "..." } ] ou { "questions": [...] }:',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: jsonController,
                      maxLines: 8,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      decoration: InputDecoration(
                        hintText: '{\n  "questions": [\n    {\n      "question": "O SignWriting surgiu em 1974?",\n      "answer": true,\n      "explanation": "..."\n    }\n  ]\n}',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onChanged: validate,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.paste_rounded, size: 18),
                          label: const Text('Colar da Área de Transferência'),
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              jsonController.text = data!.text!;
                              validate(data.text!);
                            }
                          },
                        ),
                      ],
                    ),
                    if (validationMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        validationMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: detectedCount != null ? AppTheme.trueGreen : AppTheme.falseRed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: detectedCount == null || detectedCount! == 0
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final parsed = _questionService.parseQuestionsJson(jsonController.text);
                          await _questionService.saveQuestions(parsed);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (mounted) {
                            await _loadQuestions();
                            messenger.showSnackBar(
                              SnackBar(content: Text('$detectedCount perguntas importadas com sucesso!')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Falha ao importar: $e')),
                            );
                          }
                        }
                      },
                child: const Text('Importar & Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showExportJsonDialog() async {
    final jsonText = _questionService.exportToJson(_questions);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_upload_outlined, color: AppTheme.primaryIndigo),
            SizedBox(width: 8),
            Text('Exportar Perguntas JSON'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Aqui está a configuração em JSON de todas as perguntas ativas:'),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonText,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar JSON'),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(ClipboardData(text: jsonText));
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('JSON copiado para a área de transferência!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar Perguntas Originais?'),
        content: const Text(
          'Deseja restaurar as perguntas padrão extraídas do PDF oficial de SignWriting?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryIndigo),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _questionService.resetToDefault();
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perguntas restauradas para o padrão do PDF!')),
        );
      }
    }
  }

  Future<void> _showAddEditQuestionDialog([Question? questionToEdit]) async {
    final isEditing = questionToEdit != null;
    final questionCtrl = TextEditingController(text: questionToEdit?.question ?? '');
    final explanationCtrl = TextEditingController(text: questionToEdit?.explanation ?? '');
    final categoryCtrl = TextEditingController(text: questionToEdit?.category ?? 'Geral');
    bool answer = questionToEdit?.answer ?? true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Editar Pergunta' : 'Nova Pergunta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: questionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Afirmação / Pergunta',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Resposta Correta (Gabarito):', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('VERDADEIRO (V)'),
                          selected: answer == true,
                          selectedColor: AppTheme.trueGreen,
                          labelStyle: TextStyle(
                            color: answer == true ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => answer = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('FALSO (F)'),
                          selected: answer == false,
                          selectedColor: AppTheme.falseRed,
                          labelStyle: TextStyle(
                            color: answer == false ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => answer = false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: explanationCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Explicação / Justificativa pedagógica',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: categoryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () async {
                  if (questionCtrl.text.trim().isEmpty) return;

                  final newQ = Question(
                    id: questionToEdit?.id ?? 'q_${DateTime.now().millisecondsSinceEpoch}',
                    question: questionCtrl.text.trim(),
                    answer: answer,
                    explanation: explanationCtrl.text.trim(),
                    category: categoryCtrl.text.trim().isEmpty ? 'Geral' : categoryCtrl.text.trim(),
                    source: questionToEdit?.source ?? 'Personalizada',
                  );

                  if (isEditing) {
                    await _questionService.updateQuestion(newQ);
                  } else {
                    await _questionService.addQuestion(newQ);
                  }

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    await _loadQuestions();
                  }
                },
                child: Text(isEditing ? 'Atualizar' : 'Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurar Perguntas',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Exportar JSON',
            onPressed: _showExportJsonDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Importar JSON',
            onPressed: _showImportJsonDialog,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Restaurar Padrão (PDF)',
            onPressed: _confirmResetToDefault,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditQuestionDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova Pergunta'),
        backgroundColor: AppTheme.primaryIndigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: AppTheme.primaryIndigo.withAlpha(isDark ? 30 : 15),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, size: 18, color: AppTheme.primaryIndigo),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_questions.length} perguntas cadastradas. Configure via JSON ou adicione manualmente.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFA5B4FC) : AppTheme.primaryIndigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Question List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _questions.length,
                    itemBuilder: (ctx, index) {
                      final q = _questions[index];
                      final isTrue = q.answer;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Placa V/F indicator chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isTrue ? AppTheme.trueGreen : AppTheme.falseRed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isTrue ? 'V' : 'F',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    q.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () => _showAddEditQuestionDialog(q),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.falseRed),
                                  onPressed: () async {
                                    await _questionService.deleteQuestion(q.id);
                                    await _loadQuestions();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              q.question,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Gabarito: ${q.explanation}',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                            if (q.source.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Fonte: ${q.source}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
