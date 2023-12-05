// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:chatapp/Models/UIHelper.dart';
import 'package:chatapp/Models/UserModel_n.dart';
import 'package:chatapp/Pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();


  void selectImage(ImageSource source) async{
    XFile? pickedFile =   await ImagePicker().pickImage(source: source);

    if(pickedFile!= null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async{
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20
      );

    if(croppedImage!= null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
         ),
         title: Text("Upload Profile Picture"),
         content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                selectImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Galary"),
            ),

            ListTile(
              onTap: (){
                selectImage(ImageSource.camera);
                Navigator.pop(context);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
            )
          ],
         ),
      );
    }); 
  }

  void checkValues(){
    String fullname = fullNameController.text.trim();

    if(fullname=="" || imageFile==null){
      UIHelper.showAlertDialog(context,"Incomplete Data","Please fill all the fields");
    
    }else{
      uploadData();
    }
  }

  void uploadData() async {


    UIHelper.showLoadingDialog(context, "Uploading image..");
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilepictures").
    child(widget.userModel.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask; 

    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("users")
    .doc(widget.userModel.uid)
    .set(widget.userModel.toMap()).then((value){
      print("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute
      (builder: (context){
        return HomePage(userModel:widget.userModel, firebaseUser: widget.firebaseUser);
      }));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 40
            ),
            children: [

              SizedBox(height: 20),

              CupertinoButton(
                onPressed: (){
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  backgroundImage:(imageFile!=null) ?  FileImage(imageFile!):null,
                  radius: 60,
                  child: (imageFile == null) ? Icon(Icons.person,size: 60,):null,
                ),
              ),

              SizedBox(height: 20),

              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),
              SizedBox(height: 20),

              CupertinoButton(
                child: Text("Submit"),
                onPressed:(){
                  checkValues();
      
                },
                color: Theme.of(context).colorScheme.secondary,
        
              )
            ],
          ),
        ),
      ),
    );
  }
}