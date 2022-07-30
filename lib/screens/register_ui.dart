import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter3_firestore_driver/screens/login_ui.dart';
import 'package:flutter3_firestore_driver/screens/register_auto.dart';
import 'package:flutter3_firestore_driver/screens/register_auto_ui.dart';
import 'package:flutter3_firestore_driver/screens/tabs.dart';

class RegisterUI extends StatefulWidget {
  RegisterUI({Key? key}) : super(key: key);

  @override
  State<RegisterUI> createState() => _RegisterUIState();
}

class _RegisterUIState extends State<RegisterUI> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  String photoURL = '';
  String error = '';

  final email = TextEditingController();

  final password = TextEditingController();

  final address = TextEditingController();

  final displayName = TextEditingController();

  final lastName = TextEditingController();

  final phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              key: _scaffoldKey,

              // appBar: AppBar(
              //   backgroundColor: Colors.deepOrange.shade300,
              //   elevation: 0.0,
              //   automaticallyImplyLeading: true,
              //   title: Text('Register', style: TextStyle(color: Colors.white)),
              // ), //appBar
              body: Container(
                //                 decoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.topRight,
                //     end: Alignment.bottomLeft,
                //     colors: [
                //       Colors.black,
                //       Colors.blue,
                //     ],
                //   )
                // ),
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Image.asset(
                          'images/logo.png',
                          height: 230,
                          width: 200,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 0.0, right: 10.0, bottom: 5.0),
                          child: TextFormField(
                            controller: displayName,
                            //validator: (val) => val?.isEmpty ? 'Enter a FirstName' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Firstname'),
                            // decoration: InputDecoration(
                            //     hintText: 'Firstname', labelText: 'Firstname'),

                            decoration: InputDecoration(
                                hintText: 'Firstname',
                                //labelText: 'Firstname',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: outlineBorder(),
                                focusedBorder: outlineBorder(),
                                enabledBorder: outlineBorder()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 0.0, right: 10.0, bottom: 5.0),
                          child: TextFormField(
                            controller: lastName,
                            //validator: (val) => val.isEmpty ? 'Enter a Lastname' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Lastname'),
                            // decoration: InputDecoration(
                            //     hintText: 'Lastname', labelText: 'Lastname'),
                            decoration: InputDecoration(
                                hintText: 'Lastname',
                                //labelText: 'Lastname',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: outlineBorder(),
                                focusedBorder: outlineBorder(),
                                enabledBorder: outlineBorder()),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 0.0, right: 10.0, bottom: 5.0),
                          child: TextFormField(
                            controller: address,
                            //validator: (val) => val.isEmpty ? 'Enter a Address' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Address'),
                            // decoration: InputDecoration(
                            //     hintText: 'Address', labelText: 'Address'),

                            decoration: InputDecoration(
                                hintText: 'Address',
                                //labelText: 'Address',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: outlineBorder(),
                                focusedBorder: outlineBorder(),
                                enabledBorder: outlineBorder()),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 0.0, right: 10.0, bottom: 5.0),
                          child: TextFormField(
                            controller: phone,
                            //validator: (val) => val.isEmpty ? 'Enter a Phone' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Phone'),
                            // decoration: InputDecoration(
                            //     hintText: 'Phonenumber',
                            //     labelText: 'Phonenumber'),

                            decoration: InputDecoration(
                                hintText: 'Phonenumber',
                                //labelText: 'Phonenumber',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: outlineBorder(),
                                focusedBorder: outlineBorder(),
                                enabledBorder: outlineBorder()),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 0.0, right: 10.0, bottom: 5.0),
                          child: TextFormField(
                            controller: email,
                            //validator: (val) => val.isEmpty ? 'Enter a Email' : null,
                            //decoration: textInputDecoration.copyWith(hintText: 'Email'),
                            // decoration: InputDecoration(
                            //     hintText: 'Email', labelText: 'Email'),

                            decoration: InputDecoration(
                                hintText: 'Email',
                                //labelText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: outlineBorder(),
                                focusedBorder: outlineBorder(),
                                enabledBorder: outlineBorder()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 0.0, right: 10.0, bottom: 5.0),
                          child: TextFormField(
                            controller: password,
                            //validator: (val) => val.isEmpty ? 'Enter a Password' : null,
                            obscureText: true,
                            //decoration: textInputDecoration.copyWith(hintText: 'Password'),
                            // decoration: InputDecoration(
                            //     hintText: 'Password', labelText: 'Password'),
                            decoration: InputDecoration(
                                hintText: 'Password',
                                //labelText: 'Password',
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                border: outlineBorder(),
                                focusedBorder: outlineBorder(),
                                enabledBorder: outlineBorder()),
                          ),
                        ),

                        Text(
                          error,
                          style: TextStyle(
                              color: Colors.lightGreen.shade700, fontSize: 7.0),
                        ), //text

                        Column(
                          children: <Widget>[
                            ButtonTheme(
                              minWidth: 320.0,
                              height: 45.0,
                              child: ElevatedButton(
                                // shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(7.0)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                ),
                                onPressed: () async {
                                  // widget.toggleView();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterAutoUI(
                                              name: displayName.text,
                                              lastName: lastName.text,
                                              address: address.text,
                                              phone: phone.text,
                                              email: email.text,
                                              password: password.text,
                                            )),
                                  );
                                },
                                child: Text('Continue',
                                    style: TextStyle(color: Colors.white)),
                              ), //rec
                            ), //flat
                          ], //widget
                        ), //column
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: _buildBottomContainer(), //textform
            );
          }

          return TabsScreen();
        });
  }

  outlineBorder() {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(width: 0, color: Colors.white));
  }

  Widget _buildBottomContainer() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginUI()));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        color: Colors.deepOrange.shade100,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'You have already an account? ',
            style: TextStyle(
                fontSize: 16, color: Colors.black, fontFamily: 'regular'),
            children: <TextSpan>[
              TextSpan(
                  text: 'Login', style: TextStyle(color: Colors.deepOrange)),
            ],
          ),
        ),
      ),
    );
  }
}
