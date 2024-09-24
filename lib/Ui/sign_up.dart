import 'package:flutter/material.dart';
import 'package:quizeclipse/services/auth_services/auth_gate.dart';
import 'package:quizeclipse/shared_widgets/appbar.dart';
import 'package:quizeclipse/services/auth_services/auth.dart';
import 'package:quizeclipse/Ui/sign_in.dart';
import 'package:quizeclipse/shared_widgets/dialog.dart';

enum UserRole { admin, participant }

class SignUp extends StatefulWidget {
  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.admin;
  bool _isLoading = false;

  bool _validateForm() {
    return _formKey.currentState!.validate();
  }

  void _signUpHandler() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      errorDialogBox(context, "Password and Confirm Password should be the same");
      return;
    }
    if (_validateForm()) {
      setState(() => _isLoading = true);
      final AuthService authService = AuthService();
      try {
        await authService.signUpWithEmailPassword(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _selectedRole.toString(),
        );
        redirectDialogBox(
          context,
          "Sign up is successful. Click OK to continue",
          AuthGate(),
        );
      } catch (e) {
        errorDialogBox(context, e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? "Enter password" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) => val!.isEmpty ? "Confirm your password" : null,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Select your role",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: [
                        RadioListTile<UserRole>(
                          title: const Text('Admin'),
                          value: UserRole.admin,
                          groupValue: _selectedRole,
                          onChanged: (UserRole? value) {
                            setState(() => _selectedRole = value!);
                          },
                        ),
                        RadioListTile<UserRole>(
                          title: const Text('Participant'),
                          value: UserRole.participant,
                          groupValue: _selectedRole,
                          onChanged: (UserRole? value) {
                            setState(() => _selectedRole = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUpHandler,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
                        },
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}