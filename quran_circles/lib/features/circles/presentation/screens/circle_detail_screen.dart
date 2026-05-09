import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/circle_bloc.dart';
import '../../domain/entities/circle.dart';
import '../../domain/entities/attendance.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../../memorization/presentation/screens/memorization_screen.dart';

class CircleDetailScreen extends StatelessWidget {
  final Circle circle;

  const CircleDetailScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    context.read<StudentBloc>().add(const LoadStudents());

    return Scaffold(
      appBar: AppBar(
        title: Text(circle.name),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تفاصيل الحلقة', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.person, label: 'المعلم', value: circle.teacherId.toString()),
                  if (circle.location != null)
                    _InfoRow(icon: Icons.location_on, label: 'الموقع', value: circle.location!),
                  if (circle.description != null)
                    _InfoRow(icon: Icons.description, label: 'الوصف', value: circle.description!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.checklist,
                  label: 'تسجيل الحضور',
                  onTap: () => _showAttendanceDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.book,
                  label: 'تسجيل الحفظ',
                  onTap: () => _showMemorizationScreen(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('الطلاب', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          BlocBuilder<StudentBloc, StudentState>(
            builder: (context, state) {
              if (state is StudentLoaded) {
                return Column(
                  children: state.students
                      .map((s) => Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text(s.name.substring(0, 1))),
                              title: Text(s.name),
                              subtitle: Text(s.phone),
                              onTap: () {
                                Navigator.pushNamed(context, '/student_detail', arguments: s);
                              },
                            ),
                          ))
                      .toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _AttendanceScreen(circleId: circle.id!, date: date, circleName: circle.name),
          ),
        );
      }
    });
  }

  void _showMemorizationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemorizationScreen(circleId: circle.id),
      ),
    );
  }
}

class _AttendanceScreen extends StatefulWidget {
  final int circleId;
  final DateTime date;
  final String circleName;

  const _AttendanceScreen({required this.circleId, required this.date, required this.circleName});

  @override
  State<_AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<_AttendanceScreen> {
  final Map<int, AttendanceStatus> _attendanceMap = {};
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    context.read<CircleBloc>().add(LoadAttendance(widget.circleId, widget.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الحضور - ${widget.circleName}'),
        centerTitle: true,
      ),
      body: BlocBuilder<CircleBloc, CircleState>(
        builder: (context, state) {
          if (state is AttendanceLoaded) {
            return _buildAttendanceList(context, state);
          }
          if (state is CircleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildAttendanceList(context, null);
        },
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context, AttendanceLoaded? state) {
    final existingAttendance = state?.attendance ?? <Attendance>[];
    for (final a in existingAttendance) {
      _attendanceMap.putIfAbsent(a.studentId, () => a.status);
    }

    return Column(
      children: [
        Expanded(
          child: BlocBuilder<StudentBloc, StudentState>(
            builder: (context, sState) {
              if (sState is! StudentLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              final students = sState.students;
              if (students.isEmpty) {
                return const Center(child: Text('لا يوجد طلاب في هذه الحلقة'));
              }
              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (ctx, i) {
                  final student = students[i];
                  final status = _attendanceMap[student.id!] ?? AttendanceStatus.present;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    child: ListTile(
                      title: Text(student.name),
                      trailing: SegmentedButton<AttendanceStatus>(
                        segments: const [
                          ButtonSegment(value: AttendanceStatus.present, label: Text('حاضر'), icon: Icon(Icons.check_circle, size: 16)),
                          ButtonSegment(value: AttendanceStatus.absent, label: Text('غائب'), icon: Icon(Icons.cancel, size: 16)),
                          ButtonSegment(value: AttendanceStatus.late, label: Text('متأخر'), icon: Icon(Icons.access_time, size: 16)),
                          ButtonSegment(value: AttendanceStatus.excused, label: Text('معذور'), icon: Icon(Icons.medical_services, size: 16)),
                        ],
                        selected: {status},
                        onSelectionChanged: (v) {
                          setState(() => _attendanceMap[student.id!] = v.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (!_saved)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('حفظ الحضور', style: TextStyle(fontSize: 16)),
                onPressed: _saveAttendance,
              ),
            ),
          ),
        if (_saved)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('تم حفظ الحضور', style: TextStyle(color: Colors.green, fontSize: 16)),
          ),
      ],
    );
  }

  void _saveAttendance() {
    for (final entry in _attendanceMap.entries) {
      context.read<CircleBloc>().add(RecordAttendanceEvent(
        Attendance(
          studentId: entry.key,
          circleId: widget.circleId,
          date: widget.date,
          status: entry.value,
        ),
      ));
    }
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الحضور بنجاح')),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
