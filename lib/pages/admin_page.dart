import 'package:blinking_text/blinking_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:sasl_app/utils.dart';
import 'package:sasl_app/widgets/custom_dialog.dart';
import 'package:sasl_app/widgets/reusable.dart';

class adminPage extends StatefulWidget {
  const adminPage({Key? key}) : super(key: key);

  @override
  State<adminPage> createState() => _adminPageState();
}

class _adminPageState extends State<adminPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  int _index = 0;
  bool isLive = true;

  @override
  Widget build(BuildContext context) {
    Widget liveGame() {
      double scoreButtonTextSize = 30;
      return Padding(
        padding: EdgeInsets.all(10),
        child: FractionallySizedBox(
          widthFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color.fromARGB(255, 158, 105, 255),
              borderRadius: BorderRadius.circular(Constants.padding),
              // boxShadow: [
              //   BoxShadow(
              //       color: Colors.black,
              //       offset: Offset(0, 10),
              //       blurRadius: 10),
              // ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                  child: BlinkText(
                    duration: Duration(seconds: 1),
                    'LIVE MATCH',
                    style: TextStyle(fontSize: 24.0, color: Colors.red),
                    endColor: Colors.orange,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            height: 60,
                            width: 60,
                            imageUrl:
                                "https://scontent-jnb1-1.xx.fbcdn.net/v/t1.18169-9/13051687_1000213036735333_100597284100935242_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=fKBMG9czaGIAX_6m5ky&_nc_ht=scontent-jnb1-1.xx&oh=00_AT-gX1i96mhdkReaNAeJ9wOSWsPhlAY3LvBOF5cnGRTgcw&oe=6329D77E",
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // minimumSize: Size.fromHeight(50),
                              primary: Colors.green,
                            ),
                            onPressed: (() {
                              print("Team 1 Score ++");
                            }),
                            child: Text(
                              "+",
                              style: TextStyle(fontSize: scoreButtonTextSize),
                            ),
                          ),
                          Text(
                            "0",
                            style: TextStyle(fontSize: 40),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // minimumSize: Size.fromHeight(50),
                              primary: Colors.red,
                            ),
                            onPressed: (() {
                              print("Team 1 Score --");
                            }),
                            child: Text(
                              "-",
                              style: TextStyle(fontSize: scoreButtonTextSize),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              textAlign: TextAlign.center,
                              "Cape Town Kings",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "VS",
                            style: TextStyle(fontSize: 40),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            height: 60,
                            width: 60,
                            imageUrl:
                                "https://scontent-jnb1-1.xx.fbcdn.net/v/t1.18169-9/13051687_1000213036735333_100597284100935242_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=fKBMG9czaGIAX_6m5ky&_nc_ht=scontent-jnb1-1.xx&oh=00_AT-gX1i96mhdkReaNAeJ9wOSWsPhlAY3LvBOF5cnGRTgcw&oe=6329D77E",
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // minimumSize: Size.fromHeight(50),
                              primary: Colors.green,
                            ),
                            onPressed: (() {
                              print("Team 2 Score ++");
                            }),
                            child: Text(
                              "+",
                              style: TextStyle(fontSize: scoreButtonTextSize),
                            ),
                          ),
                          Text(
                            "0",
                            style: TextStyle(fontSize: 40),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              // minimumSize: Size.fromHeight(50),
                              primary: Colors.red,
                            ),
                            onPressed: (() {
                              print("Team 2 Score --");
                            }),
                            child: Text(
                              "-",
                              style: TextStyle(fontSize: scoreButtonTextSize),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              textAlign: TextAlign.center,
                              "Pretoria Capitals",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget mainAdmin() {
      double buttonHeight = 60, buttonWidth = 150;
      Color buttonColors = Colors.blue;

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isLive) liveGame(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Add Admin",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {
                      _index = 2;
                    }),
                  ),
                ),
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Add Player",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Add Team",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Add Match",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Edit Statistics",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Edit Player Details",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Edit Match",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
                Container(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      primary: buttonColors,
                    ),
                    child: Text(
                      "Edit Clubs",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget addTeam() {
      return Text("test");
    }

    Widget addMatch() {
      return Text("test");
    }

    Widget addPlayer() {
      return Text("test");
    }

    Widget addAdmin() {
      return Form(
        key: formKey,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              spacer(10),
              Text(
                'Add Admin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
              spacer(20),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: "Email"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'Please enter a valid email'
                        : null,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                  primary: Colors.red,
                ),
                icon: Icon(Icons.email_outlined),
                label: Text(
                  "Add Email",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  //showAlertDialog(context);

                  if (emailController.text.trim().isNotEmpty) {
                    //emailController.clear();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialogBox(
                              title: "Are you sure?",
                              descriptions:
                                  "It seems like you are wanting to add ${emailController.text.trim()} as an admin... please confirm this is correct.",
                              secondButtonText: "Confirm",
                              firstButtonText: "Cancel",
                              fromParent: () =>
                                  addAdminToDB(emailController.text.trim()));
                        });
                  }
                },
              ),
              spacer(20),
              Container(
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Constants.padding),
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.black,
                  //       offset: Offset(0, 10),
                  //       blurRadius: 10),
                  // ]
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                    primary: Colors.red,
                  ),
                  icon: Icon(Icons.arrow_back),
                  label: Text(
                    "Back",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    setState(() {
                      _index = 0;
                    });
                    print("Back pressed");
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<Widget> body = [
      mainAdmin(),
      addPlayer(),
      addAdmin(),
      addTeam(),
      addMatch(),
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (_index == 0) mainAdmin(),
            // if (_index == 1) addPlayer(),
            // if (_index == 2) addAdmin(),
            // if (_index == 3) addTeam(),
            // if (_index == 4) addMatch(),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
              child: body[_index],
            ),
          ],
        ),
      ),
    );
  }
}

// class addAdmin extends StatefulWidget {
//   const addAdmin({Key? key}) : super(key: key);

//   @override
//   State<addAdmin> createState() => _addAdminState();
// }

// class _addAdminState extends State<addAdmin> {
//   final formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   @override
//   void dispose() {
//     emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           children: [
//             Form(
//               key: formKey,
//               child: FractionallySizedBox(
//                 widthFactor: 0.8,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     spacer(10),
//                     Text(
//                       'Add Admin',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 24),
//                     ),
//                     spacer(20),
//                     TextFormField(
//                       controller: emailController,
//                       cursorColor: Colors.white,
//                       textInputAction: TextInputAction.done,
//                       decoration: InputDecoration(labelText: "Email"),
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                       validator: (email) =>
//                           email != null && !EmailValidator.validate(email)
//                               ? 'Please enter a valid email'
//                               : null,
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: Size.fromHeight(50),
//                         primary: Colors.red,
//                       ),
//                       icon: Icon(Icons.email_outlined),
//                       label: Text(
//                         "Add Email",
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       onPressed: () {
//                         //showAlertDialog(context);

//                         if (emailController.text.trim().isNotEmpty) {
//                           //emailController.clear();
//                           showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return CustomDialogBox(
//                                     title: "Are you sure?",
//                                     descriptions:
//                                         "It seems like you are wanting to add ${emailController.text.trim()} as an admin... please confirm this is correct.",
//                                     secondButtonText: "Confirm",
//                                     firstButtonText: "Cancel",
//                                     fromParent: () => addAdminToDB(
//                                         emailController.text.trim()));
//                               });
//                         }
//                       },
//                     ),
//                     spacer(20),
//                     Container(
//                       width: 150,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.rectangle,
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(Constants.padding),
//                         // boxShadow: [
//                         //   BoxShadow(
//                         //       color: Colors.black,
//                         //       offset: Offset(0, 10),
//                         //       blurRadius: 10),
//                         // ]
//                       ),
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size.fromHeight(50),
//                           primary: Colors.red,
//                         ),
//                         icon: Icon(Icons.arrow_back),
//                         label: Text(
//                           "Back",
//                           style: TextStyle(fontSize: 24),
//                         ),
//                         onPressed: () {
//                           print("Back pressed");
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // CustomDialogBox(
//             //   title: "title",
//             //   descriptions: "descriptions",
//             //   text: "text",
//             //   fromParent: () => test(),
//             // )
//           ],
//         ),
//       ),
//     );
//   }
// }

void test() {
  print("It worked!");
}

Future addAdminToDB(emailToAdd) async {
  final db = FirebaseFirestore.instance;
  final emailList = [];
  final docRef = db.collection("backend_stuff").doc("admin_stuff");
  docRef.get().then(
    (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      // ...
      for (var adminEmail in data["admins"]) {
        //print(adminEmail);
        emailList.add(adminEmail.toString());
      }

      if (!emailList.contains(emailToAdd)) {
        emailList.add(emailToAdd.toString().toLowerCase());
        final admins = <String, dynamic>{"admins": emailList};

        //print(admins);
        try {
          db
              .collection("backend_stuff")
              .doc("admin_stuff")
              .set(admins)
              .onError((e, _) => print("Error writing document: $e"));

          Utils.showSnackBar("Admin added", Colors.green);
          //Navigator.of(context).pop();
        } catch (e) {
          Utils.showSnackBar(e.toString(), Colors.red);
        }
      } else {
        Utils.showSnackBar("Already admin", Colors.orange);
      }
    },
    onError: (e) => print("Error getting document: $e"),
  );
}

class Constants {
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;
}
