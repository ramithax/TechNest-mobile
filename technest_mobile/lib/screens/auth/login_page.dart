import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/typography/text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    print('Email: $email');
    print('Password: $password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.computer,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'TechNest',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your technology marketplace',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Welcome Back',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue to TechNest',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Email',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  child: const Text(
                    'Login',
                    style: AppTextStyles.button,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Create an account',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
