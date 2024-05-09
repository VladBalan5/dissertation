import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';

abstract class ChatEvent {}

class LoadMessages extends ChatEvent {
  final String chatId;
  LoadMessages(this.chatId);
}

class SendMessage extends ChatEvent {
  final String chatId;
  final Message message;
  SendMessage(this.chatId, this.message);
}

abstract class ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirestoreService _firestoreService;

  ChatBloc(this._firestoreService) : super(ChatLoading()) {
    on<LoadMessages>((event, emit) async {
      try {
        await for (var messages in _firestoreService.getMessages(event.chatId)) {
          emit(ChatLoaded(messages));
        }
      } catch (_) {
        emit(ChatError());
      }
    });

    on<SendMessage>((event, emit) async {
      await _firestoreService.sendMessage(event.chatId, event.message);
    });
  }
}
