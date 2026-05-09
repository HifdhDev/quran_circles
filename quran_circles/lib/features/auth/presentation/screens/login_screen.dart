import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/network/network_utils.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final authRepo = context.read<AuthRepository>();
    final user = await authRepo.getCurrentUser();
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _DashboardWrapper()),
      );
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'حلقات القرآن',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'نظام إدارة حلقات التحفيظ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textInputAction: _isRegistering ? TextInputAction.next : TextInputAction.done,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: _isRegistering ? 'الاسم الكامل' : 'اسم المستخدم',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isRegistering ? _register : _login,
                    child: Text(_isRegistering ? 'تسجيل جديد' : 'دخول', style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = !_isRegistering),
                  child: Text(_isRegistering ? 'لدي حساب بالفعل' : 'ليس لدي حساب؟ تسجيل جديد'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final phone = _phoneCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (phone.isEmpty || name.isEmpty) return;

    final deviceId = (await NetworkUtils.getLocalIp()) ?? 'unknown';
    final authRepo = context.read<AuthRepository>();
    final user = await authRepo.login(phone, deviceId);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _DashboardWrapper()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المستخدم غير موجود. يرجى التسجيل أولاً.')),
      );
    }
  }

  Future<void> _register() async {
    final phone = _phoneCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (phone.isEmpty || name.isEmpty) return;

    final deviceId = (await NetworkUtils.getLocalIp()) ?? 'unknown';
    final authRepo = context.read<AuthRepository>();
    await authRepo.register(name, phone, UserRole.teacher, deviceId);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _DashboardWrapper()),
      );
    }
  }
}

class _DashboardWrapper extends StatelessWidget {
  const _DashboardWrapper();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: DashboardScreen(),
    );
  }
}
