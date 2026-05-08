import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/memorization_repository.dart';
import '../../domain/entities/memorization_record.dart';

sealed class MemorizationEvent extends Equatable {
  const MemorizationEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudentMemorization extends MemorizationEvent {
  final int studentId;
  const LoadStudentMemorization(this.studentId);
}

class AddMemorizationRecord extends MemorizationEvent {
  final MemorizationRecord record;
  const AddMemorizationRecord(this.record);
}

class LoadMemorizationProgress extends MemorizationEvent {
  final int studentId;
  const LoadMemorizationProgress(this.studentId);
}

sealed class MemorizationState extends Equatable {
  const MemorizationState();
  @override
  List<Object?> get props => [];
}

class MemorizationInitial extends MemorizationState {
  const MemorizationInitial();
}

class MemorizationLoading extends MemorizationState {
  const MemorizationLoading();
}

class MemorizationLoaded extends MemorizationState {
  final List<MemorizationRecord> records;
  const MemorizationLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

class MemorizationProgressLoaded extends MemorizationState {
  final Map<String, int> summary;
  const MemorizationProgressLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class MemorizationError extends MemorizationState {
  final String message;
  const MemorizationError(this.message);
  @override
  List<Object?> get props => [message];
}

class MemorizationBloc extends Bloc<MemorizationEvent, MemorizationState> {
  final MemorizationRepository _repository;

  MemorizationBloc(this._repository) : super(const MemorizationInitial()) {
    on<LoadStudentMemorization>(_onLoadStudentMemorization);
    on<AddMemorizationRecord>(_onAddMemorizationRecord);
    on<LoadMemorizationProgress>(_onLoadMemorizationProgress);
  }

  Future<void> _onLoadStudentMemorization(
      LoadStudentMemorization event, Emitter<MemorizationState> emit) async {
    emit(const MemorizationLoading());
    try {
      final records = await _repository.getByStudent(event.studentId);
      emit(MemorizationLoaded(records));
    } catch (e) {
      emit(MemorizationError('فشل تحميل سجل الحفظ: $e'));
    }
  }

  Future<void> _onAddMemorizationRecord(
      AddMemorizationRecord event, Emitter<MemorizationState> emit) async {
    emit(const MemorizationLoading());
    try {
      await _repository.add(event.record);
      emit(const MemorizationLoaded([]));
    } catch (e) {
      emit(MemorizationError('فشل إضافة记录 الحفظ: $e'));
    }
  }

  Future<void> _onLoadMemorizationProgress(
      LoadMemorizationProgress event, Emitter<MemorizationState> emit) async {
    emit(const MemorizationLoading());
    try {
      final summary = await _repository.getProgressSummary(event.studentId);
      emit(MemorizationProgressLoaded(summary));
    } catch (e) {
      emit(MemorizationError('فشل تحميل ملخص التقدم: $e'));
    }
  }
}
