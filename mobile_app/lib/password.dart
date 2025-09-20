import 'package:flutter/material.dart';
import 'package:mobile_app/home.dart';
import 'package:mobile_app/main.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Password extends StatelessWidget {
  const Password({Key? key}) : super(key: key);
  static const String _title = 'Mental Health App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ),
      ),
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
        backgroundColor: Colors.lightGreen[100],
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

  final _auth = FirebaseAuth.instance;
  final user = _auth.currentUser;

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/beach.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: DefaultTextStyle(
                        style: TextStyle(fontSize: 30, color: Colors.black),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText('Did you'),
                            TypewriterAnimatedText('forget your password?'),
                          ],
                        ))),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Password',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                  },
                  child: const Text(
                    'Back',
                  ),
                ),
                Container(
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        //COMPLETE : Update Password Code 
                        // null-aware call to firebase update operation
                        // used toast format from the adding user base code
                        try{
                        await user?.updatePassword(
                          passwordController.text.trim()
                        );
                        } catch (e) {
                           Fluttertoast.showToast(
                            msg:
                                "Enter a valid password and try again",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity
                                .BOTTOM, // Also possible "TOP" and "CENTER"
                          );
                          print(e);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      },
                    )),
              ],
            )));
  }
}
