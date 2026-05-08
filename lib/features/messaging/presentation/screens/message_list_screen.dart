import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/message_bloc.dart';
import '../../domain/entities/message.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<MessageBloc>().add(const LoadInbox(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _showSendDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<MessageBloc, MessageState>(
        builder: (context, state) {
          if (state is MessageLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MessageError) {
            return Center(child: Text('خطأ: ${state.message}'));
          }
          if (state is MessagesLoaded) {
            final messages = state.messages;
            if (messages.isEmpty) {
              return const Center(child: Text('لا توجد رسائل'));
            }
            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (ctx, i) => _MessageCard(messages[i]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showSendDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إرسال رسالة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'المحتوى', border: OutlineInputBorder()),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              context.read<MessageBloc>().add(SendMessage(Message(
                title: titleCtrl.text,
                body: bodyCtrl.text,
                senderId: 1,
                sentAt: DateTime.now(),
              )));
              Navigator.pop(ctx);
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final Message message;
  const _MessageCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            message.priority == MessagePriority.urgent
                ? Icons.priority_high
                : Icons.message,
          ),
        ),
        title: Text(message.title, style: TextStyle(
          fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
        )),
        subtitle: Text(message.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: message.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          context.read<MessageBloc>().add(MarkMessageRead(message.id!));
        },
      ),
    );
  }
}
