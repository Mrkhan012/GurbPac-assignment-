import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/projects/project_list_cubit.dart';
import '../../cubits/projects/project_list_state.dart';
import '../../cubits/tasks/task_list_cubit.dart';
import '../../cubits/tasks/task_list_state.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskItem? task;
  final String? projectId;
  final String? orgId;

  const TaskFormScreen({
    super.key,
    this.task,
    this.projectId,
    this.orgId,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String? _selectedProjectId;
  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedAssigneeId;
  DateTime? _dueDate;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _selectedProjectId = t?.projectId ?? widget.projectId;
    _status = t?.status ?? TaskStatus.todo;
    _priority = t?.priority ?? TaskPriority.medium;
    _selectedAssigneeId = t?.assigneeId;
    _dueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProjectId == null || _selectedProjectId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a project for this task')),
        );
        return;
      }

      if (isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          projectId: _selectedProjectId!,
          status: _status,
          priority: _priority,
          assigneeId: _selectedAssigneeId,
          clearAssignee: _selectedAssigneeId == null,
          dueDate: _dueDate,
        );
        context.read<TaskListCubit>().createTask(updated);
      } else {
        final newTask = TaskItem(
          id: '',
          projectId: _selectedProjectId!,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          status: _status,
          priority: _priority,
          assigneeId: _selectedAssigneeId,
          dueDate: _dueDate,
        );
        context.read<TaskListCubit>().createTask(newTask);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final orgId = (authState is Authenticated) ? (authState.user.orgId ?? 'org_a1b2c3') : 'org_a1b2c3';

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'New Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Task Title', prefixIcon: Icon(Icons.title_rounded)),
                  validator: (v) => Validators.requiredField(v, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_rounded)),
                ),
                const SizedBox(height: 16),
                _buildProjectDropdown(orgId),
                const SizedBox(height: 16),
                _buildAssigneeDropdown(),
                const SizedBox(height: 16),
                _buildPriorityAndStatusSelectors(),
                const SizedBox(height: 16),
                _buildDueDatePicker(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Changes' : 'Create Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDropdown(String orgId) {
    return BlocBuilder<ProjectListCubit, ProjectListState>(
      builder: (context, state) {
        List<Project> projects = [];
        if (state is ProjectListSuccess) {
          projects = state.projects;
          if (_selectedProjectId == null && projects.isNotEmpty) {
            _selectedProjectId = projects.first.id;
          }
        }
        return DropdownButtonFormField<String>(
          initialValue: _selectedProjectId,
          decoration: const InputDecoration(labelText: 'Project', prefixIcon: Icon(Icons.folder_outlined)),
          items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
          onChanged: (val) => setState(() => _selectedProjectId = val),
          validator: (v) => v == null ? 'Project is required' : null,
        );
      },
    );
  }

  Widget _buildAssigneeDropdown() {
    return BlocBuilder<TaskListCubit, TaskListState>(
      builder: (context, state) {
        List<User> members = [];
        if (state is TaskListSuccess) members = state.orgMembers;

        return DropdownButtonFormField<String?>(
          initialValue: _selectedAssigneeId,
          decoration: const InputDecoration(labelText: 'Assignee', prefixIcon: Icon(Icons.person_outline)),
          items: [
            const DropdownMenuItem(value: null, child: Text('Unassigned')),
            ...members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
          ],
          onChanged: (val) => setState(() => _selectedAssigneeId = val),
        );
      },
    );
  }

  Widget _buildPriorityAndStatusSelectors() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
            onChanged: (val) => setState(() => _priority = val ?? TaskPriority.medium),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<TaskStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
            onChanged: (val) => setState(() => _status = val ?? TaskStatus.todo),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) setState(() => _dueDate = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          _dueDate != null ? DateFormatter.formatFull(_dueDate) : 'Select a due date',
          style: TextStyle(color: _dueDate != null ? null : Colors.grey),
        ),
      ),
    );
  }
}
