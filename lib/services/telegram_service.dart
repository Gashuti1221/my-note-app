import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class TelegramService {
  static const String keyAppInstanceId = 'telegram_app_instance_id';
  static const String keyConnectedChannelId = 'telegram_connected_channel_id';
  static const String keyConnectedChannelName = 'telegram_connected_channel_name';


  // Base URL for your backend
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Public tunnel URL for cellular data (Serveo)
      return 'https://116063f262ff052c-213-55-102-49.serveousercontent.com';
    } else {
      return 'http://localhost:3000'; // iOS/Desktop
    }
  }

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Bypass-Tunnel-Reminder': 'true',
      };

  Future<String> getAppInstanceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(keyAppInstanceId);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(keyAppInstanceId, id);
    }
    return id;
  }

  Future<Map<String, dynamic>> verifyChannel(String channelUsername) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-telegram'),
        headers: headers,
        body: jsonEncode({'channel_username': channelUsername}),
      ).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Server returned empty response. Check backend connection.'};
      }

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          return {
            'success': true,
            'channel_id': data['channel_id'],
            'channel_name': data['channel_name'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Verification failed (Status: ${response.statusCode})',
          };
        }
      } on FormatException {
         // This catches "Unexpected end of input" and other JSON errors
         final bodyPreview = response.body.length > 50 ? response.body.substring(0, 50) : response.body;
         return {
           'success': false, 
           'error': 'Invalid server response. expected JSON, got: "$bodyPreview..."'
         };
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: ${e.toString().replaceAll("Exception:", "").trim()}'};
    }
  }

  Future<void> saveConnection(String channelId, String channelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyConnectedChannelId, channelId);
    await prefs.setString(keyConnectedChannelName, channelName);
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyConnectedChannelId);
    await prefs.remove(keyConnectedChannelName);
  }

  Future<Map<String, String?>> getConnectionDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'channelId': prefs.getString(keyConnectedChannelId),
      'channelName': prefs.getString(keyConnectedChannelName),
    };
  }
}
