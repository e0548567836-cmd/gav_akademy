import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

/// A screen that displays the list of available chat conversations.
class ChatListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final bool isManagement;

  const ChatListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.isManagement,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  /// Loads the list of users the current user has chatted with.
  Future<void> _loadStudents() async {
    final data = await ApiService.getConversations(widget.currentUserId);
    if (!mounted) return;
    setState(() {
      _students = List<Map<String, dynamic>>.from(data)
          .where((s) => s['studentId']?.toString() != widget.currentUserId)
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F1F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A2540),
          title: const Text(
            'הצ\'אטים שלי',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _students.isEmpty
                ? const Center(child: Text('אין משתמשים זמינים לצאט'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final String partnerId = student['studentId']?.toString() ?? '';
                      final String partnerName = student['studentName']?.toString() ?? 'סטודנט';
                      final bool isAdmin = student['management'] == true;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  currentUserId: widget.currentUserId,
                                  chatPartnerId: partnerId,
                                  chatPartnerName: partnerName,
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: isAdmin
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF1F3C88),
                            child: Icon(
                              isAdmin ? Icons.admin_panel_settings : Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(partnerName),
                          subtitle: Text(student['studentEmail']?.toString() ?? ''),
                          trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1F3C88)),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
