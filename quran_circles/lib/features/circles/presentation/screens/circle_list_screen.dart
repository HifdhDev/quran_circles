import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/circle_bloc.dart';
import '../../domain/entities/circle.dart';

class CircleListScreen extends StatelessWidget {
  const CircleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CircleBloc>().add(const LoadCircles());

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحلقات'),
        centerTitle: true,
      ),
      body: BlocBuilder<CircleBloc, CircleState>(
        builder: (context, state) {
          if (state is CircleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CircleError) {
            return Center(child: Text('خطأ: ${state.message}'));
          }
          if (state is CirclesLoaded) {
            final circles = state.circles;
            if (circles.isEmpty) {
              return const Center(child: Text('لا توجد حلقات'));
            }
            return ListView.builder(
              itemCount: circles.length,
              itemBuilder: (ctx, i) => _CircleCard(circles[i]),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة حلقة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم الحلقة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              context.read<CircleBloc>().add(AddCircle(Circle(
                name: nameCtrl.text,
                teacherId: 1,
                description: descCtrl.text,
                createdAt: DateTime.now(),
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

class _CircleCard extends StatelessWidget {
  final Circle circle;
  const _CircleCard(this.circle);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.group, color: Colors.green[700]),
        ),
        title: Text(circle.name),
        subtitle: Text(circle.description ?? ''),
        trailing: circle.isActive
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : null,
        onTap: () {
          Navigator.pushNamed(context, '/circle_detail', arguments: circle);
        },
      ),
    );
  }
}
