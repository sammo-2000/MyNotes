import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/widgets/button.dart';
import 'package:notes/widgets/forms/input.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String errorMessege = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Change page between login & signup
  bool loginPage = true;
  void changePage() {
    setState(() {
      loginPage = !loginPage;
    });
  }

  // Create new user
  void createUser() async {
    try {
      validateEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "invalid-credential") {
          errorMessege = "Incorrect credential";
        } else {
          errorMessege = e.message.toString();
        }
      });
    } catch (e) {
      setState(() {
        errorMessege = e.toString();
      });
    }
  }

  // Login the user
  void loginUser() async {
    try {
      validateEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "invalid-credential") {
          errorMessege = "Incorrect credential";
        } else {
          errorMessege = e.message.toString();
        }
      });
    } catch (e) {
      setState(() {
        errorMessege = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            loginPage ? const Text('L O G I N') : const Text('S I G N    U P '),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(
              controller: emailController,
              label: 'Email',
            ),
            CustomInput(
              controller: passwordController,
              label: 'Password',
              obscureText: true,
            ),
            if (errorMessege == "")
              const SizedBox()
            else
              CustomButton(
                label: errorMessege,
                icon: Icons.error,
                color: Colors.red,
                onClick: () {},
              ),
            if (loginPage)
              Column(
                children: [
                  CustomButton(
                    label: 'Login',
                    icon: Icons.login,
                    onClick: loginUser,
                  ),
                  CustomButton(
                    label: 'Don\'t have an account',
                    icon: Icons.add,
                    onClick: changePage,
                    color: Colors.black,
                  ),
                ],
              )
            else
              Column(
                children: [
                  CustomButton(
                    label: 'Sign Up',
                    icon: Icons.login,
                    onClick: createUser,
                  ),
                  CustomButton(
                    label: 'Already have an account',
                    icon: Icons.verified_user,
                    onClick: changePage,
                    color: Colors.black,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void validateEmailAndPassword(
    {required String email, required String password}) {
  // Email validation regex pattern
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // Check if email is empty
  if (email.isEmpty) {
    throw 'Email cannot be empty';
  }
  // Check if email format is valid
  if (!emailRegex.hasMatch(email)) {
    throw 'Invalid email format';
  }
  // Check if password is empty
  if (password.isEmpty) {
    throw 'Password cannot be empty';
  }
  // Check if password length is at least 6 characters
  if (password.length < 6) {
    throw 'Password must be at least 6 characters';
  }
}
