import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ungconstructor14march/utility/my_style.dart';
import 'package:ungconstructor14march/utility/normal_dialog.dart';
import 'package:ungconstructor14march/widget/my_service.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Field
  String levelString, urlAvatar, name, email, password, uidUser;
  File file;

  // Method
  Widget nameForm() {
    Color color = MyStyle().darkColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (String string) {
              name = string.trim();
            },
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor),
              ),
              helperStyle: TextStyle(color: color),
              helperText: 'Type Your Name in Blank',
              labelStyle: MyStyle().h3Style,
              labelText: 'Name :',
              icon: Icon(
                Icons.account_box,
                size: 36.0,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget emailForm() {
    Color color = MyStyle().darkColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => email = value.trim(),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor),
              ),
              helperStyle: TextStyle(color: color),
              helperText: 'Type Your Email in Blank',
              labelStyle: MyStyle().h3Style,
              labelText: 'Email :',
              icon: Icon(
                Icons.email,
                size: 36.0,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget passwordForm() {
    Color color = MyStyle().darkColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 250.0,
          child: TextField(
            onChanged: (value) => password = value.trim(),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor),
              ),
              helperStyle: TextStyle(color: color),
              helperText: 'Type Your Password in Blank',
              labelStyle: MyStyle().h3Style,
              labelText: 'Password :',
              icon: Icon(
                Icons.lock_open,
                size: 36.0,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget level1Button() {
    return Row(
      children: <Widget>[
        Theme(
          data: Theme.of(context)
              .copyWith(unselectedWidgetColor: MyStyle().darkColor),
          child: Radio(
            value: 'Level1',
            groupValue: levelString,
            onChanged: (String string) {
              setState(() {
                levelString = string;
                print('level ==> $levelString');
              });
            },
          ),
        ),
        Text(
          'Level 1',
          style: MyStyle().h3Style,
        ),
      ],
    );
  }

  Widget level2Button() {
    return Row(
      children: <Widget>[
        Theme(
          data: Theme.of(context)
              .copyWith(unselectedWidgetColor: MyStyle().darkColor),
          child: Radio(
            value: 'Level2',
            groupValue: levelString,
            onChanged: (String string) {
              setState(() {
                levelString = string;
                print('level ==> $levelString');
              });
            },
          ),
        ),
        Text(
          'Level 2',
          style: MyStyle().h3Style,
        ),
      ],
    );
  }

  Widget chooseLevel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            level1Button(),
            level2Button(),
          ],
        ),
      ],
    );
  }

  Widget showTitle(String string) {
    return Container(
      margin: EdgeInsets.only(top: 16.0, left: 16.0),
      child: Text(
        string,
        style: MyStyle().h2Style,
      ),
    );
  }

  Widget showAvatar() {
    return GestureDetector(
      onTap: () {
        print('Click Avatar');
        chooseDevices();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        padding: EdgeInsets.all(16.0),
        child:
            file == null ? Image.asset('images/avatar.png') : Image.file(file),
      ),
    );
  }

  Future<void> chooseDevices() async {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: Text('Choose Device ?'),
            content: Text('Please Choose Camera or Gallery ?'),
            actions: <Widget>[
              chooseFlash(ImageSource.camera, 'Camera'),
              chooseFlash(ImageSource.gallery, 'Gallery')
            ],
          );
        });
  }

  Widget chooseFlash(ImageSource imageSource, String string) {
    return FlatButton(
      onPressed: () {
        chooseAvatar(imageSource);
        Navigator.of(context).pop();
      },
      child: Text(string),
    );
  }

  Future<void> chooseAvatar(ImageSource imageSource) async {
    try {
      var object = await ImagePicker.pickImage(
        source: imageSource,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );
      setState(() {
        file = object;
      });
    } catch (e) {}
  }

  Widget registerButton() {
    return IconButton(
      icon: Icon(Icons.cloud_upload),
      onPressed: () {
        if (file == null) {
          normalDialog(context, 'No Avatar', 'Please Choose Camera or Gallery');
        } else if (levelString == null) {
          normalDialog(context, 'No Level', 'Please Choose Level');
        } else if (name == null ||
            name.isEmpty ||
            email == null ||
            email.isEmpty ||
            password == null ||
            password.isEmpty) {
          normalDialog(context, 'Have Space', 'Please Fill Every Blank');
        } else {
          authenThread();
        }
      },
    );
  }

  Future<void> authenThread() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then(
      (value) {
        FirebaseUser firebaseUser = value.user;
        uidUser = firebaseUser.uid;
        print('Register Success uid ==>>> $uidUser');
        uploadImageToStorage();
      },
    ).catchError((error) {
      String title = error.code;
      String message = error.message;
      normalDialog(context, title, message);
    });
  }

  Future<void> uploadImageToStorage() async {
    Random random = Random();
    int i = random.nextInt(100000);
    String string = 'Avatar/avatar$i.jpg';

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    StorageReference storageReference = firebaseStorage.ref().child(string);
    StorageUploadTask storageUploadTask = storageReference.putFile(file);

    urlAvatar = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    print('urlAvatar = $urlAvatar');
    insertDataToCloudFireStore();
  }

  Future<void> insertDataToCloudFireStore() async {
    Map<String, dynamic> map = Map();
    map['Email'] = email;
    map['Name'] = name;
    map['Level'] = levelString;
    map['UrlAvatar'] = urlAvatar;

    Firestore firestore = Firestore.instance;

    await firestore.collection('User').document(uidUser).setData(map).then(
          (value) {
            MaterialPageRoute route = MaterialPageRoute(builder: (value)=>MyService());
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(bottom: 100.0),
        children: <Widget>[
          showTitle('Avatar :'),
          showAvatar(),
          showTitle('Level :'),
          chooseLevel(),
          showTitle('Information :'),
          nameForm(),
          emailForm(),
          passwordForm(),
        ],
      ),
      appBar: AppBar(
        actions: <Widget>[registerButton()],
        backgroundColor: MyStyle().darkColor,
        title: Text('Register'),
      ),
    );
  }
}
