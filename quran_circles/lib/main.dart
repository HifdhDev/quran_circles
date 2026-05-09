import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/students/presentation/bloc/student_bloc.dart';
import 'features/students/data/repositories/student_repository.dart';
import 'features/circles/presentation/bloc/circle_bloc.dart';
import 'features/circles/data/repositories/circle_repository.dart';
import 'features/memorization/presentation/bloc/memorization_bloc.dart';
import 'features/memorization/data/repositories/memorization_repository.dart';
import 'features/messaging/presentation/bloc/message_bloc.dart';
import 'features/messaging/data/repositories/message_repository.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'core/database/database_service.dart';
import 'core/logging/quran_logger.dart';
import 'l10n/app_localizations.dart';
import 'app_router.dart';

final DatabaseService databaseService = DatabaseService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await databaseService.database;
  QuranLogger.instance.init(Directory.systemTemp);
  runApp(const QuranCirclesApp());
}

class QuranCirclesApp extends StatelessWidget {
  const QuranCirclesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      databaseService: databaseService,
      child: MaterialApp(
        title: 'حلقات القرآن',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.generateRoute,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1B5E20),
          brightness: Brightness.light,
          fontFamily: 'Cairo',
        ),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: LoginScreen(),
        ),
      ),
    );
  }
}

class AppProviders extends StatelessWidget {
  final DatabaseService databaseService;
  final Widget child;

  const AppProviders({
    super.key,
    required this.databaseService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DatabaseService>(create: (_) => databaseService),
        RepositoryProvider(create: (_) => AuthRepository(databaseService)),
        RepositoryProvider(create: (_) => StudentRepository(databaseService)),
        RepositoryProvider(create: (_) => CircleRepository(databaseService)),
        RepositoryProvider(create: (_) => MemorizationRepository(databaseService)),
        RepositoryProvider(create: (_) => MessageRepository(databaseService)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => StudentBloc(ctx.read<StudentRepository>())),
          BlocProvider(create: (ctx) => CircleBloc(ctx.read<CircleRepository>())),
          BlocProvider(create: (ctx) => MemorizationBloc(ctx.read<MemorizationRepository>())),
          BlocProvider(create: (ctx) => MessageBloc(ctx.read<MessageRepository>())),
        ],
        child: child,
      ),
    );
  }
}
