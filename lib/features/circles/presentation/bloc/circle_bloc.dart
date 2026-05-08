import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/circle_repository.dart';
import '../../domain/entities/circle.dart';
import '../../domain/entities/attendance.dart';

sealed class CircleEvent extends Equatable {
  const CircleEvent();
  @override
  List<Object?> get props => [];
}

class LoadCircles extends CircleEvent {
  final bool? activeOnly;
  const LoadCircles({this.activeOnly});
}

class AddCircle extends CircleEvent {
  final Circle circle;
  const AddCircle(this.circle);
}

class UpdateCircle extends CircleEvent {
  final Circle circle;
  const UpdateCircle(this.circle);
}

class DeleteCircle extends CircleEvent {
  final int id;
  const DeleteCircle(this.id);
}

class RecordAttendanceEvent extends CircleEvent {
  final Attendance attendance;
  const RecordAttendanceEvent(this.attendance);
}

class LoadAttendance extends CircleEvent {
  final int circleId;
  final DateTime date;
  const LoadAttendance(this.circleId, this.date);
}

sealed class CircleState extends Equatable {
  const CircleState();
  @override
  List<Object?> get props => [];
}

class CircleInitial extends CircleState {}

class CircleLoading extends CircleState {}

class CirclesLoaded extends CircleState {
  final List<Circle> circles;
  const CirclesLoaded(this.circles);
  @override
  List<Object?> get props => [circles];
}

class AttendanceLoaded extends CircleState {
  final List<Attendance> attendance;
  const AttendanceLoaded(this.attendance);
  @override
  List<Object?> get props => [attendance];
}

class CircleError extends CircleState {
  final String message;
  const CircleError(this.message);
  @override
  List<Object?> get props => [message];
}

class CircleOperationSuccess extends CircleState {
  final String message;
  const CircleOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final CircleRepository _repository;

  CircleBloc(this._repository) : super(const CircleInitial()) {
    on<LoadCircles>(_onLoadCircles);
    on<AddCircle>(_onAddCircle);
    on<UpdateCircle>(_onUpdateCircle);
    on<DeleteCircle>(_onDeleteCircle);
    on<RecordAttendanceEvent>(_onRecordAttendance);
    on<LoadAttendance>(_onLoadAttendance);
  }

  Future<void> _onLoadCircles(
      LoadCircles event, Emitter<CircleState> emit) async {
    emit(const CircleLoading());
    try {
      final circles = await _repository.getAll(activeOnly: event.activeOnly);
      emit(CirclesLoaded(circles));
    } catch (e) {
      emit(CircleError('فشل تحميل الحلقات: $e'));
    }
  }

  Future<void> _onAddCircle(
      AddCircle event, Emitter<CircleState> emit) async {
    emit(const CircleLoading());
    try {
      await _repository.add(event.circle);
      emit(const CircleOperationSuccess('تم إنشاء الحلقة بنجاح'));
      final circles = await _repository.getAll();
      emit(CirclesLoaded(circles));
    } catch (e) {
      emit(CircleError('فشل إنشاء الحلقة: $e'));
    }
  }

  Future<void> _onUpdateCircle(
      UpdateCircle event, Emitter<CircleState> emit) async {
    emit(const CircleLoading());
    try {
      await _repository.update(event.circle);
      emit(const CircleOperationSuccess('تم تحديث الحلقة بنجاح'));
      final circles = await _repository.getAll();
      emit(CirclesLoaded(circles));
    } catch (e) {
      emit(CircleError('فشل تحديث الحلقة: $e'));
    }
  }

  Future<void> _onDeleteCircle(
      DeleteCircle event, Emitter<CircleState> emit) async {
    emit(const CircleLoading());
    try {
      await _repository.delete(event.id);
      emit(const CircleOperationSuccess('تم حذف الحلقة بنجاح'));
      final circles = await _repository.getAll();
      emit(CirclesLoaded(circles));
    } catch (e) {
      emit(CircleError('فشل حذف الحلقة: $e'));
    }
  }

  Future<void> _onRecordAttendance(
      RecordAttendanceEvent event, Emitter<CircleState> emit) async {
    try {
      await _repository.recordAttendance(event.attendance);
      emit(const CircleOperationSuccess('تم تسجيل الحضور'));
    } catch (e) {
      emit(CircleError('فشل تسجيل الحضور: $e'));
    }
  }

  Future<void> _onLoadAttendance(
      LoadAttendance event, Emitter<CircleState> emit) async {
    emit(const CircleLoading());
    try {
      final attendance =
          await _repository.getAttendance(event.circleId, event.date);
      emit(AttendanceLoaded(attendance));
    } catch (e) {
      emit(CircleError('فشل تحميل الحضور: $e'));
    }
  }
}
