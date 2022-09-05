import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sasl_app/pages/games_page.dart';
import 'package:sasl_app/pages/main_home_page.dart';
import 'package:sasl_app/pages/settings_page.dart';
import 'package:sasl_app/pages/standings_page.dart';
import 'package:sasl_app/pages/statistcs_page.dart';
import 'package:sasl_app/pages/teams_page.dart';
import 'package:sasl_app/pages/admin_page.dart';

Stream<QuerySnapshot> admins =
    FirebaseFirestore.instance.collection("backend_stuff").snapshots();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;

  int _currentIndex = 0;
  int _currentMenuTitle = 0;

  List<Widget> body = [
    mainMenuPage(),
    const teams(),
    games(),
    standings(),
    // FutureBuilder(
    //   future: statistics(),
    //   builder: ((context, snapshot) {
    //     return Test(snapshot.data);
    //   }),
    // ),
    const StatisticsPage(),
    profile(),
    const adminPage(),
  ];

  List<Text> menuTitles = [
    const Text("Home"),
    const Text("Teams"),
    const Text("Games"),
    const Text("Standings"),
    const Text("Statistics"),
    const Text("Profile"),
    const Text("Admin"),
  ];

  // List<BottomNavigationBarItem> bottomNavItems = [
  //   BottomNavigationBarItem(
  //     label: 'Home',
  //     icon: Icon(Icons.home),
  //   ),
  //   BottomNavigationBarItem(
  //     label: 'Teams',
  //     icon: Icon(Icons.people),
  //   ),
  //   BottomNavigationBarItem(
  //     label: 'Games',
  //     icon: Icon(Icons.sports_hockey),
  //   ),
  //   BottomNavigationBarItem(
  //     label: 'Standings',
  //     icon: Icon(Icons.leaderboard_outlined),
  //   ),
  //   BottomNavigationBarItem(
  //     label: 'Statistics',
  //     icon: Icon(Icons.show_chart),
  //   ),
  //   BottomNavigationBarItem(
  //     label: 'Settings',
  //     icon: Icon(Icons.settings),
  //   ),
  //   if (admin)
  //     BottomNavigationBarItem(
  //       label: 'Settings',
  //       icon: Icon(Icons.settings),
  //     ),
  // ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: admins,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong, please reload app.'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            heightFactor: 6,
            child: Container(
              width: 100,
              height: 100,
              child: const CircularProgressIndicator(
                strokeWidth: 10,
                color: Colors.red,
                backgroundColor: Colors.blue,
              ),
            ),
          );
        }

        final data = snapshot.requireData.docs[0].get('admins');
        //final test = data.docs as Map<String, dynamic>;
        //var userData = data.docs[0]['admins'];
        //var userData = data.docs as Map<String, dynamic>;
        //print(data);
        //print(user?.uid);
        bool admin = false;
        bool previouslyAdmin = false;
        if (data.contains(user?.email)) {
          // print("YES");

          admin = true;
          previouslyAdmin = true;
        } else {
          //print("No");
          admin = false;
        }

        if (previouslyAdmin && admin == false) {
          _currentIndex = 0;
          previouslyAdmin = false;
        }

        //print(userData);
        //print(user?.uid);
        //if (userData.contains(user?.uid)) {
        //print("YES");
        //}
        try {
          return WillPopScope(
            onWillPop: () {
              if (_currentIndex != 0) {
                try {
                  setState(() {
                    _currentIndex = 0;
                  });
                } catch (e) {
                  print(e);
                }
                throw {};
              } else {
                exit(0);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: menuTitles[_currentMenuTitle],
                centerTitle: true,
              ),
              drawer: Drawer(
                // Add a ListView to the drawer. This ensures the user can scroll
                // through the options in the drawer if there isn't enough vertical
                // space to fit everything.
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Text('Drawer Header'),
                    ),
                    ListTile(
                      title: const Text('Home'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        setState(() {
                          _currentIndex = 0;
                          _currentMenuTitle = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Teams'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        setState(() {
                          _currentIndex = 1;
                          _currentMenuTitle = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Games'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        setState(() {
                          _currentIndex = 2;
                          _currentMenuTitle = 2;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Standings'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        setState(() {
                          _currentIndex = 3;
                          _currentMenuTitle = 3;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Statistics'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        setState(() {
                          _currentIndex = 4;
                          _currentMenuTitle = 4;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Settings'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                        setState(() {
                          _currentIndex = 5;
                          _currentMenuTitle = 5;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const ListTile(),
                    ListTile(
                      title: Row(
                        children: [
                          const Icon(Icons.person),
                          const Text(" Log Out"),
                        ],
                      ),
                      onTap: () {
                        GoogleSignIn().signOut();
                        FirebaseAuth.instance.signOut();
                      },
                    )
                  ],
                ),
              ),
              body: body[_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.black,
                unselectedItemColor: Colors.black,
                fixedColor: Colors.red,
                currentIndex: _currentIndex,
                onTap: (int newIndex) {
                  setState(() {
                    _currentIndex = newIndex;
                    _currentMenuTitle = newIndex;
                  });
                },
                items: [
                  const BottomNavigationBarItem(
                    label: 'Home',
                    icon: Icon(Icons.home),
                  ),
                  const BottomNavigationBarItem(
                    label: 'Teams',
                    icon: const Icon(Icons.people),
                  ),
                  const BottomNavigationBarItem(
                    label: 'Games',
                    icon: const Icon(Icons.sports_hockey),
                  ),
                  const BottomNavigationBarItem(
                    label: 'Standings',
                    icon: Icon(Icons.leaderboard_outlined),
                  ),
                  const BottomNavigationBarItem(
                    label: 'Statistics',
                    icon: Icon(Icons.show_chart),
                  ),
                  const BottomNavigationBarItem(
                    label: 'Settings',
                    icon: const Icon(Icons.settings),
                  ),
                  if (admin)
                    const BottomNavigationBarItem(
                        label: 'Admin', icon: Icon(Icons.person)),
                ],
              ),
            ),
          );
        } catch (e) {
          print(e);

          _currentIndex = 0;

          // return Scaffold(
          //   appBar: AppBar(
          //     title: menuTitles[_currentMenuTitle],
          //     centerTitle: true,
          //   ),
          //   drawer: Drawer(
          //     // Add a ListView to the drawer. This ensures the user can scroll
          //     // through the options in the drawer if there isn't enough vertical
          //     // space to fit everything.
          //     child: ListView(
          //       // Important: Remove any padding from the ListView.
          //       padding: EdgeInsets.zero,
          //       children: [
          //         const DrawerHeader(
          //           decoration: BoxDecoration(
          //             color: Colors.blue,
          //           ),
          //           child: Text('Drawer Header'),
          //         ),
          //         ListTile(
          //           title: const Text('Home'),
          //           onTap: () {
          //             // Update the state of the app.
          //             // ...
          //             setState(() {
          //               _currentIndex = 0;
          //               _currentMenuTitle = 0;
          //             });
          //             Navigator.pop(context);
          //           },
          //         ),
          //         ListTile(
          //           title: const Text('Teams'),
          //           onTap: () {
          //             // Update the state of the app.
          //             // ...
          //             setState(() {
          //               _currentIndex = 1;
          //               _currentMenuTitle = 1;
          //             });
          //             Navigator.pop(context);
          //           },
          //         ),
          //         ListTile(
          //           title: const Text('Games'),
          //           onTap: () {
          //             // Update the state of the app.
          //             // ...
          //             setState(() {
          //               _currentIndex = 2;
          //               _currentMenuTitle = 2;
          //             });
          //             Navigator.pop(context);
          //           },
          //         ),
          //         ListTile(
          //           title: const Text('Standings'),
          //           onTap: () {
          //             // Update the state of the app.
          //             // ...
          //             setState(() {
          //               _currentIndex = 3;
          //               _currentMenuTitle = 3;
          //             });
          //             Navigator.pop(context);
          //           },
          //         ),
          //         ListTile(
          //           title: const Text('Statistics'),
          //           onTap: () {
          //             // Update the state of the app.
          //             // ...
          //             setState(() {
          //               _currentIndex = 4;
          //               _currentMenuTitle = 4;
          //             });
          //             Navigator.pop(context);
          //           },
          //         ),
          //         ListTile(
          //           title: const Text('Settings'),
          //           onTap: () {
          //             // Update the state of the app.
          //             // ...
          //             setState(() {
          //               _currentIndex = 5;
          //               _currentMenuTitle = 5;
          //             });
          //             Navigator.pop(context);
          //           },
          //         ),
          //         const ListTile(),
          //         ListTile(
          //           title: Row(
          //             children: [
          //               const Icon(Icons.person),
          //               const Text(" Log Out"),
          //             ],
          //           ),
          //           onTap: () {
          //             GoogleSignIn().signOut();
          //             FirebaseAuth.instance.signOut();
          //           },
          //         )
          //       ],
          //     ),
          //   ),
          //   body: SingleChildScrollView(
          //     scrollDirection: Axis.vertical,
          //     child: body[_currentIndex],
          //   ),
          //   bottomNavigationBar: BottomNavigationBar(
          //     backgroundColor: Colors.black,
          //     unselectedItemColor: Colors.black,
          //     fixedColor: Colors.red,
          //     currentIndex: _currentIndex,
          //     onTap: (int newIndex) {
          //       setState(() {
          //         _currentIndex = newIndex;
          //         _currentMenuTitle = newIndex;
          //       });
          //     },
          //     items: [
          //       BottomNavigationBarItem(
          //         label: 'Home',
          //         icon: Icon(Icons.home),
          //       ),
          //       BottomNavigationBarItem(
          //         label: 'Teams',
          //         icon: Icon(Icons.people),
          //       ),
          //       BottomNavigationBarItem(
          //         label: 'Games',
          //         icon: Icon(Icons.sports_hockey),
          //       ),
          //       BottomNavigationBarItem(
          //         label: 'Standings',
          //         icon: Icon(Icons.leaderboard_outlined),
          //       ),
          //       BottomNavigationBarItem(
          //         label: 'Statistics',
          //         icon: Icon(Icons.show_chart),
          //       ),
          //       BottomNavigationBarItem(
          //         label: 'Settings',
          //         icon: Icon(Icons.settings),
          //       ),
          //       if (admin)
          //         BottomNavigationBarItem(
          //           label: 'Settings',
          //           icon: Icon(Icons.settings),
          //         ),
          //     ],
          //   ),
          // );

          return Center(
            child: Container(
              width: 300,
              height: 100,
              color: Colors.red,
              child: TextButton(
                child: const Text(
                  "You were removed as admin, tap to reload",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => setState(() {
                  admin = false;
                  _currentIndex = 0;
                }),
              ),
            ),
          );
          ;
        }
      },
    );
  } //Call this method from initState()

  // Future<void> _getUserDoc() async {
  //   List adminList = [];
  //   final db = FirebaseFirestore.instance;
  //   final docRef = db.collection("backend_stuff").doc("admin_stuff");
  //   docRef.get().then(
  //     (DocumentSnapshot doc) {
  //       final data = doc.data() as Map<String, dynamic>;

  //       if (data['admins'].contains(user?.uid)) {
  //         print("YES");

  //         if (mounted) {
  //           setState(() {
  //             admin = true;
  //           });
  //         }
  //       } else {
  //         print("No");
  //         if (mounted) {
  //           setState(() {
  //             admin = false;
  //           });
  //         }
  //       }

  //       // ...
  //     },
  //     onError: (e) => print("Error getting document: $e"),
  //   );

  //   //print(adminList);

  //   // final FirebaseAuth _auth = FirebaseAuth.instance;
  //   // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //   // var data = FirebaseFirestore.instance
  //   //     .collection("backend_stuff")
  //   //     .doc("admin_stuff")
  //   //     .snapshots();

  //   //print(data.toString());
  //   // for (var test in data.) {
  //   //   print(test);
  //   //   adminList.add(test.toString());
  //   // }

  //   //print(adminList);
  //   //print(userData);
  //   //print(user?.uid);
  //   // if (adminList.contains(user?.uid)) {
  //   //   print("YES");
  //   //   setState(() {});
  //   // }
  // }
}
