class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  static Future<void> init() async {
    print('Background Service Initialized');
  }

  static void startStockCheck() {
    print('Stock check background task started');
  }

  static void startDailyReport() {
    print('Daily report background task started');
  }

  static void stopAll() {
    print('All background tasks stopped');
  }
}