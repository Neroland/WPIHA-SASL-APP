import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sasl_app/widgets/classes.dart';
import 'package:sasl_app/widgets/reusable.dart';

Stream<QuerySnapshot> seasons =
    FirebaseFirestore.instance.collection("seasons").snapshots();

// Future<dynamic> statistics() async {
//   DatabaseReference ref = FirebaseDatabase.instance.ref("teams_db/teams");

//   await ref.set({
//     "name": "John",
//     "age": 18,
//     "address": {"line1": "100 Mountain View"}
//   });
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: seasons,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Waiting");
                  }

                  final data = snapshot.requireData;

                  List<Players> playerList = [];
                  List<Teams> teamsList = [];

                  var playersData = data.docs[0]['players'];
                  var teams_data = data.docs[0]['teams'];

                  //print(sortedMap);

                  //test.add(Text('$latest_season'));
                  for (var doc in playersData) {
                    playerList.add(
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
                        player_pts: ((int.parse(doc["player_a"]) +
                                int.parse(doc["player_g"]))
                            .toString()),
                        player_jersey_number: doc["player_jersey_number"],
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
                  int count = 0;
                  String first_player_name = "",
                      second_player_name = "",
                      third_player_name = "",
                      first_player_url = "",
                      second_player_url = "",
                      third_player_url = "",
                      first_player_id = "",
                      second_player_id = "",
                      third_player_id = "";

                  playerList.sort(
                    (a, b) {
                      return a.player_g.compareTo(b.player_g);
                    },
                  );

                  for (var player in playerList) {
                    if (count == 0) {
                      first_player_name = player.player_first_name +
                          " " +
                          player.player_last_name;
                      first_player_id = player.player_id;
                      first_player_url = player.player_picture_url;
                      if (first_player_url.isEmpty) {
                        first_player_url =
                            "https://www.pngkey.com/png/full/73-730477_first-name-profile-image-placeholder-png.png";
                      }
                    }
                    if (count == 1) {
                      second_player_name = player.player_first_name +
                          " " +
                          player.player_last_name;
                      second_player_id = player.player_id;
                      second_player_url = player.player_picture_url;
                      if (first_player_url.isEmpty) {
                        first_player_url =
                            "https://www.pngkey.com/png/full/73-730477_first-name-profile-image-placeholder-png.png";
                      }
                    }
                    if (count == 2) {
                      third_player_name = player.player_first_name +
                          " " +
                          player.player_last_name;
                      third_player_id = player.player_id;
                      third_player_url = player.player_picture_url;
                      if (third_player_url.isEmpty) {
                        third_player_url =
                            "https://www.pngkey.com/png/full/73-730477_first-name-profile-image-placeholder-png.png";
                      }
                    }
                    count++;
                    if (count == 3) {
                      break;
                    }
                  }

                  //print(count);
                  playerList.sort(
                    (a, b) {
                      return b.player_pts.compareTo(a.player_pts);
                    },
                  );

                  // print(test[0].date_time);
                  List<DataRow> playerRows = [];
                  count = 0;

                  for (var player in playerList) {
                    count++;
                    // print(player.player_id);
                    var profilePicURL = player.player_picture_url;
                    if (player.player_picture_url.isEmpty) {
                      profilePicURL =
                          "https://www.pngkey.com/png/full/73-730477_first-name-profile-image-placeholder-png.png";
                    }

                    //print(profilePicURL);

                    playerRows.add(
                      DataRow(
                        cells: [
                          DataCell(
                            Center(
                              child: Text(count.toString()),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: CachedNetworkImageProvider(
                                  profilePicURL,
                                ),
                                //   CachedNetworkImage(
                                // imageUrl: profilePicURL,
                                // progressIndicatorBuilder:
                                //     (context, url, downloadProgress) =>
                                //         CircularProgressIndicator(
                                //             value: downloadProgress.progress),
                                // errorWidget: (context, url, error) =>
                                //     const Icon(Icons.error),
                                // height: 40,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${player.player_first_name}\n${player.player_last_name}",
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    player.player_position,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                player.player_gp,
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(player.player_g),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(player.player_a),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                (int.parse(player.player_a) +
                                        int.parse(player.player_g))
                                    .toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      spacer(10),
                      Text("Scoring Leaders"),
                      spacer(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (first_player_id.isNotEmpty)
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: CachedNetworkImageProvider(
                                    first_player_url,
                                  ),
                                ),
                                spacer(10),
                                Text(first_player_name),
                              ],
                            ),
                          if (second_player_id.isNotEmpty)
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: CachedNetworkImageProvider(
                                    second_player_url,
                                  ),
                                ),
                                spacer(10),
                                Text(second_player_name),
                              ],
                            ),
                          if (third_player_id.isNotEmpty)
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: CachedNetworkImageProvider(
                                    third_player_url,
                                  ),
                                ),
                                spacer(10),
                                Text(third_player_name),
                              ],
                            ),
                        ],
                      ),
                      spacer(10),
                      Text("Player Statistics"),
                      spacer(20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          sortColumnIndex: 0,
                          sortAscending: true,
                          dividerThickness: 2,
                          columnSpacing: 20,
                          dataRowHeight: 60,
                          headingRowHeight: 30,
                          horizontalMargin: 10,
                          columns: const [
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "Rank",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "Picture",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "Player",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "GP",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "G",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "A",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "PTS",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                          rows: playerRows,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: DataTable(
        //     sortColumnIndex: 0,
        //     sortAscending: true,
        //     dividerThickness: 2,
        //     columnSpacing: 25,
        //     dataRowHeight: 60,
        //     headingRowHeight: 30,
        //     horizontalMargin: 10,
        //     columns: const [
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "Rank",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //         numeric: true,
        //       ),
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "Picture",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       ),
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "Player",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       ),
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "GP",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       ),
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "G",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       ),
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "A",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       ),
        //       DataColumn(
        //         label: Expanded(
        //           child: Text(
        //             "PTS",
        //             textAlign: TextAlign.center,
        //           ),
        //         ),
        //       ),
        //     ],
        //     rows: [
        //       DataRow(
        //         cells: [
        //           const DataCell(
        //             Text("1"),
        //           ),
        //           DataCell(
        //             Center(
        //               child: CachedNetworkImage(
        //                 imageUrl:
        //                     "https://www.pngkey.com/png/full/73-730477_first-name-profile-image-placeholder-png.png",
        //                 progressIndicatorBuilder:
        //                     (context, url, downloadProgress) =>
        //                         CircularProgressIndicator(
        //                             value: downloadProgress.progress),
        //                 errorWidget: (context, url, error) =>
        //                     const Icon(Icons.error),
        //                 height: 40,
        //               ),
        //             ),
        //           ),
        //           DataCell(
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: const [
        //                 Text(
        //                   "Dario\nMaselli",
        //                   textAlign: TextAlign.center,
        //                 ),
        //                 Text(
        //                   "Defence",
        //                   style: TextStyle(fontSize: 10),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const DataCell(
        //             Text("Testing"),
        //           ),
        //           const DataCell(
        //             Text("Testing"),
        //           ),
        //           const DataCell(
        //             Text("Testing"),
        //           ),
        //           const DataCell(
        //             Text("Testing"),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
