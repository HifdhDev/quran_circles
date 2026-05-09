import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/memorization_bloc.dart';
import '../../domain/entities/memorization_record.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../../../core/surah/surah_data.dart';

class MemorizationScreen extends StatefulWidget {
  final int? circleId;
  final int? teacherId;

  const MemorizationScreen({super.key, this.circleId, this.teacherId});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  int? _selectedSurah;
  int _startAyah = 1;
  int _endAyah = 1;
  String _type = 'new';
  Student? _selectedStudent;

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(const LoadStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الحفظ'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('اختر الطالب', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          BlocBuilder<StudentBloc, StudentState>(
            builder: (context, state) {
              if (state is StudentLoaded) {
                return DropdownButtonFormField<Student>(
                  value: _selectedStudent,
                  items: state.students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (v) {
                    setState(() => _selectedStudent = v);
                    if (v != null) {
                      context.read<MemorizationBloc>().add(LoadStudentMemorization(v.id!));
                    }
                  },
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اختر طالباً...'),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 20),
          Text('السورة', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildSurahPicker(),
          if (_selectedSurah != null) ...[
            const SizedBox(height: 20),
            Text('الآيات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildAyahPicker('من', _startAyah, (v) => setState(() => _startAyah = v))),
                const SizedBox(width: 12),
                Expanded(child: _buildAyahPicker('إلى', _endAyah, (v) => setState(() => _endAyah = v))),
              ],
            ),
            const SizedBox(height: 20),
            Text('النوع', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'new', label: Text('حفظ جديد')),
                ButtonSegment(value: 'revision', label: Text('مراجعة')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 20),
            Text('الجزء: ${SurahData.getJuz(_selectedSurah!)}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('حفظ التسجيل', style: TextStyle(fontSize: 16)),
                onPressed: _selectedStudent == null ? null : _saveRecord,
              ),
            ),
          ],
          const SizedBox(height: 32),
          Text('سجل الحفظ', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          BlocBuilder<MemorizationBloc, MemorizationState>(
            builder: (context, state) {
              if (state is MemorizationLoaded) {
                final records = state.records;
                if (records.isEmpty) {
                  return const Card(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('لا توجد تسجيلات حفظ')),
                  ));
                }
                return Column(
                  children: records.reversed.take(50).map((r) => _RecordCard(record: r)).toList(),
                );
              }
              if (state is MemorizationProgressLoaded) {
                final s = state.summary;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _StatItem(label: 'آيات', value: '${s['totalAyahs']}'),
                        _StatItem(label: 'سور', value: '${s['totalSurahs']}'),
                        _StatItem(label: 'أجزاء', value: '${s['totalJuz']}'),
                        _StatItem(label: 'جلسات', value: '${s['totalSessions']}'),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurahPicker() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.5,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 114,
        itemBuilder: (ctx, i) {
          final surah = SurahData.surahs[i];
          final selected = _selectedSurah == surah.number;
          return FilledButton.tonal(
            onPressed: () => setState(() {
              _selectedSurah = surah.number;
              _endAyah = surah.ayahCount;
            }),
            style: selected ? FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ) : null,
            child: Text('${surah.number}\n${surah.name}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          );
        },
      ),
    );
  }

  Widget _buildAyahPicker(String label, int value, ValueChanged<int> onChanged) {
    final maxAyah = _selectedSurah != null ? SurahData.getAyahCount(_selectedSurah!) : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          value: value,
          items: List.generate(maxAyah, (i) => i + 1).map((a) => DropdownMenuItem(value: a, child: Text('$a'))).toList(),
          onChanged: (v) => onChanged(v!),
          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
        ),
      ],
    );
  }

  void _saveRecord() {
    if (_selectedStudent == null || _selectedSurah == null) return;
    context.read<MemorizationBloc>().add(AddMemorizationRecord(MemorizationRecord(
      studentId: _selectedStudent!.id!,
      circleId: widget.circleId ?? 1,
      surahNumber: _selectedSurah!,
      startAyah: _startAyah,
      endAyah: _endAyah,
      juzNumber: SurahData.getJuz(_selectedSurah!),
      type: _type,
      recordedAt: DateTime.now(),
      teacherId: widget.teacherId ?? 1,
    )));
    context.read<MemorizationBloc>().add(LoadStudentMemorization(_selectedStudent!.id!));
    context.read<MemorizationBloc>().add(LoadMemorizationProgress(_selectedStudent!.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل الحفظ بنجاح')),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MemorizationRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('${record.surahNumber}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
        ),
        title: Text('سورة ${record.surahNumber} (${record.startAyah}-${record.endAyah})', style: const TextStyle(fontSize: 14)),
        subtitle: Text('${record.type == "new" ? "حفظ جديد" : "مراجعة"} | ${record.recordedAt.day}/${record.recordedAt.month}/${record.recordedAt.year}', style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
