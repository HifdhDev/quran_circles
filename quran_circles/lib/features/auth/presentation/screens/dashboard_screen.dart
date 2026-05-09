import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => _showSyncDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _DashboardCard(
            icon: Icons.group,
            label: 'الحلقات',
            color: Colors.green,
            onTap: () => Navigator.pushNamed(context, '/circles'),
          ),
          _DashboardCard(
            icon: Icons.people,
            label: 'الطلاب',
            color: Colors.blue,
            onTap: () => Navigator.pushNamed(context, '/students'),
          ),
          _DashboardCard(
            icon: Icons.book,
            label: 'الحفظ',
            color: Colors.orange,
            onTap: () => Navigator.pushNamed(context, '/memorization'),
          ),
          _DashboardCard(
            icon: Icons.assessment,
            label: 'التقارير',
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
          _DashboardCard(
            icon: Icons.message,
            label: 'الرسائل',
            color: Colors.teal,
            onTap: () => Navigator.pushNamed(context, '/messages'),
          ),
          _DashboardCard(
            icon: Icons.settings,
            label: 'الإعدادات',
            color: Colors.grey,
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حالة المزامنة'),
        content: const Text('جميع الأجهزة متزامنة'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل خروج'),
        content: const Text('هل تريد تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              context.read<AuthRepository>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Directionality(
                  textDirection: TextDirection.rtl,
                  child: LoginScreen(),
                )),
                (_) => false,
              );
            },
            child: const Text('تسجيل خروج'),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
