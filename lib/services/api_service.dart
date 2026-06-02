import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Primary API endpoint
  static const String primaryUrl = 'https://api.wellcarepharmacy.com/v1';
  
  // Alternative backup backend (non-Firebase)
  static const String backupUrl = 'https://backup-api.wellcarepharmacy.com/v1';

  Future<Map<String, dynamic>> fetchExchangeRates() async {
    print('🌐 Fetching exchange rates from API...');
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'base': 'USD', 'rates': {'AFN': 71.50, 'PKR': 278.50}};
    } catch (e) {
      return {'base': 'USD', 'rates': {'AFN': 71.50, 'PKR': 278.50}};
    }
  }

  Future<bool> syncData(Map<String, dynamic> data) async {
    print('🔄 Syncing data to primary API: $data');
    bool success = await _callApi(primaryUrl, data);
    
    // If primary fails, try backup (Alternative Backend)
    if (!success) {
      print('⚠️ Primary API failed, trying backup...');
      success = await _callApi(backupUrl, data);
    }
    return success;
  }

  Future<bool> _callApi(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$url/sync'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}