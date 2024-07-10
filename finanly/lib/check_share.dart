import 'dart:convert';

import 'package:http/http.dart' as http;


class share_check{

  late String name;
  late String password;
  share_check({required String name,required String password}){

    this.name=name;
    this.password=password;
  }
  Future<bool> is_Share() async{
    late bool Is_long;
    var url = Uri.parse('http://localhost:31091/file/enterfile');
    var requestBody = json.encode({
      "name": name,
      "share_parsed": password
    });
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: requestBody,
    );
    if (response.statusCode == 200) {
      Is_long=json.decode(response.body);
      print('User created successfully');
    } else {
      print('Failed to create user. Error: ${response.body}');
      Is_long=false;
    }
    return Is_long;

  }
}