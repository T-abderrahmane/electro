import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class ChatScreen extends StatefulWidget {
  final String requestId;

  const ChatScreen({super.key, required this.requestId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    unawaited(provider.refreshMessagesForRequest(widget.requestId));
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      unawaited(context.read<AppProvider>().refreshMessagesForRequest(widget.requestId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await context.read<AppProvider>().sendMessage(
      requestId: widget.requestId,
      message: text,
    );

    _messageController.clear();
    _scrollToBottom();
    unawaited(context.read<AppProvider>().refreshMessagesForRequest(widget.requestId));
  }

  Future<void> _sendImage() async {
    final l10n = AppLocalizer.of(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await context.read<AppProvider>().sendMessage(
        requestId: widget.requestId,
        message: l10n.tr('صورة', 'Image'),
        imageUrl: image.path,
      );
      _scrollToBottom();
      unawaited(context.read<AppProvider>().refreshMessagesForRequest(widget.requestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final l10n = AppLocalizer.of(context);
    final messages = provider.getMessagesForRequest(widget.requestId);
    final currentUser = provider.currentUser;
    final request = provider.allRequests.firstWhere(
      (r) => r.id == widget.requestId,
    );

    // Get the other party's name
    String otherPartyName;
    if (currentUser?.role == UserRole.client) {
      otherPartyName =
          request.assignedElectricianName ??
          l10n.tr('الكهربائي', 'Electricien');
    } else {
      otherPartyName = request.clientName;
    }

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(otherPartyName, style: const TextStyle(fontSize: 16)),
            Text(
              request.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showRequestInfo(context, request),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child:
                messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: AppColors.inactive,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.tr(
                              'ابدأ المحادثة',
                              'Demarrer la conversation',
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            l10n.tr(
                              'أرسل رسالة للتواصل',
                              'Envoyez un message pour communiquer',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUser?.id;
                        final showDate =
                            index == 0 ||
                            !_isSameDay(
                              messages[index - 1].createdAt,
                              message.createdAt,
                            );

                        return Column(
                          children: [
                            if (showDate)
                              _DateSeparator(date: message.createdAt),
                            _MessageBubble(message: message, isMe: isMe),
                          ],
                        );
                      },
                    ),
          ),
          // Message Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 12 : 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo, color: AppColors.secondary),
                    onPressed: _sendImage,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: l10n.tr(
                            'اكتب رسالتك...',
                            'Ecrivez votre message...',
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          unawaited(_sendMessage());
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        unawaited(_sendMessage());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showRequestInfo(BuildContext context, ServiceRequest request) {
    final l10n = AppLocalizer.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('تفاصيل الطلب', 'Details de la demande'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: l10n.tr('العنوان', 'Titre'),
                  value: request.title,
                ),
                _InfoRow(
                  label: l10n.tr('الموقع', 'Localisation'),
                  value: l10n.location(request.wilaya, request.commune),
                ),
                _InfoRow(
                  label: l10n.tr('الحالة', 'Statut'),
                  value: _getStatusText(context, request.status),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  String _getStatusText(BuildContext context, RequestStatus status) {
    final l10n = AppLocalizer.of(context);
    switch (status) {
      case RequestStatus.open:
        return l10n.tr('مفتوح', 'Ouverte');
      case RequestStatus.assigned:
        return l10n.tr('قيد التنفيذ', 'En cours');
      case RequestStatus.closed:
        return l10n.tr('مغلق', 'Fermee');
    }
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);
    final now = DateTime.now();
    String dateText;

    if (_isSameDay(date, now)) {
      dateText = l10n.tr('اليوم', 'Aujourd hui');
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      dateText = l10n.tr('أمس', 'Hier');
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 0 : 60,
          right: isMe ? 60 : 0,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null) ...[
              Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    message.imageUrl!.startsWith('/')
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(message.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        )
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message.message ?? '',
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color:
                        message.isRead
                            ? Colors.lightBlueAccent
                            : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
