import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:hse_assassin/constants/constants.dart';
import 'package:hse_assassin/constants/routes.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPass;
  bool isPassObscure = true;
  String? errorMessage;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPass = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    OutlineInputBorder border = const OutlineInputBorder(
        borderSide: BorderSide(color: kGreyColor, width: 3.0));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhiteColor,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.2,
                    child:
                        Image.asset('assets/images/thunderbirdCrosshair.png'),
                  ),
                  // RichText(
                  //   textAlign: TextAlign.center,
                  //   text: const TextSpan(
                  //     children: <TextSpan>[
                  //       TextSpan(
                  //         text: textRegisterTitle,
                  //         style: TextStyle(
                  //             color: kBlackColor,
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 30),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const Text(
                  //   textRegisterSubtitle,
                  //   style: TextStyle(
                  //     color: kDarkGreyColor,
                  //   ),
                  // ),
                  SizedBox(
                    height: size.height * 0.05,
                    width: size.width * 0.8,
                    child: errorMessage == null
                        ? null
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(FontAwesomeIcons.circleExclamation,
                                  color: kErrorColor),
                              Text(errorMessage ?? '',
                                  style: const TextStyle(color: kErrorColor)),
                            ],
                          ),
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        hintText: textHintEmail,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 10.0,
                        ),
                        enabledBorder: border,
                        focusedBorder: border,
                      ),
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: TextField(
                      controller: _password,
                      decoration: InputDecoration(
                        hintText: textHintPass,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 10.0,
                        ),
                        enabledBorder: border,
                        focusedBorder: border,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPassObscure = !isPassObscure;
                            });
                          },
                          icon: isPassObscure
                              ? const FaIcon(
                                  FontAwesomeIcons.eyeSlash,
                                  size: 17,
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.eye,
                                  size: 17,
                                ),
                        ),
                      ),
                      obscureText: isPassObscure,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: TextField(
                      controller: _confirmPass,
                      decoration: InputDecoration(
                        hintText: textHintConfirm,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 10.0,
                        ),
                        enabledBorder: border,
                        focusedBorder: border,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPassObscure = !isPassObscure;
                            });
                          },
                          icon: isPassObscure
                              ? const FaIcon(
                                  FontAwesomeIcons.eyeSlash,
                                  size: 17,
                                )
                              : const FaIcon(
                                  FontAwesomeIcons.eye,
                                  size: 17,
                                ),
                        ),
                      ),
                      obscureText: isPassObscure,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: size.height * 0.04,
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.8,
                      child: OutlinedButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          final confirm = _confirmPass.text;
                          if (confirm != password) {
                            setState(() {
                              errorMessage = textErrorNoMatch;
                            });
                          } else {
                            try {
                              final userCredential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              final databaseRef =
                                  FirebaseDatabase.instance.ref();
                              final usersRef = databaseRef.child('users');
                              final userRef =
                                  usersRef.child(userCredential.user!.uid);
                              await userRef.set({
                                "has_info": false,
                                "has_chosen_game": false,
                              });
                              if (!mounted) return;
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                infoRoute,
                                (_) => false,
                              );
                            } on FirebaseAuthException catch (e) {
                              devtools.log(e.code);
                              if (e.code == 'weak-password') {
                                setState(() {
                                  errorMessage = textErrorWeakPassword;
                                });
                              } else if (e.code == 'email-already-in-use') {
                                setState(() {
                                  errorMessage = textErrorUserExists;
                                });
                              } else if (e.code == 'invalid-email') {
                                setState(() {
                                  errorMessage = textErrorInvalidEmail;
                                });
                              }
                            }
                          }
                        },
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(kWhiteColor),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kBlackColor),
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide.none)),
                        child: const Text(textSignUp),
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                            text: textHaveAcc,
                            style: TextStyle(
                              color: kDarkGreyColor,
                            ),
                          ),
                          TextSpan(
                            text: textLogin,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kRedColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  loginRoute,
                                  (_) => false,
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
