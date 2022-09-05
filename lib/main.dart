import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sasl_app/theme.dart';
import 'package:sasl_app/auth_pages/verify_email_page.dart';
import 'package:sasl_app/utils.dart';
import 'firebase_options.dart';
import 'package:sasl_app/auth_pages/auth_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_app_installations/firebase_app_installations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await FirebaseMessaging.instance.subscribeToTopic("development");
  print('User granted permission: ${settings.authorizationStatus}');
  // String id = await FirebaseInstallations.instance.getId();

  // print("ID: " + id);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("HERE " + message.notification!.body.toString());

    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final fcmToken = await messaging.getToken();
  print("FCM Token: " + fcmToken.toString());

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

final navigatorKey = GlobalKey<NavigatorState>();

bool oops = false;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'South African Ice Hockey Super League',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: myCustomTheme.light(),
      darkTheme: myCustomTheme.dark(),
      // ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // Try running your application with "flutter run". You'll see the
      //   // application has a blue toolbar. Then, without quitting the app, try
      //   // changing the primarySwatch below to Colors.green and then invoke
      //   // "hot reload" (press "r" in the console where you ran "flutter run",
      //   // or simply save your changes to "hot reload" in a Flutter IDE).
      //   // Notice that the counter didn't reset back to zero; the application
      //   // is not restarted.
      //   primarySwatch: Colors.blue,
      // ),
      home: anotherMistake(oops),
    );
  }
}

Widget anotherMistake(yesOrNo) {
  if (yesOrNo) {
    fixDB();
    return const Center(
      child: Text("Oops"),
    );
  } else {
    return MainPage();
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // @override
  // void initState() {
  //   super.initState();
  //   initialization();
  // }

  // void initialization() async {
  //   // This is where you can initialize the resources needed by your app while
  //   // the splash screen is displayed.  Remove the following example because
  //   // delaying the user experience is a bad design practice!
  //   // ignore_for_file: avoid_print
  //   print('ready in 3...');
  //   await Future.delayed(const Duration(seconds: 1));
  //   print('ready in 2...');
  //   await Future.delayed(const Duration(seconds: 1));
  //   print('ready in 1...');
  //   await Future.delayed(const Duration(seconds: 1));
  //   print('go!');
  //   FlutterNativeSplash.remove();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong!"),
            );
          }
          if (snapshot.hasData) {
            return const VerifyEmailPage();
          } else {
            return AuthPage();
          }
        }),
      ),
    );
  }
}

Future fixDB() async {
  var newHour = 5;
  var time = DateTime.parse("2022-09-11T18:30:00.000z");
  time = time.toLocal();
  time = new DateTime(time.year, time.month, time.day, newHour, time.minute,
      time.second, time.millisecond, time.microsecond);

  DateTime currentPhoneDate = DateTime.now(); //DateTime

  Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate); //To TimeStamp
  Timestamp game1 = Timestamp.fromDate(time); //To TimeStamp
  Timestamp game2 = Timestamp.fromDate(currentPhoneDate); //To TimeStamp
  Timestamp post1 = Timestamp.fromDate(currentPhoneDate); //To TimeStamp

  //DateTime myDateTime = myTimeStamp.toDate(); // TimeStamp to DateTime

  Map<String, dynamic> allData = {
    "games": [
      {
        "game_number": "2",
        "current_score_team_1": "0",
        "current_score_team_2": "0",
        "livestream_url": "https://youtube.com/neroland",
        "buy_ticket_url":
            "https://computicket-boxoffice.com/e/south-african-super-league-joYaka",
        "team_1_id": "1",
        "team_2_id": "2",
        "date_time": game1,
        "live_stats": [
          {
            "type": "goal",
            "team_id": "1",
            "time": myTimeStamp,
            "by_player_id": "1",
            "assisted_by": ["2", "3"],
          },
          {
            "type": "penalty",
            "team_id": "2",
            "time": myTimeStamp,
            "by_player_id": "1",
            "served_by_player_id": "2",
            "more_info": "roughing",
          },
        ]
      },
      {
        "game_number": "1",
        "current_score_team_1": "0",
        "current_score_team_2": "0",
        "livestream_url": "https://youtube.com/neroland",
        "buy_ticket_url":
            "https://computicket-boxoffice.com/e/south-african-super-league-ice-hockey-series-1-game-2-t0z7Ji",
        "team_1_id": "1",
        "team_2_id": "2",
        "date_time": game2,
        "live_stats": [
          {
            "type": "goal",
            "team_id": "1",
            "time": myTimeStamp,
            "by_player_id": "1",
            "assisted_by": ["2", "3"],
          },
          {
            "type": "penalty",
            "team_id": "2",
            "time": myTimeStamp,
            "by_player_id": "1",
            "served_by_player_id": "2",
            "more_info": "roughing",
          },
        ],
      }
    ],
    "news": [
      {
        "post_body":
            "The South African Super League is back and our Cape Town Kings has been announced and is in training for the upcoming competition against The Pretoria Capitals and The Gauteng WildCats. The first series kicks off on Sunday 11th September at 8:30pm, taking place at The Ice Station - GrandWest Casino. Tickets are available now via Computicket.",
        "post_id": "1",
        "post_title": "Cape Town Kings Ready To Battle",
        "post_image_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/posts_pictures%2FPoster.jpg?alt=media&token=a295da8f-8214-4204-948c-e54830095b99",
        "post_timestamp": myTimeStamp,
      },
      {
        "post_body":
            "This is the body of a second post, I was too lazy to write something proper.",
        "post_id": "1",
        "post_title": "Cape Town Kings Ready To Battle",
        "post_image_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/posts_pictures%2FPoster.jpg?alt=media&token=a295da8f-8214-4204-948c-e54830095b99",
        "post_timestamp": game1,
      },
    ],
    "teams": [
      {
        "team_name": "Cape Town Kings",
        "team_id": "1",
        "club_info": {
          "club_name": "WPIHA",
          "female_players": "0",
          "junior_players": "0",
          "male_players": "0",
          "number_of_players": "0",
          "senior_players": "0",
          "total_referees": "4",
          "club_fb_link": "https://www.facebook.com/wpicehockey",
          "club_ig_link": "https://www.instagram.com/wpicehockey.co.za/",
          "club_website_link": "https://www.wpicehockey.co.za/index.html",
        },
        "team_logo_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/team_images%2FKingsLogo.jpg?alt=media&token=ee82d9f1-e938-49f8-9559-c77e9dab6b45",
        "team_jersey_picture_url": "https://placeimg.com/1920/1080/any",
        "team_manager": "Tracy Cerff",
        "head_coach": "Gavin Smith",
        "assistant_coach": "Sharief Kamish"
      },
      {
        "team_name": "Pretoria Capitals",
        "team_id": "2",
        "club_info": {
          "club_name": "GIHA",
          "female_players": "0",
          "junior_players": "0",
          "male_players": "0",
          "number_of_players": "0",
          "senior_players": "0",
          "total_referees": "0",
          "club_fb_link": "https://www.facebook.com/GautengIceHockey/",
          "club_ig_link": "https://www.instagram.com/pretoriacapitals/",
          "club_website_link": "https://www.giha.co.za/Clubs-PretoriaCapitals",
        },
        "team_logo_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/team_images%2FPretoriaCapitalsLogo.png?alt=media&token=721a964c-51ae-478b-bd5e-ce840cff9251",
        "team_jersey_picture_url": "",
        "team_manager": "Unknown",
        "head_coach": "Unknown",
        "assistant_coach": "Unknown"
      },
      {
        "team_name": "Johannesburg Wildcats",
        "team_id": "3",
        "club_info": {
          "club_name": "GIHA",
          "female_players": "0",
          "junior_players": "0",
          "male_players": "0",
          "number_of_players": "0",
          "senior_players": "0",
          "total_referees": "0",
          "club_fb_link": "https://www.facebook.com/GautengIceHockey/",
          "club_ig_link": "https://www.instagram.com/sabresicehockey/",
          "club_website_link": "https://www.giha.co.za/Clubs-Sabres",
        },
        "team_logo_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/team_images%2FWildcatsLogo.jpg?alt=media&token=44160598-7b52-4b78-8e51-5155f522c4d3",
        "team_jersey_picture_url": "",
        "team_manager": "Unknown",
        "head_coach": "Unknown",
        "assistant_coach": "Unknown"
      },
    ],
    "players": [
      {
        "player_id": "0",
        "player_first_name": "Luke",
        "player_last_name": "Carelse",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "1",
        "player_first_name": "Ryan",
        "player_last_name": "Fourie",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "2",
        "player_first_name": "Marc",
        "player_last_name": "Giot",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "3",
        "player_first_name": "Daanyal",
        "player_last_name": "Kamish",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "4",
        "player_first_name": "Wesley",
        "player_last_name": "Krotz",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "5",
        "player_first_name": "Alex",
        "player_last_name": "Obery",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "6",
        "player_first_name": "Uthman",
        "player_last_name": "Samaai",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "7",
        "player_first_name": "Mich",
        "player_last_name": "van Doesburgh",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "8",
        "player_first_name": "Luke",
        "player_last_name": "Vivier",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Forward",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "9",
        "player_first_name": "Matthew",
        "player_last_name": "Cerff",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Defence",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "10",
        "player_first_name": "Deen",
        "player_last_name": "Magmoed",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Defence",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "11",
        "player_first_name": "Keenan",
        "player_last_name": "Marrow",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Defence",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "12",
        "player_first_name": "Bradley",
        "player_last_name": "Morris",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Defence",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "13",
        "player_first_name": "Ethon",
        "player_last_name": "Saaiman",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Defence",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "14",
        "player_first_name": "Adam",
        "player_last_name": "Vivier",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Defence",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
      {
        "player_id": "15",
        "player_first_name": "Matthew",
        "player_last_name": "Cleinwerck",
        "player_picture_url":
            "https://firebasestorage.googleapis.com/v0/b/wpiha-sasl-app.appspot.com/o/placeholder_profile_image.jpg?alt=media&token=8b855496-48a9-4cad-bcf4-d430a27859e4",
        "player_team_id": "1",
        "player_position": "Goalie",
        "player_gp": "0",
        "player_g": "0",
        "player_a": "0",
        "player_pts": "0",
        "player_jersey_number": "0",
      },
    ],
    "statistics": [
      {
        "player_id": "0",
        "game_played": "0",
        "assists": "0",
        "goals_scored": "0",
      }
    ],

    // "news": {},
    // "teams": {},
    // "players": {}
  };

  final db = FirebaseFirestore.instance;
  final docToFix = db.collection("seasons").doc("2022").set(allData);
}
