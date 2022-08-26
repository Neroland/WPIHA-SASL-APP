import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:intl/intl.dart';
import 'package:sasl_app/widgets/classes.dart';
import 'package:sasl_app/widgets/reusable.dart';

// final db = FirebaseFirestore.instance;

final Stream<QuerySnapshot> seasons =
    FirebaseFirestore.instance.collection("seasons").snapshots();

// test() async {
//   await FirebaseFirestore.instance.collection("seasons").get().then((event) {
//     for (var doc in event.docs) {
//       print("AVVV: ${doc.id} => ${doc.data()}");
//     }
//   });
// }

class mainMenuPage extends StatelessWidget {
  mainMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double spacerSize = 10;
    double card_width = 220;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            spacer(spacerSize),
            gameLive(false),
            const Text(
              "Matches",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
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

                List<Games> gamesList = [];
                List<Teams> teamsList = [];

                var latest_season = data.docs[0]['games'];
                var teams_data = data.docs[0]['teams'];

                //print(sortedMap);

                //test.add(Text('$latest_season'));
                for (var doc in latest_season) {
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
                        team_name: doc["name"],
                        team_id: doc["team_id"],
                        team_logo_url: doc["team_logo_url"],
                        club_info: doc["club_info"],
                        team_jersey_picture_url:
                            doc["team_jersey_picture_url"]),
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
                List<Widget> cards = [];
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

                Widget isLive(differenceInMinutes) {
                  if (0 < differenceInMinutes && differenceInMinutes < 240) {
                    return BlinkText(
                      duration: Duration(seconds: 1),
                      'LIVE',
                      style: TextStyle(fontSize: 24.0, color: Colors.red),
                      endColor: Colors.orange,
                    );
                  } else {
                    return SizedBox();
                  }
                }

                Widget isLiveSpacer(differenceInMinutes) {
                  if (0 < differenceInMinutes && differenceInMinutes < 240) {
                    return SizedBox(
                      height: spacerSize,
                    );
                  } else {
                    return SizedBox();
                  }
                }

                for (var game in gamesList) {
                  //print(game.game_number);
                  var gameDate = DateTime.fromMillisecondsSinceEpoch(
                      game.date_time.millisecondsSinceEpoch);

                  final difference = date2.difference(gameDate).inMinutes;
                  //print(teamsList[int.parse(game.team_1_id)].team_name);

                  cards.add(
                    GestureDetector(
                      onTap: () {
                        print("Tappped game ${game.game_number}");
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        elevation: 5,
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isLive(difference),
                              isLiveSpacer(difference),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // Text("Game ${game.game_number}"),
                                  // const SizedBox(
                                  //   width: 20,
                                  // ),
                                  Text(
                                    "Game ${game.game_number.toString()}" +
                                        "\n" +
                                        gameDate.day.toString() +
                                        " " +
                                        months[gameDate.month - 1] +
                                        " " +
                                        gameDate.year.toString() +
                                        " at " +
                                        gameDate.hour.toString() +
                                        ":" +
                                        gameDate.minute
                                            .toString()
                                            .padLeft(2, '0'),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 120,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CachedNetworkImage(
                                          height: 60,
                                          imageUrl: teamsList[
                                                  int.parse(game.team_1_id) - 1]
                                              .team_logo_url,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                        spacer(10),
                                        Text(
                                          teamsList[
                                                  int.parse(game.team_1_id) - 1]
                                              .team_name,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            game.current_score_team_1,
                                            style:
                                                const TextStyle(fontSize: 40),
                                          ),
                                          Text(
                                              style:
                                                  const TextStyle(fontSize: 20),
                                              " : "),
                                          Text(
                                              style:
                                                  const TextStyle(fontSize: 40),
                                              game.current_score_team_2)
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 120,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CachedNetworkImage(
                                          height: 60,
                                          imageUrl: teamsList[
                                                  int.parse(game.team_2_id) - 1]
                                              .team_logo_url,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                        spacer(10),
                                        Text(
                                          teamsList[
                                                  int.parse(game.team_2_id) - 1]
                                              .team_name,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Watch Live"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(children: cards));
              },
            ),
            spacer(spacerSize),
            Text(
              "News",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
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

                List<News> newsList = [];

                var news_data = data.docs[0]['news'];

                //print(sortedMap);

                //test.add(Text('$latest_season'));
                for (var doc in news_data) {
                  //print(doc);
                  newsList.add(
                    News(
                        post_body: doc["post_body"],
                        post_id: doc["post_id"],
                        post_image_url: doc["post_image_url"],
                        post_title: doc["post_title"],
                        post_timestamp: doc["timestamp"]),
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

                newsList.sort(
                  (a, b) {
                    return a.post_timestamp.compareTo(b.post_timestamp);
                  },
                );

                // print(test[0].date_time);
                List<Widget> newsCards = [];
                List monthsLong = [
                  'January',
                  'February',
                  'March',
                  'April',
                  'May',
                  'June',
                  'July',
                  'August',
                  'September',
                  'October',
                  'November',
                  'December'
                ];

                for (var post in newsList) {
                  //print(post.post_body);
                  var postDate = DateTime.fromMillisecondsSinceEpoch(
                      post.post_timestamp.millisecondsSinceEpoch);

                  // final difference = date2.difference(gameDate).inMinutes;
                  // print(teamsList[int.parse(game.team_1_id)].team_name);

                  newsCards.add(
                    GestureDetector(
                      onTap: () {
                        print("Tappped ${post.post_id}");
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              color: Colors.amber,
                              child: FractionallySizedBox(
                                heightFactor: 0.85,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text('Modal BottomSheet'),
                                      ElevatedButton(
                                        child: const Text('Close BottomSheet'),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: Column(children: [
                          ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                              ).createShader(Rect.fromLTRB(
                                  0, 0, rect.width, rect.height - 10));
                            },
                            blendMode: BlendMode.darken,
                            child: CachedNetworkImage(
                              maxWidthDiskCache: card_width.toInt(),
                              fit: BoxFit.cover,
                              imageUrl: post.post_image_url,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: card_width,
                            child: Text(
                              post.post_body,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            child: Text(
                              // postDate.day.toString() +
                              //     postDate.day.toString() +
                              //     " " +
                              //     monthsLong[postDate.month - 1] +
                              //     " " +
                              //     postDate.year.toString() +
                              //     ", " +
                              //     postDate.hour.toString() +
                              //     ":" +
                              //     postDate.minute.toString().padLeft(2, '0') +
                              DateFormat.yMMMMEEEEd().format(postDate) +
                                  ', ' +
                                  DateFormat.jm().format(postDate),
                              //"10 November 2022, 4:20pm",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ]),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(children: newsCards));
              },
            ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   padding: const EdgeInsets.all(16),
            //   child: Row(
            //     children: [
            //       GestureDetector(
            //         onTap: () {
            //           print("Tappped");
            //           showModalBottomSheet<void>(
            //             isScrollControlled: true,
            //             context: context,
            //             builder: (BuildContext context) {
            //               return Container(
            //                 color: Colors.amber,
            //                 child: FractionallySizedBox(
            //                   heightFactor: 0.85,
            //                   child: Center(
            //                     child: Column(
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: <Widget>[
            //                         const Text('Modal BottomSheet'),
            //                         ElevatedButton(
            //                           child: const Text('Close BottomSheet'),
            //                           onPressed: () => Navigator.pop(context),
            //                         )
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               );
            //             },
            //           );
            //         },
            //         child: Card(
            //           clipBehavior: Clip.antiAliasWithSaveLayer,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10.0),
            //           ),
            //           elevation: 5,
            //           margin: const EdgeInsets.all(10),
            //           child: Column(children: [
            //             ShaderMask(
            //               shaderCallback: (rect) {
            //                 return const LinearGradient(
            //                   begin: Alignment.topCenter,
            //                   end: Alignment.bottomCenter,
            //                   colors: [Colors.transparent, Colors.black],
            //                 ).createShader(
            //                     Rect.fromLTRB(0, 0, rect.width, rect.height - 10));
            //               },
            //               blendMode: BlendMode.darken,
            //               child: Image.network(
            //                 height: 128,
            //                 width: card_width,
            //                 'https://placeimg.com/1920/1080/any',
            //                 fit: BoxFit.cover,
            //                 scale: 10,
            //               ),
            //             ),
            //             SizedBox(
            //               height: 5,
            //             ),
            //             Container(
            //               width: card_width,
            //               child: Text(
            //                 "This is a long text asd asda sd asdasdas asdas adasda dasd asdas adsda dasdasd asdasdadsadas ",
            //                 overflow: TextOverflow.ellipsis,
            //                 textAlign: TextAlign.center,
            //                 maxLines: 3,
            //               ),
            //             ),
            //             SizedBox(
            //               height: 5,
            //             ),
            //             SizedBox(
            //               child: Text(
            //                 "10 November 2022, 4:20pm",
            //                 style: TextStyle(fontSize: 10),
            //               ),
            //             ),
            //             SizedBox(
            //               height: 5,
            //             ),
            //           ]),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            spacer(spacerSize),
            const Text(
              "Season Statistcs",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      print("Tappped");
                    },
                    child: Card(
                      elevation: 5,
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Game 1'),
                                const SizedBox(
                                  width: 20,
                                ),
                                const Text("11/08/2022, 18:30")
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.network(
                                      "https://cdn.britannica.com/27/4227-004-32423B42/Flag-South-Africa.jpg",
                                      scale: 10,
                                    ),
                                    const Text("South Africa"),
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  "6:1",
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.network(
                                      "https://upload.wikimedia.org/wikipedia/en/thumb/0/03/Flag_of_Italy.svg/255px-Flag_of_Italy.svg.png",
                                      scale: 3,
                                    ),
                                    const Text("Italy"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text("Watch Live"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget gameLive(isGameLive) {
  if (isGameLive) {
    return Column(children: [
      Text("Yes"),
      spacer(10),
    ]);
  } else {
    return SizedBox();
  }
}
