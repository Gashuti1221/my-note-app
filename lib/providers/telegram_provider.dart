import 'package:flutter/foundation.dart';
import '../services/telegram_service.dart';

class TelegramProvider extends ChangeNotifier {
  final TelegramService _service = TelegramService();
  
  String? _appInstanceId;
  String? _connectedChannelName;
  bool _isLoading = false;
  String? _error;

  String? get appInstanceId => _appInstanceId;
  String? get connectedChannelName => _connectedChannelName;
  bool get isConnected => _connectedChannelName != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TelegramProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _appInstanceId = await _service.getAppInstanceId();
      final details = await _service.getConnectionDetails();
      _connectedChannelName = details['channelName'];
    } catch (e) {
      print('Error initializing TelegramProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> connectChannel(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.verifyChannel(username);
      
      if (result['success'] == true) {
        final channelId = result['channel_id'];
        final channelName = result['channel_name'];
        await _service.saveConnection(channelId, channelName);
        _connectedChannelName = channelName;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    _connectedChannelName = null;
    notifyListeners();
  }
}
