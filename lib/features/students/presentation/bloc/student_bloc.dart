import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/student_repository.dart';
import '../../domain/entities/student.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentEvent {
  final bool? activeOnly;
  const LoadStudents({this.activeOnly});
  @override
  List<Object?> get props => [activeOnly];
}

class AddStudent extends StudentEvent {
  final Student student;
  const AddStudent(this.student);
}

class UpdateStudent extends StudentEvent {
  final Student student;
  const UpdateStudent(this.student);
}

class DeleteStudent extends StudentEvent {
  final int id;
  const DeleteStudent(this.id);
}

class SearchStudents extends StudentEvent {
  final String query;
  const SearchStudents(this.query);
}

sealed class StudentState extends Equatable {
  const StudentState();
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students;
  const StudentLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

class StudentError extends StudentState {
  final String message;
  const StudentError(this.message);
  @override
  List<Object?> get props => [message];
}

class StudentOperationSuccess extends StudentState {
  final String message;
  const StudentOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository _repository;

  StudentBloc(this._repository) : super(const StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<SearchStudents>(_onSearchStudents);
  }

  Future<void> _onLoadStudents(
      LoadStudents event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      final students = await _repository.getAll(activeOnly: event.activeOnly);
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError('فشل تحميل الطلاب: $e'));
    }
  }

  Future<void> _onAddStudent(
      AddStudent event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      await _repository.add(event.student);
      emit(const StudentOperationSuccess('تم إضافة الطالب بنجاح'));
      final students = await _repository.getAll();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError('فشل إضافة الطالب: $e'));
    }
  }

  Future<void> _onUpdateStudent(
      UpdateStudent event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      await _repository.update(event.student);
      emit(const StudentOperationSuccess('تم تحديث الطالب بنجاح'));
      final students = await _repository.getAll();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError('فشل تحديث الطالب: $e'));
    }
  }

  Future<void> _onDeleteStudent(
      DeleteStudent event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      await _repository.delete(event.id);
      emit(const StudentOperationSuccess('تم حذف الطالب بنجاح'));
      final students = await _repository.getAll();
      emit(StudentLoaded(students));
    } catch (e) {
      emit(StudentError('فشل حذف الطالب: $e'));
    }
  }

  Future<void> _onSearchStudents(
      SearchStudents event, Emitter<StudentState> emit) async {
    emit(const StudentLoading());
    try {
      if (event.query.isEmpty) {
        final students = await _repository.getAll();
        emit(StudentLoaded(students));
      } else {
        final students = await _repository.search(event.query);
        emit(StudentLoaded(students));
      }
    } catch (e) {
      emit(StudentError('فشل البحث: $e'));
    }
  }
}
