import 'package:elephant_mall/services/Category_service.dart';
import 'package:elephant_mall/view/common/footer.dart';
import 'package:elephant_mall/view/common/header.dart';
import 'package:elephant_mall/view/signup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _apiEmailError;
  String? _apiPasswordError;

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
    // if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please fill in all fields'),
    //       backgroundColor: Colors.orange,
    //     ),
    //   );
    //   return;
    // }
    setState(() {
      _apiEmailError = null;
      _apiPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) {
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
        context.go('/');
      } else {
        //  SHOW API ERROR ON THE FIELDS INSTEAD OF SNACKBAR
        setState(() {
          final error = authService.errorMessage ?? 'Invalid email or password';
          
          // We set the API error on the Email field
          _apiEmailError = error; 
          _apiPasswordError = null; 
        });
        
        _formKey.currentState!.validate();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Show network error on the field too
      setState(() {
        _apiEmailError = 'Connection error. Try again.';
      });
      _formKey.currentState!.validate();
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
                                margin: const EdgeInsets.symmetric(
                                  vertical: 50,
                                ),
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
            //  Footer - Only on Desktop (NOT mobile)
            if (!isMobile) const CommonFooter(),
          ],
        ),
        //  Bottom Bar - Only on Mobile
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
        vertical: isMobile ? 30 : 20,
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
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
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
            const SizedBox(height: 10),
            // 2. EMAIL FIELD WITH VALIDATOR
            _textField(
              Icons.person_outline,
              "Email/Username",
              controller: _emailController,
               onChanged: (val) {
                // Clear BOTH errors when typing in email
                if (_apiEmailError != null || _apiPasswordError != null) {
                  setState(() {
                    _apiEmailError = null;
                    _apiPasswordError = null;
                  });
                }
              },
              validator: (value) {
                if (_apiEmailError != null) {
                  return _apiEmailError;
                }
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // 3. PASSWORD FIELD WITH VALIDATOR
            _textField(
              Icons.lock_outline,
              "Password",
              controller: _passwordController,
              textInputAction:
                  TextInputAction.done, // Done shows the "Enter" icon
              onFieldSubmitted:
                  _login, //  2. Trigger login when Enter is pressed
              onChanged: (val) {
                // Clear BOTH errors when typing in password
                if (_apiEmailError != null || _apiPasswordError != null) {
                  setState(() {
                    _apiEmailError = null;
                    _apiPasswordError = null;
                  });
                }
              },
              validator: (value) {
                 if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
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
            const SizedBox(height: 15),
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
            _socialButton(FontAwesomeIcons.google, "Sign in with Google"),
            const SizedBox(height: 5),
            _socialButton(FontAwesomeIcons.apple, "Sign in with Apple"),
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
                    context.go('/signup');
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
      ),
    );
  }

  Widget _textField(
    IconData icon,
    String hint, {
    bool obscure = false,
    required TextEditingController controller,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.next, // Added
    VoidCallback? onFieldSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: (_) {
            if (onFieldSubmitted != null) {
              onFieldSubmitted();
            }
          },
          //  THIS IS THE MAGIC: Validate ONLY this field when you click outside it
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
            // Find the specific FormFieldState for this text field and validate it
            final FormFieldState<String> fieldState = context
                .findAncestorStateOfType<FormFieldState<String>>()!;
            fieldState.validate();
          },
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
            errorMaxLines: 1,
          ),
        );
      },
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
