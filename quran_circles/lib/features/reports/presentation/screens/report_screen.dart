import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../circles/presentation/bloc/circle_bloc.dart';
import '../../../circles/domain/entities/circle.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../../memorization/data/repositories/memorization_repository.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CircleBloc>().add(const LoadCircles());
    context.read<StudentBloc>().add(const LoadStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportCard(
            icon: Icons.calendar_today,
            title: 'تقرير الحضور',
            subtitle: 'عرض تقارير حضور الطلاب',
            color: Colors.blue,
            onTap: () => _showAttendanceReport(context),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.trending_up,
            title: 'تقرير التقدم',
            subtitle: 'متابعة تقدم الحفظ',
            color: Colors.green,
            onTap: () => _showProgressReport(context),
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.pie_chart,
            title: 'ملخص الحلقات',
            subtitle: 'إحصائيات عامة للحلقات',
            color: Colors.orange,
            onTap: () => _showCircleSummary(context),
          ),
        ],
      ),
    );
  }

  void _showAttendanceReport(BuildContext context) {
    final repo = context.read<CircleBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: repo,
          child: const _AttendanceReportScreen(),
        ),
      ),
    );
  }

  void _showProgressReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _ProgressReportScreen()),
    );
  }

  void _showCircleSummary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _CircleSummaryScreen()),
    );
  }
}

class _AttendanceReportScreen extends StatelessWidget {
  const _AttendanceReportScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير الحضور'), centerTitle: true),
      body: BlocBuilder<CircleBloc, CircleState>(
        builder: (context, state) {
          if (state is CirclesLoaded) {
            final circles = state.circles;
            if (circles.isEmpty) {
              return const Center(child: Text('لا توجد حلقات'));
            }
            return ListView.builder(
              itemCount: circles.length,
              itemBuilder: (ctx, i) => _CircleAttendanceCard(circle: circles[i]),
            );
          }
          if (state is CircleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          context.read<CircleBloc>().add(const LoadCircles());
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _CircleAttendanceCard extends StatelessWidget {
  final Circle circle;
  const _CircleAttendanceCard({required this.circle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        title: Text(circle.name),
        subtitle: Text('اضغط لعرض تفاصيل الحضور'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                if (state is! StudentLoaded) {
                  context.read<StudentBloc>().add(const LoadStudents());
                  return const CircularProgressIndicator();
                }
                final students = state.students;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عدد الطلاب: ${students.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('اختر التاريخ لعرض الحضور لكل طالب'),
                    const SizedBox(height: 8),
                    ...students.map((s) => ListTile(
                      dense: true,
                      leading: CircleAvatar(child: Text(s.name.substring(0, 1))),
                      title: Text(s.name),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressReportScreen extends StatefulWidget {
  const _ProgressReportScreen();

  @override
  State<_ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<_ProgressReportScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير التقدم'), centerTitle: true),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is! StudentLoaded) {
            context.read<StudentBloc>().add(const LoadStudents());
            return const Center(child: CircularProgressIndicator());
          }
          final students = state.students;
          if (students.isEmpty) {
            return const Center(child: Text('لا يوجد طلاب'));
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (ctx, i) {
              final student = students[i];
              return FutureBuilder<Map<String, int>>(
                future: context.read<MemorizationRepository>().getProgressSummary(student.id!),
                builder: (ctx, snap) {
                  final data = snap.data ?? {};
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(student.name.substring(0, 1))),
                      title: Text(student.name),
                      subtitle: Text('آيات: ${data['totalAyahs'] ?? 0} | سور: ${data['totalSurahs'] ?? 0} | أجزاء: ${data['totalJuz'] ?? 0}'),
                      trailing: Text('جلسات: ${data['totalSessions'] ?? 0}'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CircleSummaryScreen extends StatelessWidget {
  const _CircleSummaryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملخص الحلقات'), centerTitle: true),
      body: BlocBuilder<CircleBloc, CircleState>(
        builder: (context, state) {
          if (state is CirclesLoaded) {
            final circles = state.circles;
            if (circles.isEmpty) {
              return const Center(child: Text('لا توجد حلقات'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(
                  title: 'إجمالي الحلقات',
                  value: '${circles.length}',
                  icon: Icons.group,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _SummaryCard(
                  title: 'الحلقات النشطة',
                  value: '${circles.where((c) => c.isActive).length}',
                  icon: Icons.check_circle,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                ...circles.map((c) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(c.name.substring(0, 1))),
                    title: Text(c.name),
                    subtitle: Text(c.isActive ? 'نشطة' : 'غير نشطة'),
                    trailing: Icon(c.isActive ? Icons.check_circle : Icons.cancel,
                      color: c.isActive ? Colors.green : Colors.red),
                  ),
                )),
              ],
            );
          }
          if (state is CircleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          context.read<CircleBloc>().add(const LoadCircles());
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(icon, color: color)),
            const SizedBox(width: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(icon, color: color)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
