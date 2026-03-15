import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/safe_pop_scope.dart';
import '../../domain/entities/wellness_entities.dart';
import '../state/wellness_bloc.dart';
import '../state/wellness_state.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> {
  @override
  void initState() {
    super.initState();
    context.read<WellnessBloc>().add(LoadWellnessEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      fallbackRoute: '/',
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<WellnessBloc, WellnessState>(
            builder: (ctx, state) {
              final loaded = state is WellnessLoaded ? state : null;
              return CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _Header(
                      todayMood: loaded?.todayMood,
                      weeklyAvg: loaded?.weeklyAvgMood ?? 0,
                      onLogMood: () => context.go('/wellness/mood'),
                    ),
                  ),

                  // ── Quick stats ──────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _NavCard(
                              icon: Icons.auto_graph_rounded,
                              color: AppColors.primary,
                              label: 'Insights',
                              sub: 'Correlaciones',
                              onTap: () => context.go('/wellness/insights'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NavCard(
                              icon: Icons.book_rounded,
                              color: AppColors.accent,
                              label: 'Diario',
                              sub: '${loaded?.journal.length ?? 0} entradas',
                              onTap: () => context.go('/wellness/journal'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NavCard(
                              icon: Icons.mood_rounded,
                              color: AppColors.warning,
                              label: 'Ánimo',
                              sub: 'Registrar',
                              onTap: () => context.go('/wellness/mood'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tendencia de ánimo ──────────────────────────────────────
                  if (loaded != null && loaded.recentMoods.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text('Últimos 7 días',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _MoodWeekChart(moods: loaded.recentMoods),
                    ),
                  ],

                  // ── Entradas recientes del diario ────────────────────────────
                  if (loaded != null && loaded.journal.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Diario Reciente',
                                style: Theme.of(context).textTheme.titleLarge),
                            TextButton(
                              onPressed: () => context.go('/wellness/journal'),
                              child: const Text('Ver todo',
                                  style: TextStyle(
                                      color: AppColors.accent, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _JournalTile(entry: loaded.journal[i]),
                        childCount: loaded.journal.length.clamp(0, 3),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/wellness/journal/new'),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Nueva entrada'),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final MoodLogEntity? todayMood;
  final double weeklyAvg;
  final VoidCallback onLogMood;
  const _Header({required this.todayMood, required this.weeklyAvg, required this.onLogMood});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark 
          ? const LinearGradient(
              colors: [Color(0xFF1A0533), Color(0xFF0D1B38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).primaryColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).colorScheme.onSurface, size: 20),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
              const SizedBox(width: 8),
              Text('Bienestar 🧘',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          GlassCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(18),
            child: GestureDetector(
              onTap: onLogMood,
              child: Row(
                children: [
                  Text(
                    todayMood?.moodEmoji ?? '❓',
                    style: const TextStyle(fontSize: 44),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayMood != null
                              ? '¿Cómo te sientes ahora?'
                              : '¿Cómo te sientes hoy?',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          todayMood != null
                              ? '${todayMood!.moodLabel} • Toca para actualizar'
                              : 'No registrado. Toca para registrar.',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textHint),
                ],
              ),
            ),
          ),
          if (weeklyAvg > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: AppColors.textHint, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Promedio semanal: ${weeklyAvg.toStringAsFixed(1)}/5',
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Nav cards ─────────────────────────────────────────────────────────────────
class _NavCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _NavCard({required this.icon, required this.color, required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        borderColor: color.withValues(alpha: 0.3),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sub, style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Mood week chart ───────────────────────────────────────────────────────────
class _MoodWeekChart extends StatelessWidget {
  final List<MoodLogEntity> moods;
  const _MoodWeekChart({required this.moods});

  @override
  Widget build(BuildContext context) {
    // Agrupa por día y toma el último del día
    final Map<String, MoodLogEntity> byDay = {};
    for (final m in moods) {
      final key = DateFormat('yyyy-MM-dd').format(m.loggedAt);
      byDay[key] = m;
    }
    final last7 = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      return (d, byDay[key]);
    });

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: last7.map((entry) {
          final day = entry.$1;
          final mood = entry.$2;
          final isToday = DateFormat('yyyy-MM-dd').format(day) ==
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          return Column(
            children: [
              Text(
                mood?.moodEmoji ?? '·',
                style: TextStyle(fontSize: mood != null ? 22 : 16),
              ),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: mood != null
                      ? _moodColor(mood.moodScore).withValues(alpha: 0.7)
                      : AppColors.bgCardLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('E', 'es').format(day).substring(0, 2),
                style: TextStyle(
                    color: isToday ? AppColors.primary : AppColors.textHint,
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _moodColor(int score) {
    return [
      Colors.transparent,
      AppColors.error,
      const Color(0xFFFF7043),
      AppColors.warning,
      AppColors.success,
      AppColors.accent,
    ][score.clamp(0, 5)];
  }
}

// ── Journal tile ──────────────────────────────────────────────────────────────
class _JournalTile extends StatelessWidget {
  final JournalEntryEntity entry;
  const _JournalTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.moodEmoji != null)
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 2),
              child: Text(entry.moodEmoji!, style: const TextStyle(fontSize: 20)),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(entry.content,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Text(
            DateFormat('d MMM', 'es').format(entry.createdAt),
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}