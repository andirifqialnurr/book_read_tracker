import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

Future<void> showGoalEditorDialog({
  required BuildContext context,
  required int current,
  required ValueChanged<int> onChanged,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => GoalEditorDialog(
      current: current,
      onCancel: () => Navigator.pop(dialogContext),
      onSave: (goal) {
        onChanged(goal);
        Navigator.pop(dialogContext);
      },
    ),
  );
}

class GoalEditorDialog extends StatefulWidget {
  const GoalEditorDialog({
    required this.current,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final int current;
  final VoidCallback onCancel;
  final ValueChanged<int> onSave;

  @override
  State<GoalEditorDialog> createState() => _GoalEditorDialogState();
}

class _GoalEditorDialogState extends State<GoalEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.current}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final goal = (int.tryParse(_controller.text) ?? widget.current)
        .clamp(1, 999)
        .toInt();
    widget.onSave(goal);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Annual goal', style: AppTextStyles.editorial(context, 22)),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Books to finish in 2026'),
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
