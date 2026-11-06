import 'package:flutter/material.dart';
import '../models/scoreboard_entry.dart';
import '../services/scoreboard_service.dart';
import '../theme/app_theme.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScoreboardService _scoreboardService = ScoreboardService();
  bool _isLoading = true;
  List<ScoreboardEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _scoreboardService.loadEntries();
    if (mounted) {
      setState(() {
        _entries = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmClear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Scoreboard?'),
        content: const Text('Tem certeza que deseja apagar todo o histórico de pontuações e recordes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.falseRed),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _scoreboardService.clearHistory();
      await _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final soloLeaderboard = _scoreboardService.getSoloLeaderboard();
    final multiHistory = _scoreboardService.getMultiplayerHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scoreboard',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Limpar Histórico',
              onPressed: _confirmClear,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryIndigo,
          unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          indicatorColor: AppTheme.primaryIndigo,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'RECORDES SOLO', icon: Icon(Icons.emoji_events_rounded, size: 20)),
            Tab(text: 'HISTÓRICO MULTIPLAYER', icon: Icon(Icons.history_rounded, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Solo Leaderboard
                soloLeaderboard.isEmpty
                    ? _buildEmptyState('Nenhum recorde solo registrado ainda.\nJogue uma partida no modo Solo!')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: soloLeaderboard.length,
                        itemBuilder: (ctx, index) {
                          final item = soloLeaderboard[index];
                          final medal = index == 0
                              ? '🥇'
                              : index == 1
                                  ? '🥈'
                                  : index == 2
                                      ? '🥉'
                                      : '${index + 1}º';
                          final DateTime dt = item['date'] as DateTime;
                          final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: index == 0
                                    ? Colors.amber.withAlpha(120)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                width: index == 0 ? 2 : 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(medal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$dateStr • ${item['correctCount']}/${item['totalQuestions']} acertos (${(item['accuracy'] as double).toStringAsFixed(0)}%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.amberStreak.withAlpha(isDark ? 50 : 25),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    '${item['score']} pts',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.amberStreak,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                // Tab 2: Multiplayer History
                multiHistory.isEmpty
                    ? _buildEmptyState('Nenhuma partida multiplayer registrada ainda.\nChame amigos para jogar na mesma tela!')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: multiHistory.length,
                        itemBuilder: (ctx, index) {
                          final item = multiHistory[index];
                          final dt = item.dateTime;
                          final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryIndigo.withAlpha(isDark ? 50 : 25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item.gameMode.shortName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryIndigo,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Vencedor: ${item.winnerName}',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${item.winnerScore} pts',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.amberStreak,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: item.playersSummary.map((p) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${p['name']}: ${p['score']} pts',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.military_tech_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
