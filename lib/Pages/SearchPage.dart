// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:developer';

import 'package:chatapp/Models/ChatRoomModel.dart';
import 'package:chatapp/Models/UserModel_n.dart';
import 'package:chatapp/Pages/ChatRoomPage.dart';
import 'package:chatapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {

  final UserModel userModel;
  final User firebaseUser;


  const SearchPage({super.key, required this.userModel , required this.firebaseUser}) ;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {

    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms")
    .where("participants.${widget.userModel.uid}", isEqualTo: true)
    .where("participants.${targetUser.uid}", isEqualTo: true).get();


    if(snapshot.docs.length > 0){
      // fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(docData as 
      Map<String, dynamic>);

      chatRoom = existingChatRoom;


    }else{
      // create a new one
       ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance.collection("chatrooms").doc
      (newChatroom.chatroomid).set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created");
    }
    return chatRoom;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Email Address"
                ),
              ),
        
              SizedBox(height: 20),
        
              CupertinoButton(
                child: Text("Search"),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: (){
                  setState(() {
                      
                  });
                }
              ),
        
              SizedBox(height: 20),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").where("email",isEqualTo: searchController.text.trim()).where("email",isNotEqualTo:widget.userModel.email).snapshots(),
                builder: (context , snapshot){
                  if(snapshot.connectionState == ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                      if(dataSnapshot.docs.length > 0){
                        Map<String ,dynamic> userMap = dataSnapshot.docs[0].data() as Map<String,dynamic>;
                        UserModel searchedUser = UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: ()async{
                            ChatRoomModel? chatRoomModel =  await getChatroomModel(searchedUser);

                            if(chatRoomModel!=null){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return ChatRoomPage(
                                  targetUser: searchedUser,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  chatroom: chatRoomModel,
                                );
                              }
                              ));

                            }


                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searchedUser.profilepic!),
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      }else{
                        return Text("No result found!!");
                      }

                    }else if(snapshot.hasError){
                      return Text("No error found!!");

                    }else{
                      return Text("No result found!!");
                    }

                  }else{
                    return CircularProgressIndicator();
                  }
                }
              ),
            ],
          ),
        )
      ),
    );
  }
}