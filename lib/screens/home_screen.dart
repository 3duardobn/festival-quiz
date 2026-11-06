import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import 'player_setup_screen.dart';
import 'scoreboard_screen.dart';
import 'question_manager_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 8 : 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo.withAlpha(isDark ? 50 : 25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: isTablet ? 24 : 20,
                color: AppTheme.primaryIndigo,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'SignWriting Quiz',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: isTablet ? 22 : 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Configurar Perguntas (JSON)',
            icon: Icon(Icons.code_rounded, size: isTablet ? 28 : 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuestionManagerScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Scoreboard & Histórico',
            icon: Icon(Icons.leaderboard_rounded, size: isTablet ? 28 : 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScoreboardScreen()),
              );
            },
          ),
          IconButton(
            tooltip: isDarkMode ? 'Modo Claro' : 'Modo Escuro',
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: isTablet ? 28 : 24,
            ),
            onPressed: onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 36 : 20,
            vertical: isTablet ? 20 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                        : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isTablet ? 36 : 32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withAlpha(isDark ? 60 : 70),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: isTablet ? 18 : 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Material de apoio • Curso de Libras • Gincana',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    Text(
                      'Desafio SignWriting',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 38 : 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quiz interativo de Verdadeiro ou Falso otimizado para tablets e gincanas, com placas animadas e gabarito pedagógico.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: isTablet ? 17 : 14,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: isTablet ? 22 : 18),

                    // Quick V / F Placas preview mini pill
                    Row(
                      children: [
                        _buildMiniPlacaBadge('V', 'VERDADEIRO', AppTheme.trueGreen, isTablet),
                        const SizedBox(width: 12),
                        _buildMiniPlacaBadge('F', 'FALSO', AppTheme.falseRed, isTablet),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 32 : 28),

              // Title Section: Modos de Jogo
              Text(
                'ESCOLHA O MODO DE JOGO',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 14),

              // 1 Jogador (Solo)
              _buildGameModeCard(
                context: context,
                mode: GameMode.solo,
                icon: Icons.person_rounded,
                accentColor: AppTheme.primaryIndigo,
                badgeText: 'Individual',
                title: '1 Jogador (Modo Solo)',
                description: 'Responda no seu ritmo, teste seu tempo e grave seu recorde no placar geral.',
              ),
              const SizedBox(height: 14),

              // Duelo 2 Jogadores (Simultâneo na Mesma Tela)
              _buildGameModeCard(
                context: context,
                mode: GameMode.duel2P,
                icon: Icons.flash_on_rounded,
                accentColor: const Color(0xFFEC4899),
                badgeText: '2 Jogadores • Mesma Tela',
                title: 'Duelo 2P (Simultâneo)',
                description: 'Dois jogadores competem ao mesmo tempo no mesmo aparelho. Quem é mais rápido?',
              ),
              const SizedBox(height: 14),

              // Multijogador (2 a 4 Jogadores Simultâneos)
              _buildGameModeCard(
                context: context,
                mode: GameMode.multiplayer4P,
                icon: Icons.groups_rounded,
                accentColor: const Color(0xFFF59E0B),
                badgeText: 'Até 4 Jogadores',
                title: 'Batalha 2 a 4 Jogadores',
                description: 'Todos respondem simultaneamente com suas próprias placas V e F na tela.',
              ),
              const SizedBox(height: 14),

              // Modo Apresentador / Turma (Sala de Aula com Placas do PDF)
              _buildGameModeCard(
                context: context,
                mode: GameMode.classroom,
                icon: Icons.co_present_rounded,
                accentColor: AppTheme.secondaryCyan,
                badgeText: 'Sala de Aula / Projetor / Gincana',
                title: 'Modo Apresentador (Turma)',
                description: 'Perfeito para o professor conduzir a turma levantando as placas impressas do PDF.',
              ),
              SizedBox(height: isTablet ? 32 : 28),

              // Bottom Cards for Scoreboard & Questions
              Row(
                children: [
                  Expanded(
                    child: _buildSecondaryActionCard(
                      context: context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Scoreboard',
                      subtitle: 'Recordes & Histórico',
                      color: AppTheme.amberStreak,
                      isTablet: isTablet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScoreboardScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: _buildSecondaryActionCard(
                      context: context,
                      icon: Icons.data_object_rounded,
                      title: 'Perguntas JSON',
                      subtitle: 'Importar / Editar',
                      color: AppTheme.primaryIndigo,
                      isTablet: isTablet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuestionManagerScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlacaBadge(String letter, String text, Color color, [bool isTablet = false]) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 10,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white38),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 8 : 6,
              vertical: isTablet ? 4 : 2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isTablet ? 15 : 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: isTablet ? 13 : 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard({
    required BuildContext context,
    required GameMode mode,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerSetupScreen(initialMode: mode),
          ),
        );
      },
      borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: isTablet ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 18 : 14),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(isDark ? 50 : 25),
                borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
              ),
              child: Icon(icon, color: accentColor, size: isTablet ? 36 : 28),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      height: 1.35,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: isTablet ? 32 : 24,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isTablet = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 22 : 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: isTablet ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 14 : 10),
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 50 : 25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: isTablet ? 28 : 22),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 18 : 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
