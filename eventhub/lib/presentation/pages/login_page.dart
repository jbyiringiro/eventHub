import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_footer.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    context.read<AuthBloc>().add(LoginRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    ));
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(const GoogleSignInRequested());
  }

  void _handlePasswordReset() {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email first');
      return;
    }
    
    context.read<AuthBloc>().add(PasswordResetRequested(
      email: _emailController.text.trim(),
    ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is AuthError) {
          _showError(state.message);
        } else if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset instructions sent to your email'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return Scaffold(
            backgroundColor: AppColors.gray50,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.emerald600, AppColors.blue600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(16, 60, 16, 40),
                    child: Column(
                      children: [
                        Icon(Icons.event, color: Colors.white, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'EventEase',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Discover, Connect & Celebrate',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Login Form
                  Container(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        child: Column(
                          children: [
                            // Welcome Text
                            Column(
                              children: [
                                Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gray800,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Login to your EventEase account',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),

                            // Email Input
                            TextField(
                              controller: _emailController,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline, color: AppColors.emerald600),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 16),

                            // Password Input
                            TextField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline, color: AppColors.emerald600),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.emerald600,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.emerald600, width: 2),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              obscureText: _obscurePassword,
                            ),
                            SizedBox(height: 12),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading ? null : _handlePasswordReset,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.emerald600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald600,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBackgroundColor: AppColors.gray400,
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.gray300)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: TextStyle(color: AppColors.gray600),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppColors.gray300)),
                              ],
                            ),
                            SizedBox(height: 24),

                            // Google Sign-In Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : _handleGoogleSignIn,
                                icon: Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
                                label: Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: AppColors.gray800,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.gray300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Register Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: AppColors.gray600,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: isLoading ? null : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterPage()),
                                  ),
                                  child: Text(
                                    'Register here',
                                    style: TextStyle(
                                      color: AppColors.emerald600,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  CustomFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}