import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../screens/splash_screen.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      company: _companyController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Sign up failed'),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Text(
                          'Create Account',
                          style: AppTheme.heading1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to get started',
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),

                        // Progress Indicator
                        _buildProgressIndicator(),
                        const SizedBox(height: 32),

                        // Step Content
                        if (_currentStep == 0) ..._buildPersonalInfoStep(),
                        if (_currentStep == 1) ..._buildAccountInfoStep(),
                        if (_currentStep == 2) ..._buildSecurityStep(),

                        const SizedBox(height: 32),

                        // Navigation Buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentStep--;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                              ),
                            if (_currentStep > 0) const SizedBox(width: 16),
                            Expanded(
                              flex: _currentStep == 0 ? 1 : 1,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () {
                                        if (_currentStep < 2) {
                                          if (_validateCurrentStep()) {
                                            setState(() {
                                              _currentStep++;
                                            });
                                          }
                                        } else {
                                          _handleSignUp();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const CircularLoadingIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _currentStep == 2
                                            ? 'Create Account'
                                            : 'Next',
                                        style: AppTheme.buttonText,
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (authProvider.isLoading)
                  const LoadingOverlay(
                    message: 'Creating your account...',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppTheme.primaryBlue : AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildPersonalInfoStep() {
    return [
      // Step Title
      const Text(
        'Personal Information',
        style: AppTheme.heading3,
      ),
      const SizedBox(height: 24),

      // Full Name
      TextFormField(
        controller: _fullNameController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your full name';
          }
          if (value.length < 3) {
            return 'Name must be at least 3 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Phone
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          hintText: '+27 XX XXX XXXX',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          }
          if (value.length < 10) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Company
      TextFormField(
        controller: _companyController,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Company',
          hintText: 'Enter your company name',
          prefixIcon: Icon(Icons.business_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your company name';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildAccountInfoStep() {
    return [
      const Text(
        'Account Information',
        style: AppTheme.heading3,
      ),
      const SizedBox(height: 24),

      // Email
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Email Address',
          hintText: 'Enter your email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.contains('@') || !value.contains('.')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      const SizedBox(height: 24),

      // Info Box
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This email will be used for login and notifications',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSecurityStep() {
    return [
      const Text(
        'Security',
        style: AppTheme.heading3,
      ),
      const SizedBox(height: 24),

      // Password
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Create a strong password',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),

      // Confirm Password
      TextFormField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
      const SizedBox(height: 24),

      // Terms Checkbox
      CheckboxListTile(
        value: _acceptTerms,
        onChanged: (value) {
          setState(() {
            _acceptTerms = value ?? false;
          });
        },
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text.rich(
          TextSpan(
            text: 'I agree to the ',
            style: AppTheme.bodySmall,
            children: [
              TextSpan(
                text: 'Terms & Conditions',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _fullNameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _companyController.text.isNotEmpty;
    } else if (_currentStep == 1) {
      return _emailController.text.isNotEmpty &&
          _emailController.text.contains('@');
    }
    return true;
  }
}
