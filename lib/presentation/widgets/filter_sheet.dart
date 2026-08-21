import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';

class FilterSheet extends StatefulWidget {
  final TaskStatus? initialStatus;
  final TaskPriority? initialPriority;
  final String? initialAssignee;
  final List<User> orgMembers;
  final Function(TaskStatus?, TaskPriority?, String?) onApply;
  final VoidCallback onClear;

  const FilterSheet({
    super.key,
    this.initialStatus,
    this.initialPriority,
    this.initialAssignee,
    required this.orgMembers,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;
  String? _selectedAssignee;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedPriority = widget.initialPriority;
    _selectedAssignee = widget.initialAssignee;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskStatus.values.map((s) {
                  final isSelected = _selectedStatus == s;
                  return ChoiceChip(
                    label: Text(s.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = selected ? s : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((p) {
                  final isSelected = _selectedPriority == p;
                  return ChoiceChip(
                    label: Text(p.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedPriority = selected ? p : null);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Assignee', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Unassigned'),
                    selected: _selectedAssignee == 'unassigned',
                    onSelected: (selected) {
                      setState(() => _selectedAssignee = selected ? 'unassigned' : null);
                    },
                  ),
                  ...widget.orgMembers.map((m) {
                    final isSelected = _selectedAssignee == m.id;
                    return ChoiceChip(
                      label: Text(m.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedAssignee = selected ? m.id : null);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    widget.onApply(_selectedStatus, _selectedPriority, _selectedAssignee);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
