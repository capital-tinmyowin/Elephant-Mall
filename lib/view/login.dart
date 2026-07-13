import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffdfaf4), Color(0xfff7edd9)],
          ),
        ),
        child: SafeArea(
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
                          _leftSide(true),

                          const SizedBox(height: 50),

                          _rightSide(true),

                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  : SizedBox.expand(
                      child: Row(
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
              width: isMobile ? 220 : 500,
              fit: BoxFit.contain,
            ),

            SizedBox(height: isMobile ? 20 : 25),

            Text(
              "Shop, Sell, and Connect\nwith your local community.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 28 : 42,
                fontWeight: FontWeight.bold,
                color: const Color(0xff315b2d),
                height: 1.2,
              ),
            ),

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
      width: isMobile ? double.infinity : 460,
      constraints: const BoxConstraints(maxWidth: 460),
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

          const SizedBox(height: 30),

          _textField(Icons.person_outline, "Email/Username"),

          const SizedBox(height: 18),

          _textField(Icons.lock_outline, "Password", obscure: true),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2f6b2f),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xffb8860b),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          _socialButton(FontAwesomeIcons.google, "Sign in with Google"),

          const SizedBox(height: 15),

          _socialButton(FontAwesomeIcons.apple, "Sign in with Apple"),

          const SizedBox(height: 25),

          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 16),
              ),
              GestureDetector(
                onTap: () {},
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

  Widget _textField(IconData icon, String hint, {bool obscure = false}) {
    return SizedBox(
      height: 52,
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,

          prefixIcon: Icon(icon),

          suffixIcon: obscure
              ? const Icon(Icons.visibility_off_outlined)
              : null,

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
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () {},
        icon: FaIcon(icon, size: 22, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}
