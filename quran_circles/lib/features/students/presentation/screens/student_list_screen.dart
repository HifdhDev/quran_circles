import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../../domain/entities/student.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلاب'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن طالب...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) {
                context.read<StudentBloc>().add(SearchStudents(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                if (state is StudentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is StudentError) {
                  return Center(child: Text('خطأ: ${state.message}'));
                }
                if (state is StudentLoaded) {
                  final students = state.students;
                  if (students.isEmpty) {
                    return const Center(child: Text('لا يوجد طلاب'));
                  }
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (ctx, i) => _StudentCard(students[i]),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    var gender = Gender.male;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة طالب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'رقم الجوال', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Gender>(
              value: gender,
              items: Gender.values.map((g) => DropdownMenuItem(
                value: g,
                child: Text(g == Gender.male ? 'ذكر' : 'أنثى'),
              )).toList(),
              onChanged: (v) => gender = v!,
              decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              context.read<StudentBloc>().add(AddStudent(Student(
                name: nameCtrl.text,
                age: 0,
                gender: gender,
                phone: phoneCtrl.text,
                enrolledAt: DateTime.now(),
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

class _StudentCard extends StatelessWidget {
  final Student student;
  const _StudentCard(this.student);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            student.name.substring(0, 1),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(student.name),
        subtitle: Text(student.phone),
        trailing: student.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.red),
        onTap: () {
          Navigator.pushNamed(context, '/student_detail', arguments: student);
        },
      ),
    );
  }
}
