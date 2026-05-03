import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:my_app/widgets/custom_text_field.dart';
import '../widgets/page_padding.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String userName;
  const EditProfilePage({super.key, required this.userId, this.userName = ''});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;

  String _originalName = '';
  String _originalEmail = '';
  String _originalPhone = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    try {
      final data = await ApiService.getStudent(widget.userId);
      if (!mounted) return;
      if (data != null) {
        _originalName = data['studentName'] ?? '';
        _originalEmail = data['studentEmail'] ?? '';
        _originalPhone = data['studentPhone'] ?? '';

        _nameController.text = _originalName;
        _emailController.text = _originalEmail;
        _phoneController.text = _originalPhone;
      }
    } catch (e) {
      _nameController.text = widget.userName;
      _originalName = widget.userName;
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('שם לא יכול להיות ריק')));
      return;
    }

    final Map<String, dynamic> dataToUpdate = {};

    if (_nameController.text.trim() != _originalName) {
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty) {
        dataToUpdate['studentName'] = newName;
      }
    }
    if (_emailController.text.trim() != _originalEmail) {
      final newEmail = _emailController.text.trim();
      if (newEmail.isNotEmpty) {
        dataToUpdate['studentEmail'] = newEmail;
      }
    }
    if (_phoneController.text.trim() != _originalPhone) {
      final newPhone = _phoneController.text.trim();
      if (newPhone.isNotEmpty) {
        dataToUpdate['studentPhone'] = newPhone;
      }
    }

    if (dataToUpdate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('לא בוצעו שינויים')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updateStudent(
        widget.userId,
        dataToUpdate,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('עודכן בהצלחה!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, _nameController.text.trim());
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בעדכון'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אין חיבור לשרת'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: _isFetching
            ? const Center(child: CircularProgressIndicator())
            : PagePadding(
                child: Column(
                  children: [
                    GreetingHeader(
                      title: 'עריכת פרופיל',
                      userName: widget.userName,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _nameController,
                      hint: 'ישראל ישראלי',
                      label: 'שם מלא',
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _emailController,
                      hint: 'example@college.ac.il',
                      label: 'מייל אקדמי',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _phoneController,
                      hint: '050-0000000',
                      label: 'טלפון',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('שמור שינויים'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
