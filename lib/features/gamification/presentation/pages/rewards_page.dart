import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../state/gamification_bloc.dart';
import '../state/gamification_state.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamificationBloc>().add(LoadGamificationEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<GamificationBloc, GamificationState>(
          listener: (ctx, state) {
            if (state is RewardRedeemedSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('¡"${state.rewardName}" canjeado! 🎉'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is RewardRedeemFailed) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('No tienes suficientes monedas 🪙'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (ctx, state) {
            if (state is GamificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is GamificationLoaded) {
              return _buildContent(ctx, state);
            }
            return const Center(
              child: Text(
                'Cargando recompensas...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext ctx, GamificationLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recompensas',
                  style: Theme.of(ctx).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Canjea tus monedas por premios',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _buildStatsBar(ctx, state),
                const SizedBox(height: 24),
                _buildXpProgress(ctx, state),
                const SizedBox(height: 24),
                Text(
                  'Mis Logros',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _buildAchievements(ctx, state),
                const SizedBox(height: 24),
                Text(
                  'Tienda de Recompensas',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tienes ${state.stats.coins} 🪙',
                  style:
                      const TextStyle(color: AppColors.warning, fontSize: 14),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildRewardCard(ctx, state, i),
              childCount: state.rewards.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext ctx, GamificationLoaded state) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.bolt_rounded,
          value: '${state.stats.totalXp} XP',
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.monetization_on_rounded,
          value: '${state.stats.coins} monedas',
          color: AppColors.warning,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.local_fire_department_rounded,
          value: '${state.stats.currentStreak} días',
          color: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildXpProgress(BuildContext ctx, GamificationLoaded state) {
    final stats = state.stats;
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.levelName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${stats.totalXp} / ${stats.xpForNextLevel} XP',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stats.levelProgress,
              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext ctx, GamificationLoaded state) {
    final stats = state.stats;
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.catTasks,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.tasksCompleted}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Text(
                  'Tareas\ncompletadas',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(
                  Icons.repeat_rounded,
                  color: AppColors.catHabits,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.habitsCompleted}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Text(
                  'Hábitos\nregistrados',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GlassCard(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.currentStreak}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Text(
                  'Días de racha',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(
    BuildContext ctx,
    GamificationLoaded state,
    int index,
  ) {
    final reward = state.rewards[index];
    final canAfford = state.stats.coins >= reward.costCoins;
    final iconMap = {
      'coffee': Icons.coffee_rounded,
      'sports_esports': Icons.sports_esports_rounded,
      'movie': Icons.movie_rounded,
      'people': Icons.people_rounded,
      'emoji_events': Icons.emoji_events_rounded,
    };
    final iconData = iconMap[reward.iconName] ?? Icons.card_giftcard_rounded;

    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      borderColor: reward.isRedeemed
          ? AppColors.glassBorder
          : canAfford
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.glassBorder,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (reward.isRedeemed
                      ? AppColors.textHint
                      : canAfford
                          ? AppColors.warning
                          : AppColors.primary)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iconData,
              color: reward.isRedeemed
                  ? AppColors.textHint
                  : canAfford
                      ? AppColors.warning
                      : AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reward.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: reward.isRedeemed
                  ? AppColors.textHint
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${reward.costCoins} 🪙',
            style: TextStyle(
              fontSize: 12,
              color: canAfford && !reward.isRedeemed
                  ? AppColors.warning
                  : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: reward.isRedeemed || !canAfford
                  ? null
                  : () {
                      ctx.read<GamificationBloc>().add(
                            RedeemRewardEvent(reward.id!),
                          );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford && !reward.isRedeemed
                    ? AppColors.warning
                    : AppColors.bgCardLight,
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                reward.isRedeemed
                    ? 'Canjeado'
                    : canAfford
                        ? 'Canjear'
                        : 'Sin monedas',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: reward.isRedeemed || !canAfford
                      ? AppColors.textHint
                      : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}