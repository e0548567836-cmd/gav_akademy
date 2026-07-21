import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'is_avialable.dart';

class CoursePage extends StatefulWidget {
  final String courseName;
  final String courseId;
  final String currentStudentId;

  const CoursePage({
    super.key,
    required this.courseName,
    required this.courseId,
    required this.currentStudentId,
  });

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Future<List<dynamic>> fetchMaterials() async {
    final url = Uri.parse(
      '${ApiService.serverUrl}/Materials/GetMaterialsByCourse/${widget.courseId}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('שגיאה בטעינת נתונים');
      }
    } catch (e) {
      throw Exception('שגיאת תקשורת: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF001F4D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'קורס: ${widget.courseName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseAvailabilityPage(
                    userId: widget.currentStudentId,
                    courseId: widget.courseId,
                    courseName: widget.courseName,
                    ),
                    ),
                  );
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6A869),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "אני רוצה ללמוד",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                "חומרים",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001F4D),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchMaterials(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("שגיאה: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("אין עדיין חומרים בקורס זה."),
                    );
                  }

                  final materials = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final item = materials[index];
                      final String fileUrl = item['fileLink'];
                      final bool isPdf = (item['userFileName'] ?? '')
                          .toLowerCase()
                          .endsWith('.pdf');
                      final String uploaderId = item['uploaderStudentId']
                          .toString();
                      final String materialId = item['materialId'].toString();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () => _openFile(fileUrl),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: isPdf
                                          ? const Center(
                                              child: Icon(
                                                Icons.picture_as_pdf,
                                                size: 50,
                                                color: Colors.red,
                                              ),
                                            )
                                          : Image.network(
                                              _getThumbnailUrl(fileUrl),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.description,
                                                    size: 40,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      item['userFileName'] ?? 'חומר',
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.download_for_offline,
                                  size: 20,
                                  color: Color(0xFFC6A869),
                                ),
                                onPressed: () => _downloadFile(fileUrl),
                              ),
                            ),
                            if (uploaderId == widget.currentStudentId)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _confirmDelete(materialId),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: 300,
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.add, size: 28),
                  label: const Text("העלאת חומר לימוד"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6A869),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("מחיקת קובץ"),
          content: const Text("בטוח שברצונך למחוק את החומר שהעלית?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("ביטול"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("מחק", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      _deleteMaterial(id);
    }
  }

  Future<void> _deleteMaterial(String id) async {
    final url = Uri.parse(
      '${ApiService.serverUrl}/Materials/DeleteMaterial/$id',
    );
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("נמחק בהצלחה")));
        }
      }
    } catch (e) {
      debugPrint("שגיאה במחיקה: $e");
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );
    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.bytes != null) {
        await uploadFile(file.bytes!, file.name);
        setState(() {});
      }
    }
  }

  Future<void> uploadFile(Uint8List fileBytes, String fileName) async {
    var url = Uri.parse('${ApiService.serverUrl}/Materials/UploadNewMaterial');
    try {
      var request = http.MultipartRequest('POST', url);
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
      request.fields['courseId'] = widget.courseId;
      request.fields['studentId'] = widget.currentStudentId;

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("הועלה בהצלחה!")));
        }
      }
    } catch (e) {
      debugPrint("שגיאה בהעלאת קובץ: $e");
    }
  }

  Future<void> _openFile(String urlString) async {
    final Uri url = Uri.parse(urlString.trim());
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _downloadFile(String urlString) async {
    String downloadUrl = urlString.replaceFirst(
      '/upload/',
      '/upload/fl_attachment/',
    );
    final Uri url = Uri.parse(downloadUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _getThumbnailUrl(String originalUrl) {
    if (originalUrl.toLowerCase().contains('.pdf')) {
      String url = originalUrl.replaceFirst(
        '/raw/upload/',
        '/image/upload/w_400,h_400,c_fill,page_1/',
      );
      if (!url.contains('w_400')) {
        url = url.replaceFirst(
          '/upload/',
          '/upload/w_400,h_400,c_fill,page_1/',
        );
      }
      return '$url.jpg';
    }
    return originalUrl.replaceFirst('/upload/', '/upload/w_400,h_400,c_fill/');
  }
}
