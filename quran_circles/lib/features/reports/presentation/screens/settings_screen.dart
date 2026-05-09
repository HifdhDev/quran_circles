import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/sync/transports/file_transport.dart';
import '../../../../core/sync/transports/qr_transport.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('المزامنة التلقائية'),
                  subtitle: const Text('مزامنة تلقائية عند اكتشاف أجهزة'),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.wifi),
                  title: const Text('المزامنة عبر WiFi'),
                  subtitle: const Text('ممكّنة'),
                  trailing: const Icon(Icons.check, color: Colors.green),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: const Text('المزامنة عبر Bluetooth'),
                  subtitle: const Text('ممكّنة'),
                  trailing: const Icon(Icons.check, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('تصدير نسخة احتياطية'),
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('استيراد نسخة احتياطية'),
                  onTap: () => _importBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('تصدير QR Code'),
                  subtitle: const Text('لمشاركة البيانات مع جهاز آخر'),
                  onTap: () => _exportQr(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('المستخدم الحالي'),
                  subtitle: FutureBuilder(
                    future: context.read<AuthRepository>().getCurrentUser(),
                    builder: (ctx, snap) {
                      final user = snap.data;
                      if (user == null) return const Text('غير مسجل');
                      return Text('${user.name} (${user.phone})');
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('حول التطبيق'),
                  subtitle: const Text('نظام إدارة حلقات تحفيظ القرآن v1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final dbService = context.read<DatabaseService>();
    final transport = FileTransport();
    try {
      final db = await dbService.database;
      final allData = <String, dynamic>{};
      final storeNames = ['students', 'circles', 'attendance', 'memorization', 'messages', 'syncRecords', 'users'];
      for (final name in storeNames) {
        final store = intMapStoreFactory.store(name);
        final records = await store.find(db);
        allData[name] = records.map((r) => {'key': r.key, 'value': r.value}).toList();
      }
      await transport.exportToFile(Directory.systemTemp, allData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تصدير النسخة الاحتياطية بنجاح')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التصدير: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final dbService = context.read<DatabaseService>();
    final transport = FileTransport();
    try {
      final data = await transport.importFromFile('${Directory.systemTemp.path}/quran_circles_backup.json');
      if (data == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا توجد نسخة احتياطية')),
          );
        }
        return;
      }
      final db = await dbService.database;
      for (final entry in data.entries) {
        final store = intMapStoreFactory.store(entry.key);
        if (entry.value is List) {
          for (final record in entry.value as List) {
            await store.add(db, record['value'] as Map<String, dynamic>);
          }
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استيراد النسخة الاحتياطية بنجاح')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الاستيراد: $e')),
        );
      }
    }
  }

  Future<void> _exportQr(BuildContext context) async {
    final dbService = context.read<DatabaseService>();
    final transport = QRTransport();
    try {
      final db = await dbService.database;
      final records = await intMapStoreFactory.store('circles').find(db, finder: Finder(limit: 5));
      final data = records.map((r) => r.value).toList();
      final json = transport.exportAsJson(data);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('بيانات QR'),
            content: SingleChildScrollView(
              child: SelectableText(json.length > 500 ? '${json.substring(0, 500)}...' : json),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تصدير QR: $e')),
        );
      }
    }
  }
}
