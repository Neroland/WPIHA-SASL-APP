import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sasl_app/widgets/classes.dart';
import 'package:sasl_app/widgets/reusable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

final db = FirebaseFirestore.instance;

final Stream<QuerySnapshot> seasons =
    FirebaseFirestore.instance.collection("seasons").snapshots();

Widget infoRow(title, data) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      Text(
        data,
        style: TextStyle(color: Colors.black),
      ),
    ],
  );
}

Future<void> _launchURL(url) async {
  final Uri _url = Uri.parse(url);
  // const url = 'https://flutter.io';
  if (await canLaunchUrl(_url)) {
    await launchUrl(mode: LaunchMode.externalApplication, _url);
  } else {
    throw 'Could not launch $_url';
  }
}

class teams extends StatelessWidget {
  const teams({Key? key}) : super(key: key);

  final double spacerSize = 10;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<QuerySnapshot>(
          stream: seasons,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                heightFactor: 6,
                child: Container(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    color: Colors.red,
                    backgroundColor: Colors.green,
                  ),
                ),
              );
            }

            final data = snapshot.requireData;

            List<Teams> teamsList = [];
            List<Players> playersList = [];
            var countTeam = [];
            var countPosition = [];
            var teams_data = data.docs[0]['teams'];
            var players_data = data.docs[0]['players'];

            for (var doc in teams_data) {
              //print(doc);
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
            for (var doc in players_data) {
              countTeam.add(doc["player_team_id"]);
              countPosition
                  .add(doc["player_team_id"] + "_" + doc["player_position"]);
              playersList.add(
                Players(
                  player_id: doc["player_id"],
                  player_first_name: doc["player_first_name"],
                  player_last_name: doc["player_last_name"],
                  player_picture_url: doc["player_picture_url"],
                  player_team_id: doc["player_team_id"],
                  player_position: doc["player_position"],
                  player_gp: doc["player_gp"],
                  player_g: doc["player_g"],
                  player_a: doc["player_a"],
                  player_pts: doc["player_pts"],
                  player_jersey_number: doc["player_jersey_number"],
                ),
              );
            }
            //print(countTeam);
            //print(countPosition);

            var countPlayersInTeam = Map();
            var countPositionsInTeam = Map();
            var playerCount = "0";
            var defenceCount = "0";
            var forwardCount = "0";
            var goaltenderCount = "0";
            var teamManager = "None",
                headCoach = "None",
                assistantCoach = "None";

            countTeam.forEach((element) {
              if (!countPlayersInTeam.containsKey(element)) {
                countPlayersInTeam[element] = 1;
              } else {
                countPlayersInTeam[element] += 1;
              }
            });

            countPosition.forEach((element) {
              if (!countPositionsInTeam.containsKey(element)) {
                countPositionsInTeam[element] = 1;
              } else {
                countPositionsInTeam[element] += 1;
              }
            });

            // print(countPlayersInTeam);
            // print(countPlayersInTeam["1"]);
            // print(countPositionsInTeam);

            Map clubInfoMap = {};
            List<Widget> teamInfoCards = [];
            for (var team in teamsList) {
              //print(countPositionsInTeam["${team.team_id}_Defence"]);

              if (countPlayersInTeam[team.team_id] == null) {
                playerCount = "0";
              } else {
                playerCount = countPlayersInTeam[team.team_id].toString();
              }

              if (countPositionsInTeam["${team.team_id}_Defence"] == null) {
                defenceCount = "0";
              } else {
                defenceCount =
                    countPositionsInTeam["${team.team_id}_Defence"].toString();
              }
              if (countPositionsInTeam["${team.team_id}_Forward"] == null) {
                forwardCount = "0";
              } else {
                forwardCount =
                    countPositionsInTeam["${team.team_id}_Forward"].toString();
              }
              if (countPositionsInTeam["${team.team_id}_Goaltender"] == null) {
                goaltenderCount = "0";
              } else {
                goaltenderCount =
                    countPositionsInTeam["${team.team_id}_Goaltender"]
                        .toString();
              }
              teamManager = team.team_manager;
              headCoach = team.head_coach;
              assistantCoach = team.assistant_coach;

              clubInfoMap = team.club_info;
              // clubInfo.add(ClubInfo(
              //     club_name: team.club_info[0],
              //     female_players: team.club_info[0],
              //     junior_players: team.club_info[0],
              //     male_players: team.club_info[0],
              //     number_of_players: team.club_info[0],
              //     senior_players: team.club_info[0],
              //     total_referees: team.club_info[0]));

              teamInfoCards.add(
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    elevation: 5,
                    color: Colors.red,
                    margin: EdgeInsets.all(8),
                    child: Container(
                      width: 900,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  team.team_name,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            spacer(15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: CachedNetworkImage(
                                    maxWidthDiskCache: 200,
                                    imageUrl: team.team_logo_url,
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ],
                            ),
                            spacer(15),
                            Text("Team Info"),
                            spacer(15),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              width: 900,
                              child: Column(
                                children: [
                                  infoRow("Number of Players", playerCount),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Number of Defence", defenceCount),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Number of Forwards", forwardCount),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Head Coach", headCoach),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  infoRow("Assistant Coach", assistantCoach),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  infoRow("Team Manager", teamManager),
                                ],
                              ),
                            ),
                            spacer(15),
                            Text("Club Info"),
                            spacer(15),
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              width: 900,
                              child: Column(
                                children: [
                                  infoRow("Club", clubInfoMap["club_name"]),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Number of Players",
                                      clubInfoMap["number_of_players"]),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Male Players",
                                      clubInfoMap["male_players"]),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Female Players",
                                      clubInfoMap["female_players"]),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Junior Players",
                                      clubInfoMap["junior_players"]),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Senior Players",
                                      clubInfoMap["senior_players"]),
                                  spacer(spacerSize / 3),
                                  Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                  spacer(spacerSize / 3),
                                  infoRow("Referees",
                                      clubInfoMap["total_referees"]),
                                ],
                              ),
                            ),
                            spacer(15),
                            Text("Club Links"),
                            spacer(15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (clubInfoMap["club_fb_link"]
                                    .toString()
                                    .isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL(clubInfoMap["club_fb_link"]);
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.facebook,
                                      color: Colors.black,
                                      size: 32.0,
                                      shadows: [
                                        Shadow(
                                            color: Colors.white,
                                            offset: Offset.fromDirection(-50))
                                      ],
                                    ),
                                  ),
                                if (clubInfoMap["club_ig_link"]
                                    .toString()
                                    .isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL(clubInfoMap["club_ig_link"]);
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.instagram,
                                      color: Colors.black,
                                      size: 32.0,
                                      shadows: [
                                        Shadow(
                                            color: Colors.white,
                                            offset: Offset.fromDirection(-50))
                                      ],
                                    ),
                                  ),
                                if (clubInfoMap["club_website_link"]
                                    .toString()
                                    .isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _launchURL(
                                          clubInfoMap["club_website_link"]);
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.globe,
                                      color: Colors.black,
                                      size: 32.0,
                                      shadows: [
                                        Shadow(
                                            color: Colors.white,
                                            offset: Offset.fromDirection(-50))
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            spacer(15),
                            if (team.team_jersey_picture_url.isNotEmpty)
                              Text("Jerseys"),
                            if (team.team_jersey_picture_url.isNotEmpty)
                              spacer(15),
                            if (team.team_jersey_picture_url.isNotEmpty)
                              Container(
                                width: 900,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: CachedNetworkImage(
                                  height: 200,
                                  imageUrl: team.team_jersey_picture_url,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // var teams = doc["teams"];

            return Column(children: teamInfoCards);
          },
        ),
      ),
    );
  }
}


// StreamBuilder<QuerySnapshot>(
//         stream: seasons,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return const Text('Something went wrong');
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Text("Waiting");
//           }

//           final data = snapshot.requireData;

//           List<Players> playerList = [];
//           List<Teams> teamsList = [];

//           var playersData = data.docs[0]['players'];
//           var teams_data = data.docs[0]['teams'];

//           //print(sortedMap);

//           //test.add(Text('$latest_season'));
//           for (var doc in playersData) {
//             playerList.add(
//               Players(
//                   player_id: doc["player_id"],
//                   player_first_name: doc["player_first_name"],
//                   player_last_name: doc["player_last_name"],
//                   player_picture_url: doc["player_picture_url"],
//                   player_team_id: doc["player_team_id"],
//                   player_position: doc["player_position"],
//                   player_gp: doc["player_gp"],
//                   player_g: doc["player_g"],
//                   player_a: doc["player_a"],
//                   player_pts: doc["player_pts"]),
//             );
//           }

//           for (var doc in teams_data) {
//             teamsList.add(
//               Teams(
//                   team_name: doc["name"],
//                   team_id: doc["team_id"],
//                   team_logo_url: doc["team_logo_url"]),
//             );
//           }

//           // var teams = doc["teams"];

//           // return Column(
//           //   children: test,
//           // );

//           // for (var game in test) {
//           //   print(game.game_number);
//           // }

//           //print(test[0].date_time);

//           playerList.sort(
//             (a, b) {
//               return b.player_pts.compareTo(a.player_pts);
//             },
//           );

//           // print(test[0].date_time);
//           List<DataRow> playerRows = [];
//           int count = 0;
//           for (var player in playerList) {
//             count++;
//             // print(player.player_id);

//             playerRows.add(


// StreamBuilder<QuerySnapshot>(
//                   stream: seasons,
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.hasError) {
//                       return const Text('Something went wrong');
//                     }
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Text("Waiting");
//                     }

//                     final data = snapshot.requireData;

//                     List<Widget> test = [];

//                     var latest_season = data.docs[0]['teams'];

//                     test.add(Text('$latest_season'));
//                     for (var doc in latest_season) {
//                       test.add(Text('$doc'));
//                     }

//                     // var teams = doc["teams"];

//                     return Column(
//                       children: test,
//                     );
//                   },
//                 ),
