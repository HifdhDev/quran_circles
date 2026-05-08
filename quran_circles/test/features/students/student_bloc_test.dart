import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_circles/features/students/presentation/bloc/student_bloc.dart';
import 'package:quran_circles/features/students/data/repositories/student_repository.dart';
import 'package:quran_circles/features/students/domain/entities/student.dart';
import 'package:sembast/sembast_io.dart';
import 'package:quran_circles/core/database/database_service.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

void main() {
  late StudentBloc bloc;

  setUp(() {
    bloc = StudentBloc(MockStudentRepository());
  });

  tearDown(() {
    bloc.close();
  });

  group('StudentBloc', () {
    test('initial state is StudentInitial', () {
      expect(bloc.state, const StudentInitial());
    });

    blocTest<StudentBloc, StudentState>(
      'emits [Loading, Loaded] when LoadStudents succeeds',
      build: () {
        final mock = MockStudentRepository();
        when(() => mock.getAll).thenAnswer((_) async => []);
        return StudentBloc(mock);
      },
      act: (bloc) => bloc.add(const LoadStudents()),
      expect: () => [const StudentLoading(), const StudentLoaded([])],
    );
  });
}
