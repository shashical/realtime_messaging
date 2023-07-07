import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:realtime_messaging/Services/remote_services.dart';
import 'package:realtime_messaging/screens/search_contacts.dart';
import 'package:realtime_messaging/screens/user_info.dart';

import '../Models/users.dart';
import '../Services/users_remote_services.dart';
import '../main.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String? chatId;
  final String? userId;
  const OtherUserProfilePage({Key? key, this.chatId, this.userId})
      : super(key: key);

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  String id = '';
  bool userLoaded = false;
  Users? user;
  int index = -1;
  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getId() {
    if (widget.userId != null) {
      id = widget.userId!;
    } else if (widget.chatId!.startsWith(cid)) {
      id = widget.chatId!.substring(cid.length);
    } else {
      id = widget.chatId!.substring(0, widget.chatId!.length - cid.length);
    }
  }

  void getUser() async {
    getId();
    try {
      user = await RemoteServices()
          .getSingleUser(id)
          .catchError((e) => throw Exception('$e'));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$e')));
    }
    setState(() {
      userLoaded = true;
      index = savedNumber.indexOf(user!.phoneNo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
        body: (userLoaded)
            ? Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical:20 ,horizontal: 35),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset.fromDirection(2,3),
                        blurRadius: 0.5,
                        spreadRadius: 3.0,
                        color: Colors.black),
                    BoxShadow(
                        offset: Offset.fromDirection(1,2),
                        blurRadius: 0.5,
                        spreadRadius: 3.0,
                        color: Colors.white),
                    BoxShadow(
                        offset: Offset.fromDirection(3,2),
                        blurRadius: 0.5,
                        spreadRadius: 3.0,
                        color: Colors.black),

                  ],
                  borderRadius: BorderRadius.circular(30)
                ),

                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:  const Color.fromARGB(255, 253, 0, 70),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset.fromDirection(4,2),
                                  blurRadius: 0.5,
                                  spreadRadius: 3.0,
                                  color: Colors.black),
                              BoxShadow(
                                  offset: Offset.fromDirection(2,2),
                                  blurRadius: 0.5,
                                  spreadRadius: 3.0,
                                  color: Colors.white)
                            ],
                            borderRadius: BorderRadius.circular(10)
                              
                          ),
                          child: Stack(children: [
                            ClipOval(
                              child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ClipOval(
                                    child: Material(
                                      child: Image(
                                        image: NetworkImage(user!.photoUrl!),
                                        fit: BoxFit.cover,
                                        width: 200,
                                        height: 200,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: ClipOval(
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  color: Colors.white,
                                  child: ClipOval(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      color: (user!.isOnline!)
                                          ? const Color.fromARGB(255, 0, 228, 31)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]),
                        ),

                        (!user!.isOnline!)
                            ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  'last seen: ${user!.lastOnline!.hour}:${(user!.lastOnline!.minute) ~/ 10}${(user!.lastOnline!.minute) % 10} on ${user!.lastOnline!.day}/${user!.lastOnline!.month}/${user!.lastOnline!.year}'),
                            )
                            : const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Online Now',style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 22
                          ),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            (index != -1) ? savedUsers[index] : user!.name!,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            '${user!.phoneNo.substring(0, 3)} ${user!.phoneNo.substring(3)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        Container(
                          color: Colors.white70,
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              user!.about!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
            )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 5,
                ),
              ));
  }
}
