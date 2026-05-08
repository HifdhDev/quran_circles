import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

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
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.trending_up,
            title: 'تقرير التقدم',
            subtitle: 'متابعة تقدم الحفظ',
            color: Colors.green,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.pie_chart,
            title: 'ملخص الحلقات',
            subtitle: 'إحصائيات عامة للحلقات',
            color: Colors.orange,
            onTap: () {},
          ),
        ],
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
