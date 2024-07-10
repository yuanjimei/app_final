import 'dart:convert';

import 'package:http/http.dart' as http;


class long_check{

  late String name;
  late String password;
  long_check({required String name,required String password}){

    this.name=name;
    this.password=password;
  }
  Future<bool> is_longe() async{
    late bool Is_long;
    var url = Uri.parse('http://localhost:31091/file/login');
    var requestBody = json.encode({
      "name": name,
      "parsed": password
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