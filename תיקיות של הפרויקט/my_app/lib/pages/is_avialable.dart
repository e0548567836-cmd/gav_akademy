import 'package:flutter/material.dart';
import '../helpers/location_helper.dart';
import '../services/api_service.dart';
import '../constants.dart';
import 'chat_screen.dart';

class CourseAvailabilityPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseName;

  const CourseAvailabilityPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseAvailabilityPage> createState() => _CourseAvailabilityPageState();
}

class _CourseAvailabilityPageState extends State<CourseAvailabilityPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isAvailable = false;

  bool _isInPerson = false;
  bool _wantsToTeach = false;
  bool _wantsPartner = false;
  double _distanceKm = 10;

  double? _latitude;
  double? _longitude;
  bool _locationSaved = false;

  List<dynamic> _availableStudents = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final myCourses = await ApiService.getMyCourses(widget.userId);

    final course = myCourses.cast<Map<String, dynamic>?>().firstWhere(
      (c) => c?['courseId'].toString() == widget.courseId,
      orElse: () => null,
    );

    setState(() {
      _isAvailable = course?['isAvailable'] == true;
      _isInPerson = course?['isInPerson'] == true;
      _wantsToTeach = course?['wantsToTeach'] == true;
      _wantsPartner = course?['wantsPartner'] == true;
      _distanceKm = (course?['maxDistanceKm'] as num?)?.toDouble() ?? 10;

      final lat = (course?['latitude'] as num?)?.toDouble();
      final lon = (course?['longitude'] as num?)?.toDouble();
      _latitude = lat;
      _longitude = lon;
      _locationSaved = lat != null && lon != null;

      _isLoading = false;
    });

    await _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await ApiService.getAvailableStudents(
      studentId: widget.userId,
      courseId: widget.courseId,
      isInPerson: _isInPerson,
      wantsToTeach: _wantsToTeach,
      wantsPartner: _wantsPartner,
      latitude: _latitude,
      longitude: _longitude,
      distanceKm: _isInPerson ? _distanceKm : null,
    );

    setState(() {
      _availableStudents = students;
    });
  }

  Future<bool> _saveAvailability({
    required bool isAvailable,
    required bool isInPerson,
    required bool wantsToTeach,
    required bool wantsPartner,
  }) async {
    return await ApiService.updateAvailability(
      studentId: widget.userId,
      courseId: widget.courseId,
      isAvailable: isAvailable,
      isInPerson: isInPerson,
      wantsToTeach: wantsToTeach,
      wantsPartner: wantsPartner,
      maxDistanceKm: isInPerson ? _distanceKm : null,
      latitude: isInPerson ? _latitude : null,
      longitude: isInPerson ? _longitude : null,
    );
  }

  Future<void> _toggleAvailability(bool newValue) async {
    setState(() {
      _isSaving = true;
      _isAvailable = newValue;
    });

    final success = await _saveAvailability(
      isAvailable: newValue,
      isInPerson: _isInPerson,
      wantsToTeach: _wantsToTeach,
      wantsPartner: _wantsPartner,
    );

    if (!success) {
      setState(() => _isAvailable = !newValue);
    }

    setState(() => _isSaving = false);
    await _loadStudents();
  }

  Future<void> _changeLearningType(bool isInPerson) async {
    setState(() {
      _isSaving = true;
      _isInPerson = isInPerson;
    });

    final success = await _saveAvailability(
      isAvailable: _isAvailable,
      isInPerson: isInPerson,
      wantsToTeach: _wantsToTeach,
      wantsPartner: _wantsPartner,
    );

    if (!success) {
      setState(() => _isInPerson = !isInPerson);
    }

    setState(() => _isSaving = false);
    await _loadStudents();
  }

  Future<void> _changeStudyMode(String mode) async {
    setState(() {
      _isSaving = true;

      if (mode == 'partner') {
        _wantsPartner = true;
        _wantsToTeach = false;
      } else if (mode == 'teach') {
        _wantsPartner = false;
        _wantsToTeach = true;
      } else {
        _wantsPartner = false;
        _wantsToTeach = false;
      }
    });

    final success = await _saveAvailability(
      isAvailable: _isAvailable,
      isInPerson: _isInPerson,
      wantsToTeach: _wantsToTeach,
      wantsPartner: _wantsPartner,
    );

    if (!success) {
      await _loadAvailability();
      return;
    }

    setState(() => _isSaving = false);
    await _loadStudents();
  }

  Future<void> _saveAddressAndDistance() async {
    setState(() => _isSaving = true);

    await _saveAvailability(
      isAvailable: _isAvailable,
      isInPerson: _isInPerson,
      wantsToTeach: _wantsToTeach,
      wantsPartner: _wantsPartner,
    );

    setState(() => _isSaving = false);
    await _loadStudents();
  }

  Future<void> _fetchAndSaveLocation() async {
    setState(() => _isSaving = true);

    final result = await fetchCurrentLocation();

    if (result.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error!)),
        );
      }
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _locationSaved = false;
    });

    await _saveAvailability(
      isAvailable: _isAvailable,
      isInPerson: _isInPerson,
      wantsToTeach: _wantsToTeach,
      wantsPartner: _wantsPartner,
    );

    if (mounted) {
      setState(() => _locationSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('המיקום נשמר בהצלחה!')),
      );
    }

    await _loadStudents();
    if (mounted) setState(() => _isSaving = false);
  }

  String get _studyMode {
    if (_wantsPartner) return 'partner';
    if (_wantsToTeach) return 'teach';
    return 'learn';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text('זמינות: ${widget.courseName}'),
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: kPrimaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isAvailable ? 'זמין ללמידה' : 'לא זמין כרגע',
                                  style: TextStyle(
                                    color: _isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Switch(
                                  value: _isAvailable,
                                  activeThumbColor: kPrimaryColor,
                                  onChanged:
                                      _isSaving ? null : _toggleAvailability,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            RadioGroup<String>(
                              groupValue: _studyMode,
                              onChanged: (v) {
                                if (!_isSaving && v != null) {
                                  _changeStudyMode(v);
                                }
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: const Text('רוצה ללמוד'),
                                          value: 'learn',
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: const Text('רוצה ללמד'),
                                          value: 'teach',
                                        ),
                                      ),
                                    ],
                                  ),
                                  RadioListTile<String>(
                                    title: const Text('מחפש שותף'),
                                    subtitle: const Text(
                                      'יוצגו סטודנטים בטווח של עד 10 נקודות מהממוצע שלך',
                                    ),
                                    value: 'partner',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            RadioGroup<bool>(
                              groupValue: _isInPerson,
                              onChanged: (v) {
                                if (!_isSaving && v != null) {
                                  _changeLearningType(v);
                                }
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('זום'),
                                      value: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<bool>(
                                      title: const Text('פרונטלי'),
                                      value: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isInPerson) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.my_location),
                                  label: Text(
                                    _locationSaved
                                        ? '✓ מיקום נשמר — לחץ לעדכון'
                                        : 'קבל מיקום נוכחי',
                                  ),
                                  onPressed:
                                      _isSaving ? null : _fetchAndSaveLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _locationSaved
                                        ? Colors.green
                                        : kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'מרחק מקסימלי: ${_distanceKm.round()} ק״מ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Slider(
                                value: _distanceKm,
                                min: 1,
                                max: 100,
                                divisions: 99,
                                label: '${_distanceKm.round()} ק״מ',
                                onChanged: _isSaving
                                    ? null
                                    : (value) {
                                        setState(() => _distanceKm = value);
                                      },
                                onChangeEnd: (_) => _saveAddressAndDistance(),
                              ),
                              ElevatedButton(
                                onPressed:
                                    _isSaving ? null : _saveAddressAndDistance,
                                child: const Text('שמור כתובת ומרחק'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 400,
                        child: _availableStudents.isEmpty
                            ? const Center(
                                child: Text('אין סטודנטים זמינים כרגע'),
                              )
                            : ListView.builder(
                                itemCount: _availableStudents.length,
                                itemBuilder: (context, index) {
                                  final student = _availableStudents[index];
                                  final studentName = student['studentName'] ??
                                      student['name'] ??
                                      'סטודנט ללא שם';

                                  return Card(
                                    child: ListTile(
                                      title: Text(studentName),
                                      subtitle: Text(
                                        student['studentEmail'] ??
                                            student['email'] ??
                                            '',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_isInPerson ? 'פרונטלי' : 'זום'),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.chat_bubble_outline,
                                              color: Color(0xFF1F3C88),
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                    currentUserId:
                                                        widget.userId,
                                                    chatPartnerId:
                                                        student['studentId']
                                                                ?.toString() ??
                                                            '',
                                                    chatPartnerName:
                                                        studentName,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}