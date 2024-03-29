import 'package:flutter/material.dart';
import 'package:hse_assassin/views/pages/edit.dart';
// import 'package:hse_assassin/views/testview.dart';

import 'util/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:hse_assassin/views/main_view.dart';
import 'package:hse_assassin/views/register_view.dart';
import 'package:hse_assassin/views/login_view.dart';
import 'package:hse_assassin/views/welcome_view.dart';
import 'package:hse_assassin/views/info_view.dart';
import 'package:hse_assassin/views/game_choice_view.dart';

import 'package:hse_assassin/constants/routes.dart';
import 'package:hse_assassin/constants/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DismissKeyboard(
      child: MaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const MyApp(), // const TestView(),
        routes: {
          welcomeRoute: (context) => const WelcomeView(),
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          homeRoute: (context) => const MainView(),
          infoRoute: (context) => const InfoView(),
          editRoute: (context) => const EditView(),
          gameChoiceRoute: (context) => const GameChoiceView(),
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: startRouting(),
      builder: (context, AsyncSnapshot<Widget> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return snapshot.data!;
          default:
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: textLoading,
                            style: TextStyle(
                              color: kCyanColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircularProgressIndicator(
                      color: kCyanColor,
                    )
                  ],
                ),
              ),
              backgroundColor: kBlackColor,
            );
        }
      },
    );
  }
}

Future<Widget> startRouting() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
    return const WelcomeView();
  } else {
    // return const WelcomeView();
    final userRef = FirebaseDatabase.instance
        .ref('users/${FirebaseAuth.instance.currentUser!.uid}');
    final event = await userRef.once();
    final userSnapshot = event.snapshot;
    final hasInfo = userSnapshot.child('has_info').value;
    final hasChosenGame = userSnapshot.child('has_chosen_game').value;
    if (hasChosenGame == true) {
      return const MainView();
    } else if (hasInfo == true) {
      return const GameChoiceView();
    } else if (hasChosenGame == false && hasInfo == false) {
      return const InfoView();
    } else {
      return const WelcomeView();
    }
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}
