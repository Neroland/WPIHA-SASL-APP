import 'package:cloud_firestore/cloud_firestore.dart';

class Games {
  String current_score_team_1,
      current_score_team_2,
      game_number,
      livestream_url,
      team_1_id,
      team_2_id;
  Timestamp date_time;

  Games(
      {required this.current_score_team_1,
      required this.current_score_team_2,
      required this.date_time,
      required this.game_number,
      required this.livestream_url,
      required this.team_1_id,
      required this.team_2_id});

  factory Games.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Games(
        current_score_team_1: data?["current_score_team_1"],
        current_score_team_2: data?["current_score_team_2"],
        game_number: data?["game_number"],
        livestream_url: data?["livestream_url"],
        team_1_id: data?["team_1_id"],
        team_2_id: data?["team_2_id"],
        date_time: data?["date_time"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (current_score_team_1 != null)
        "current_score_team_1": current_score_team_1,
      if (current_score_team_2 != null)
        "current_score_team_2": current_score_team_2,
      if (game_number != null) "game_number": game_number,
      if (livestream_url != null) "livestream_url": livestream_url,
      if (date_time != null) "date_time": date_time,
      if (team_1_id != null) "team_1_id": team_1_id,
      if (team_2_id != null) "team_2_id": team_2_id,
    };
  }
}

class TeamStandings {
  String team_id;
  int team_pts;

  TeamStandings({required this.team_id, required this.team_pts});
}

class TeamStandingsCalculated {
  String team_id, team_name, team_logo_url;
  int team_pts, team_games, team_wins, team_losses, team_ties;

  TeamStandingsCalculated(
      {required this.team_id,
      required this.team_pts,
      required this.team_games,
      required this.team_logo_url,
      required this.team_losses,
      required this.team_name,
      required this.team_ties,
      required this.team_wins});
}

class Teams {
  String team_name,
      team_id,
      team_logo_url,
      team_jersey_picture_url,
      head_coach,
      assistant_coach,
      team_manager;
  Map club_info;

  Teams(
      {required this.team_name,
      required this.team_id,
      required this.team_logo_url,
      required this.club_info,
      required this.team_jersey_picture_url,
      required this.head_coach,
      required this.assistant_coach,
      required this.team_manager});

  factory Teams.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Teams(
        club_info: data?["club_info"],
        team_id: data?["team_id"],
        team_jersey_picture_url: data?["team_jersey_picture_url"],
        team_logo_url: data?["team_logo_url"],
        team_name: data?["team_name"],
        assistant_coach: data?["assistant_coach"],
        head_coach: data?["head_coach"],
        team_manager: data?["team_manage"]);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (club_info != null) "club_info": club_info,
      if (team_id != null) "team_id": team_id,
      if (team_jersey_picture_url != null)
        "team_jersey_picture_url": team_jersey_picture_url,
      if (team_logo_url != null) "team_logo_url": team_logo_url,
      if (team_name != null) "team_name": team_name,
    };
  }
}

class ClubInfo {
  String club_name,
      female_players,
      junior_players,
      male_players,
      number_of_players,
      senior_players,
      total_referees,
      club_fb_link,
      club_ig_link,
      club_website_link;

  ClubInfo({
    required this.club_name,
    required this.female_players,
    required this.junior_players,
    required this.male_players,
    required this.number_of_players,
    required this.senior_players,
    required this.total_referees,
    required this.club_fb_link,
    required this.club_ig_link,
    required this.club_website_link,
  });
}

class News {
  String post_body, post_id, post_image_url, post_title;
  Timestamp post_timestamp;

  News(
      {required this.post_body,
      required this.post_id,
      required this.post_image_url,
      required this.post_title,
      required this.post_timestamp});
}

class Players {
  String player_a,
      player_first_name,
      player_g,
      player_gp,
      player_id,
      player_last_name,
      player_picture_url,
      player_position,
      player_pts,
      player_team_id,
      player_jersey_number;

  Players(
      {required this.player_id,
      required this.player_first_name,
      required this.player_last_name,
      required this.player_picture_url,
      required this.player_team_id,
      required this.player_position,
      required this.player_gp,
      required this.player_g,
      required this.player_a,
      required this.player_pts,
      required this.player_jersey_number});
}

class Admins {
  String user_ids;
  Admins({required this.user_ids});
}
