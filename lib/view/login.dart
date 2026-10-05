import 'package:elephant_mall/services/Category_service.dart';
import 'package:elephant_mall/view/common/footer.dart';
import 'package:elephant_mall/view/common/header.dart';
import 'package:elephant_mall/view/signup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'Signup.dart' hide RegisterPage;
import 'home.dart';

bool mobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 800;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late ApiService _apiService;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('👋 Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        final error = authService.errorMessage ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Connection error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = mobile(context);

    return ChangeNotifierProvider.value(
      value: _apiService,
      child: Scaffold(
        body: Column(
          children: [
            const CommonHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfffdfaf4), Color(0xfff7edd9)],
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: isMobile
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 40,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // _leftSide(true),
                                // const SizedBox(height: 50),
                                _rightSide(true),
                                const SizedBox(height: 30),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: _leftSide(false),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                margin: const EdgeInsets.symmetric(vertical: 50),
                                color: Colors.grey.shade300,
                              ),
                              Expanded(
                                flex: 5,
                                child: Center(child: _rightSide(false)),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            // 🔥 Footer - Only on Desktop (NOT mobile)
            if (!isMobile) const CommonFooter(),
          ],
        ),
        // 🔥 Bottom Bar - Only on Mobile
        bottomNavigationBar: isMobile
            ? const CommonBottomBar(currentIndex: 4)
            : null,
      ),
    );
  }

  Widget _leftSide(bool isMobile) {
    return Center(
      child: SizedBox(
        width: isMobile ? double.infinity : 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'lib/uploads/login.png',
              width: isMobile ? 220 : 300,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: isMobile ? 220 : 400,
                  height: isMobile ? 200 : 350,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            SizedBox(height: isMobile ? 20 : 25),
            // Text(
            //   "Shop, Sell, and Connect\nwith your local community.",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: isMobile ? 28 : 42,
            //     fontWeight: FontWeight.bold,
            //     color: const Color(0xff315b2d),
            //     height: 1.2,
            //   ),
            // ),
            SizedBox(height: isMobile ? 15 : 20),
            Text(
              "Everything your local mall offers, but on a bigger stage.\nWelcome to Elephant Mall.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 22,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rightSide(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 400,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 35,
        vertical: isMobile ? 30 : 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 25,
            color: Colors.black.withOpacity(.12),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Welcome",
            style: TextStyle(
              fontSize: isMobile ? 30 : 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          // const SizedBox(height: 30),
          _textField(
            Icons.person_outline,
            "Email/Username",
            controller: _emailController,
          ),
          const SizedBox(height: 18),
          _textField(
            Icons.lock_outline,
            "Password",
            obscure: _obscurePassword,
            controller: _passwordController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2f6b2f),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
            ),
          ),
          // const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xffb8860b),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // const SizedBox(height: 15),
          _socialButton(FontAwesomeIcons.google, "Sign in with Google"),
          const SizedBox(height: 15),
          _socialButton(FontAwesomeIcons.apple, "Sign in with Apple"),
          // const SizedBox(height: 25),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Register page (if exists)
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Color(0xff2f6b2f),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textField(
    IconData icon,
    String hint, {
    bool obscure = false,
    required TextEditingController controller,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Color(0xff2f6b2f), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(FaIconData icon, String text) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$text coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: FaIcon(icon, size: 22, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}