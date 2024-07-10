
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'Database_help.dart';
import 'File_show.dart';
import 'add_User_like.dart';
import 'get_file_list.dart';
import 'get_like_Amount.dart';

const Color darkBlue = Colors.white;

void main()=>runApp(MainHomePage(name: "Alice"));
late String selectedCategory;
late String Username;
late DatabaseHelper dbHelper;

class MainHomePage extends StatefulWidget {

  final String name;
  MainHomePage({Key? key,required String this.name}){
    Username=this.name;
  }


  @override
  _MainHomePage createState()=> _MainHomePage(name: name);
}
class _MainHomePage extends State<MainHomePage> with SingleTickerProviderStateMixin{

   _MainHomePage({required String this.name});
   final String name;

   int content=1;//计数
   late TabController _tabController;
   final List<String> categories = ['推荐', '风景', '科技'];
   @override
   void initState() {
     super.initState();
     _tabController = TabController(length: categories.length, vsync: this);
     _tabController.addListener(() {
       if (_tabController.indexIsChanging) {
         setState(() {
           selectedCategory = categories[_tabController.index]; // 更新选中的类别
         });
       }
     });
     selectedCategory = categories[0]; // 默认选中第一个类别
   }

   @override
   void dispose() {
     _tabController.dispose();
     super.dispose();
   }

   void _handleTabSelection() {
     setState(() {
       // Here you can update any state related to the current tab selection
     });
   }

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home:  Scaffold(

        body: Center(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.lightBlueAccent,
                pinned:true,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background:DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: <Color>[
                          Colors.lightBlueAccent!,
                          Colors.transparent,
                        ],
                      )
                    ),
                    child: Image.asset('assets/background.jpeg',
                      fit:BoxFit.cover,
                    ),
                  )


                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: categories.map((String category) {
                    return Tab(
                      text: category,
                    );
                  }).toList(),
                  onTap: (index) {
                    setState(() {
                      selectedCategory = categories[index];
                      print("12314"+selectedCategory);// 当标签被点击时更新选中的类别
                    });
                  },
                ),

              ),
              ExampleParallax(name: selectedCategory,shu: content),
          ],
          ),
        ),
      ),
    );
  }
}

class ExampleParallax extends StatefulWidget {
  final String name;
  late int shu;
  ExampleParallax({Key? key, required this.name,required this.shu}) : super(key: key);

  @override
  _ExampleParallaxState createState() => _ExampleParallaxState(name: name);
}

class _ExampleParallaxState extends State<ExampleParallax> {
  late String profilePicture;
  late int userId;

   final String name;
  _ExampleParallaxState({required this.name}){
    _printName();
  }
   void _printName() {
     print("-------------------------------------"+Username);
   }

  Future<bool> Addlike(String ImageUrl ) async{
  return  await dbHelper.insertData(userId, 'ImageUrl', '');
  }
  Future<bool> Addfavorite(String ImageUrl ) async{
     return  await dbHelper.insertData(userId, '', 'ImageUrl');
  }
  Future<String> _updateProfilePicture(String username) async{
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
    return userData["Proflie_picture"] ?? "1.jpg";
  }
  List<Location> locations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();

  }
   @override
   void didUpdateWidget(covariant ExampleParallax oldWidget) {
     if (widget.name != oldWidget.name) {
       setState(() {
         _fetchLocations();
       });

     }
     super.didUpdateWidget(oldWidget);
   }

  Future<void> _fetchLocations() async {
    await _fetchFileList(selectedCategory); // Assuming 'LY' is a username or identifier

    List<Location> updatedLocations = [];

    for (var filelist in _fileList) {
      var id = filelist['id'] ?? '';
      String headImageUrl = await _updateProfilePicture(filelist['userID']); // Wait for the future to resolve
      print(headImageUrl);
      bool xx=await AddUserLike(userId: Username,userlikeid:id ).check_like();
      int rr=await UserLikeAmount(userlikeid:id).getlikeamount();
      bool ff=await AddUserLike(userId: Username,userlikeid:id ).check_favoriter();
      int fc=await UserLikeAmount(userlikeid:id).getfavoriteramount();
      updatedLocations.add(Location(
        name: filelist['fileName'] ?? '',
        place: 'come from '+filelist['userID'] ?? '',
        imageUrl: '$urlPrefix/$id',
        UserId: filelist['userID'] ?? '66',
        headImage: headImageUrl,
        like: xx,
        likeamount: rr,
        id: id,
        favoriter: ff,
        favoriteramount: fc,
        ddescription: filelist['description']
      ));
    }

    setState(() {
      locations = updatedLocations;

    });
  }


  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var location = locations[index];

          return Card(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                LocationListItem(
                  imageUrl: location.imageUrl,
                  name: location.name,
                  country: location.place,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    location.ddescription,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),

                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(

                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 45,
                                          height: 45,
                                          // Placeholder or background image
                                          decoration: BoxDecoration(
                                            //color: Colors.grey, // Placeholder color
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: AssetImage('assets/${location.headImage}'),
                                        ),
                                        Positioned(
                                          bottom: -13,
                                          left: -5,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              print("IconButton pressed");
                                            },
                                            icon: Icon(
                                              Username!=location.UserId? Icons.add:null,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 1),
                                    Text(
                                      location.UserId,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () async{
                            print("dfsdf"+location.imageUrl);
                            bool is_like;
                            is_like= await AddUserLike(
                              userId:Username,
                              userlikeid: location.id).addlike();
                             int likeAmount=await UserLikeAmount(userlikeid: location.id).getlikeamount();
                            setState(() {
                              location.likeamount=likeAmount;
                              location.like=is_like;
                            });
                            },//添加喜欢
                              icon: Icon(
                                  location.like ? Icons.favorite : Icons.favorite_border,
                                  color:   location.like ? Colors.red : Colors.grey,
                                   size: 16,
                              )
                      ),

                     Text(
                        "${location.likeamount}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () async{
                            print("dfsdf"+location.imageUrl);
                            bool is_like;
                            is_like= await AddUserLike(
                                userId:Username,
                                userlikeid: location.id).addfavoriter();
                            int likeAmount=await UserLikeAmount(userlikeid: location.id).getfavoriteramount();
                            setState(() {
                              location.favoriteramount=likeAmount;
                              location.favoriter=is_like;

                            });
                          },//添加喜欢
                          icon: Icon(
                            location.favoriter ? Icons.star: Icons.star_border,
                            color:   location.favoriter ? Colors.yellow : Colors.grey,
                            size: 16,
                          )
                      ),
                      SizedBox(width: 2),
                      Text(
                        "${location.favoriteramount}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat,
                              color: Colors.cyanAccent,
                              size: 16,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "100",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],

                        ),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context) =>FileShow(imageUrl: location.imageUrl,Name: location.UserId,headimage:location.headImage ,like: location.like,likeAmount: location.likeamount,)));
                          },

                          icon: Icon(
                          Icons.open_with,
                            size: 16,

                      ),
                )
                    ],

                  ),
                ),
              ],
            ),
          );
        },
        childCount: locations.length,
      ),

    );

  }
}


class LocationListItem extends StatelessWidget {
  LocationListItem({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.country,
  }) : super(key: key);

  final String imageUrl;
  final String name;
  final String country;
  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AspectRatio(
        aspectRatio: 9/4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildParallaxBackground(context),
              _buildGradient(),
              _buildTitleAndSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Flow(
      delegate: ParallaxFlowDelegate(
        scrollable: Scrollable.of(context)!,
        listItemContext: context,
        backgroundImageKey: _backgroundImageKey,
      ),
      children: [
        Image.network(
          imageUrl,
          key: _backgroundImageKey,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.6, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            country,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
    (listItemOffset.dy / viewportDimension).clamp(0.0, 0.8);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
    verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform:
      Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class Parallax extends SingleChildRenderObjectWidget {
  const Parallax({
    super.key,
    required Widget background,
  }) : super(child: background);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParallax(scrollable: Scrollable.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderParallax renderObject) {
    renderObject.scrollable = Scrollable.of(context);
  }
}

class ParallaxParentData extends ContainerBoxParentData<RenderBox> {}

class RenderParallax extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>, RenderProxyBoxMixin {
  RenderParallax({
    required ScrollableState scrollable,
  }) : _scrollable = scrollable;

  ScrollableState _scrollable;

  ScrollableState get scrollable => _scrollable;

  set scrollable(ScrollableState value) {
    if (value != _scrollable) {
      if (attached) {
        _scrollable.position.removeListener(markNeedsLayout);
      }
      _scrollable = value;
      if (attached) {
        _scrollable.position.addListener(markNeedsLayout);
      }
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParallaxParentData) {
      child.parentData = ParallaxParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    // Force the background to take up all available width
    // and then scale its height based on the image's aspect ratio.
    final background = child!;
    final backgroundImageConstraints =
    BoxConstraints.tightFor(width: size.width);
    background.layout(backgroundImageConstraints, parentUsesSize: true);

    // Set the background's local offset, which is zero.
    (background.parentData as ParallaxParentData).offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Get the size of the scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;

    // Calculate the global position of this list item.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final backgroundOffset =
    localToGlobal(size.centerLeft(Offset.zero), ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final scrollFraction =
    (backgroundOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final background = child!;
    final backgroundSize = background.size;
    final listItemSize = size;
    final childRect =
    verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
        background,
        (background.parentData as ParallaxParentData).offset +
            offset +
            Offset(0.0, childRect.top));
  }
}

class Location {
   Location({
    required this.name,
    required this.place,
    required this.imageUrl,
    required this.UserId,
    required this.headImage,
    required this.like,
    required this.likeamount,
     required this.id,
   required this.favoriter,
   required this.favoriteramount,
     required this.ddescription,

  });
  final String UserId;
  final String name;
  final String place;
  final String imageUrl;
  final String headImage;
  late bool like;
  late int likeamount;
  final String id;
   late bool favoriter;
   late int favoriteramount;
   late String ddescription;

}

List<Map<String, dynamic>> _fileList = [];
Future<void> _fetchFileList(String name) async {

    _fileList = await GetFileList(User_name: name).getFileList();


  // Once file list is fetched, you can setState if necessary
}

const urlPrefix = 'http://localhost:31091/file/download';
