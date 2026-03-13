import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/wellness_entities.dart';
import '../state/wellness_bloc.dart';
import '../state/wellness_state.dart';

class JournalEntryPage extends StatefulWidget {
  final int? entryId; // null = nueva entrada
  const JournalEntryPage({super.key, this.entryId});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final List<String> _tags = [];
  bool _isEditing = false;
  JournalEntryEntity? _existingEntry;

  // Prompts de escritura reflexiva rotantes
  static const _prompts = [
    '¿Qué salió bien hoy?',
    '¿Qué momento del día disfrutaste más?',
    '¿Qué podrías mejorar mañana?',
    '¿Por qué estás agradecido hoy?',
    '¿Qué aprendiste hoy?',
    '¿Cómo te sientes con tu progreso esta semana?',
    '¿Qué te da energía últimamente?',
  ];

  String get _currentPrompt {
    final idx = DateTime.now().day % _prompts.length;
    return _prompts[idx];
  }

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _isEditing = true;
      final state = context.read<WellnessBloc>().state;
      if (state is WellnessLoaded) {
        _existingEntry = state.journal.firstWhere(
          (e) => e.id == widget.entryId,
          orElse: () => JournalEntryEntity(
            title: '', content: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        );
        _titleCtrl.text = _existingEntry!.title;
        _contentCtrl.text = _existingEntry!.content;
        _tags.addAll(_existingEntry!.tags);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save(BuildContext ctx) {
    if (_contentCtrl.text.trim().isEmpty) return;
    final now = DateTime.now();
    final entry = JournalEntryEntity(
      id: _existingEntry?.id,
      title: _titleCtrl.text.trim().isEmpty
          ? 'Entrada del ${now.day}/${now.month}/${now.year}'
          : _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      moodScore: null,
      moodEmoji: null,
      tags: List.from(_tags),
      createdAt: _existingEntry?.createdAt ?? now,
      updatedAt: now,
    );
    ctx.read<WellnessBloc>().add(SaveJournalEntryEvent(entry));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WellnessBloc, WellnessState>(
      listenWhen: (_, curr) => curr is JournalSavedSuccess,
      listener: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('📓 Entrada guardada'),
          ),
        );
        context.go('/wellness/journal');
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/wellness/journal');
              }
            },
          ),
          title: Text(
            _isEditing ? 'Editar entrada' : 'Nueva entrada',
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _save(context),
              icon: const Icon(Icons.save_rounded,
                  color: AppColors.accent, size: 18),
              label: const Text('Guardar',
                  style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prompt del día
                if (!_isEditing)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('💭', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentPrompt,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Título
                TextField(
                  controller: _titleCtrl,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Título...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                Divider(color: AppColors.glassBorder),

                const SizedBox(height: 8),

                // Contenido
                TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.7),
                  decoration: InputDecoration(
                    hintText: _currentPrompt,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintStyle: const TextStyle(
                        color: AppColors.textHint, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // Tags rápidos
                const Text('Etiquetas rápidas',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MoodData.commonTags.map((tag) {
                    final active = _tags.contains(tag);
                    return GestureDetector(
                      onTap: () => setState(() {
                        active ? _tags.remove(tag) : _tags.add(tag);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: active
                                ? AppColors.accent
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                color: active
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
