import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ungconstructor14march/utility/my_style.dart';
import 'package:ungconstructor14march/utility/normal_dialog.dart';
import 'package:ungconstructor14march/widget/my_service.dart';
import 'package:ungconstructor14march/widget/register.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Field
  bool status = true;
  String user, password;

  // Method

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    if (firebaseUser != null) {
      routeToMyService();
    } else {
      setState(() {
        status = false;
      });
    }
  }

  void routeToMyService() {
    MaterialPageRoute route =
        MaterialPageRoute(builder: (value) => MyService());
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
  }

  Widget registerButton() {
    return Container(
      width: 250.0,
      child: FlatButton(
        onPressed: () {
          print('You Click Register');

          MaterialPageRoute route =
              MaterialPageRoute(builder: (BuildContext context) {
            return Register();
          });
          Navigator.of(context).push(route);
        },
        child: Text(
          'New Register',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.pink,
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    return Container(
      width: 250.0,
      child: RaisedButton(
        color: MyStyle().primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          if (user == null ||
              user.isEmpty ||
              password == null ||
              password.isEmpty) {
            normalDialog(context, 'Have Space', 'Please Fill Every Blank');
          } else {
            checkAuthen();
          }
        },
      ),
    );
  }

  Future<void> checkAuthen() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth
        .signInWithEmailAndPassword(email: user, password: password)
        .then((value) {
          routeToMyService();
        })
        .catchError((value) {
          String title = value.code;
          String message = value.message;
          normalDialog(context, title, message);
        });
  }

  Widget userForm() {
    return Container(
      decoration: BoxDecoration(
        color: MyStyle().lightColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: 35.0,
      width: 250.0,
      child: TextField(
        onChanged: (value) => user = value.trim(),
        keyboardType: TextInputType.emailAddress,
        style: MyStyle().h3Style,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: MyStyle().h3Style,
          hintText: 'User :',
          prefixIcon: Icon(
            Icons.email,
            color: MyStyle().darkColor,
          ),
        ),
      ),
    );
  }

  Widget passwordForm() {
    return Container(
      decoration: BoxDecoration(
        color: MyStyle().lightColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: 35.0,
      width: 250.0,
      child: TextField(
        onChanged: (value) => password = value.trim(),
        obscureText: true,
        keyboardType: TextInputType.text,
        style: MyStyle().h3Style,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: MyStyle().h3Style,
          hintText: 'Password :',
          prefixIcon: Icon(
            Icons.lock_open,
            color: MyStyle().darkColor,
          ),
        ),
      ),
    );
  }

  Widget showAppName() {
    return Text(
      'Ung Constructor',
      style: GoogleFonts.righteous(textStyle: MyStyle().h1Style),
    );
  }

  Widget showLogo() {
    return Container(
      width: 120.0,
      child: Image.asset('images/logo.png'),
    );
  }

  Widget mySizeBox() {
    return SizedBox(
      height: 12.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: status ? showProcess() : mainContent(),
    );
  }

  Widget showProcess() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Container mainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.3,
          colors: <Color>[Colors.white, MyStyle().primaryColor],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              showLogo(),
              mySizeBox(),
              showAppName(),
              mySizeBox(),
              userForm(),
              mySizeBox(),
              passwordForm(),
              mySizeBox(),
              loginButton(),
              registerButton(),
            ],
          ),
        ),
      ),
    );
  }
}
