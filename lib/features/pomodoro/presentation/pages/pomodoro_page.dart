import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../gamification/presentation/state/gamification_bloc.dart';
import '../../../gamification/presentation/state/gamification_state.dart';
import '../state/pomodoro_bloc.dart';
import '../state/pomodoro_state.dart';

class PomodoroPage extends StatelessWidget {
  final int? taskId;
  final String? taskTitle;

  const PomodoroPage({super.key, this.taskId, this.taskTitle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PomodoroBloc>(
      create: (ctx) {
        final bloc = ctx.read<PomodoroBloc>();
        bloc.add(PomodoroInitEvent(taskId: taskId, taskTitle: taskTitle));
        return bloc;
      },
      child: const _PomodoroView(),
    );
  }
}

class _PomodoroView extends StatelessWidget {
  const _PomodoroView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PomodoroBloc, PomodoroState>(
      listenWhen: (prev, curr) => !prev.isCompleted && curr.isCompleted,
      listener: (ctx, state) {
        if (state.phase == PomodoroPhase.shortBreak ||
            state.phase == PomodoroPhase.longBreak) {
          // Dar XP al completar una sesión de trabajo
          ctx.read<GamificationBloc>().add(AddXpEvent(xp: 20, coins: 5, source: 'pomodoro'));
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              content: Row(
                children: const [
                  Icon(Icons.star_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('+20 XP • Sesión Pomodoro completada 🎉'),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textPrimary),
              onPressed: () {
                ctx.read<PomodoroBloc>().add(PomodoroPauseEvent());
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },

            ),
            title: Text(
              state.taskTitle != null
                  ? '📌 ${state.taskTitle}'
                  : '⏱️ Pomodoro',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              TextButton.icon(
                onPressed: () => ctx.read<PomodoroBloc>().add(PomodoroSkipEvent()),
                icon: const Icon(Icons.skip_next_rounded,
                    color: AppColors.textHint, size: 18),
                label: const Text('Skip',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12)),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _PhaseChips(state),
                const SizedBox(height: 40),
                _CircularTimer(state),
                const SizedBox(height: 40),
                _Controls(state),
                const Spacer(),
                _SessionCountRow(state),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Phase chips ───────────────────────────────────────────────────────────────
class _PhaseChips extends StatelessWidget {
  final PomodoroState state;
  const _PhaseChips(this.state);

  @override
  Widget build(BuildContext context) {
    final phases = [
      (PomodoroPhase.working, 'Concentración'),
      (PomodoroPhase.shortBreak, 'Descanso Corto'),
      (PomodoroPhase.longBreak, 'Descanso Largo'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: phases.map((p) {
        final isActive = state.phase == p.$1 ||
            (state.phase == PomodoroPhase.idle && p.$1 == PomodoroPhase.working);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.glassBorder,
            ),
          ),
          child: Text(
            p.$2,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.primary : AppColors.textHint,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Círculo animado ───────────────────────────────────────────────────────────
class _CircularTimer extends StatelessWidget {
  final PomodoroState state;
  const _CircularTimer(this.state);

  Color get _phaseColor {
    return switch (state.phase) {
      PomodoroPhase.working => AppColors.primary,
      PomodoroPhase.shortBreak => AppColors.success,
      PomodoroPhase.longBreak => AppColors.accent,
      PomodoroPhase.idle => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(240, 240),
            painter: _TimerPainter(
              progress: state.progress,
              color: _phaseColor,
              bgColor: AppColors.bgCardLight,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  state.formattedTime,
                  key: ValueKey(state.formattedTime),
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: _phaseColor,
                    letterSpacing: -2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.isCompleted ? '¡Completado!' : state.isRunning ? 'Enfocado' : 'Listo',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _TimerPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final radius = (size.width - strokeWidth) / 2;

    // Fondo
    canvas.drawCircle(
        center, radius, Paint()..color = bgColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
    // Arco
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter old) => old.progress != progress;
}

// ── Controles ─────────────────────────────────────────────────────────────────
class _Controls extends StatelessWidget {
  final PomodoroState state;
  const _Controls(this.state);

  @override
  Widget build(BuildContext context) {
    final isRunning = state.isRunning;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset
        _CircleBtn(
          icon: Icons.replay_rounded,
          size: 52,
          iconSize: 24,
          color: AppColors.textHint,
          onTap: () => context.read<PomodoroBloc>().add(PomodoroResetEvent()),
        ),
        const SizedBox(width: 24),
        // Play/Pause
        GestureDetector(
          onTap: () => context.read<PomodoroBloc>().add(
                isRunning ? PomodoroPauseEvent() : PomodoroStartEvent(),
              ),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Estadísticas del día
        _CircleBtn(
          icon: Icons.bar_chart_rounded,
          size: 52,
          iconSize: 24,
          color: AppColors.textHint,
          onTap: () => _showStatsSheet(context),
        ),
      ],
    );
  }

  void _showStatsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2))),
            const Text('Estadísticas de Hoy',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  label: 'Sesiones',
                  value: '${context.read<PomodoroBloc>().state.completedWorkSessions}',
                ),
                _StatItem(
                  icon: Icons.timer_rounded,
                  color: AppColors.primary,
                  label: 'Minutos',
                  value: '${context.read<PomodoroBloc>().state.completedWorkSessions * context.read<PomodoroBloc>().state.config.workMinutes}',
                ),
                _StatItem(
                  icon: Icons.stars_rounded,
                  color: AppColors.warning,
                  label: 'XP ganada',
                  value: '${context.read<PomodoroBloc>().state.completedWorkSessions * 20}',
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color color;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.size, required this.iconSize, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgCardLight,
            border: Border.all(color: AppColors.glassBorder)),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }
}

// ── Sesiones completadas ──────────────────────────────────────────────────────
class _SessionCountRow extends StatelessWidget {
  final PomodoroState state;
  const _SessionCountRow(this.state);

  @override
  Widget build(BuildContext context) {
    final count = state.completedWorkSessions;
    final maxDots = state.config.sessionsBeforeLongBreak;
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sesiones: ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ...List.generate(maxDots, (i) => Container(
                width: 14, height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (count % maxDots) > i
                      ? AppColors.primary
                      : AppColors.bgCardLight,
                  border: Border.all(color: AppColors.glassBorder),
                ),
              )),
        ],
      ),
    );
  }
}
