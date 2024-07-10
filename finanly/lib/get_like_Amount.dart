import 'dart:convert';

import 'package:http/http.dart' as http;

class UserLikeAmount{

  final String userlikeid;

  UserLikeAmount({required this.userlikeid});

  Future<int> getlikeamount() async{
    late  int is_create;
    var url = Uri.parse('http://localhost:31091/file/user-like/$userlikeid');

    var response = await http.get(
      url,
    );
    if (response.statusCode == 200) {
      is_create=json.decode(response.body);

    } else {
      print('获取点赞数失败. Error: ${response.body}');
      is_create=0;
    }
    return is_create;

  }
  Future<int> getfavoriteramount() async{
    late  int is_create;
    var url = Uri.parse('http://localhost:31091/file/user-favoriter/$userlikeid');

    var response = await http.get(
      url,
    );
    if (response.statusCode == 200) {
      is_create=json.decode(response.body);

    } else {
      print('获取点赞数失败. Error: ${response.body}');
      is_create=0;
    }
    return is_create;

  }

}