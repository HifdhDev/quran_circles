import 'dart:io';
import 'package:flutter/material.dart';

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
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تصدير النسخة الاحتياطية')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('استيراد نسخة احتياطية'),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('تصدير QR Code'),
                  subtitle: const Text('لمشاركة البيانات مع جهاز آخر'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('حول التطبيق'),
              subtitle: const Text('نظام إدارة حلقات تحفيظ القرآن v1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
