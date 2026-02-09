import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'telegram_service.dart';

import '../models/note.dart';

class DatabaseService {
  final String baseUrl;

  DatabaseService({required this.baseUrl});

  
  Future<void> addNote(Note note) async {
    final url = Uri.parse('$baseUrl/notes.json');
    final res = await http.post(url, body: jsonEncode(note.toMap()));
    if (res.statusCode != 200) {
      throw Exception('Failed to add note');
    } else {
      await sendTelegramNotification(note);
    }
  }

  Future<void> sendTelegramNotification(Note note) async {
    // Use the dynamic base URL from TelegramService
    final url = Uri.parse('${TelegramService.baseUrl}/notify'); 

    
    try {
      final prefs = await SharedPreferences.getInstance();
      final channelId = prefs.getString(TelegramService.keyConnectedChannelId);

      // Only send if a channel is connected
      if (channelId == null) {
        print("No Telegram channel connected. Skipping notification.");
        return;
      }

      await http.post(
        url,
        headers: TelegramService.headers,
        body: jsonEncode({
          'title': note.title,
          'content': note.content,
          'channel_id': channelId,
        }),
      );
      print("Notification sent to backend for channel $channelId");
    } catch (e) {
      print("Failed to send notification to backend: $e");
    }
  }


  Future<List<Note>> getNotes() async {
    final url = Uri.parse('$baseUrl/notes.json');
    final res = await http.get(url);
    if (res.statusCode == 200 && res.body != 'null') {
      Map<String, dynamic> data = jsonDecode(res.body);
      List<Note> notes = [];
      data.forEach((key, value) {
        notes.add(Note.fromMap(key, value));
      });
      return notes;
    }
    return [];
  }

  
  Future<void> deleteNote(String noteId) async {
    final url = Uri.parse('$baseUrl/notes/$noteId.json');
    await http.delete(url);
  }

  
  Future<void> updateNote(Note note) async {
    final url = Uri.parse('$baseUrl/notes/${note.id}.json');
    await http.put(url, body: jsonEncode(note.toMap()));
  }
}
