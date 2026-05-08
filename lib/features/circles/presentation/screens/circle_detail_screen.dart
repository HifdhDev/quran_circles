import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/circle_bloc.dart';
import '../../domain/entities/circle.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../../memorization/presentation/bloc/memorization_bloc.dart';
import '../../../memorization/domain/entities/memorization_record.dart';

class CircleDetailScreen extends StatelessWidget {
  final Circle circle;

  const CircleDetailScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    context.read<StudentBloc>().add(const LoadStudents());

    return Scaffold(
      appBar: AppBar(
        title: Text(circle.name),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تفاصيل الحلقة', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.person, label: 'المعلم', value: circle.teacherId.toString()),
                  if (circle.location != null)
                    _InfoRow(icon: Icons.location_on, label: 'الموقع', value: circle.location!),
                  if (circle.description != null)
                    _InfoRow(icon: Icons.description, label: 'الوصف', value: circle.description!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.checklist,
                  label: 'تسجيل الحضور',
                  onTap: () => _showAttendanceDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.book,
                  label: 'تسجيل الحفظ',
                  onTap: () => _showMemorizationDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('الطلاب', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          BlocBuilder<StudentBloc, StudentState>(
            builder: (context, state) {
              if (state is StudentLoaded) {
                return Column(
                  children: state.students
                      .map((s) => Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text(s.name.substring(0, 1))),
                              title: Text(s.name),
                              subtitle: Text(s.phone),
                            ),
                          ))
                      .toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        context.read<CircleBloc>().add(LoadAttendance(circle.id!, date));
      }
    });
  }

  void _showMemorizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل حفظ'),
        content: const Text('اختر الطالب وسجل ما حفظه'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
