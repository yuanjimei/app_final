import 'dart:convert';

import 'package:http/http.dart' as http;


class Create_User{
  late String name;
  late String parsed;
  late String share_parsed;
  late String Proflie_picture;


  Create_User({required String name,required String parsed,required String share_parsed,required String Proflie_picture}){
    this.name=name;
    this.parsed=parsed;
    this.share_parsed=share_parsed;
    this.Proflie_picture=Proflie_picture;
  }
  Future<bool> is_Create() async{
  late  bool is_create;
  var url = Uri.parse('http://localhost:31091/file/createUser');
  var requestBody = json.encode({
    "name": name,
    "parsed": parsed,
    "share_parsed":share_parsed,
    "Proflie_picture": Proflie_picture
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
    print('User created successfully');
  } else {
    print('Failed to create user. Error: ${response.body}');
    is_create=false;
  }
  return is_create;

  }

  }
