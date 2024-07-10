


import 'package:finanly/user_interface.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'File_show.dart';
import 'MainHomePage.dart';
import 'check_share.dart';
import 'obtainUserList.dart';
import 'other_user_file_show.dart';

void main()=>runApp(sbsun());

class sbsun extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(  // 使用MaterialApp作为根组件
      title: '关注列表',
      home: Scaffold(

        body: Center(
          child: CustomScrollView(


            slivers: <Widget>[
              SliverAppBar(
                backgroundColor: Colors.cyanAccent,
                title: Text('关注列表'),
              ),
              UserList(),
            ],
          ),
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // 直接返回 UserCard，不再嵌套 Scaffold
    return UserCard();
  }

}
class UserCard extends StatefulWidget{

  _UserCardState createState() =>_UserCardState();
}

class _UserCardState extends State<UserCard>{


  List<Map<String,dynamic>> _fileList = [];

  @override
  void initState() {
    super.initState();
    _fetchFileList();

  }
  Future<void> _fetchFileList() async {
    _fileList = await ObtainUserList().getUserList();
    print(_fileList.length);
    // Once file list is fetched, you can setState if necessary
    setState(() {
      // Update your UI if needed
    });
  }




  Widget _buildCard(Map<String,dynamic> fileInfo) {

    // 根据文件信息构建卡片
    String Name = fileInfo['name'] ?? '';
    String id = fileInfo['id'] ?? '';
    String Proflie_picture = fileInfo['Proflie_picture']?? ''  ;
    if(Proflie_picture==''){
      Proflie_picture="1.jpg";

    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
              Container(
               width: 65,
               height: 65,

               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(10),

               ),
                child:ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child:
                  Image.asset(
                      'assets/$Proflie_picture',
                      fit: BoxFit.cover,
                  ),
                )

             ),
          const  SizedBox(width: 20),
            Text(Name,style:
            TextStyle(
              fontSize: 24, // 调整文字大小
              color: Colors.blue, // 设置文字颜色
              shadows: [
                Shadow(
                  blurRadius: 2, // 阴影模糊半径
                  color: Colors.white, // 阴影颜色
                  offset: Offset(1, 1), // 阴影偏移量
                ),
              ],
            ),
            ),
            Spacer(),
            IconButton(
                onPressed: ()=>
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>UserInterface(UserName: Name))),
                icon:Icon(
                  Icons.visibility_sharp, // 指定要显示的图标，这里以星星图标为例
                  size: 24, // 设置图标的大小，单位为逻辑像素
                  color: Colors.black, // 设置图标的颜色
                ),

            )


          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context){

    return SliverList(

      delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index){
            var _file=_fileList[index];
           return _buildCard(_file);
          },
          childCount: _fileList.length,
      ),

    );
  }

}