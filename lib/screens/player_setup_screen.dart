import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../theme/app_theme.dart';
import 'solo_quiz_screen.dart';
import 'simultaneous_quiz_screen.dart';
import 'classroom_quiz_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  final GameMode initialMode;

  const PlayerSetupScreen({
    super.key,
    required this.initialMode,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  late GameMode _selectedMode;
  int _playerCount = 1;
  int _timerSeconds = 15; // 0 = no timer
  bool _shuffle = true;
  bool _onlyPdfOfficial = false;

  final List<TextEditingController> _nameControllers = [];
  final QuestionService _questionService = QuestionService();
  bool _isLoadingQuestions = true;
  List<Question> _loadedQuestions = [];

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _updatePlayerCountForMode(_selectedMode);
    _initQuestions();
  }

  void _updatePlayerCountForMode(GameMode mode) {
    switch (mode) {
      case GameMode.solo:
        _playerCount = 1;
        break;
      case GameMode.duel2P:
        _playerCount = 2;
        break;
      case GameMode.multiplayer4P:
        if (_playerCount < 2) _playerCount = 3;
        break;
      case GameMode.classroom:
        _playerCount = 2; // equipes
        break;
    }
    _syncControllers();
  }

  void _syncControllers() {
    while (_nameControllers.length < _playerCount) {
      final index = _nameControllers.length;
      final defaultName = _selectedMode == GameMode.classroom
          ? 'Equipe ${String.fromCharCode(65 + index)}'
          : 'Jogador ${index + 1}';
      _nameControllers.add(TextEditingController(text: defaultName));
    }
    while (_nameControllers.length > _playerCount) {
      _nameControllers.removeLast().dispose();
    }
  }

  Future<void> _initQuestions() async {
    final list = await _questionService.loadQuestions();
    if (mounted) {
      setState(() {
        _loadedQuestions = list;
        _isLoadingQuestions = false;
      });
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    if (_loadedQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma pergunta cadastrada. Carregue perguntas primeiro!')),
      );
      return;
    }

    // Filter questions if requested
    List<Question> gameQuestions = List.from(_loadedQuestions);
    if (_onlyPdfOfficial) {
      gameQuestions = gameQuestions.where((q) => q.source.contains('Afirmação')).toList();
      if (gameQuestions.isEmpty) {
        gameQuestions = List.from(_loadedQuestions.take(8));
      }
    }

    if (_shuffle) {
      gameQuestions.shuffle();
    }

    // Create Players
    final List<Player> players = [];
    for (int i = 0; i < _playerCount; i++) {
      final name = _nameControllers[i].text.trim().isEmpty
          ? (_selectedMode == GameMode.classroom ? 'Equipe ${i + 1}' : 'Jogador ${i + 1}')
          : _nameControllers[i].text.trim();

      players.add(
        Player(
          id: i + 1,
          name: name,
          color: AppTheme.playerColors[i % AppTheme.playerColors.length],
          icon: AppTheme.playerIcons[i % AppTheme.playerIcons.length],
        ),
      );
    }

    if (_selectedMode == GameMode.solo) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SoloQuizScreen(
            player: players.first,
            questions: gameQuestions,
            secondsPerQuestion: _timerSeconds,
          ),
        ),
      );
    } else if (_selectedMode == GameMode.classroom) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClassroomQuizScreen(
            teams: players,
            questions: gameQuestions,
            secondsPerQuestion: _timerSeconds,
          ),
        ),
      );
    } else {
      // Simultaneous Duel or Multiplayer
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SimultaneousQuizScreen(
            mode: _selectedMode,
            players: players,
            questions: gameQuestions,
            secondsPerQuestion: _timerSeconds,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurar Partida',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoadingQuestions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Selection Segmented Selector
                  Text(
                    'MODO DE JOGO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GameMode.values.map((mode) {
                      final isSelected = _selectedMode == mode;
                      return ChoiceChip(
                        label: Text(mode.shortName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedMode = mode;
                              _updatePlayerCountForMode(mode);
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryIndigo,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Player Count Selector (if Multiplayer)
                  if (_selectedMode == GameMode.multiplayer4P || _selectedMode == GameMode.classroom) ...[
                    Text(
                      _selectedMode == GameMode.classroom ? 'QUANTIDADE DE EQUIPES' : 'QUANTIDADE DE JOGADORES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [2, 3, 4].map((count) {
                        final isSelected = _playerCount == count;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _playerCount = count;
                                  _syncControllers();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? AppTheme.primaryIndigo
                                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                foregroundColor: isSelected ? Colors.white : null,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.primaryIndigo
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Player Names Setup
                  Text(
                    _selectedMode == GameMode.classroom ? 'NOMES DAS EQUIPES' : 'NOMES DOS PARTICIPANTES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_playerCount, (i) {
                    final color = AppTheme.playerColors[i % AppTheme.playerColors.length];
                    final icon = AppTheme.playerIcons[i % AppTheme.playerIcons.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _nameControllers[i],
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: color,
                              child: Icon(icon, size: 14, color: Colors.white),
                            ),
                          ),
                          labelText: _selectedMode == GameMode.classroom ? 'Equipe ${i + 1}' : 'Jogador ${i + 1}',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Timer Selector
                  Text(
                    'TEMPO POR PERGUNTA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTimerButton(label: 'Sem tempo', seconds: 0),
                      _buildTimerButton(label: '10s', seconds: 10),
                      _buildTimerButton(label: '15s', seconds: 15),
                      _buildTimerButton(label: '30s', seconds: 30),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Question Options Card
                  Container(
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
                        Text(
                          'CONFIGURAÇÃO DO BARALHO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Embaralhar perguntas', style: TextStyle(fontWeight: FontWeight.w700)),
                          value: _shuffle,
                          onChanged: (val) => setState(() => _shuffle = val),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Somente as 8 oficiais do PDF', style: TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            _onlyPdfOfficial ? '8 perguntas selecionadas' : '${_loadedQuestions.length} perguntas ativas',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          value: _onlyPdfOfficial,
                          onChanged: (val) => setState(() => _onlyPdfOfficial = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Start Button
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'INICIAR QUIZ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTimerButton({required String label, required int seconds}) {
    final isSelected = _timerSeconds == seconds;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () => setState(() => _timerSeconds = seconds),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: isSelected
                ? AppTheme.primaryIndigo
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            foregroundColor: isSelected ? Colors.white : null,
            side: BorderSide(
              color: isSelected
                  ? AppTheme.primaryIndigo
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
