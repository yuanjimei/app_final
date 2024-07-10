import 'package:flutter/material.dart';

import 'Create_User.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
 late  String profilePicture;
 String _username = '';
 String _password = '';
 String _share_password = '';
 void _login() async{
   bool loggedIn =await Create_User(name:_username,
     parsed: _password,
     share_parsed:_share_password,
       Proflie_picture:profilePicture).is_Create();
   if (!loggedIn) {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: Text('注册失败'),
           content: Text('请重新注册'),
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
     Navigator.pop(context, profilePicture);
   }
 }
  @override
  void initState() {
    super.initState();
    profilePicture = '1.jpg'; // 设置默认头像
  }

 void _showImagePickerDialog() {
   showDialog(
     context: context,
     builder: (BuildContext context) {
       return AlertDialog(
         title: Text('选择头像'),
         content: SingleChildScrollView(
           child: ListBody(
             children: <Widget>[
               ListTile(
                 leading: CircleAvatar(
                   radius: 25.0,
                   backgroundImage: AssetImage('assets/1.jpg'), // 假设1.png是头像1的图片
                 ),
                 title: Text('宵宫'),
                 onTap: () {
                   setState(() {
                     profilePicture = '1.jpg';
                   });
                   Navigator.of(context).pop();
                 },
               ),
               ListTile(
                 leading: CircleAvatar(
                   radius: 25.0,
                   backgroundImage: AssetImage('assets/2.jpg'), // 假设2.png是头像2的图片
                 ),
                 title: Text('头像2'),
                 onTap: () {
                   setState(() {
                     profilePicture = '2.jpg';
                   });
                   Navigator.of(context).pop();
                 },
               ),
               ListTile(
                 leading: CircleAvatar(
                   radius: 25.0,
                   backgroundImage: AssetImage('assets/3.jpg'), // 假设2.png是头像2的图片
                 ),
                 title: Text('头像3'),
                 onTap: () {
                   setState(() {
                     profilePicture = '3.jpg';
                   });
                   Navigator.of(context).pop();
                 },
               ),
               ListTile(
                 leading: CircleAvatar(
                   radius: 25.0,
                   backgroundImage: AssetImage('assets/4.png'), // 假设2.png是头像2的图片
                 ),
                 title: Text('头像4'),
                 onTap: () {
                   setState(() {
                     profilePicture = '4.png';
                   });
                   Navigator.of(context).pop();
                 },
               ),// 可以根据需要添加更多头像选项
             ],
           ),
         ),
       );
     },
   );
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: CircleAvatar(
                radius: 80.0,
                backgroundImage: AssetImage('assets/$profilePicture'),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
              decoration: InputDecoration(
                labelText: '用户名',
                hintText: '请输入用户名',
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
                labelText: '密码',
                hintText: '请输入密码',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true, // 隐藏输入的文本
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  _share_password = value;
                });
              },
              decoration: InputDecoration(
                labelText: '分享码',
                hintText: '请输入分享码',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: false,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}