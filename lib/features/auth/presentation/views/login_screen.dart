// ─── Login Screen ─────────────────────────────────────────────────────────────
// Presentation layer — pure UI, communicates only via BLoC events
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/core/utils/validators.dart';
import 'package:rangrej_fleet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthLoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D2040), // primaryDark
                Color(0xFF1A3C6E), // primary
                Color(0xFFF8F9FA), // background
              ],
              stops: [0.0, 0.4, 0.95],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Transparent app logo
                    Center(
                      child: Container(
                        width: size.width * 0.3,
                        height: size.width * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/app_logo.jpeg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Center(
                      child: Text(
                        'Rangrej Fleet',
                        style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 26),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Center(
                      child: Text(
                        'Admin Login for Fleet Owners',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Card wrapper for the login form
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthTextField(
                                controller: _emailController,
                                label: 'Email or Username',
                                hint: 'e.g., owner@rangrejfleet.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                              ),
                              const SizedBox(height: AppDimensions.md),
                              AuthTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter your secure password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                validator: Validators.validatePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.grey400,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              const SizedBox(height: AppDimensions.sm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push(AppRoutes.forgotPassword),
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTextStyles.button.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.lg),

                              // Submit Button
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoginInProgress;
                                  return ElevatedButton(
                                    onPressed: isLoading ? null : _onSubmit,
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.white,
                                            ),
                                          )
                                        : const Text('Login to Dashboard'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Footer
                    Center(
                      child: Text(
                        'Unauthorized access is strictly prohibited.\nProtected by Rangrej Security Protocol.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(color: AppColors.grey600),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('Privacy Policy', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                        ),
                        const Text('•', style: TextStyle(color: AppColors.grey600)),
                        TextButton(
                          onPressed: () {},
                          child: Text('Contact Support', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
