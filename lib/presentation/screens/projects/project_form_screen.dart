import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/project.dart';
import '../../cubits/projects/project_list_cubit.dart';

class ProjectFormScreen extends StatefulWidget {
  final String orgId;
  final Project? project;

  const ProjectFormScreen({
    super.key,
    required this.orgId,
    this.project,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  String _status = 'active';

  bool get isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name ?? '');
    _descController = TextEditingController(text: widget.project?.description ?? '');
    _status = widget.project?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (isEditing) {
        final updated = widget.project!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _status,
        );
        context.read<ProjectListCubit>().updateProject(updated);
      } else {
        final newProj = Project(
          id: '',
          orgId: widget.orgId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          status: _status,
        );
        context.read<ProjectListCubit>().createProject(newProj);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'New Project'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g. Website Relaunch',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                  validator: (v) => Validators.requiredField(v, 'Project name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Briefly describe the project goals...',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (v) => Validators.requiredField(v, 'Description'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'archived', child: Text('Archived')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Save Changes' : 'Create Project'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
