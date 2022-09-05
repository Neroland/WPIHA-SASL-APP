import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sasl_app/pages/games_page.dart';
import 'package:sasl_app/widgets/classes.dart';
import 'package:sasl_app/widgets/reusable.dart';

Stream<QuerySnapshot> seasons =
    FirebaseFirestore.instance.collection("seasons").snapshots();

// Points
// 2 points for winning
// 1 points for tie
// 0 points for loss

Widget standings() {
  return StreamBuilder<QuerySnapshot>(
    stream: seasons,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Waiting");
      }

      final data = snapshot.requireData;

      List<Games> gamesList = [];
      List<Games> pastGamesList = [];
      List<Teams> teamsList = [];
      List<TeamStandings> teamPoints = [];

      //var playersData = data.docs[0]['players'];
      var teams_data = data.docs[0]['teams'];
      var games_data = data.docs[0]['games'];

      //print(sortedMap);

      //test.add(Text('$latest_season'));
      // for (var doc in playersData) {
      //   playerList.add(
      //     Players(
      //       player_id: doc["player_id"],
      //       player_first_name: doc["player_first_name"],
      //       player_last_name: doc["player_last_name"],
      //       player_picture_url: doc["player_picture_url"],
      //       player_team_id: doc["player_team_id"],
      //       player_position: doc["player_position"],
      //       player_gp: doc["player_gp"],
      //       player_g: doc["player_g"],
      //       player_a: doc["player_a"],
      //       player_pts:
      //           ((int.parse(doc["player_a"]) + int.parse(doc["player_g"]))
      //               .toString()),
      //       player_jersey_number: doc["player_jersey_number"],
      //     ),
      //   );
      // }

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

      for (var doc in games_data) {
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

      for (var game in gamesList) {
        final date2 = DateTime.now();
        // print(date2);
        //print(game.game_number);
        var gameDate = DateTime.fromMillisecondsSinceEpoch(
            game.date_time.millisecondsSinceEpoch);

        //print(gameDate);
        final difference = date2.difference(gameDate).inMinutes;
        //print(difference);

        if (difference > 240) {
          //print("here");
          pastGamesList.add(Games(
              current_score_team_1: game.current_score_team_1,
              current_score_team_2: game.current_score_team_2,
              date_time: game.date_time,
              game_number: game.game_number,
              livestream_url: game.livestream_url,
              team_1_id: game.team_1_id,
              team_2_id: game.team_2_id));
        }
      }

      for (var game in pastGamesList) {
        //print("game num: " + game.game_number);
        //print("game score team 1: " + game.current_score_team_1);
        //print("game score team 2: " + game.current_score_team_2);
        var team_1_pts = 0, team_2_pts = 0;
        if (int.parse(game.current_score_team_1) >
            int.parse(game.current_score_team_2)) {
          teamPoints.add(TeamStandings(team_id: game.team_1_id, team_pts: 2));
          teamPoints.add(TeamStandings(team_id: game.team_2_id, team_pts: 0));
          //print("score 1 > score 2");
        }
        if (int.parse(game.current_score_team_1) <
            int.parse(game.current_score_team_2)) {
          teamPoints.add(TeamStandings(team_id: game.team_1_id, team_pts: 0));
          teamPoints.add(TeamStandings(team_id: game.team_2_id, team_pts: 2));
          //print("score 2 > score 1");
        }
        if (int.parse(game.current_score_team_1) ==
            int.parse(game.current_score_team_2)) {
          teamPoints.add(TeamStandings(team_id: game.team_1_id, team_pts: 1));
          teamPoints.add(TeamStandings(team_id: game.team_2_id, team_pts: 1));

          //print("score 1 = score 2");
        }
      }
      var teamsListed = [];
      var teamsListedPoints = [[]];
      teamsListed.clear();
      teamsListedPoints.clear();
      //print(count);

      for (var teams in teamPoints) {
        print("Team Points = [${teams.team_id},${teams.team_pts}]");
        if (teamsListed.contains(teams.team_id) != true) {
          teamsListed.add(teams.team_id);
        }

        //print("TeamID: " + teams.team_id);
        //print("TeamPts: " + teams.team_pts.toString());
        // if (teamsListed.contains(teams.team_id) == false) {
        //   // var count = teamPoints
        //   //     .where((c) => c.team_id == teams.team_id)
        //   //     .toList()
        //   //     .length;
        //   //print("Count: " + count.toString());
        //   teamsListedPoints.add([teams.team_id, count]);
        //   teamsListed.add(teams.team_id);
        // }
        //print(count);
      }

      for (var teams in teamsListed) {
        int pts = 0, ties = 0, losses = 0, games_played = 0, wins = 0;
        for (var temp in teamPoints) {
          if (temp.team_id == teams) {
            games_played += 1;
            if (temp.team_pts == 0) {
              losses = losses + 1;
            }
            if (temp.team_pts == 1) {
              ties = ties + 1;
            }
            if (temp.team_pts == 2) {
              wins = wins + 1;
            }
            pts = pts + temp.team_pts;
          }
        }
        print(pts);
        teamsListedPoints.add([
          pts,
          teams,
          wins,
          losses,
          ties,
          games_played,
        ]);
      }

      print(teamsListed);
      print(teamsListedPoints);

      // print(teamsListedPoints);
      // var count = 0;
      // var teamCalculated = [];
      // print("Team Points: " + teamPoints.toString());
      // print("TeamListed: " + teamsListed.toString());
      // print("TeamListedPoints: " + teamsListedPoints.toString());
      // for (var team in teamsListed) {
      //   for (var teams in teamsListedPoints) {
      //     print(team[0]);
      //     if (teams[0] == team) {
      //       count += int.parse(teams[1].toString());
      //     }
      //   }
      //   teamCalculated.add([team, count]);
      // }

      List<TeamStandingsCalculated> teamsCalculated = [];

      // print(teamCalculated);
      for (var team in teamsListedPoints) {
        for (var test in teamsList) {
          if (test.team_id == team[1]) {
            teamsCalculated.add(TeamStandingsCalculated(
                team_id: test.team_id,
                team_pts: team[0],
                team_games: team[5],
                team_logo_url: test.team_logo_url,
                team_losses: team[3],
                team_name: test.team_name,
                team_ties: team[4],
                team_wins: team[2]));
          }
        }
      }

      teamsCalculated.sort(
        (a, b) {
          return b.team_pts.compareTo(a.team_pts);
        },
      );
      List<DataRow> standingsRows = [];
      bool team_1_isValid = false,
          team_2_isValid = false,
          team_3_isValid = false,
          noData_isValid = false;
      var count = 0;
      String team_1_url = '', team_2_url = '', team_3_url = '';

      List<Widget> noData = [];

      for (var tempTeam in teamsCalculated) {
        count++;
        if (count == 1) {
          team_1_url = tempTeam.team_logo_url;
        }
        if (count == 2) {
          team_2_url = tempTeam.team_logo_url;
        }
        if (count == 3) {
          team_3_url = tempTeam.team_logo_url;
        }
        standingsRows.add(
          DataRow(
            cells: [
              DataCell(
                Center(
                  child: Text(count.toString()),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    tempTeam.team_name,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(tempTeam.team_games.toString()),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    tempTeam.team_wins.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    tempTeam.team_losses.toString(),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    tempTeam.team_ties.toString(),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    tempTeam.team_pts.toString(),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      count = 0;
      if (standingsRows.isEmpty) {
        noData_isValid = true;
      }

      if (noData_isValid) {
        teamsList.sort(
          (a, b) {
            return b.team_name.compareTo(a.team_name);
          },
        );
        for (var teams in teamsList) {
          count++;
          if (count == 1) {
            team_1_isValid = true;

            if (count == 1) {
              team_1_isValid = true;
              noData.add(
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(
                    teams.team_logo_url,
                  ),
                ),
              );
            }
          }
          if (count == 2) {
            team_2_isValid = true;
            noData.add(
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(
                  teams.team_logo_url,
                ),
              ),
            );
          }
          if (count == 3) {
            team_3_isValid = true;
            noData.add(
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(
                  teams.team_logo_url,
                ),
              ),
            );
          }

          standingsRows.add(
            DataRow(
              cells: [
                DataCell(
                  Center(
                    child: Text("0"),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      teams.team_name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text("0"),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text("0"),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text("0"),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text("0"),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text("0"),
                  ),
                ),
              ],
            ),
          );
        }
      }
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              height: 170,
              color: Colors.red,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (team_1_url != '')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("2nd Place"),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                            team_1_url,
                          ),
                        ),
                      ],
                    ),
                  if (team_2_url != '')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("1st Place"),
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: CachedNetworkImageProvider(
                            team_2_url,
                          ),
                        ),
                      ],
                    ),
                  if (team_3_url != '')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("3rd Place"),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: CachedNetworkImageProvider(
                            team_2_url,
                          ),
                        ),
                      ],
                    ),
                  if (noData_isValid && team_1_isValid) noData[0],
                  if (noData_isValid && team_2_isValid) noData[1],
                  if (noData_isValid && team_3_isValid) noData[2],
                  // Container(
                  //   height: 10,
                  //   width: 100,
                  //   color: Colors.red,
                  // ),
                  // Container(
                  //   height: 100,
                  //   width: 120,
                  //   color: Colors.green,
                  // ),
                  // Container(
                  //   height: 100,
                  //   width: 120,
                  //   color: Colors.blue,
                  // ),
                ],
              ),
            ),
            spacer(20),
            Text("Team Standings"),
            spacer(10),
            DataTable(
              sortColumnIndex: 0,
              sortAscending: true,
              dividerThickness: 2,
              columnSpacing: 8,
              dataRowHeight: 60,
              headingRowHeight: 40,
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
                      "Team",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "Games",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "Wins",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "Losses",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text(
                      "Ties",
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
              rows: standingsRows,
            ),
          ],
        ),
      );
    },
  );
}
