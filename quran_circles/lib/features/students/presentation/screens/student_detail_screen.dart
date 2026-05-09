import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../../domain/entities/student.dart';
import '../../../memorization/presentation/bloc/memorization_bloc.dart';
import '../../../memorization/domain/entities/memorization_record.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    context.read<MemorizationBloc>().add(LoadStudentMemorization(student.id!));
    context.read<MemorizationBloc>().add(LoadMemorizationProgress(student.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(student: student),
          const SizedBox(height: 16),
          Text('تقدم الحفظ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          BlocBuilder<MemorizationBloc, MemorizationState>(
            builder: (context, state) {
              if (state is MemorizationProgressLoaded) {
                final s = state.summary;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _ProgressStat(label: 'آيات', value: '${s['totalAyahs']}'),
                        _ProgressStat(label: 'سور', value: '${s['totalSurahs']}'),
                        _ProgressStat(label: 'أجزاء', value: '${s['totalJuz']}'),
                        _ProgressStat(label: 'جلسات', value: '${s['totalSessions']}'),
                      ],
                    ),
                  ),
                );
              }
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('لا توجد بيانات حفظ بعد')),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('سجل الحفظ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          BlocBuilder<MemorizationBloc, MemorizationState>(
            builder: (context, state) {
              if (state is MemorizationLoaded) {
                final records = state.records;
                if (records.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('لا توجد تسجيلات حفظ')),
                    ),
                  );
                }
                return Column(
                  children: records.reversed.map((r) => _RecordCard(record: r)).toList(),
                );
              }
              if (state is MemorizationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: student.name);
    final phoneCtrl = TextEditingController(text: student.phone);
    final guardianCtrl = TextEditingController(text: student.guardianName ?? '');
    final notesCtrl = TextEditingController(text: student.notes ?? '');
    var gender = student.gender;
    var isActive = student.isActive;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل بيانات الطالب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'رقم الجوال', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              TextField(controller: guardianCtrl, decoration: const InputDecoration(labelText: 'ولي الأمر', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'ملاحظات', border: OutlineInputBorder()), maxLines: 3),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                value: gender,
                items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g == Gender.male ? 'ذكر' : 'أنثى'))).toList(),
                onChanged: (v) => gender = v!,
                decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SwitchListTile(title: const Text('نشط'), value: isActive, onChanged: (v) => isActive = v),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              context.read<StudentBloc>().add(UpdateStudent(student.copyWith(
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                gender: gender,
                guardianName: guardianCtrl.text.isEmpty ? null : guardianCtrl.text,
                notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                isActive: isActive,
              )));
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Student student;
  const _InfoCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(student.name.substring(0, 1),
                style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text(student.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(student.phone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Chip(student.gender == Gender.male ? 'ذكر' : 'أنثى'),
              const SizedBox(width: 8),
              _Chip(student.isActive ? 'نشط' : 'غير نشط'),
              if (student.guardianName != null) ...[const SizedBox(width: 8), _Chip('ولي: ${student.guardianName}')],
            ]),
            if (student.notes != null && student.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('ملاحظات: ${student.notes}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  const _ProgressStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MemorizationRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('${record.surahNumber}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        title: Text('سورة ${record.surahNumber}'),
        subtitle: Text('الآيات ${record.startAyah}-${record.endAyah} | ${record.type}'),
        trailing: Text(
          '${record.recordedAt.day}/${record.recordedAt.month}/${record.recordedAt.year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
