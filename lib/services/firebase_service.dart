import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'encryption_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late FirebaseAuth _auth;
  late DatabaseReference _database;
  late EncryptionService _encryption;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _database = FirebaseDatabase.instance.ref();
    _encryption = EncryptionService();
    _encryption.init();
  }

  FirebaseAuth get auth => _auth;
  DatabaseReference get database => _database;
  EncryptionService get encryption => _encryption;

  // Authentication
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password, Map<String, dynamic> userData) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(userData['name']);
    final encryptedData = _encryption.encryptMap(userData);
    await _database.child('users/${credential.user!.uid}').set(encryptedData);
    return credential;
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Medicines CRUD
  Future<void> addMedicine(Map<String, dynamic> medicine) async {
    final encrypted = _encryption.encryptMap(medicine);
    await _database.child('medicines/${medicine['id']}').set(encrypted);
  }

  Stream<DatabaseEvent> getMedicines() {
    return _database.child('medicines').onValue;
  }

  Future<void> updateMedicine(String id, Map<String, dynamic> data) async {
    final encrypted = _encryption.encryptMap(data);
    await _database.child('medicines/$id').update(encrypted);
  }

  Future<void> deleteMedicine(String id) async {
    await _database.child('medicines/$id').remove();
  }

  // Sales
  Future<void> addSale(Map<String, dynamic> sale) async {
    final encrypted = _encryption.encryptMap(sale);
    await _database.child('sales/${sale['id']}').set(encrypted);
    
    for (var item in sale['items']) {
      final medicineRef = _database.child('medicines/${item['id']}');
      final snapshot = await medicineRef.get();
      if (snapshot.exists) {
        final currentStock = snapshot.child('stock').value as int;
        await medicineRef.update({'stock': currentStock - item['quantity']});
      }
    }
  }

  // Stock alerts
  Stream<DatabaseEvent> getLowStockItems() {
    return _database.child('medicines').orderByChild('stock').endAt(10).onValue;
  }
}