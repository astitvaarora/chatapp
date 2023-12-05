// ignore_for_file: prefer_const_constructors
import 'package:chatapp/Models/UserModel_n.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/pages/HomePage.dart';
import 'package:chatapp/pages/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


var uuid = Uuid();

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if(currentUser!=null){
    UserModel? thisUserModel = (await FirebaseHelper.getUserModelById(currentUser.uid)) as UserModel;
    if(thisUserModel!=null){
      return runApp(MainAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }else{
      return runApp(MainApp());
    }
  }else{
    return runApp(MainApp());
  }

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class MainAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MainAppLoggedIn({super.key,required this.userModel , required this.firebaseUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel,firebaseUser: firebaseUser,),
    );
  }
}
