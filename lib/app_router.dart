import 'package:flutter/material.dart';
import 'features/students/presentation/screens/student_list_screen.dart';
import 'features/circles/presentation/screens/circle_list_screen.dart';
import 'features/circles/presentation/screens/circle_detail_screen.dart';
import 'features/circles/domain/entities/circle.dart';
import 'features/messaging/presentation/screens/message_list_screen.dart';
import 'features/reports/presentation/screens/report_screen.dart';
import 'features/reports/presentation/screens/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/students':
        return MaterialPageRoute(builder: (_) => const StudentListScreen());
      case '/circles':
        return MaterialPageRoute(builder: (_) => const CircleListScreen());
      case '/circle_detail':
        final circle = routeSettings.arguments as Circle;
        return MaterialPageRoute(
          builder: (_) => CircleDetailScreen(circle: circle),
        );
      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessageListScreen());
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('الصفحة غير موجودة')),
          ),
        );
    }
  }
}
