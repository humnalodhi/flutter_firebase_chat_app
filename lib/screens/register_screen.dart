import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/consts.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';
import 'package:flutter_firebase_chat_app/services/alert_service.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/database_service.dart';
import 'package:flutter_firebase_chat_app/services/media_service.dart';
import 'package:flutter_firebase_chat_app/services/navigation_service.dart';
import 'package:flutter_firebase_chat_app/services/storage_service.dart';
import 'package:flutter_firebase_chat_app/widgets/custom_form_field.dart';
import 'package:get_it/get_it.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final registerFormKey = GlobalKey<FormState>();
  final GetIt getIt = GetIt.instance;

  String? name, email, password;
  bool isLoading = false;

  late AuthService authService;
  late AlertService alertService;
  late MediaService mediaService;
  late NavigationService navigationService;
  late StorageService storageService;
  late DatabaseService databaseService;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    mediaService = getIt.get<MediaService>();
    navigationService = getIt.get<NavigationService>();
    authService = getIt.get<AuthService>();
    storageService = getIt.get<StorageService>();
    alertService = getIt.get<AlertService>();
    databaseService = getIt.get<DatabaseService>();
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
                      "Let's get going!",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Register and account using the form below",
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
                height: MediaQuery.sizeOf(context).height * 0.60,
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.05,
                ),
                child: Form(
                  key: registerFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          File? file = await mediaService.getImageFromGallery();
                          if (file != null) {
                            setState(() {
                              selectedImage = file;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.15,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : const AssetImage('assets/placeholder.png'),
                        ),
                      ),
                      CustomFormField(
                        onSaved: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        obscureText: false,
                        validationRegExp: NAME_VALIDTAION_REGEX,
                        hintText: 'Name',
                        height: MediaQuery.sizeOf(context).height * 0.1,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      if ((registerFormKey.currentState?.validate() ?? false) &&
                          selectedImage != null) {
                        registerFormKey.currentState?.save();
                        bool result = await authService.signup(
                          email!,
                          password!,
                        );
                        // name = null;
                        // email = null;
                        // password = null;
                        print(result);
                        if (result) {
                          String? pfpUrl = await storageService.uploadUserPfp(
                            file: selectedImage!,
                            uid: authService.user!.uid,
                          );
                          if (pfpUrl != null) {
                            await databaseService.createUserProfile(
                              userProfile: UserProfile(
                                uid: authService.user!.uid,
                                name: name,
                                pfpUrl: pfpUrl,
                              ),
                            );
                            alertService.showToast(
                              text: "User registered successfully!",
                              icon: Icons.check,
                            );
                            navigationService.pushReplacementNamed("/login");
                          } else {
                            throw Exception(
                                "Unable to upload user profile picture.");
                          }
                          print(result);
                        } else {
                          throw Exception("Unable to register user.");
                        }
                      }
                    } catch (e) {
                      print("Exception: $e");
                      alertService.showToast(
                        text: "Failed to register, Please try again!",
                        icon: Icons.error,
                      );
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: isLoading == true
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          ),
                        )
                      : const Text(
                          'Register',
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
                      "Already have an account? ",
                    ),
                    InkWell(
                      onTap: () {
                        navigationService.pushNamed("/login");
                      },
                      child: const Text(
                        "Login",
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
