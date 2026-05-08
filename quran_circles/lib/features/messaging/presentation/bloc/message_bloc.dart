import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/message_repository.dart';
import '../../domain/entities/message.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();
  @override
  List<Object?> get props => [];
}

class LoadInbox extends MessageEvent {
  final int userId;
  const LoadInbox(this.userId);
}

class LoadSentMessages extends MessageEvent {
  final int userId;
  const LoadSentMessages(this.userId);
}

class SendMessage extends MessageEvent {
  final Message message;
  const SendMessage(this.message);
}

class MarkMessageRead extends MessageEvent {
  final int messageId;
  const MarkMessageRead(this.messageId);
}

class DeleteMessage extends MessageEvent {
  final int id;
  const DeleteMessage(this.id);
}

sealed class MessageState extends Equatable {
  const MessageState();
  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessagesLoaded extends MessageState {
  final List<Message> messages;
  const MessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class MessageSent extends MessageState {
  final String message;
  const MessageSent(this.message);
  @override
  List<Object?> get props => [message];
}

class MessageError extends MessageState {
  final String message;
  const MessageError(this.message);
  @override
  List<Object?> get props => [message];
}

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _repository;

  MessageBloc(this._repository) : super(const MessageInitial()) {
    on<LoadInbox>(_onLoadInbox);
    on<LoadSentMessages>(_onLoadSentMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessageRead>(_onMarkMessageRead);
    on<DeleteMessage>(_onDeleteMessage);
  }

  Future<void> _onLoadInbox(
      LoadInbox event, Emitter<MessageState> emit) async {
    emit(const MessageLoading());
    try {
      final messages = await _repository.getInbox(event.userId);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessageError('فشل تحميل الرسائل: $e'));
    }
  }

  Future<void> _onLoadSentMessages(
      LoadSentMessages event, Emitter<MessageState> emit) async {
    emit(const MessageLoading());
    try {
      final messages = await _repository.getSent(event.userId);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(MessageError('فشل تحميل الرسائل المرسلة: $e'));
    }
  }

  Future<void> _onSendMessage(
      SendMessage event, Emitter<MessageState> emit) async {
    try {
      await _repository.send(event.message);
      emit(const MessageSent('تم إرسال الرسالة'));
    } catch (e) {
      emit(MessageError('فشل إرسال الرسالة: $e'));
    }
  }

  Future<void> _onMarkMessageRead(
      MarkMessageRead event, Emitter<MessageState> emit) async {
    try {
      await _repository.markAsRead(event.messageId);
    } catch (_) {}
  }

  Future<void> _onDeleteMessage(
      DeleteMessage event, Emitter<MessageState> emit) async {
    try {
      await _repository.delete(event.id);
      emit(const MessageSent('تم حذف الرسالة'));
    } catch (e) {
      emit(MessageError('فشل حذف الرسالة: $e'));
    }
  }
}
