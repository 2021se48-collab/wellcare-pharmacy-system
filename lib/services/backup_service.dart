import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  Future<Map<String, dynamic>> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Collect all data
    final backupData = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'data': {
        'settings': {
          'darkMode': prefs.getBool('darkMode') ?? false,
          'languageCode': prefs.getString('languageCode') ?? 'en',
        },
      },
    };
    
    return backupData;
  }

  Future<void> backupToFile() async {
    final data = await exportData();
    final jsonString = json.encode(data);
    
    print('Backup data: $jsonString');
    // In a real app, save to file or cloud
  }

  Future<void> restoreFromBackup(String backupJson) async {
    try {
      final data = json.decode(backupJson);
      final prefs = await SharedPreferences.getInstance();
      
      if (data['data']['settings'] != null) {
        final settings = data['data']['settings'];
        if (settings['darkMode'] != null) {
          await prefs.setBool('darkMode', settings['darkMode']);
        }
        if (settings['languageCode'] != null) {
          await prefs.setString('languageCode', settings['languageCode']);
        }
      }
      
      print('Restore completed');
    } catch (e) {
      print('Restore failed: $e');
    }
  }
}