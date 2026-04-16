import 'dart:convert';
import 'package:http/http.dart' as http;

class PreviewResponse {
  final bool success;
  final String message;
  final String? hairstyleId;
  final String? hairstyleName;
  final String? originalFilename;
  final String? savedInputPath;
  final String? previewImageUrl;

  PreviewResponse({
    required this.success,
    required this.message,
    this.hairstyleId,
    this.hairstyleName,
    this.originalFilename,
    this.savedInputPath,
    this.previewImageUrl,
  });

  factory PreviewResponse.fromJson(Map<String, dynamic> json) {
    return PreviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Sin mensaje',
      hairstyleId: json['hairstyle_id'],
      hairstyleName: json['hairstyle_name'],
      originalFilename: json['original_filename'],
      savedInputPath: json['saved_input_path'],
      previewImageUrl: json['preview_image_url'],
    );
  }
}

class ApiService {
  // Cambia esta IP por la IP local de tu PC
  // Ejemplo: http://192.168.1.20:8000
  static const String baseUrl = 'http://192.168.0.1:8000';
  static String buildFileUrl(String relativePath) {
  return '$baseUrl$relativePath';
}

  static Future<bool> checkHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    return response.statusCode == 200;
  }

  static Future<PreviewResponse> generatePreview({
    required String imagePath,
    required String hairstyleId,
    required String hairstyleName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/generate-preview'),
    );

    request.fields['hairstyle_id'] = hairstyleId;
    request.fields['hairstyle_name'] = hairstyleName;
    request.files.add(
      await http.MultipartFile.fromPath('file', imagePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return PreviewResponse.fromJson(data);
    } else {
      throw Exception(
        'Error ${response.statusCode}: ${response.body}',
      );
    }
  }
}
