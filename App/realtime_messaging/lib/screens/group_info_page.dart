
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtime_messaging/Services/groups_remote_services.dart';
import 'package:realtime_messaging/main.dart';
import 'package:realtime_messaging/screens/current_user_profile_page.dart';
import 'package:realtime_messaging/screens/otherUser_profile_page.dart';
import 'package:realtime_messaging/screens/search_within_group.dart';
import 'package:realtime_messaging/screens/user_info.dart';

import '../Models/groups.dart';
import 'dart:io';

import '../Models/users.dart';
import '../Services/users_remote_services.dart';
class GroupInfoPage extends StatefulWidget {
  final String groupId;
  const GroupInfoPage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Group? currentGroup;
  bool isloaded=false;
  bool photoUploading = false;
  bool nameUpdating = false;
  bool aboutUpdating = false;
  File ?_image;
  List<String> appUsersIds=[];
  List<String> appUserNumber=[];
  @override
  void initState() {
    super.initState();
    getCurrentGroup();
  }
  getCurrentGroup()async{
    currentGroup=await GroupsRemoteServices().getSingleGroup(widget.groupId);
    setState(() {
      isloaded=true;
    });
  }
  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) {
      return;
    }
    final imageTemp = File(image.path);
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      _image = imageTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:(isloaded)?
          ListView(
            children: [
              const SizedBox(
                height: 22,
              ),
              const Row(
                children: [
                  BackButton(),
                  SizedBox(
                    width: 18,
                  ),

                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Stack(children: [
                ClipOval(
                  child: Material(
                    child: (photoUploading)
                        ? const Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.purple,
                            ),
                            Text('Uploading Image'),
                          ],
                        ),
                      ),
                    )
                        : Image(
                      image: NetworkImage(currentGroup!.imageUrl!),
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                (currentGroup!.admins!.contains(cid))?Positioned(
                  bottom: 0,
                  right: 4,
                  child: ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      color: Colors.white,
                      child: ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          color: Colors.lightBlue,
                          child: IconButton(
                            onPressed: () {
                              SimpleDialog alert = SimpleDialog(
                                title: const Text("Choose an action"),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () async {
                                      await getImage(ImageSource.gallery);
                                      if (_image != null) {
                                        try {
                                          setState(() {
                                            photoUploading = true;
                                          });
                                          String photoUrl =
                                          await GroupsRemoteServices()
                                              .uploadNewImage(
                                              _image!, widget.groupId)
                                              .catchError((e) =>
                                          throw Exception(
                                              '$e'));
                                          GroupsRemoteServices().updateGroup(cid, {
                                            "imageUrl": photoUrl
                                          }).catchError(
                                                  (e) => throw Exception('$e'));
                                          setState(() {
                                            currentGroup!.imageUrl =
                                                photoUrl;
                                            photoUploading = false;
                                          });
                                        } on FirebaseException catch (e) {
                                          setState(() {
                                            photoUploading = false;
                                          });
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                                content:
                                                Text('${e.message}')));
                                        } catch (e) {
                                          setState(() {
                                            photoUploading = false;
                                          });
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                                content: Text('$e')));
                                        }
                                      }
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.photo,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          "Pick from gallery",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () async {
                                      await getImage(ImageSource.camera);
                                      if (_image != null) {
                                        try {
                                          setState(() {
                                            photoUploading = true;
                                          });
                                          String photoUrl =
                                          await GroupsRemoteServices()
                                              .uploadNewImage(
                                              _image!, widget.groupId)
                                              .catchError((e) =>
                                          throw Exception(
                                              '$e'));
                                          GroupsRemoteServices().updateGroup(cid, {
                                            "imageUrl": photoUrl
                                          }).catchError(
                                                  (e) => throw Exception('$e'));
                                          setState(() {
                                            photoUploading = false;
                                          });
                                        } on FirebaseException catch (e) {
                                          setState(() {
                                            photoUploading = false;
                                          });

                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                                content:
                                                Text('${e.message}')));
                                        } catch (e) {
                                          setState(() {
                                            photoUploading = false;
                                          });
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(SnackBar(
                                                content: Text('$e')));
                                        }
                                      }
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          "Capture from camera",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (currentGroup!.imageUrl !=
                                      "https://geodash.gov.bd/uploaded/people_group/default_group.png")
                                      ? SimpleDialogOption(
                                    onPressed: () async {
                                      try {
                                        setState(() {
                                          photoUploading = true;
                                        });

                                       GroupsRemoteServices().updateGroup(
                                            widget.groupId, {
                                          "imageUrl":
                                          "https://geodash.gov.bd/uploaded/people_group/default_group.png"
                                        }).catchError((e) =>
                                        throw Exception('$e'));
                                        setState(() {
                                          currentGroup!.imageUrl =
                                          "https://geodash.gov.bd/uploaded/people_group/default_group.png";
                                          photoUploading = false;
                                        });
                                      } on FirebaseException catch (e) {
                                        setState(() {
                                          photoUploading = false;
                                        });

                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                              content: Text(
                                                  '${e.message}')));
                                      } catch (e) {
                                        setState(() {
                                          photoUploading = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                              content: Text('$e')));
                                      }
                                      },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text(
                                          "Remove profile image",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                            FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : const SizedBox(
                                    height: 0,
                                    width: 0,
                                  ),
                                ],
                              );
                              showDialog(
                                context: context,
                                builder: (context) => alert,
                                barrierDismissible: true,
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ),
                  ),
                ):const SizedBox(),
              ]),
              const SizedBox(
                height: 10,
              ),
              Text((currentGroup!.name),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),),
              Text('Members: ${currentGroup!.participantIds.length}',
              style:const TextStyle(fontSize: 16,color: Colors.grey)),
              Container(
                color: Colors.grey[100],
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
               child: Text(currentGroup!.description??'',
               style: const TextStyle(fontSize: 18),),
              ),
              SizedBox(
                width: double.infinity,
                child: Text('Created by ${currentGroup!.createdBy},${currentGroup!.creationTimestamp.day}/${currentGroup!.creationTimestamp.month}/${currentGroup!.creationTimestamp.year}',
                  style: const TextStyle(fontSize: 16,color: Colors.grey),
                ),
              ),
              Container(
                color: Colors.grey[100],
                height: 20,
              ),

              StreamBuilder<List<Users>>(
                stream: RemoteServices().getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                        'Something went wrong !${snapshot.error}');
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: const Text(
                              ' Group participant will appear here'),
                        ));
                  } else {
                    final users = snapshot.data!;

                    appUsersIds =
                        users.map((user) => user.id).toList();
                    appUserNumber=users.map((user)=>user.id).toList();
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(currentGroup!.participantIds.length as String,
                              style: const TextStyle(color: Colors.grey,fontSize: 15),),
                            Spacer(),
                            IconButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchWithinGroup(ListItem: showableWidget(currentGroup!.admins!, currentGroup!.participantIds, context, appUsersIds, users), ListContent: convertToList(currentGroup!.admins!, currentGroup!.participantIds, appUsersIds, users))));
                            }, icon: const Icon(Icons.search))

                          ],
                        ),
                        Column(
                          children: getTopTen(showableWidget(currentGroup!.admins!, currentGroup!.participantIds, context, appUsersIds, users),convertToList(currentGroup!.admins!, currentGroup!.participantIds, appUsersIds, users),context),
                        ),
                      ],
                    );
                  }
                })

            ],
          )
            :const CircularProgressIndicator(
        color: Colors.deepPurpleAccent,
      ) ,
    );
  }
}
List<List<String>>convertToList(List<String> adminsids,List<String>participantIds,List<String> usersIds,List<Users> users){
  List<List<String>> returnableList=[[]];
  List<List<String>> aux=[[]];
  List<List<String>> extrAux=[[]];
  for(int i=0;i<adminsids.length;i++){
    int  pl=usersIds.indexOf(adminsids[i]);
    int   kl=savedNumber.indexOf(users[pl].phoneNo);
    if(kl!=-1){
      aux.add([savedUsers[kl],users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
    }
    else{
      extrAux.add([users[pl].name??'',users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
    }

  }
  List<List<String>> pAux=[[]];
  List<List<String>> epAux=[[]];
  for(int j=0;j<participantIds.length;j++){
    if(!adminsids.contains(participantIds[j])&& participantIds[j]!=cid){
      int pl=usersIds.indexOf(participantIds[j]);
      int kl=savedNumber.indexOf(users[pl].phoneNo);
      if(kl!=-1){
        pAux.add([savedUsers[kl],users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
      }
      else{
        epAux.add([users[pl].name??'',users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
      }

    }
  }
  aux.sort();
  extrAux.sort();
  pAux.sort();
  epAux.sort();
  returnableList.addAll(aux);
  returnableList.addAll(extrAux);
  returnableList.addAll(pAux);
  returnableList.addAll(epAux);
  return returnableList;

}

List<Widget> showableWidget(List<String> adminsids,List<String>participantIds,BuildContext context,List<String> usersIds,List<Users> users){
  List<Widget> admins=[];
  int index=usersIds.indexOf(cid);
  admins.add(ListTile(
    leading: InkWell(
      child: CircleAvatar(
        foregroundImage: NetworkImage('${users[index].photoUrl}'),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CurrentUserProfilePage()));
      },
    ),
    trailing: (adminsids.contains(cid))?Container(
      color: Colors.lightBlue,
      child: const Text('Admin',style: TextStyle(color: Colors.green),),
    ):const SizedBox(height: 0,),
    title: const Text('You'),
    subtitle: Text(
      '${users[index].about}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  ));
  List<List<String>> aux=[[]];
  List<List<String>> extrAux=[[]];
  for(int i=0;i<adminsids.length;i++){
    int  pl=usersIds.indexOf(adminsids[i]);
    int   kl=savedNumber.indexOf(users[pl].phoneNo);
    if(kl!=-1){
      aux.add([savedUsers[kl],users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
    }
    else{
      extrAux.add([users[pl].name??'',users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
    }

  }
  List<List<String>> pAux=[[]];
  List<List<String>> epAux=[[]];
  for(int j=0;j<participantIds.length;j++){
    if(!adminsids.contains(participantIds[j])&& participantIds[j]!=cid){
      int pl=usersIds.indexOf(participantIds[j]);
      int kl=savedNumber.indexOf(users[pl].phoneNo);
      if(kl!=-1){
        pAux.add([savedUsers[kl],users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
      }
      else{
        epAux.add([users[pl].name??'',users[pl].phoneNo,users[pl].photoUrl!,users[pl].about??'',users[pl].id]);
      }

    }
  }
  aux.sort();
  extrAux.sort();
  pAux.sort();
  epAux.sort();
  for(int i=0;i<aux.length;i++) {
    admins.add(ListTile(
      leading: InkWell(
        child: CircleAvatar(
          foregroundImage: NetworkImage('${aux[i][2]}'),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(

                  builder: (context) =>
                      OtherUserProfilePage(userId: aux[i][4] as String)));
        },
      ),
      trailing: Container(
        color: Colors.lightBlue,
        child: const Text('Admin', style: TextStyle(color: Colors.green),),
      ),
      title: Text(aux[i][0]),
      subtitle: Text(
        '${aux[i][3]}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }
  for(int i=0;i<extrAux.length;i++) {
    admins.add(ListTile(
      leading: InkWell(
        child: CircleAvatar(
          foregroundImage: NetworkImage(extrAux[i][2]),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(

                  builder: (context) =>
                      OtherUserProfilePage(userId: extrAux[i][4])));
        },
      ),
      trailing: Column(
        children: [
          const Text('Admin', style: TextStyle(color: Colors.green),),
           Text(extrAux[i][1]),
        ],
      ),
      title: Text(extrAux[i][0]),
      subtitle: Text(
        extrAux[i][3],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }
  for(int i=0;i<pAux.length;i++) {
    admins.add(ListTile(
      leading: InkWell(
        child: CircleAvatar(
          foregroundImage: NetworkImage(pAux[i][2]),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(

                  builder: (context) =>
                      OtherUserProfilePage(userId: pAux[i][4])));
        },
      ),

      title: Text(pAux[i][0]),
      subtitle: Text(
        pAux[i][3],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }
  for(int i=0;i<epAux.length;i++) {
    admins.add(ListTile(
      leading: InkWell(
        child: CircleAvatar(
          foregroundImage: NetworkImage(epAux[i][2]),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(

                  builder: (context) =>
                      OtherUserProfilePage(userId: epAux[i][4])));
        },
      ),
      trailing:Text(epAux[i][1]),
      title: Text(epAux[i][0]),
      subtitle: Text(
        epAux[i][3],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }

  return admins;
}
List<Widget> getTopTen(List<Widget> admins,List<List<String>> contentlist,BuildContext context){
  List<Widget> returnAble=[];
  for(int i=0;i<min(10,admins.length);i++){
    returnAble.add(admins[i]);
  }
  if(admins.length>10){
    returnAble.add(TextButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchWithinGroup(ListItem: admins, ListContent: contentlist)));
    }, child: Text('View All')));
  }
  return returnAble;
}