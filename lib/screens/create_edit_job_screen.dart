import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_jobs/models/job_post.dart';
import 'package:quick_jobs/providers/auth_provider.dart';
import 'package:quick_jobs/providers/job_provider.dart';

class CreateEditJobScreen extends StatefulWidget {
  final JobPost? jobToEdit;

  const CreateEditJobScreen({super.key, this.jobToEdit});

  @override
  State<CreateEditJobScreen> createState() => _CreateEditJobScreenState();
}

class _CreateEditJobScreenState extends State<CreateEditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _creditsController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      _titleController.text = widget.jobToEdit!.title;
      _descriptionController.text = widget.jobToEdit!.description;
      _requirementsController.text = widget.jobToEdit!.requirements ?? '';
      _creditsController.text = widget.jobToEdit!.credits?.toString() ?? '';
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    final jobPost = JobPost(
      id: widget.jobToEdit?.id ?? '',
      professorId: authProvider.user!.id,
      title: _titleController.text,
      description: _descriptionController.text,
      status: widget.jobToEdit?.status ?? 'open',
      createdAt: widget.jobToEdit?.createdAt ?? DateTime.now(),
      requirements: _requirementsController.text.isEmpty
          ? null
          : _requirementsController.text,
      credits: double.tryParse(_creditsController.text),
    );

    try {
      print(
        '[JOB] saving job: title=${jobPost.title}, professorId=${jobPost.professorId}',
      );
      if (widget.jobToEdit == null) {
        await jobProvider.createJobPost(jobPost);
        print('[JOB] job created successfully');
      } else {
        await jobProvider.updateJobPost(widget.jobToEdit!.id, {
          'title': jobPost.title,
          'description': jobPost.description,
          'requirements': jobPost.requirements,
          'credits': jobPost.credits,
        });
        print('[JOB] job updated successfully');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job saved successfully!')));
      Navigator.pop(context);
    } catch (e) {
      print('[JOB] ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobToEdit == null ? 'Create Job' : 'Edit Job'),
        backgroundColor: const Color(0xFF2B2EC7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requirementsController,
                decoration: const InputDecoration(
                  labelText: 'Requirements (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditsController,
                decoration: const InputDecoration(
                  labelText: 'Credits (optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveJob,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.jobToEdit == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _creditsController.dispose();
    super.dispose();
  }
}
