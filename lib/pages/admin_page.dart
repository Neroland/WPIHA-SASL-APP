import 'dart:io';
import 'dart:math';

import 'package:blinking_text/blinking_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sasl_app/main.dart';
import 'package:sasl_app/pages/games_page.dart';
import 'package:sasl_app/utils.dart';
import 'package:sasl_app/widgets/classes.dart';
import 'package:sasl_app/widgets/custom_dialog.dart';
import 'package:sasl_app/widgets/reusable.dart';
import 'package:editable/editable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Stream<QuerySnapshot> seasons =
    FirebaseFirestore.instance.collection("seasons").snapshots();

Future updateScore(gamesList, gameNumberToUpdate, teamID, newScore) async {
  List<Games> updateGamesData = [];

  print("HERE: Start");
  print(newScore);
  for (var game in gamesList) {
    if (game.game_number == gameNumberToUpdate) {
      if (teamID == game.team_1_id) {
        print("Added!");

        game.current_score_team_1 = newScore.toString();
      } else {
        game.current_score_team_2 = newScore.toString();
      }
    }

    updateGamesData.add(
      Games(
          current_score_team_1: game.current_score_team_1,
          current_score_team_2: game.current_score_team_2,
          date_time: game.date_time,
          game_number: game.game_number,
          livestream_url: game.livestream_url,
          team_1_id: game.team_1_id,
          team_2_id: game.team_2_id),
    );
  }

  //print(updateGamesData[0].current_score_team_1);
  //var test = [];

  var entry = [];
  entry.clear();

  //var count = 0;
  //Map<dynamic, dynamic> entry = {};
  for (var game in updateGamesData) {
    entry.add(
      {
        "game_number": game.game_number,
        "current_score_team_1": game.current_score_team_1,
        "current_score_team_2": game.current_score_team_2,
        "livestream_url": game.livestream_url,
        "team_1_id": game.team_1_id,
        "team_2_id": game.team_2_id,
        "date_time": game.date_time,
      },
    );
  }

  Map<String, dynamic> allData = {"games": entry};

  final db = FirebaseFirestore.instance;

  try {
    db.collection("seasons").doc("2022").update(allData).onError(
        (error, stackTrace) =>
            Utils.showSnackBar(error.toString(), Colors.red));
  } catch (e) {
    Utils.showSnackBar(e.toString(), Colors.red);
  }
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

Future addPlayerToDB(playerFirstName, playerSurname, playerJerseyNum,
    playerPosition, playerTeamID, playerProfilePicURL) async {
  final db = FirebaseFirestore.instance;
  final playersList = [];
  List<int> playersIDs = [];
  final docRef = db.collection("seasons").doc("2022");
  docRef.get().then(
    (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      // ...
      for (var players in data["players"]) {
        //print(adminEmail);
        playersIDs.add(int.parse(players["player_id"]));

        playersList.add(players);
      }

      var randomNum = Random();
      var newPlayerID = randomNum.nextInt(10000);

      while (playersIDs.contains(newPlayerID)) {
        newPlayerID = randomNum.nextInt(10000);
      }

      print("12345: " + playersIDs.toString());

      print("12345: " + randomNum.toString());

      playersList.add(
        {
          "player_id": newPlayerID.toString(),
          "player_first_name": playerFirstName,
          "player_last_name": playerSurname,
          "player_picture_url": "https://placeimg.com/1920/1080/any",
          "player_team_id": playerTeamID,
          "player_position": playerPosition,
          "player_gp": "1",
          "player_g": "10",
          "player_a": "10",
          "player_pts": "1",
          "player_jersey_number": playerJerseyNum,
        },
      );

      print("1234: " + playersList.toString());

      //    "players": [
      //   {
      //     "player_id": "0",
      //     "player_first_name": "Dario",
      //     "player_last_name": "Maselli",
      //     "player_picture_url": "https://placeimg.com/1920/1080/any",
      //     "player_team_id": "1",
      //     "player_position": "Defence",
      //     "player_gp": "1",
      //     "player_g": "10",
      //     "player_a": "10",
      //     "player_pts": "1",
      //     "player_jersey_number": "61",
      //   },
      // ],

      final players = <String, dynamic>{"players": playersList};

      //print(admins);
      try {
        db
            .collection("seasons")
            .doc("2022")
            .update(players)
            .onError((e, _) => print("Error writing document: $e"));

        Utils.showSnackBar("Player added", Colors.green);
        //Navigator.of(context).pop();
      } catch (e) {
        Utils.showSnackBar(e.toString(), Colors.red);
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

class adminPage extends StatefulWidget {
  const adminPage({Key? key}) : super(key: key);

  @override
  State<adminPage> createState() => _adminPageState();
}

String team_1_name = "Cape Town Kings", team_2_name = "Pretoria Capitals";
String imageUrl =
    'https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4';

class _adminPageState extends State<adminPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  File? pickedFile;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool isLive = true;

  Future selectPhoto(double ratioX, double ratioY) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    final croppedImage =
        await Utils.cropImage(result.files.first, ratioX, ratioY);

    if (croppedImage != null) {
      setState(() {
        pickedFile = File(croppedImage.path);
      });

      final path = "/player_profile_photos/${result.names.first.toString()}";
      final file = File(pickedFile!.path);

      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);

      await ref.getDownloadURL().then(
            (value) => print(value),
          );

      var temp = await ref.getDownloadURL();
      setState(() {
        pickedFile = null;
        imageUrl = temp;
      });
    }
  }

  Future uploadFile(fileName) async {
    // // Create a reference to a file from a Google Cloud Storage URI
    // final gsReference = FirebaseStorage.instance
    //     .refFromURL("gs://wpiha-sasl-app.appspot.com/${path}");
  }

  int _index = 0;
  @override
  Widget build(BuildContext context) {
    Widget mainAdmin() {
      double buttonHeight = 60, buttonWidth = 150;
      Color buttonColors = Colors.blue;

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: seasons,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Waiting");
              }

              final data = snapshot.requireData;

              List<Games> gamesList = [];
              List<Teams> teamsList = [];

              var latest_season = data.docs[0]['games'];
              var teams_data = data.docs[0]['teams'];

              //print(sortedMap);

              //test.add(Text('$latest_season'));
              //print("AVVV: " + latest_season.toString());
              for (var doc in latest_season) {
                //print("AVVV: " + doc.toString());
                gamesList.add(
                  Games(
                    current_score_team_1: doc["current_score_team_1"],
                    current_score_team_2: doc["current_score_team_2"],
                    date_time: doc["date_time"],
                    game_number: doc["game_number"],
                    livestream_url: doc["livestream_url"],
                    team_1_id: doc["team_1_id"],
                    team_2_id: doc["team_2_id"],
                  ),
                );
              }

              for (var doc in teams_data) {
                teamsList.add(
                  Teams(
                    team_name: doc["team_name"],
                    team_id: doc["team_id"],
                    team_logo_url: doc["team_logo_url"],
                    club_info: doc["club_info"],
                    team_jersey_picture_url: doc["team_jersey_picture_url"],
                    assistant_coach: doc["assistant_coach"],
                    head_coach: doc["head_coach"],
                    team_manager: doc["team_manager"],
                  ),
                );
              }

              // var teams = doc["teams"];

              // return Column(
              //   children: test,
              // );

              // for (var game in test) {
              //   print(game.game_number);
              // }

              //print(test[0].date_time);

              gamesList.sort(
                (a, b) {
                  return a.game_number.compareTo(b.game_number);
                },
              );

              final date2 = DateTime.now();
              int count = 0;
              for (var game in gamesList) {
                var gameDate = DateTime.fromMicrosecondsSinceEpoch(
                    game.date_time.microsecondsSinceEpoch);
                //print(gameDate);
                final difference = date2.difference(gameDate).inHours;
                //print(difference);
                if (difference > 4) {
                  gamesList.insert(
                      gamesList.length - 1, gamesList.removeAt(count));
                }
                count++;
              }

              // print(test[0].date_time);
              List<Widget> liveGames = [];
              List months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sept',
                'Oct',
                'Nov',
                'Dec'
              ];

              bool isLive(differenceInSeconds) {
                if (0 < differenceInSeconds && differenceInSeconds < 14400) {
                  return true;
                } else {
                  return false;
                }
              }

              double scoreButtonTextSize = 30;
              for (var game in gamesList) {
                //print(game.game_number);
                var gameDate = DateTime.fromMillisecondsSinceEpoch(
                    game.date_time.millisecondsSinceEpoch);

                final difference = date2.difference(gameDate).inSeconds;
                //print(teamsList[int.parse(game.team_1_id)].team_name);

                if (isLive(difference)) {
                  print("Game Number: " + game.game_number);
                  print("current_score_team_1: " + game.current_score_team_1);
                  var _team_1_score = int.parse(game.current_score_team_1);
                  //print(_team_1_score);
                  print("current_score_team_2: " + game.current_score_team_2);
                  //print(_team_2_score);
                  var _team_2_score = int.parse(game.current_score_team_2);
                  team_1_name = teamsList[int.parse(game.team_1_id) - 1]
                      .team_name
                      .toString();
                  team_2_name = teamsList[int.parse(game.team_2_id) - 1]
                      .team_name
                      .toString();

                  liveGames.add(
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FractionallySizedBox(
                        widthFactor: 0.95,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Color.fromARGB(255, 158, 105, 255),
                            borderRadius:
                                BorderRadius.circular(Constants.padding),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                                child: BlinkText(
                                  duration: Duration(seconds: 1),
                                  'LIVE MATCH',
                                  style: TextStyle(
                                      fontSize: 24.0, color: Colors.red),
                                  endColor: Colors.orange,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 40),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.white,
                                            // borderRadius: BorderRadius.circular(
                                            //     Constants.padding),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //       color: Colors.black,
                                            //       offset: Offset(0, 10),
                                            //       blurRadius: 10),
                                            // ]
                                          ),
                                          child: CachedNetworkImage(
                                            height: 60,
                                            width: 60,
                                            imageUrl: teamsList[
                                                    int.parse(game.team_1_id) -
                                                        1]
                                                .team_logo_url,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // minimumSize: Size.fromHeight(50),
                                            primary: Colors.green,
                                          ),
                                          onPressed: (() {
                                            print(
                                                "${teamsList[int.parse(game.team_1_id) - 1].team_name} Score ++");
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  profilePicture: false,
                                                  descriptions:
                                                      "Are you sure you want to add a goal to $team_1_name?",
                                                  firstButtonText: "Cancel",
                                                  fromParent: () =>
                                                      setState(() {
                                                    print(
                                                        "Team 1 Score Before: " +
                                                            _team_1_score
                                                                .toString());
                                                    _team_1_score++;
                                                    print("Team 1 Score: " +
                                                        _team_1_score
                                                            .toString());

                                                    //updateScore(gamesList, gameNumberToUpdate, teamID, newScore)
                                                    updateScore(
                                                        gamesList,
                                                        game.game_number,
                                                        game.team_1_id,
                                                        _team_1_score
                                                        // game.current_score_team_2,
                                                        // game.date_time,
                                                        // game.game_number,
                                                        // game.livestream_url,
                                                        // game.team_1_id,
                                                        // game.team_2_id
                                                        );
                                                    Utils.showSnackBar(
                                                        "Goal added to $team_1_name",
                                                        Colors.green.shade800);
                                                  }),
                                                  secondButtonText: "Confirm",
                                                  title: "Add a goal?",
                                                );
                                              },
                                            );
                                          }),
                                          child: Text(
                                            "+",
                                            style: TextStyle(
                                                fontSize: scoreButtonTextSize),
                                          ),
                                        ),
                                        Text(
                                          _team_1_score.toString(),
                                          style: TextStyle(fontSize: 40),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // minimumSize: Size.fromHeight(50),
                                            primary: Colors.red,
                                          ),
                                          onPressed: (() {
                                            print("Team 1 Score --");
                                            if (_team_1_score != 0) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomDialogBox(
                                                    profilePicture: false,
                                                    descriptions:
                                                        "Are you sure you want to minus a goal from $team_1_name??",
                                                    firstButtonText: "Cancel",
                                                    fromParent: () =>
                                                        setState(() {
                                                      _team_1_score--;
                                                      updateScore(
                                                          gamesList,
                                                          game.game_number,
                                                          game.team_1_id,
                                                          _team_1_score);
                                                      Utils.showSnackBar(
                                                          "Goal subtracted",
                                                          Colors
                                                              .orange.shade800);
                                                    }),
                                                    secondButtonText: "Confirm",
                                                    title: "Minus a goal?",
                                                  );
                                                },
                                              );
                                            }
                                          }),
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                                fontSize: scoreButtonTextSize),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            team_1_name,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "VS",
                                          style: TextStyle(fontSize: 40),
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.white,
                                          ),
                                          child: CachedNetworkImage(
                                            height: 60,
                                            width: 60,
                                            imageUrl: teamsList[
                                                    int.parse(game.team_2_id) -
                                                        1]
                                                .team_logo_url,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // minimumSize: Size.fromHeight(50),
                                            primary: Colors.green,
                                          ),
                                          onPressed: (() {
                                            print("Team 2 Score ++");

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  profilePicture: false,
                                                  descriptions:
                                                      "Are you sure you want to add a goal to $team_2_name?",
                                                  firstButtonText: "Cancel",
                                                  fromParent: () =>
                                                      setState(() {
                                                    _team_2_score++;
                                                    updateScore(
                                                      gamesList,
                                                      game.game_number,
                                                      game.team_2_id,
                                                      _team_2_score,
                                                    );

                                                    Utils.showSnackBar(
                                                        "Goal added",
                                                        Colors.green.shade800);
                                                  }),
                                                  secondButtonText: "Confirm",
                                                  title: "Add a goal?",
                                                );
                                              },
                                            );
                                          }),
                                          child: Text(
                                            "+",
                                            style: TextStyle(
                                                fontSize: scoreButtonTextSize),
                                          ),
                                        ),
                                        Text(
                                          _team_2_score.toString(),
                                          style: TextStyle(fontSize: 40),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // minimumSize: Size.fromHeight(50),
                                            primary: Colors.red,
                                          ),
                                          onPressed: (() {
                                            print("Team 2 Score --");
                                            if (_team_2_score != 0) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomDialogBox(
                                                    profilePicture: false,
                                                    descriptions:
                                                        "Are you sure you want to minus a goal from $team_2_name??",
                                                    firstButtonText: "Cancel",
                                                    fromParent: () =>
                                                        setState(() {
                                                      _team_2_score--;
                                                      updateScore(
                                                        gamesList,
                                                        game.game_number,
                                                        game.team_2_id,
                                                        _team_2_score,
                                                      );
                                                      Utils.showSnackBar(
                                                          "Goal subtracted",
                                                          Colors
                                                              .orange.shade800);
                                                    }),
                                                    secondButtonText: "Confirm",
                                                    title: "Minus a goal?",
                                                  );
                                                },
                                              );
                                            }
                                          }),
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                                fontSize: scoreButtonTextSize),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            team_2_name,
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
                    ),
                  );
                }
              }

              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: liveGames);

              //Row(children: liveGames));
            },
          ),
          //if (isLive) liveGame(),
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
                    onPressed: () => setState(() {
                      _index = 1;
                    }),
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
                    onPressed: () => setState(() {
                      _index = 3;
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
                      "Send Message (Edit Clubs)",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget addPlayer() {
      String _myActivity = '';
      String _myActivityResult = '';
      final formKey = new GlobalKey<FormState>();

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: seasons,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Waiting");
              }

              final data = snapshot.requireData;

              List<Games> gamesList = [];
              List<Teams> teamsList = [];

              var latest_season = data.docs[0]['games'];
              var teams_data = data.docs[0]['teams'];

              //print(sortedMap);

              //test.add(Text('$latest_season'));
              //print("AVVV: " + latest_season.toString());
              for (var doc in latest_season) {
                //print("AVVV: " + doc.toString());
                gamesList.add(
                  Games(
                    current_score_team_1: doc["current_score_team_1"],
                    current_score_team_2: doc["current_score_team_2"],
                    date_time: doc["date_time"],
                    game_number: doc["game_number"],
                    livestream_url: doc["livestream_url"],
                    team_1_id: doc["team_1_id"],
                    team_2_id: doc["team_2_id"],
                  ),
                );
              }
              var teamsForDropdown = [''];
              teamsForDropdown.clear();
              for (var doc in teams_data) {
                teamsList.add(
                  Teams(
                    team_name: doc["team_name"],
                    team_id: doc["team_id"],
                    team_logo_url: doc["team_logo_url"],
                    club_info: doc["club_info"],
                    team_jersey_picture_url: doc["team_jersey_picture_url"],
                    assistant_coach: doc["assistant_coach"],
                    head_coach: doc["head_coach"],
                    team_manager: doc["team_manager"],
                  ),
                );
                teamsForDropdown.add(doc["team_name"]);
              }

              var positions = ["Forward", "Defence", "Goaltender"];

              var dataRows = [
                DataRow(
                  cells: [
                    DataCell(
                      Text(""),
                    ),
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "",
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "",
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        "",
                      ),
                    ),
                    DataCell(
                      Text(""),
                    ),
                    DataCell(
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: "https://placeimg.com/1920/1080/any",
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ];

              //Headers or Columns
              List headers = [
                {"title": "Name", "index": 1, "key": "name"},
                {"title": "Surname", "index": 2, "key": "surname"},
                {"title": "Position", "index": 3, "key": "position"},
                {"title": "Team", "index": 4, "key": "team"},
                {"title": "Picture", "index": 5, "key": "picture"},
              ];
              List rows = [
                {
                  "name": "",
                  "surname": "",
                  "position": "",
                  "team": "",
                  "picture": "",
                }
              ];

              var _currentSelectedValue;
              var _currentSelectedValue2;
              final nameController = TextEditingController();
              final surnameController = TextEditingController();
              final numberController = TextEditingController();

              double formSpacers = 15;
              return FractionallySizedBox(
                widthFactor: 1,
                child: Column(
                  children: [
                    spacer(10),
                    Text("Add Player"),
                    Form(
                      key: formKey,
                      child: FractionallySizedBox(
                        widthFactor: 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: nameController,
                              cursorColor: Colors.white,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                  labelText: "Player Firstname"),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (name) => name!.length < 2
                                  ? 'Please enter a valid first name.'
                                  : null,
                            ),
                            spacer(formSpacers),
                            TextFormField(
                              controller: surnameController,
                              cursorColor: Colors.white,
                              textInputAction: TextInputAction.done,
                              decoration:
                                  InputDecoration(labelText: "Player Surname"),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (surname) => surname!.length < 2
                                  ? 'Please enter a valid first name.'
                                  : null,
                            ),
                            spacer(formSpacers),
                            TextFormField(
                              controller: numberController,
                              cursorColor: Colors.white,
                              textInputAction: TextInputAction.done,
                              decoration:
                                  InputDecoration(labelText: "Jersey Number"),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (number) => !isNumeric(number!)
                                  ? 'Please enter a valid jersey number.'
                                  : null,
                            ),
                            spacer(formSpacers),
                            FormField<String>(
                              builder: (FormFieldState<String> state2) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                      //labelStyle: textStyle,
                                      labelText: "Please select position",
                                      errorStyle: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16.0),
                                      hintText: 'Please select position',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0))),
                                  isEmpty: _currentSelectedValue2 == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      style: TextStyle(color: Colors.white),
                                      value: _currentSelectedValue2,
                                      isDense: true,
                                      onChanged: (value) {
                                        state2.setState(() {
                                          print(value);
                                          _currentSelectedValue2 = value!;
                                          state2.didChange(
                                              _currentSelectedValue2);
                                        });
                                      },
                                      items: positions.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            spacer(formSpacers),
                            FormField<String>(
                              builder: (FormFieldState<String> state) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                      //labelStyle: textStyle,
                                      labelText: "Please select team",
                                      errorStyle: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16.0),
                                      hintText: 'Please select team',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0))),
                                  isEmpty: _currentSelectedValue == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      // hint:
                                      style: TextStyle(color: Colors.white),
                                      value: _currentSelectedValue,
                                      isDense: true,
                                      onChanged: (value) {
                                        state.setState(() {
                                          print(value);
                                          _currentSelectedValue = value!;
                                          state
                                              .didChange(_currentSelectedValue);
                                        });
                                      },
                                      items:
                                          teamsForDropdown.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            spacer(formSpacers),
                            // if (pickedFile != null)
                            //   Container(
                            //     width: 500,
                            //     height: 300,
                            //     color: Colors.redAccent,
                            //     child: Image.file(File(pickedFile!.path),
                            //         width: double.infinity, fit: BoxFit.cover),
                            //   ),
                            // if (pickedFile != null) spacer(formSpacers),
                            Text("Player Profile Photo:"),
                            spacer(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.red,
                                  foregroundImage: CachedNetworkImageProvider(
                                    imageUrl,
                                  ),
                                ),
                                Container(
                                  width: 130,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      selectPhoto(1, 1);
                                    },
                                    child: const Text("Select Photo"),
                                  ),
                                ),
                                // Container(
                                //   width: 150,
                                //   child: ElevatedButton(
                                //     onPressed: () {
                                //       if (pickedFile != null)
                                //         uploadFile('Testing');
                                //     },
                                //     child: const Text("Upload Photo"),
                                //   ),
                                // ),
                              ],
                            ),
                            spacer(formSpacers),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        Constants.padding),
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
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _index = 0;
                                      });
                                      print("Back pressed");
                                    },
                                  ),
                                ),
                                Container(
                                  width: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        Constants.padding),
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
                                      primary: Colors.green,
                                    ),
                                    icon: Icon(Icons.save),
                                    label: Text(
                                      "Add Player",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      print("Add Player Tapped");

                                      if (nameController.text.length > 2 &&
                                          surnameController.text.length > 2 &&
                                          int.parse(numberController.text) >
                                              0 &&
                                          _currentSelectedValue != null &&
                                          _currentSelectedValue2 != null) {
                                        print("12345 CurrentValue: " +
                                            _currentSelectedValue);
                                        var teamID;
                                        for (var team in teamsList) {
                                          if (_currentSelectedValue ==
                                              team.team_name) {
                                            teamID = team.team_id;
                                          }
                                        }
                                        print(teamID);

                                        print("12345 Name: " +
                                            nameController.text);
                                        print("12345 Jersey Name: " +
                                            numberController.text);
                                        print("12345 Postion: " +
                                            _currentSelectedValue2);
                                        print("12345 Team: " + teamID);
                                        addPlayerToDB(
                                          nameController.text,
                                          surnameController.text,
                                          numberController.text,
                                          _currentSelectedValue2,
                                          teamID,
                                          imageUrl,
                                        );

                                        setState(() {
                                          nameController.text = "";
                                          surnameController.text = "";
                                          numberController.text = "";
                                          _currentSelectedValue = "";
                                          _currentSelectedValue2 = "";
                                          imageUrl =
                                              "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4";
                                        });
                                      } else {
                                        Utils.showSnackBar(
                                            "Missing player information.",
                                            Colors.orange);
                                        print("Something Missing");
                                      }

                                      // if (nameController.text.length > 3)
                                      //
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    spacer(formSpacers),
                  ],
                ),
              );

              // return Column(
              //   children: [
              //     Center(
              //       child: Text("Players to add:"),
              //     ),
              //     spacer(10),
              //     SingleChildScrollView(
              //       scrollDirection: Axis.horizontal,
              //       child: DataTable(
              //         sortColumnIndex: 0,
              //         sortAscending: true,
              //         dividerThickness: 2,
              //         columnSpacing: 25,
              //         dataRowHeight: 60,
              //         headingRowHeight: 30,
              //         horizontalMargin: 10,
              //         columns: const [
              //           DataColumn(
              //             label: Expanded(
              //               child: Text(
              //                 "Firstname",
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //           DataColumn(
              //             label: Expanded(
              //               child: Text(
              //                 "Lastname",
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //           DataColumn(
              //             label: Expanded(
              //               child: Text(
              //                 "Position",
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //           DataColumn(
              //             label: Expanded(
              //               child: Text(
              //                 "Team",
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //           DataColumn(
              //             label: Expanded(
              //               child: Text(
              //                 "Picture",
              //                 textAlign: TextAlign.center,
              //               ),
              //             ),
              //           ),
              //         ],
              //         rows: dataRows,
              //       ),
              //     ),
              //     spacer(10),
              //     Container(
              //       width: 150,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.rectangle,
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(Constants.padding),
              //         // boxShadow: [
              //         //   BoxShadow(
              //         //       color: Colors.black,
              //         //       offset: Offset(0, 10),
              //         //       blurRadius: 10),
              //         // ]
              //       ),
              //       child: ElevatedButton.icon(
              //         style: ElevatedButton.styleFrom(
              //           minimumSize: Size.fromHeight(50),
              //           primary: Colors.red,
              //         ),
              //         icon: Icon(Icons.save),
              //         label: Text(
              //           "Save",
              //           style: TextStyle(fontSize: 24),
              //         ),
              //         onPressed: () {
              //           setState(() {
              //             //_index = 0;
              //           });
              //           print("Save");
              //         },
              //       ),
              //     ),
              //     spacer(10),
              //     Container(
              //       width: 150,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.rectangle,
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(Constants.padding),
              //         // boxShadow: [
              //         //   BoxShadow(
              //         //       color: Colors.black,
              //         //       offset: Offset(0, 10),
              //         //       blurRadius: 10),
              //         // ]
              //       ),
              //       child: ElevatedButton.icon(
              //         style: ElevatedButton.styleFrom(
              //           minimumSize: Size.fromHeight(50),
              //           primary: Colors.red,
              //         ),
              //         icon: Icon(Icons.arrow_back),
              //         label: Text(
              //           "Back",
              //           style: TextStyle(fontSize: 24),
              //         ),
              //         onPressed: () {
              //           setState(() {
              //             _index = 0;
              //           });
              //           print("Back pressed");
              //         },
              //       ),
              //     ),
              //   ],
              // );
            },
          ),
        ],
      );
    }

    Widget addMatch() {
      return Text("test");
    }

    Widget addTeam() {
      var _currentSelectedValue;
      var _currentSelectedValue2;
      final nameController = TextEditingController();
      final surnameController = TextEditingController();
      final numberController = TextEditingController();

      double formSpacer = 20;

      return Form(
        key: formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Add Team"),
                  Container(
                    width: 400,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.green)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Team Info"),

                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(labelText: "Team Name"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration:
                                InputDecoration(labelText: "Head Coach"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration:
                                InputDecoration(labelText: "Assistant Coach"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration:
                                InputDecoration(labelText: "Team Manager"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        spacer(formSpacer),
                        Text("Team Logo:"),
                        spacer(formSpacer),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                              ),
                            ),
                            Container(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: () {
                                  selectPhoto(1, 1);
                                },
                                child: const Text("Select Photo"),
                              ),
                            ),
                            // Container(
                            //   width: 150,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       if (pickedFile != null)
                            //         uploadFile('Testing');
                            //     },
                            //     child: const Text("Upload Photo"),
                            //   ),
                            // ),
                          ],
                        ),
                        spacer(formSpacer),
                        Text("Team Jersey:"),
                        spacer(formSpacer),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              color: Colors.black,
                              child: CachedNetworkImage(
                                height: (108 / 100) * 80,
                                width: (192 / 100) * 80,
                                imageUrl: imageUrl,
                              ),
                            ),
                            Container(
                              width: 130,
                              child: ElevatedButton(
                                onPressed: () {
                                  selectPhoto(16, 9);
                                },
                                child: const Text("Select Photo"),
                              ),
                            ),
                            // Container(
                            //   width: 150,
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       if (pickedFile != null)
                            //         uploadFile('Testing');
                            //     },
                            //     child: const Text("Upload Photo"),
                            //   ),
                            // ),
                          ],
                        ),
                        spacer(formSpacer),
                        // spacer(10),
                        // TextFormField(
                        //   controller: surnameController,
                        //   cursorColor: Colors.white,
                        //   textInputAction: TextInputAction.done,
                        //   decoration: InputDecoration(labelText: "Player Surname"),
                        //   autovalidateMode: AutovalidateMode.onUserInteraction,
                        //   validator: (surname) => surname!.length < 2
                        //       ? 'Please enter a valid first name.'
                        //       : null,
                        // ),
                        // spacer(10),
                        // TextFormField(
                        //   controller: numberController,
                        //   cursorColor: Colors.white,
                        //   textInputAction: TextInputAction.done,
                        //   decoration: InputDecoration(labelText: "Jersey Number"),
                        //   autovalidateMode: AutovalidateMode.onUserInteraction,
                        //   validator: (number) => !isNumeric(number!)
                        //       ? 'Please enter a valid jersey number.'
                        //       : null,
                        // ),
                        //spacer(10),
                        // FormField<String>(
                        //   builder: (FormFieldState<String> state2) {
                        //     return InputDecorator(
                        //       decoration: InputDecoration(
                        //           //labelStyle: textStyle,
                        //           labelText: "Please select position",
                        //           errorStyle: TextStyle(
                        //               color: Colors.redAccent, fontSize: 16.0),
                        //           hintText: 'Please select position',
                        //           border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(5.0))),
                        //       isEmpty: _currentSelectedValue2 == null,
                        //       child: DropdownButtonHideUnderline(
                        //         child: DropdownButton<String>(
                        //           style: TextStyle(color: Colors.white),
                        //           value: _currentSelectedValue2,
                        //           isDense: true,
                        //           onChanged: (value) {
                        //             state2.setState(() {
                        //               print(value);
                        //               _currentSelectedValue2 = value!;
                        //               state2.didChange(_currentSelectedValue2);
                        //             });
                        //           },
                        //           items: positions.map((String value) {
                        //             return DropdownMenuItem<String>(
                        //               value: value,
                        //               child: Text(value),
                        //             );
                        //           }).toList(),
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                        //spacer(10),
                        // FormField<String>(
                        //   builder: (FormFieldState<String> state) {
                        //     return InputDecorator(
                        //       decoration: InputDecoration(
                        //           //labelStyle: textStyle,
                        //           labelText: "Please select team",
                        //           errorStyle: TextStyle(
                        //               color: Colors.redAccent, fontSize: 16.0),
                        //           hintText: 'Please select team',
                        //           border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(5.0))),
                        //       isEmpty: _currentSelectedValue == null,
                        //       child: DropdownButtonHideUnderline(
                        //         child: DropdownButton<String>(
                        //           // hint:
                        //           style: TextStyle(color: Colors.white),
                        //           value: _currentSelectedValue,
                        //           isDense: true,
                        //           onChanged: (value) {
                        //             state.setState(() {
                        //               print(value);
                        //               _currentSelectedValue = value!;
                        //               state.didChange(_currentSelectedValue);
                        //             });
                        //           },
                        //           items: teamsForDropdown.map((String value) {
                        //             return DropdownMenuItem<String>(
                        //               value: value,
                        //               child: Text(value),
                        //             );
                        //           }).toList(),
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                        //spacer(10),
                        // if (pickedFile != null)
                        //   Container(
                        //     width: 500,
                        //     height: 300,
                        //     color: Colors.redAccent,
                        //     child: Image.file(File(pickedFile!.path),
                        //         width: double.infinity, fit: BoxFit.cover),
                        //   ),
                        // if (pickedFile != null) spacer(formSpacers),
                        // Text("Player Profile Photo:"),
                        // spacer(10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   children: [
                        //     CircleAvatar(
                        //       radius: 60,
                        //       backgroundColor: Colors.red,
                        //       foregroundImage: CachedNetworkImageProvider(
                        //         imageUrl,
                        //       ),
                        //     ),
                        //     Container(
                        //       width: 130,
                        //       child: ElevatedButton(
                        //         onPressed: () {
                        //           selectPhoto();
                        //         },
                        //         child: const Text("Select Photo"),
                        //       ),
                        //     ),
                        //     // Container(
                        //     //   width: 150,
                        //     //   child: ElevatedButton(
                        //     //     onPressed: () {
                        //     //       if (pickedFile != null)
                        //     //         uploadFile('Testing');
                        //     //     },
                        //     //     child: const Text("Upload Photo"),
                        //     //   ),
                        //     // ),
                        //   ],
                        // ),
                        // spacer(10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   children: [
                        //     Container(
                        //       width: 130,
                        //       decoration: BoxDecoration(
                        //         shape: BoxShape.rectangle,
                        //         color: Colors.white,
                        //         borderRadius:
                        //             BorderRadius.circular(Constants.padding),
                        //         // boxShadow: [
                        //         //   BoxShadow(
                        //         //       color: Colors.black,
                        //         //       offset: Offset(0, 10),
                        //         //       blurRadius: 10),
                        //         // ]
                        //       ),
                        //       child: ElevatedButton.icon(
                        //         style: ElevatedButton.styleFrom(
                        //           minimumSize: Size.fromHeight(50),
                        //           primary: Colors.red,
                        //         ),
                        //         icon: Icon(Icons.arrow_back),
                        //         label: Text(
                        //           "Back",
                        //           style: TextStyle(fontSize: 20),
                        //         ),
                        //         onPressed: () {
                        //           setState(() {
                        //             _index = 0;
                        //           });
                        //           print("Back pressed");
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    width: 400,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.blue)),
                    child: Column(
                      children: [
                        Text("Club Info"),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration:
                                InputDecoration(labelText: "Club Name *"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration:
                                InputDecoration(labelText: "Website Link *"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Facebook Link (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Instagram Link Coach (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Female Players (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Male Players (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Senior Players (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Junior Players (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: nameController,
                            cursorColor: Colors.white,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Number of Referees (Optional)"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (name) => name!.length < 2
                                ? 'Please enter a valid first name.'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 160,
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                  primary: Colors.green,
                ),
                icon: Icon(Icons.save),
                label: Text(
                  "Add Team",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  print("Add Team Tapped");

                  // if (nameController.text.length > 2 &&
                  //     surnameController.text.length > 2 &&
                  //     int.parse(numberController.text) > 0 &&
                  //     _currentSelectedValue != null &&
                  //     _currentSelectedValue2 != null) {
                  //   print("12345 CurrentValue: " + _currentSelectedValue);
                  //   var teamID;
                  //   for (var team in teamsList) {
                  //     if (_currentSelectedValue == team.team_name) {
                  //       teamID = team.team_id;
                  //     }
                  //   }
                  //   print(teamID);

                  //   print("12345 Name: " + nameController.text);
                  //   print("12345 Jersey Name: " + numberController.text);
                  //   print("12345 Postion: " + _currentSelectedValue2);
                  //   print("12345 Team: " + teamID);
                  //   addPlayerToDB(
                  //     nameController.text,
                  //     surnameController.text,
                  //     numberController.text,
                  //     _currentSelectedValue2,
                  //     teamID,
                  //     imageUrl,
                  //   );

                  //   setState(() {
                  //     nameController.text = "";
                  //     surnameController.text = "";
                  //     numberController.text = "";
                  //     _currentSelectedValue = "";
                  //     _currentSelectedValue2 = "";
                  //     imageUrl =
                  //         "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4";
                  //   });
                  // } else {
                  //   Utils.showSnackBar(
                  //       "Missing player information.", Colors.orange);
                  //   print("Something Missing");
                  // }

                  // if (nameController.text.length > 3)
                  //
                },
              ),
            ),
            Container(
              width: 130,
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
                  style: TextStyle(fontSize: 20),
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
      );
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
                  primary: Colors.green,
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
                              profilePicture: true,
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

    return Scaffold(
      body: Center(
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
              body[_index],
            ],
          ),
        ),
      ),
    );
  }
}
