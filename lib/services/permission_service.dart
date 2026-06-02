class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<bool> requestPermissions() async {
    print('Requesting permissions...');
    return true;
  }

  Future<bool> requestCamera() async {
    print('Requesting camera permission...');
    return true;
  }

  Future<bool> requestStorage() async {
    print('Requesting storage permission...');
    return true;
  }

  Future<bool> requestNotification() async {
    print('Requesting notification permission...');
    return true;
  }
}