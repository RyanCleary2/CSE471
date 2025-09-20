import 'dart:math';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Groups extends StatelessWidget {
  const Groups({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController cmntController = TextEditingController();
  TextEditingController descController = TextEditingController();
  //group examples
  var _groupList = [];
  var _groupEntry = [];
  var _pubpriv = false;
  
  final _auth = FirebaseAuth.instance;
  

  //Made a seperate function to fetch groups so it can refresh after creating a new group
  //Allows for easier re-fetching of groups after creating a new one
  void fetchGroups() {
  FirebaseFirestore.instance.collection('groups').get().then((querySnapshot) {
    setState(() {
      _groupList = querySnapshot.docs.map((doc) => [
        doc.id,
        doc['visibility'],
        doc['creator'],
        doc['description'],
        doc['members'] ?? [], 
      ]).toList();
      _groupEntry = List.filled(_groupList.length, false);
    });
  });
}
  //Whenever the page is loaded fetch the groups from firestore
  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Group Creation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: cmntController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Group Name',
            ),
          ),
          SizedBox(height: 5),
          TextField(
            maxLines: null,
            controller: descController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          ),
          SizedBox(height: 5),
          //Dropdown for public/private option
          Row(
            children: <Widget>[
              Text("Visibility:"),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _pubpriv ? 'Public' : 'Private',
                items: <String>['Public', 'Private']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _pubpriv = newValue == 'Public';
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            String visibility = _pubpriv ? "Public" : "Private";
            FirebaseFirestore.instance.collection('groups').doc(cmntController.text).set({
              'visibility': visibility,
              'creator': _auth.currentUser!.email!,
              'description': descController.text,
              'members': [_auth.currentUser!.email!]
            }).then((_) {
              fetchGroups();
              Navigator.of(context).pop();
              cmntController.clear();
              descController.clear();
            });
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Create'),
        ),
        ElevatedButton(
          onPressed: () {
            fetchGroups(); // Refresh the group list to include the new group
            cmntController.clear();
            descController.clear();
            Navigator.of(context).pop();
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildGroupDialog(BuildContext context, index) {
    return AlertDialog(
      title: const Text('Group Description'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_groupList[index][3],
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12))
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            // show corresponding group description after click
            // your codes begin here
            // Add user to the group's members array in Firestore
            FirebaseFirestore.instance.collection('groups').doc(_groupList[index][0])
            .update({
              'members': FieldValue.arrayUnion([_auth.currentUser!.email!])
            });
            setState(() {
              _groupEntry[index] = true;
            });
            Navigator.of(context).pop();

            // end
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Join'),
        ),
        ElevatedButton(
          onPressed: () {
            // your codes begin here
            // close the dialog and do not join the group
            Navigator.of(context).pop();
            setState(() {
              _groupEntry[index] = false;
            });

            // end
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade300),
          child: const Text('Close'),
        ),
      ],
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Location",
        home: Scaffold(
            backgroundColor: Colors.lightGreen[100],
            body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/assets/mountain.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen.shade300,
                              minimumSize: Size(64, 64),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  side: BorderSide(
                                      color: Colors.lightGreen.shade300)),
                            ),
                            child: Icon(
                              Icons.home,
                              size: 30.0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()),
                              );
                            },
                          ),
                          SizedBox(width: 60),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade300),
                            child: const Text('Create a Group'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildPopupDialog(context),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Existing Groups",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.indigo.shade300),
                      ),
                      SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                                height: 30,
                                width: 380,
                                alignment: Alignment.center,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                          width: 95,
                                          child: Text(
                                            "Name",
                                            style: TextStyle(
                                                color: Colors.indigo.shade500),
                                          )),
                                      Container(
                                          width: 75,
                                          child: Text(
                                            "Visibility",
                                            style: TextStyle(
                                                color: Colors.indigo.shade500),
                                          )),
                                      Container(
                                          width: 110,
                                          child: Text(
                                            "Creator",
                                            style: TextStyle(
                                                color: Colors.indigo.shade500),
                                          )),
                                      Container(width: 95, child: Text("")),
                                    ])),
                          ]),
                      Divider(color: Colors.black),
                      Expanded(
                          child: SizedBox(
                        height: 200.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _groupList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final members = _groupList[index][4] as List;
                            final isMember = members.contains(_auth.currentUser!.email!);
                            return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                      height: 70,
                                      width: 380,
                                      alignment: Alignment.center,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                                width: 95,
                                                child: Text(
                                                  _groupList[index][0],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors
                                                          .indigo.shade500),
                                                )),
                                            Container(
                                                width: 50,
                                                child: Text(
                                                  _groupList[index][1],
                                                  style: TextStyle(
                                                      color: Colors
                                                          .indigo.shade500),
                                                )),
                                            Container(
                                                width: 110,
                                                child: Text(
                                                  _groupList[index][2],
                                                  style: TextStyle(
                                                      color: Colors
                                                          .indigo.shade500),
                                                )),
                                            Container(
                                              width: 95,
                                              child: (() {
                                                if (isMember) {
                                                  return Icon(Icons.check);
                                                } else if (_groupList[index][1] == "Public") {
                                                  return ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.indigo.shade300),
                                                    child: Text('Join Group',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 12)),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) =>
                                                            _buildGroupDialog(context, index),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  return ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.indigo.shade300),
                                                    child: Icon(Icons.check),
                                                    onPressed: () => {},
                                                  );
                                                }
                                              })(),
                                            )
                                          ])),
                                ]);
                          },
                        ),
                      ))
                    ],
                  ),
                )))));
  }
}
