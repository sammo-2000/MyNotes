import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/widget/button.dart';
import 'package:notes/widget/form/input.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? errorMessege;
  bool isLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void validateInfo() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      throw "Email & Password are required";
    }
  }

  void signInWithEmailAndPassword() async {
    try {
      validateInfo();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "invalid-credential") {
          errorMessege = "Incorrect credential";
        } else {
          errorMessege = e.message;
        }
      });
    } catch (e) {
      setState(() {
        errorMessege = e.toString();
      });
    }
  }

  void createUserWithEmailAndPassword() async {
    try {
      validateInfo();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "invalid-credential") {
          errorMessege = "Incorrect credential";
        } else {
          errorMessege = e.message;
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
      appBar: AppBar(title: Text(isLogin ? 'L O G I N' : 'S I G N   U P')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              CustomInput(controller: emailController, label: 'Email'),
              CustomInput(controller: passwordController, label: 'Password', obscureText: true),
              errorMessege != "" && errorMessege != null
                  ? CustomButton(
                      label: errorMessege.toString(),
                      icon: Icons.error,
                      onClick: () {},
                      color: Colors.red,
                    )
                  : const SizedBox(),
              isLogin
                  ? Column(
                      children: [
                        CustomButton(
                            label: 'Login',
                            icon: Icons.login,
                            onClick: signInWithEmailAndPassword),
                        CustomButton(
                          label: 'Don\'t have an account?',
                          icon: Icons.supervised_user_circle_rounded,
                          color: Colors.black,
                          onClick: () {
                            setState(
                              () {
                                isLogin = !isLogin;
                              },
                            );
                          },
                        )
                      ],
                    )
                  : Column(
                      children: [
                        CustomButton(
                            label: 'Sign Up',
                            icon: Icons.login,
                            onClick: createUserWithEmailAndPassword),
                        CustomButton(
                          label: 'Already have an account',
                          icon: Icons.supervised_user_circle_rounded,
                          color: Colors.black,
                          onClick: () {
                            setState(
                              () {
                                isLogin = !isLogin;
                              },
                            );
                          },
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
