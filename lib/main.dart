import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/pos/presentation/pos_billing_screen.dart';
import 'features/inventory/presentation/inventory_fefo_screen.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/rbac/presentation/rbac_staff_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final isPashto = prefs.getBool('isPashto') ?? false;
  runApp(WellCareEnterpriseApp(initialLoggedIn: isLoggedIn, initialPashto: isPashto));
}

extension BilingualContext on BuildContext {
  bool get isPashto => WellCareEnterpriseApp.of(this)?.isPashto ?? false;
  String tr(String en, String ps) => isPashto ? ps : en;
}

class WellCareEnterpriseApp extends StatefulWidget {
  final bool initialLoggedIn;
  final bool initialPashto;

  const WellCareEnterpriseApp({
    super.key,
    required this.initialLoggedIn,
    required this.initialPashto,
  });

  static _WellCareEnterpriseAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_WellCareEnterpriseAppState>();

  @override
  State<WellCareEnterpriseApp> createState() => _WellCareEnterpriseAppState();
}

class _WellCareEnterpriseAppState extends State<WellCareEnterpriseApp> {
  late bool _isLoggedIn;
  late bool _isPashto;
  ThemeMode _themeMode = ThemeMode.light;

  bool get isPashto => _isPashto;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.initialLoggedIn;
    _isPashto = widget.initialPashto;
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isPashto = !_isPashto);
    await prefs.setBool('isPashto', _isPashto);
  }

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
    setState(() => _isLoggedIn = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare Pharmacy OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _isLoggedIn
          ? AppShell(
              titles: [
                _isPashto ? 'د خرڅلاو بلینګ (POS)' : 'POS Billing',
                _isPashto ? 'د درملو ګودام (FEFO)' : 'Inventory (FEFO)',
                _isPashto ? 'راپورونه او تحلیل' : 'Analytics & Reports',
                _isPashto ? 'کارکوونکي او واکونه' : 'Staff & RBAC',
              ],
              screens: const [
                PosBillingScreen(),
                InventoryFefoScreen(),
                AnalyticsScreen(),
                RbacStaffScreen(),
              ],
              onToggleTheme: toggleTheme,
              onLogout: () => setLoggedIn(false),
            )
          : LoginScreen(
              onLoginSuccess: () => setLoggedIn(true),
              onToggleLanguage: toggleLanguage,
              isPashto: _isPashto,
            ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onToggleLanguage;
  final bool isPashto;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onToggleLanguage,
    required this.isPashto,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController(text: 'pharmacist@wellcare.pk');
  final _passController = TextEditingController(text: 'wellcare2026');

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_pharmacy, color: AppColors.primaryTeal, size: 30),
                      ),
                      TextButton.icon(
                        onPressed: widget.onToggleLanguage,
                        icon: const Icon(Icons.language),
                        label: Text(widget.isPashto ? 'English' : 'پښتو'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.isPashto ? 'ویل کیئر درملتون سیسټم' : 'WellCare Pharmacy OS',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.isPashto
                        ? 'د درملو مدیریت او FEFO بلینګ ته ننوځئ'
                        : 'Enterprise FEFO Inventory & Clinical POS Terminal',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: widget.isPashto ? 'کارن نوم / بریښنالیک' : 'Pharmacist ID / Email',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: widget.isPashto ? 'پټنوم' : 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: widget.onLoginSuccess,
                    icon: const Icon(Icons.login),
                    label: Text(widget.isPashto ? 'ننوتل' : 'Sign In to Terminal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
