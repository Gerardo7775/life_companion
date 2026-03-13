import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/wellness_entities.dart';
import '../state/wellness_bloc.dart';
import '../state/wellness_state.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/wellness');
            }
          },
        ),
        title: const Text('Diario 📓',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.accent),
            ),
            onPressed: () => context.go('/wellness/journal/new'),
          ),
        ],
      ),
      body: BlocBuilder<WellnessBloc, WellnessState>(
        builder: (ctx, state) {
          if (state is WellnessLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }
          final entries =
              state is WellnessLoaded ? state.journal : <JournalEntryEntity>[];

          if (entries.isEmpty) return _EmptyJournal();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _EntryCard(
              entry: entries[i],
              onDelete: () => ctx.read<WellnessBloc>().add(
                    DeleteJournalEntryEvent(entries[i].id!),
                  ),
              onTap: () {
                // Navegar a edición pasando el id
                context.go('/wellness/journal/new?id=${entries[i].id}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/wellness/journal/new'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntryEntity entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  const _EntryCard({required this.entry, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.bgCard,
            title: const Text('¿Eliminar entrada?',
                style: TextStyle(color: AppColors.textPrimary)),
            content: const Text('Esta acción no se puede deshacer.',
                style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Eliminar')),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (entry.moodEmoji != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(entry.moodEmoji!,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  Expanded(
                    child: Text(entry.title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                  Text(
                    DateFormat('d MMM y', 'es').format(entry.createdAt),
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: entry.tags.take(3).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                color: AppColors.accent, fontSize: 11)),
                      )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.1)),
              child: const Icon(Icons.book_rounded,
                  color: AppColors.accent, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Diario vacío',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Escribe tu primera reflexión. '
                'La escritura consciente es una práctica poderosa de bienestar.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
