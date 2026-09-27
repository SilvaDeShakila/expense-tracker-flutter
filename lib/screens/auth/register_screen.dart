import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginTap;

  const RegisterScreen({
    super.key,
    required this.onLoginTap,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
          await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(
          _nameController.text.trim(),
        );

        await _authService.createUserProfile(
          uid: user.uid,
          fullName: _nameController.text,
          email: _emailController.text,
        );

        await _authService.sendEmailVerification();

        if (!mounted) return;

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              icon: Icon(
                Icons.mark_email_unread_outlined,
                size: 46,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
              title: const Text(
                'Verify your email',
              ),
              content: Text(
                'We sent a verification link to '
                '${_emailController.text.trim()}.\n\n'
                'Please open your email and verify your '
                'account before signing in.',
              ),
              actions: [
                FilledButton(
                  onPressed: () async {
                    await _authService.logout();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Continue to Sign In',
                  ),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'An account already exists with this email.';
          break;

        case 'invalid-email':
          message =
              'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
              'Password is too weak. Use at least 6 characters.';
          break;

        case 'network-request-failed':
          message =
              'Network error. Please check your connection.';
          break;

        case 'operation-not-allowed':
          message =
              'Email/password sign-up is currently unavailable.';
          break;

        default:
          message =
              'Unable to create your account. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons
                            .person_add_alt_1_rounded,
                        color:
                            colorScheme.onPrimary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Create your account',
                      style: theme
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking your expenses with a secure account.',
                      style: theme
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Full name',
                      style: theme
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:
                          _nameController,
                      textCapitalization:
                          TextCapitalization.words,
                      textInputAction:
                          TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.name,
                      ],
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Enter your full name',
                        prefixIcon: Icon(
                          Icons
                              .person_outline,
                        ),
                      ),
                      validator: (value) {
                        final name =
                            value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Full name is required.';
                        }

                        if (name.length < 2) {
                          return 'Please enter a valid name.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Email address',
                      style: theme
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction:
                          TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Enter your email',
                        prefixIcon: Icon(
                          Icons
                              .email_outlined,
                        ),
                      ),
                      validator: (value) {
                        final email =
                            value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Email is required.';
                        }

                        final emailRegex =
                            RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex
                            .hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Password',
                      style: theme
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      textInputAction:
                          TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.newPassword,
                      ],
                      decoration:
                          InputDecoration(
                        hintText:
                            'Create a password',
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          tooltip:
                              _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final password =
                            value ?? '';

                        if (password.isEmpty) {
                          return 'Password is required.';
                        }

                        if (password.length < 6) {
                          return 'Use at least 6 characters.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Confirm password',
                      style: theme
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      textInputAction:
                          TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.newPassword,
                      ],
                      onFieldSubmitted:
                          (_) => _register(),
                      decoration:
                          InputDecoration(
                        hintText:
                            'Re-enter your password',
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_reset_outlined,
                        ),
                        suffixIcon:
                            IconButton(
                          tooltip:
                              _obscureConfirmPassword
                                  ? 'Show password'
                                  : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm your password.';
                        }

                        if (value !=
                            _passwordController.text) {
                          return 'Passwords do not match.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child:
                          FilledButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : _register,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .person_add_alt_1,
                              ),
                        label: Text(
                          _isLoading
                              ? 'Creating account...'
                              : 'Create Account',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        alignment:
                            WrapAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : widget
                                        .onLoginTap,
                            child:
                                const Text(
                              'Sign in',
                            ),
                          ),
                        ],
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
}