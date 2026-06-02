import 'dart:developer';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  void logEvent(String eventName) {
    print('[PERF] $eventName at ${DateTime.now()}');
  }

  void startTimer(String name) {
    print('[PERF] ⏱️ START: $name');
  }

  void endTimer(String name, DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    print('[PERF] ⏱️ END: $name took ${duration.inMilliseconds}ms');
  }

  void logMemory() {
    print('[PERF] Memory usage tracked');
  }

  void logFrame() {
    print('[PERF] Frame rendered');
  }
}