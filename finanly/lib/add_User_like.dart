import 'dart:convert';

import 'package:http/http.dart' as http;

class AddUserLike{
  final String userId;
  final String userlikeid;

  AddUserLike({required this.userId,required this.userlikeid});

  Future<bool> addlike() async{
    late  bool is_create;
    var url = Uri.parse('http://localhost:31091/file/add/User_like');
    var requestBody = json.encode({
      "userid": userId,
      "User_like_id": userlikeid,
    });
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: requestBody,
    );
    if (response.statusCode == 200) {
      is_create=json.decode(response.body);
      print('点赞成功');
    } else {
      print('点赞失败. Error: ${response.body}');
      is_create=false;
    }
    return is_create;

  }

   Future<bool> check_like() async{
    String URL='http://localhost:31091/file/check?userid=$userId&likeId=$userlikeid';
    var url = Uri.parse(URL);
    var response = await http.get(
      url,
    );
    if (response.statusCode == 200) {
     return  json.decode(response.body);

    } else {
      print('点赞失败. Error: ${response.body}');
      return false;
    }
   }
  Future<bool> addfavoriter() async{
    late  bool is_create;
    var url = Uri.parse('http://localhost:31091/file/add/User_favorite');
    var requestBody = json.encode({
      "userid": userId,
      "user_favoriter_id":  userlikeid,
    });
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: requestBody,
    );
    if (response.statusCode == 200) {
      is_create=json.decode(response.body);
      print('收藏成功');
    } else {
      print('收藏失败. Error: ${response.body}');
      is_create=false;
    }
    return is_create;

  }

  Future<bool> check_favoriter() async{
    String URL='http://localhost:31091/file/favoriter/check?userid=$userId&likeId=$userlikeid';
    var url = Uri.parse(URL);
    var response = await http.get(
      url,
    );
    if (response.statusCode == 200) {
      return  json.decode(response.body);

    } else {
      print('点赞失败. Error: ${response.body}');
      return false;
    }
  }
}