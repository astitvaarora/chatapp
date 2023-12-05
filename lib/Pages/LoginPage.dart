// ignore_for_file: prefer_const_constructors

import 'package:chatapp/Models/UIHelper.dart';
import 'package:chatapp/Models/UserModel_n.dart';
import 'package:chatapp/Pages/HomePage.dart';
import 'package:chatapp/Pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      UIHelper.showAlertDialog(context, "Incomplete data", "Please fill all the fields");
    }else{
      logIn(email, password);
    }
  }

  void logIn(String email , String password) async{
    UserCredential? credentials;

    UIHelper.showLoadingDialog(context, "Loggin In..");

    try{
      credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email:email,password:password);
    }on FirebaseAuthException catch(e){
      // close the loading dialog
      Navigator.pop(context);

      //show alert dialog 
      UIHelper.showAlertDialog(context,"An error occured", e.message.toString());
    }
    if(credentials!=null){

      String uid = credentials.user!.uid;

      DocumentSnapshot userData = 
      await FirebaseFirestore
      .instance.collection('users')
      .doc(uid)
      .get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String,dynamic>);
      print("Log In sucessful");

      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
        return HomePage(userModel: userModel, firebaseUser: credentials!.user!);
      }));
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: (){
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Log in"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 16
              ),
            ),
            CupertinoButton(
              child: Text("Sign Up"),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context){
                      return SignUpPage();
                    }
                  )
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
