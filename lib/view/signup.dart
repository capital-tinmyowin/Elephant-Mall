import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool agree = false;

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

                          _rightSide(context, true),

                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  : SizedBox.expand(
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: const Alignment(-2, 0),
                              child: SizedBox(
                                width: 600,
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
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 250,
                              ), // Adjust this value
                              child: Center(
                                child: SizedBox(
                                  width: 460,
                                  child: _rightSide(context, false),
                                ),
                              ),
                            ),
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
    return SizedBox(
      width: double.infinity,
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
    );
  }

  Widget _rightSide(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 35,
        vertical: isMobile ? 30 : 40,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Create An Account",
            style: TextStyle(
              fontSize: isMobile ? 30 : 38,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          _textField(Icons.person_outline, "Full Name"),

          const SizedBox(height: 18),

          _textField(Icons.email_outlined, "Email"),

          const SizedBox(height: 18),

          _textField(Icons.lock_outline, "Password", obscure: true),

          const SizedBox(height: 18),

          _textField(Icons.lock_outline, "Confirm Password", obscure: true),

          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: agree,
                onChanged: (v) {
                  setState(() {
                    agree = v!;
                  });
                },
              ),

              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      const TextSpan(text: "I agree to the "),
                      TextSpan(
                        text: "Terms & Conditions",
                        style: const TextStyle(
                          color: Color(0xff2f6b2f),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

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
                "Create Account",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 15),

          _socialButton(FontAwesomeIcons.google, "Sign up with Google"),

          const SizedBox(height: 15),

          _socialButton(FontAwesomeIcons.apple, "Sign up with Apple"),
          const SizedBox(height: 15),

          Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text("Already have an account? "),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      color: Color(0xff2f6b2f),
                      fontWeight: FontWeight.bold,
                    ),
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
