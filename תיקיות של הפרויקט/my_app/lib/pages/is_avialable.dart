import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants.dart';

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
  double _distanceKm = 10;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  List<dynamic> _availableStudents = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
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
      _distanceKm = (course?['maxDistanceKm'] as num?)?.toDouble() ?? 10;

      _addressController.text = course?['address']?.toString() ?? '';
      _latitudeController.text = course?['latitude']?.toString() ?? '';
      _longitudeController.text = course?['longitude']?.toString() ?? '';

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
      latitude: double.tryParse(_latitudeController.text.trim()),
      longitude: double.tryParse(_longitudeController.text.trim()),
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
  }) async {
    return await ApiService.updateAvailability(
      studentId: widget.userId,
      courseId: widget.courseId,
      isAvailable: isAvailable,
      isInPerson: isInPerson,
      wantsToTeach: wantsToTeach,
      address: isInPerson ? _addressController.text.trim() : null,
      maxDistanceKm: isInPerson ? _distanceKm : null,
      latitude: isInPerson
          ? double.tryParse(_latitudeController.text.trim())
          : null,
      longitude: isInPerson
          ? double.tryParse(_longitudeController.text.trim())
          : null,
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
    );

    if (!success) {
      setState(() {
        _isAvailable = !newValue;
      });
    }

    setState(() {
      _isSaving = false;
    });

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
    );

    if (!success) {
      setState(() {
        _isInPerson = !isInPerson;
      });
    }

    setState(() {
      _isSaving = false;
    });

    await _loadStudents();
  }

  Future<void> _changeTeachHelpType(bool wantsToTeach) async {
    setState(() {
      _isSaving = true;
      _wantsToTeach = wantsToTeach;
    });

    final success = await _saveAvailability(
      isAvailable: _isAvailable,
      isInPerson: _isInPerson,
      wantsToTeach: wantsToTeach,
    );

    if (!success) {
      setState(() {
        _wantsToTeach = !wantsToTeach;
      });
    }

    setState(() {
      _isSaving = false;
    });

    await _loadStudents();
  }

  Future<void> _saveAddressAndDistance() async {
    setState(() {
      _isSaving = true;
    });

    await _saveAvailability(
      isAvailable: _isAvailable,
      isInPerson: _isInPerson,
      wantsToTeach: _wantsToTeach,
    );

    setState(() {
      _isSaving = false;
    });

    await _loadStudents();
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
                                  _isAvailable
                                      ? 'זמין ללמידה'
                                      : 'לא זמין כרגע',
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
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('רוצה ללמוד'),
                                    value: false,
                                    groupValue: _wantsToTeach,
                                    onChanged: _isSaving
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              _changeTeachHelpType(value);
                                            }
                                          },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('רוצה ללמד'),
                                    value: true,
                                    groupValue: _wantsToTeach,
                                    onChanged: _isSaving
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              _changeTeachHelpType(value);
                                            }
                                          },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('זום'),
                                    value: false,
                                    groupValue: _isInPerson,
                                    onChanged: _isSaving
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              _changeLearningType(value);
                                            }
                                          },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('פרונטלי'),
                                    value: true,
                                    groupValue: _isInPerson,
                                    onChanged: _isSaving
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              _changeLearningType(value);
                                            }
                                          },
                                  ),
                                ),
                              ],
                            ),
                            if (_isInPerson) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  labelText: 'הכנס כתובת',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _latitudeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _longitudeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  border: OutlineInputBorder(),
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
                                        setState(() {
                                          _distanceKm = value;
                                        });
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

                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        student['studentName'] ??
                                            student['name'] ??
                                            'סטודנט ללא שם',
                                      ),
                                      subtitle: Text(
                                        student['studentEmail'] ??
                                            student['email'] ??
                                            '',
                                      ),
                                      trailing: Text(
                                        _isInPerson ? 'פרונטלי' : 'זום',
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