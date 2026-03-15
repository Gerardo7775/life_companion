import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/safe_pop_scope.dart';
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
    return SafePopScope(
      fallbackRoute: '/wellness/journal',
      child: BlocListener<WellnessBloc, WellnessState>(
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Idea de hoy',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(_currentPrompt,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Título
                  TextField(
                    controller: _titleCtrl,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Título (opcional)',
                      hintStyle: TextStyle(
                          color: AppColors.textHint.withValues(alpha: 0.5),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  // Fecha
                  Text(
                    DateFormat('EEEE d, MMMM y', 'es')
                        .format(_existingEntry?.createdAt ?? DateTime.now()),
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Contenido
                  TextField(
                    controller: _contentCtrl,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        height: 1.6),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Empieza a escribir aquí...',
                      hintStyle: TextStyle(
                          color: AppColors.textHint.withValues(alpha: 0.5),
                          fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 50), // Espacio extra al fondo
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  border: Border(
                      top: BorderSide(color: AppColors.glassBorder)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tag_rounded,
                          color: AppColors.textSecondary),
                      onPressed: _showTagDialog,
                      tooltip: 'Etiquetas',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _tags
                              .map((tag) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      label: Text(tag),
                                      onDeleted: () =>
                                          setState(() => _tags.remove(tag)),
                                      backgroundColor: AppColors.accent
                                          .withValues(alpha: 0.1),
                                      deleteIconColor: AppColors.accent,
                                      labelStyle: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 12),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTagDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text('Agregar etiqueta',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej. Ansiedad, Logro, Trabajo',
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty && !_tags.contains(val.trim())) {
              setState(() => _tags.add(val.trim()));
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black),
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty && !_tags.contains(val)) {
                setState(() => _tags.add(val));
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}