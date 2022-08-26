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
}

class Teams {
  String team_name, team_id, team_logo_url, team_jersey_picture_url;
  Map club_info;

  Teams(
      {required this.team_name,
      required this.team_id,
      required this.team_logo_url,
      required this.club_info,
      required this.team_jersey_picture_url});
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
