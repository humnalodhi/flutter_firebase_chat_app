import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/consts.dart';
import 'package:flutter_firebase_chat_app/services/alert_service.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/navigation_service.dart';
import 'package:flutter_firebase_chat_app/widgets/custom_form_field.dart';
import 'package:get_it/get_it.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginFormKey = GlobalKey<FormState>();
  String? email, password;
  final GetIt getIt = GetIt.instance;

  late AuthService authService;
  late NavigationService navigationService;
  late AlertService alertService;

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    navigationService = getIt.get<NavigationService>();
    alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hi, Welcome Back!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Hello again, you've been missed.",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.40,
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.05,
                ),
                child: Form(
                  key: loginFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomFormField(
                        onSaved: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                        obscureText: false,
                        validationRegExp: EMAIL_VALIDATION_REGEX,
                        hintText: 'Email',
                        height: MediaQuery.sizeOf(context).height * 0.1,
                      ),
                      CustomFormField(
                        onSaved: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        obscureText: true,
                        validationRegExp: PASSWORD_VALIDATION_REGEX,
                        hintText: 'Password',
                        height: MediaQuery.sizeOf(context).height * 0.1,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: MaterialButton(
                  onPressed: () async {
                    if (loginFormKey.currentState?.validate() ?? false) {
                      loginFormKey.currentState?.save();
                      bool result = await authService.login(
                        email!,
                        password!,
                      );
                      print(result);
                      if (result) {
                        navigationService.pushReplacementNamed("/home");
                      } else {
                        alertService.showToast(
                          text: "Failed to login, Please try again!",
                          icon: Icons.error,
                        );
                      }
                    }
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      "Don't have an account? ",
                    ),
                    InkWell(
                      onTap: () {
                        navigationService.pushNamed("/register");
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
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
