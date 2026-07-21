import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/signalr_service.dart';
import '../services/api_service.dart';

/// A screen that displays a real-time chat with another user.
class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatPartnerId;
  final String chatPartnerName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.chatPartnerId,
    required this.chatPartnerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SignalRService _signalRService = SignalRService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoadingHistory = true;

  String get _hubUrl => kIsWeb
      ? 'http://localhost:5022/chathub'
      : 'http://10.0.2.2:5022/chathub';

  @override
  void initState() {
    super.initState();
    _signalRService.initHubConnection(_hubUrl, (senderId, receiverId, messageText, timestamp) {
      if ((senderId == widget.currentUserId && receiverId == widget.chatPartnerId) ||
          (senderId == widget.chatPartnerId && receiverId == widget.currentUserId)) {
        setState(() {
          _messages.add({'senderId': senderId, 'text': messageText});
        });
        _scrollToBottom();
      }
    });
    _signalRService.startConnection();
    _loadHistory();
  }

  /// Loads the previous chat messages between the current user and the chat partner.
  Future<void> _loadHistory() async {
    final history = await ApiService.getChatHistory(widget.currentUserId, widget.chatPartnerId);
    if (!mounted) return;
    setState(() {
      _messages.addAll(history.map<Map<String, String>>((m) => {
        'senderId': m['senderId']?.toString() ?? '',
        'text': m['messageText']?.toString() ?? '',
      }));
      _isLoadingHistory = false;
    });
    _scrollToBottom();
  }

  /// Scrolls the message list to the latest message.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _signalRService.stopConnection();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A2540),
          title: Text(widget.chatPartnerName, style: const TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message['senderId'] == widget.currentUserId;
                  return Align(
                    alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFFF6B35) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'] ?? '',
                        style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFFF6B35)),
                    onPressed: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        _signalRService.sendMessage(
                          widget.currentUserId,
                          widget.chatPartnerId,
                          _messageController.text,
                        );
                        _messageController.clear();
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(hintText: 'הקלד הודעה...'),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _signalRService.sendMessage(
                            widget.currentUserId,
                            widget.chatPartnerId,
                            text,
                          );
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
