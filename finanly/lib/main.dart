import 'dart:convert';

import 'package:finanly/RegistrationScreen.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'LoggedInPage.dart';
import 'long_check.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage>
with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  String _username = '';
  String _password = '';
  String profilePicture='1.jpg';
  @override
  void initState() {

    super.initState();
    _animationController=AnimationController(
      duration: Duration(seconds: 5),
        vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  void _updateProfilePicture(String username) async{
        late  Map<String, dynamic> userData;
        String url = 'http://localhost:31091/file/user/name/'+username;
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          // 解析JSON响应
          userData = jsonDecode(response.body);

        } else {

          throw Exception('Failed to load user data');
        }
        try {
          Map<String, dynamic> userData1 = userData;
          print('User Data:');
          print(userData1); // 打印解析后的用户数据
        } catch (e) {
          print('Error fetching user data: $e');
        }
        setState((){
            profilePicture = userData["Proflie_picture"];
        });
  }

  void _login() async{
    bool loggedIn =await long_check(name:_username,password: _password).is_longe();
    if (!loggedIn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('登录失败'),
            content: Text('请检查用户名和密码'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('确定'),
              ),
            ],
          );
        },
      );
    }
    else{
      // 登录成功，导航到 LoggedInPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoggedInPage(name1: _username)),
      );
    }
  }
  //获得头像数据
 String get_profilePicture(String profilePicture){
    return profilePicture;
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Center(
        child: Container(

         decoration: BoxDecoration(
           image: DecorationImage(
             image: AssetImage('assets/background.jpeg'),
             fit: BoxFit.cover,
           ),
         ),

          child:
          Container(

            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/$profilePicture'), // 圆形图像框
                  ),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _username = value;
                        _updateProfilePicture(value);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '用户名',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '密码',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('登录'),
                      ),
                      // 在前一个界面中
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );

                          if (result != null) {
                            profilePicture=get_profilePicture(result);
                            print('Received data from RegisterScreen: $result');
                          }
                        },
                        child: Text('注册'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
