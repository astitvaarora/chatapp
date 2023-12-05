// ignore_for_file: prefer_const_constructors

import 'package:chatapp/Models/UIHelper.dart';
import 'package:chatapp/Models/UserModel_n.dart';
import 'package:chatapp/Pages/CompleteProfile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();

    if(email==""||password==""||cpassword==""){
      UIHelper.showAlertDialog(context, "Incomplete Data", "please fill all the fields");
    }else if(password!=cpassword){
      UIHelper.showAlertDialog(context, "Wrong Credentials", "Password Do Not Match");
    }else{
      signUp(email,password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Creating New Account..");

    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e){
      Navigator.pop(context);
      UIHelper.showAlertDialog(context,"An error occured",e.message.toString());
    }

    if(credential!=null){
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: ""

      );
      await FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .set(newUser.toMap());
      print("New User Created!");
      Navigator.popUntil(context, (route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.push(context,
      MaterialPageRoute(
        builder: (context) {
          return CompleteProfile(userModel:newUser,firebaseUser: credential!.user!);
        }
        ),
      );
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
                  TextField(
                    controller: cpasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Sign Up"),
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
              "Already have an account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Log In"),
            )
          ],
        ),
      ),
    );
  }
}
