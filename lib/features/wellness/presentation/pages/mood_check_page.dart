import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safe_pop_scope.dart';
import '../../domain/entities/wellness_entities.dart';
import '../state/wellness_bloc.dart';
import '../state/wellness_state.dart';

class MoodCheckPage extends StatefulWidget {
  const MoodCheckPage({super.key});

  @override
  State<MoodCheckPage> createState() => _MoodCheckPageState();
}

class _MoodCheckPageState extends State<MoodCheckPage> {
  int _selectedMood = 3;
  final Set<String> _selectedTags = {};
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moods = MoodData.moods;
    final selected = moods.firstWhere((m) => m.$1 == _selectedMood);

    return SafePopScope(
      fallbackRoute: '/wellness',
      child: BlocListener<WellnessBloc, WellnessState>(
        listenWhen: (_, curr) => curr is MoodLoggedSuccess,
        listener: (_, __) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('😊 Ánimo registrado'),
            ),
          );
          context.go('/wellness');
        },
        child: Scaffold(
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
            title: const Text('¿Cómo te sientes?',
                style: TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Emoji selector ──────────────────────────────────────────
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        selected.$2,
                        key: ValueKey(_selectedMood),
                        style: const TextStyle(fontSize: 72),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(selected.$3,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),

                  // ── Slider de puntuación ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: moods.map((m) {
                      final isSelected = _selectedMood == m.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMood = m.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? _moodColor(m.$1).withValues(alpha: 0.25)
                                : AppColors.bgCard,
                            border: Border.all(
                              color: isSelected
                                  ? _moodColor(m.$1)
                                  : AppColors.glassBorder,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(m.$2,
                                style: TextStyle(
                                    fontSize: isSelected ? 26 : 22)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // ── Etiquetas ────────────────────────────────────────────────
                  const Text('¿Cómo la describes?',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MoodData.commonTags.map((tag) {
                      final active = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => setState(() {
                          active ? _selectedTags.remove(tag) : _selectedTags.add(tag);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.glassBorder,
                            ),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Nota libre ───────────────────────────────────────────────
                  const Text('Nota (opcional)',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: '¿Qué está pasando por tu mente?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Guardar ──────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<WellnessBloc>().add(LogMoodEvent(
                          moodScore: _selectedMood,
                          moodEmoji: selected.$2,
                          tags: _selectedTags.toList(),
                          note: _noteCtrl.text.trim().isEmpty
                              ? null
                              : _noteCtrl.text.trim(),
                        ));
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Registrar Ánimo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _moodColor(_selectedMood),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _moodColor(int score) => [
    Colors.transparent,
    AppColors.error,
    const Color(0xFFFF7043),
    AppColors.warning,
    AppColors.success,
    AppColors.accent,
  ][score.clamp(0, 5)];
}
