import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'get_file_list.dart';

const urlPrefix = 'http://localhost:31091/file/download';

void main() => runApp(UserInterface(UserName: 'Alice'));

class UserInterface extends StatefulWidget {
  final String UserName;

  UserInterface({required this.UserName});

  @override
  _UserInterfaceState createState() => _UserInterfaceState();
}

class _UserInterfaceState extends State<UserInterface>
    with SingleTickerProviderStateMixin {
  late String Id;
  late String name;
  late String profilePicture;
  late TabController _tabController;
  final List<String> categories = ['作品', '喜欢', '收藏'];
  String selectedCategory = '作品';

  @override
  void initState() {
    super.initState();
    _fetchUserData(widget.UserName);

    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedCategory = categories[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData(String username) async {
    try {
      String url = 'http://localhost:31091/file/user/name/' + username;
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData =
        jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          Id = userData['id'];
          name = userData['name'];
          profilePicture = userData['Proflie_picture']??"1.jpg"; // Corrected typo here
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.blue,
              pinned: true,
              floating: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 0),
                            padding: EdgeInsets.all(10),
                            height: 80,
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: Image.asset(
                                'assets/$profilePicture',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name ?? '',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "账户ID: $Id",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    "哈哈",
                                      style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => print("SB"),
                                    child: Text("编辑格言"),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: categories.map((category) {
                  return Tab(
                    text: category,
                  );
                }).toList(),
              ),
            ),
            UserLayout(UserName: widget.UserName, category: selectedCategory),
          ],
        ),
      ),
    );
  }
}

class UserLayout extends StatefulWidget {
  final String UserName;
  final String category;

  UserLayout({required this.UserName, required this.category});

  @override
  _UserLayoutState createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  List<Map<String, dynamic>> _fileList = [];

  @override
  void initState() {
    super.initState();
    _fetchFileList(widget.UserName);
  }

  @override
  void didUpdateWidget(covariant UserLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _fetchFileList(widget.UserName);
    }
  }

  Future<void> _fetchFileList(String name) async {
    List<Map<String, dynamic>> fileList = [];
    print(name);
    if (widget.category == '作品') {
      fileList = await GetFileList(User_name: name).getFileList3();
    }
    else if(widget.category == '喜欢'){
      fileList=await GetFileList(User_name: name).getFileList1();

    }
    else if(widget.category == '收藏'){
      fileList=await GetFileList(User_name: name).getFileList2();
    }
    setState(() {
      _fileList = fileList;
    });
  }

  Widget _buildCard(int index) {
    if (_fileList == null || _fileList.isEmpty) {
      return Center(child: Text('No files found'));
    }

    final String id = _fileList[index]['id'];

    return Card(
      child: Container(
        height: 180,
        width: 50,
        child: Image.network(
          '$urlPrefix/$id',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return _buildCard(index);
        },
        childCount: _fileList.length,
      ),
    );
  }
}
