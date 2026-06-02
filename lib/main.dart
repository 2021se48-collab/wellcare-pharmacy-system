import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'services/encryption_service.dart';
import 'services/notification_service.dart';
import 'services/ads_service.dart';
import 'services/background_service.dart';
import 'services/permission_service.dart';
import 'services/api_service.dart';
import 'services/performance_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services
  EncryptionService().init();
  await NotificationService().init();
  await AdsService().init();
  await BackgroundService().init();
  await PermissionService().requestPermissions();
  
  // Start background tasks
  BackgroundService.startStockCheck();
  BackgroundService.startDailyReport();
  
  // Log performance
  PerformanceService().logEvent('App Started');
  
  runApp(const MyApp());
}

// ============= SERVICE STUBS =============
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();
  
  void init() { print('EncryptionService initialized'); }
  String encrypt(String data) => data;
  String decrypt(String data) => data;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  Future<void> init() async { print('NotificationService initialized'); }
  Future<void> showNotification(String title, String body) async { print('Showing notification: $title - $body'); }
}

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();
  
  Future<void> init() async { print('AdsService initialized'); }
  void showBannerAd() {}
  void showInterstitialAd() {}
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();
  
  Future<void> init() async { print('BackgroundService initialized'); }
  static void startStockCheck() { print('Stock check background task started'); }
  static void startDailyReport() { print('Daily report background task started'); }
}

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();
  
  Future<void> requestPermissions() async { print('Requesting permissions'); }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  Future<dynamic> get(String url) async { print('GET request to $url'); return null; }
  Future<dynamic> post(String url, dynamic data) async { print('POST request to $url'); return null; }
}

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  
  void logEvent(String event) { print('Performance event: $event'); }
}

// ============= PROVIDERS =============
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() { _load(); }
  
  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }
  
  void toggle() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }
}

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'en';
  String get languageCode => _languageCode;
  
  LanguageProvider() { _load(); }
  
  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('languageCode') ?? 'en';
    notifyListeners();
  }
  
  void setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    notifyListeners();
  }
  
  String translate(String en, String ps) {
    return _languageCode == 'ps' ? ps : en;
  }
}

// ============= MAIN APP =============
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'WellCare Pharmacy',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDarkMode ? _darkTheme : _lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF0D47A1),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true, backgroundColor: Color(0xFF0D47A1), foregroundColor: Colors.white),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1565C0),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true, backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white),
  );
}

// ============= TRANSLATION HELPER =============
extension Translate on BuildContext {
  String tr(String en, String ps) {
    return Provider.of<LanguageProvider>(this, listen: false).translate(en, ps);
  }
}

// ============= SPLASH SCREEN =============
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => isLoggedIn ? const DashboardScreen() : const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF00BCD4)])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.local_pharmacy, size: 60, color: Color(0xFF0D47A1))),
              const SizedBox(height: 32),
              Builder(builder: (context) => Text(context.tr('WellCare Pharmacy', 'ويلکير درملتون'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
              const SizedBox(height: 16),
              Builder(builder: (context) => Text(context.tr('Your Health, Our Priority', 'ستاسو روغتیا، زموږ لومړیتوب'), style: const TextStyle(fontSize: 16, color: Colors.white70))),
              const SizedBox(height: 48),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============= LOGIN SCREEN =============
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    PerformanceService().logEvent('User Logged In');
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.local_pharmacy, size: 80, color: Color(0xFF0D47A1)),
              const SizedBox(height: 24),
              Builder(builder: (context) => Text(context.tr('WellCare Pharmacy', 'ويلکير درملتون'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))),
              const SizedBox(height: 8),
              Builder(builder: (context) => Text(context.tr('Welcome Back!', 'ښه راغلاست!'), style: TextStyle(fontSize: 16, color: Colors.grey[600]))),
              const SizedBox(height: 48),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: context.tr('Email', 'برېښليک'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: context.tr('Password', 'پاسورډ'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _login, child: _isLoading ? const CircularProgressIndicator() : Text(context.tr('Login', 'ننوتل')))),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: const Column(children: [Text('Demo Credentials'), Text('demo@wellcare.com'), Text('demo123')])),
            ],
          ),
        ),
      ),
    );
  }
}

// ============= DASHBOARD SCREEN =============
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const MedicinesScreen(),
    const SalesScreen(),
    const CustomersScreen(),
    const SuppliersScreen(),
    const ExpensesScreen(),
    const StockAlertsScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: context.tr('Home', 'کور')),
          BottomNavigationBarItem(icon: const Icon(Icons.medication), label: context.tr('Medicines', 'درملونه')),
          BottomNavigationBarItem(icon: const Icon(Icons.shopping_cart), label: context.tr('Sales', 'پلور')),
          BottomNavigationBarItem(icon: const Icon(Icons.people), label: context.tr('Customers', 'پیرودونکي')),
          BottomNavigationBarItem(icon: const Icon(Icons.business), label: context.tr('Suppliers', 'رسونکي')),
          BottomNavigationBarItem(icon: const Icon(Icons.money_off), label: context.tr('Expenses', 'لګښتونه')),
          BottomNavigationBarItem(icon: const Icon(Icons.warning), label: context.tr('Alerts', 'خبرتیاوې')),
          BottomNavigationBarItem(icon: const Icon(Icons.analytics), label: context.tr('Reports', 'راپورونه')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: context.tr('Profile', 'پروفایل')),
        ],
      ),
    );
  }
}

// ============= HOME SCREEN =============
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Dashboard', 'مرکزی صفحه'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF00BCD4)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, size: 35, color: Color(0xFF0D47A1))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.tr('Welcome back!', 'ښه راغلاست!'), style: const TextStyle(color: Colors.white70)), const Text('Admin User', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: TextStyle(color: Colors.white70))]))])),
          const SizedBox(height: 24),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1, children: [
            _buildStatCard(context.tr('Medicines', 'درملونه'), '234', Icons.medication, Colors.blue),
            _buildStatCard(context.tr('Low Stock', 'کم ذخیره'), '8', Icons.warning, Colors.orange),
            _buildStatCard(context.tr('Today Sales', 'نننی پلور'), '₨45,678', Icons.trending_up, Colors.green),
            _buildStatCard(context.tr('Customers', 'پیرودونکي'), '156', Icons.people, Colors.purple),
          ]),
        ]),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.grey)), Icon(icon, color: color)]), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])));
  }
}

// ============= MEDICINES SCREEN WITH EDIT =============
class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    _medicines = [
      {'id': '1', 'name': 'Paracetamol 500mg', 'price': 25, 'stock': 150},
      {'id': '2', 'name': 'Amoxicillin 250mg', 'price': 45, 'stock': 80},
      {'id': '3', 'name': 'Cough Syrup', 'price': 120, 'stock': 35},
      {'id': '4', 'name': 'Vitamin C Tablets', 'price': 85, 'stock': 200},
    ];
  }

  void _showMedicineDialog({Map<String, dynamic>? medicine, int? index}) {
    final nameController = TextEditingController(text: medicine?['name'] ?? '');
    final priceController = TextEditingController(text: medicine?['price']?.toString() ?? '');
    final stockController = TextEditingController(text: medicine?['stock']?.toString() ?? '');
    final isEditing = medicine != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? context.tr('Edit Medicine', 'درمل سمول') : context.tr('Add Medicine', 'درمل اضافه کول')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: context.tr('Medicine Name', 'د درمل نوم'))),
            const SizedBox(height: 8),
            TextField(controller: priceController, decoration: InputDecoration(labelText: context.tr('Price', 'قیمت')), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: stockController, decoration: InputDecoration(labelText: context.tr('Stock', 'ذخیره')), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('Cancel', 'ناگارل'))),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newMedicine = {
                    'id': isEditing ? medicine!['id'] : DateTime.now().toString(),
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                    'stock': int.parse(stockController.text),
                  };
                  if (isEditing && index != null) {
                    _medicines[index] = newMedicine;
                  } else {
                    _medicines.add(newMedicine);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isEditing ? context.tr('Medicine updated!', 'درمل سم شو!') : context.tr('Medicine added!', 'درمل اضافه شو!')),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: Text(isEditing ? context.tr('Update', 'تازه کول') : context.tr('Add', 'اضافه کول')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Medicines', 'درملونه')),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showMedicineDialog(medicine: null))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _medicines.length,
        itemBuilder: (context, index) {
          final med = _medicines[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.medication, color: Color(0xFF0D47A1)),
              title: Text(med['name'].toString()),
              subtitle: Text('₨${med['price']} | ${context.tr('Stock', 'ذخیره')}: ${med['stock']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showMedicineDialog(medicine: med, index: index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.tr('Delete Medicine', 'درمل ړنګول')),
                        content: Text('${context.tr('Delete', 'ړنګول')} ${med['name']}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('Cancel', 'ناگارل'))),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _medicines.removeAt(index));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('Medicine deleted!', 'درمل ړنګ شو!')), backgroundColor: Colors.red));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text(context.tr('Delete', 'ړنګول')),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============= SALES SCREEN =============
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Map<String, dynamic>> _cart = [];
  final List<Map<String, dynamic>> _medicines = [
    {'id': '1', 'name': 'Paracetamol', 'price': 25},
    {'id': '2', 'name': 'Amoxicillin', 'price': 45},
    {'id': '3', 'name': 'Cough Syrup', 'price': 120},
    {'id': '4', 'name': 'Vitamin C', 'price': 85},
  ];

  void _addToCart(Map<String, dynamic> medicine) {
    setState(() {
      final existing = _cart.firstWhere((item) => item['id'] == medicine['id'], orElse: () => {});
      if (existing.isNotEmpty) {
        existing['quantity'] = (existing['quantity'] ?? 1) + 1;
      } else {
        _cart.add({
          'id': medicine['id'],
          'name': medicine['name'],
          'price': medicine['price'],
          'quantity': 1,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${medicine['name']} ${context.tr('added to cart', 'پلورلنډۍ ته اضافه شو')}')));
  }

  void _removeFromCart(int index) { setState(() => _cart.removeAt(index)); }

  void _updateQuantity(int index, int change) {
    setState(() {
      int newQty = (_cart[index]['quantity'] ?? 1) + change;
      if (newQty <= 0) { _cart.removeAt(index); } 
      else { _cart[index]['quantity'] = newQty; }
    });
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)));
  double get _tax => _subtotal * 0.05;
  double get _total => _subtotal + _tax;

  void _checkout() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('Cart is empty', 'پلورلنډۍ خالې ده')), backgroundColor: Colors.orange));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Invoice', 'رسید')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 16),
            Text('${context.tr('Total', 'ټولټال')}: ₨${_total.toStringAsFixed(2)}'),
            Text(context.tr('Thank you for shopping!', 'د پيرلو نه مننه!')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _cart.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('Sale completed!', 'پلور بشپړ شو!')), backgroundColor: Colors.green));
              PerformanceService().logEvent('Sale Completed: ₨$_total');
            },
            child: Text(context.tr('Done', 'ترسره شو')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Sales Billing', 'د پلور بل'))),
      body: Column(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly Sales Trend', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 50000,
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 25000, color: Colors.blue)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 32000, color: Colors.blue)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 28000, color: Colors.blue)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 45000, color: Colors.blue)]),
                        BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 38000, color: Colors.blue)]),
                        BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 52000, color: Colors.blue)]),
                        BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 48000, color: Colors.blue)]),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text('₨${(value / 1000).toInt()}k', style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(16), color: const Color(0xFF0D47A1).withOpacity(0.1), child: Text(context.tr('Medicines', 'درملونه'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _medicines.length,
                          itemBuilder: (context, index) => Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(_medicines[index]['name']),
                              subtitle: Text('₨${_medicines[index]['price']}'),
                              trailing: IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () => _addToCart(_medicines[index])),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(16), color: Colors.green.withOpacity(0.1), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(context.tr('Cart', 'پلورلنډۍ'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: Text('${_cart.length} ${context.tr('items', 'توکي')}', style: const TextStyle(color: Colors.white)))])),
                      Expanded(
                        child: _cart.isEmpty
                            ? Center(child: Text(context.tr('Cart is empty', 'پلورلنډۍ خالې ده')))
                            : ListView.builder(
                                itemCount: _cart.length,
                                itemBuilder: (context, index) {
                                  final item = _cart[index];
                                  return Card(
                                    margin: const EdgeInsets.all(8),
                                    child: ListTile(
                                      title: Text(item['name']),
                                      subtitle: Text('₨${item['price']} x ${item['quantity']} = ₨${item['price'] * (item['quantity'] ?? 1)}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: () => _updateQuantity(index, -1)),
                                          Text('${item['quantity']}'),
                                          IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () => _updateQuantity(index, 1)),
                                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeFromCart(index)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(context.tr('Total:', 'ټولټال:'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text('₨${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))]),
                            const SizedBox(height: 16),
                            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _checkout, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text(context.tr('Checkout', 'تسویه'), style: const TextStyle(fontSize: 16)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============= CUSTOMERS SCREEN WITH EDIT =============
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  void _loadCustomers() {
    _customers = [
      {'id': '1', 'name': 'Ahmad Khan', 'phone': '0770 123 456', 'totalPurchases': 25000},
      {'id': '2', 'name': 'Fatima Noori', 'phone': '0788 987 654', 'totalPurchases': 45000},
      {'id': '3', 'name': 'Mohammad Hussain', 'phone': '0799 456 789', 'totalPurchases': 12000},
    ];
  }

  void _showCustomerDialog({Map<String, dynamic>? customer, int? index}) {
    final nameController = TextEditingController(text: customer?['name'] ?? '');
    final phoneController = TextEditingController(text: customer?['phone'] ?? '');
    final isEditing = customer != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newCustomer = {
                    'id': isEditing ? customer!['id'] : DateTime.now().toString(),
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'totalPurchases': isEditing ? customer!['totalPurchases'] : 0,
                  };
                  if (isEditing && index != null) {
                    _customers[index] = newCustomer;
                  } else {
                    _customers.add(newCustomer);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isEditing ? 'Customer updated!' : 'Customer added!'),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showCustomerDialog(customer: null))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final c = _customers[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1), child: Text(c['name'][0], style: const TextStyle(color: Color(0xFF0D47A1)))),
              title: Text(c['name']),
              subtitle: Text('${c['phone']}\nTotal Purchases: ₨${c['totalPurchases']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showCustomerDialog(customer: c, index: index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Customer'),
                        content: Text('Delete ${c['name']}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _customers.removeAt(index));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer deleted!'), backgroundColor: Colors.red));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============= SUPPLIERS SCREEN WITH EDIT =============
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List<Map<String, dynamic>> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  void _loadSuppliers() {
    _suppliers = [
      {'id': '1', 'name': 'Global Pharma', 'contact': 'Ahmad', 'phone': '0770 111 222', 'due': 25000},
      {'id': '2', 'name': 'Health Solutions', 'contact': 'Karim', 'phone': '0788 333 444', 'due': 0},
      {'id': '3', 'name': 'MediCare Supply', 'contact': 'Nadia', 'phone': '0799 555 666', 'due': 12000},
    ];
  }

  void _showSupplierDialog({Map<String, dynamic>? supplier, int? index}) {
    final nameController = TextEditingController(text: supplier?['name'] ?? '');
    final contactController = TextEditingController(text: supplier?['contact'] ?? '');
    final phoneController = TextEditingController(text: supplier?['phone'] ?? '');
    final isEditing = supplier != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Supplier' : 'Add Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Supplier Name')),
            TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Person')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newSupplier = {
                    'id': isEditing ? supplier!['id'] : DateTime.now().toString(),
                    'name': nameController.text,
                    'contact': contactController.text,
                    'phone': phoneController.text,
                    'due': isEditing ? supplier!['due'] : 0,
                  };
                  if (isEditing && index != null) {
                    _suppliers[index] = newSupplier;
                  } else {
                    _suppliers.add(newSupplier);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isEditing ? 'Supplier updated!' : 'Supplier added!'),
                  backgroundColor: Colors.green,
                ));
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _showSupplierDialog(supplier: null))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suppliers.length,
        itemBuilder: (context, index) {
          final s = _suppliers[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.business, color: Color(0xFF0D47A1)),
              title: Text(s['name']),
              subtitle: Text('Contact: ${s['contact']} | Phone: ${s['phone']}\nDue: ₨${s['due']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showSupplierDialog(supplier: s, index: index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Supplier'),
                        content: Text('Delete ${s['name']}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _suppliers.removeAt(index));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier deleted!'), backgroundColor: Colors.red));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============= EXPENSES SCREEN =============
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _expenses = [
      {'id': '1', 'title': 'Shop Rent', 'amount': 25000, 'date': '01/06/2024'},
      {'id': '2', 'title': 'Electricity', 'amount': 5000, 'date': '05/06/2024'},
      {'id': '3', 'title': 'Salaries', 'amount': 45000, 'date': '10/06/2024'},
    ];
  }

  void _addExpense() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Add Expense', 'لګښت اضافه کول')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: context.tr('Expense Title', 'د لګښت عنوان'))),
            TextField(controller: amountController, decoration: InputDecoration(labelText: context.tr('Amount', 'رقم')), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('Cancel', 'ناگارل'))),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _expenses.add({
                    'id': DateTime.now().toString(),
                    'title': titleController.text,
                    'amount': double.parse(amountController.text),
                    'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('Expense added!', 'لګښت اضافه شو!')), backgroundColor: Colors.green));
              }
            },
            child: Text(context.tr('Add', 'اضافه کول')),
          ),
        ],
      ),
    );
  }

  double get _total => _expenses.fold(0, (sum, e) => sum + (e['amount'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Expenses', 'لګښتونه')), actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addExpense)]),
      body: Column(
        children: [
          Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(20)), child: Column(children: [Text(context.tr('Total Expenses', 'ټول لګښتونه'), style: const TextStyle(color: Colors.red)), Text('₨${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red))])),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final e = _expenses[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.money_off, color: Colors.red),
                    title: Text(e['title']),
                    subtitle: Text(e['date']),
                    trailing: Text('₨${e['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============= STOCK ALERTS SCREEN =============
class StockAlertsScreen extends StatelessWidget {
  const StockAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> lowStockItems = [
      {'name': 'Paracetamol 500mg', 'stock': 8, 'minStock': 10, 'expiry': '2025-12-31'},
      {'name': 'Insulin Injection', 'stock': 3, 'minStock': 10, 'expiry': '2024-12-01'},
      {'name': 'Antibiotic Cream', 'stock': 6, 'minStock': 10, 'expiry': '2025-09-30'},
    ];

    final List<Map<String, dynamic>> expiringItems = [
      {'name': 'Insulin Injection', 'expiry': '2024-12-01', 'daysLeft': 30},
      {'name': 'Cough Syrup', 'expiry': '2025-08-20', 'daysLeft': 80},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Alerts')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Color(0xFF0D47A1),
              labelColor: Color(0xFF0D47A1),
              tabs: [
                Tab(text: 'Low Stock', icon: Icon(Icons.warning)),
                Tab(text: 'Expiring Soon', icon: Icon(Icons.calendar_today)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Low Stock Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lowStockItems.length,
                    itemBuilder: (context, index) {
                      final item = lowStockItems[index];
                      final int stock = item['stock'] as int;
                      final int minStock = item['minStock'] as int;
                      final bool isCritical = stock <= (minStock ~/ 2);
                      return Card(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: isCritical ? Colors.red : Colors.orange, width: 5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(isCritical ? Icons.crisis_alert : Icons.warning, color: isCritical ? Colors.red : Colors.orange),
                            title: Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Stock: $stock | Min: $minStock'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reorder requested'), backgroundColor: Colors.orange),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text('Reorder'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Expiring Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: expiringItems.length,
                    itemBuilder: (context, index) {
                      final item = expiringItems[index];
                      final int daysLeft = item['daysLeft'] as int;
                      final bool isUrgent = daysLeft <= 30;
                      return Card(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: isUrgent ? Colors.red : Colors.orange, width: 5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.calendar_today, color: isUrgent ? Colors.red : Colors.orange),
                            title: Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Expires: ${item['expiry']} | $daysLeft days left'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= REPORTS SCREEN WITH PDF AND EXCEL EXPORT (FIXED) =============
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Future<void> _generateAndDownloadPDF(String reportType, Map<String, dynamic> data) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('WellCare Pharmacy', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),
            pw.Text('$reportType Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Generated: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.Divider(),
            ...data.entries.map((entry) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(entry.key, style: pw.TextStyle(fontSize: 14)),
                  pw.Text(entry.value.toString(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            )),
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Thank you for choosing WellCare Pharmacy', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
            pw.SizedBox(height: 10),
            pw.Text('WellCare Pharmacy Management System', style: pw.TextStyle(fontSize: 10)),
            pw.Text('© 2024 WellCare Pharmacy', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
    
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${reportType}_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$reportType Report generated and ready to download!'), backgroundColor: Colors.green),
        );
      }
      PerformanceService().logEvent('$reportType Report Downloaded');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showReportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Report Type', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.today, color: Colors.blue),
              title: const Text('Daily Report'),
              subtitle: const Text('View today\'s sales summary'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                _generateAndDownloadPDF('Daily', {
                  'Date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  'Total Sales': '₨45,678',
                  'Total Expenses': '₨25,000',
                  'Net Profit': '₨20,678',
                  'Items Sold': '156',
                  'Transactions': '23',
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.green),
              title: const Text('Monthly Report'),
              subtitle: const Text('View monthly sales summary'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                _generateAndDownloadPDF('Monthly', {
                  'Month': DateFormat('MMMM yyyy').format(DateTime.now()),
                  'Total Sales': '₨12,45,678',
                  'Total Expenses': '₨5,00,000',
                  'Net Profit': '₨7,45,678',
                  'Items Sold': '4,567',
                  'Transactions': '890',
                  'Average Daily Sale': '₨41,522',
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.orange),
              title: const Text('Yearly Report'),
              subtitle: const Text('View yearly sales summary'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                _generateAndDownloadPDF('Yearly', {
                  'Year': DateTime.now().year.toString(),
                  'Total Sales': '₨1,45,67,890',
                  'Total Expenses': '₨45,00,000',
                  'Net Profit': '₨1,00,67,890',
                  'Items Sold': '45,678',
                  'Transactions': '8,456',
                  'Monthly Average': '₨12,13,990',
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.purple),
              title: const Text('Stock Report'),
              subtitle: const Text('View current inventory status'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                _generateAndDownloadPDF('Stock', {
                  'Total Medicines': '234',
                  'Low Stock Items': '8',
                  'Expiring Soon': '3',
                  'Out of Stock': '0',
                  'Total Value': '₨2,34,567',
                  'Categories': 'Tablets, Capsules, Syrups',
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      final List<List<dynamic>> excelData = [
        ['Date', 'Sales', 'Expenses', 'Profit'],
        ['01/06/2024', '45000', '25000', '20000'],
        ['02/06/2024', '38000', '22000', '16000'],
        ['03/06/2024', '52000', '28000', '24000'],
      ];
      
      String csvContent = '';
      for (var row in excelData) {
        csvContent += row.join(',') + '\n';
      }
      
      // Print to console
      print('Excel Export: \n$csvContent');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel data ready! Check console'), backgroundColor: Colors.green),
        );
      }
      PerformanceService().logEvent('Excel Report Exported');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: () => _exportToExcel(),
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _showReportOptions(),
            tooltip: 'Download PDF Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildReportCard('Today Sales', '₨45,678', Icons.today, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildReportCard('This Month', '₨12,45,678', Icons.calendar_month, Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildReportCard('Total Purchases', '₨8,56,789', Icons.shopping_cart, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildReportCard('Net Profit', '₨3,89,889', Icons.trending_up, Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Generate Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportToExcel(),
                            icon: const Icon(Icons.table_chart),
                            label: const Text('Excel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showReportOptions(),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () => _showReportOptions(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ============= PROFILE SCREEN (UPDATED WITH PROFILE PICTURE) =============
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageBase64;
  
  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImage = prefs.getString('profileImageBase64');
    if (savedImage != null && savedImage.isNotEmpty) {
      setState(() {
        _profileImageBase64 = savedImage;
      });
    }
  }

  Future<void> _uploadImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      final reader = html.FileReader();
      
      reader.onLoadEnd.listen((event) async {
        final base64String = reader.result as String;
        
        setState(() {
          _profileImageBase64 = base64String;
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageBase64', base64String);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
          );
        }
      });

      reader.readAsDataUrl(file);
    });
  }

  void _removeImage() async {
    setState(() {
      _profileImageBase64 = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImageBase64');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture removed'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Profile', 'پروفایل'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Profile Picture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.upload_file, color: Colors.blue),
                          title: const Text('Upload from PC'),
                          onTap: () {
                            Navigator.pop(context);
                            _uploadImage();
                          },
                        ),
                        if (_profileImageBase64 != null) ...[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Remove Picture'),
                            onTap: () {
                              Navigator.pop(context);
                              _removeImage();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                    backgroundImage: _profileImageBase64 != null && _profileImageBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(_profileImageBase64!.split(',').last))
                        : null,
                    child: _profileImageBase64 == null || _profileImageBase64!.isEmpty
                        ? const Icon(Icons.person, size: 60, color: Color(0xFF0D47A1))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.upload_file, color: Colors.blue),
                          title: const Text('Upload from PC'),
                          onTap: () {
                            Navigator.pop(context);
                            _uploadImage();
                          },
                        ),
                        if (_profileImageBase64 != null)
                          ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Remove Picture'),
                            onTap: () {
                              Navigator.pop(context);
                              _removeImage();
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
              child: Text(context.tr('Change Profile Picture', 'پروفایل عکس بدل کړئ')),
            ),
            const SizedBox(height: 16),
            const Text('Admin User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('admin@wellcare.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, tp, child) => SwitchListTile(
                      title: Text(context.tr('Dark Mode', 'تیاره حالت')),
                      secondary: const Icon(Icons.dark_mode),
                      value: tp.isDarkMode,
                      onChanged: (_) => tp.toggle(),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.tr('Language', 'ژبه')),
                    subtitle: Text(languageProvider.languageCode == 'en' ? 'English' : 'پښتو'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.tr('Select Language', 'ژبه وټاکئ')),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('English'),
                                onTap: () {
                                  languageProvider.setLanguage('en');
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('پښتو (Pashto)'),
                                onTap: () {
                                  languageProvider.setLanguage('ps');
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(context.tr('Logout', 'وتل')),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('isLoggedIn');
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}