import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

//hey
void main()async{
 // final ref=FirebaseFirestore.instance;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

List<Contact> contacts=[];
bool isg=false;
bool isloading=false;


  @override
  void initState(){
    super.initState();
    getContactPermission();


  }
  void getContactPermission()async{
   if(await Permission.contacts.isGranted){
     fetchContact();
    setState(() {
      isg=true;
    });

   }
   else{
     await Permission.contacts.request();
     if( await Permission.contacts.isGranted){
       fetchContact();
        setState(() {
          isg=true;
        });
      debugPrint(isg as String?);
     }


   }

  }
  void fetchContact()async {
    contacts=await FlutterContacts.getContacts();
  }

  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title:  Text('people'),
      ),

      body:isg==false?Center(child: Text('please restart the app and provide the permission to continue')):isloading?CircularProgressIndicator():ListView.builder(
          itemCount: contacts.length,
          itemBuilder:(context,index)=>ListTile(title: Text(contacts[index].displayName!),) )
    );
  }
}
