import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const OtherUserFileShow(name: 'ly'));
}

class OtherUserFileShow extends StatelessWidget {
  final String name;

  const OtherUserFileShow({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: other_Userfile(name: name),
        ),
      ),
    );
  }
}

class other_Userfile extends StatefulWidget {
  final String name;

  const other_Userfile({Key? key, required this.name}) : super(key: key);

  @override
  _other_UserfileState createState() => _other_UserfileState();
}
int index_list = 0;
class _other_UserfileState extends State<other_Userfile> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.reset();
    _controller.forward();
  }

  void _reverseAnimation() {
    _controller.reverse();
  }

  void Up_index() {
    if (index_list < locations.length) {
      setState(() {
        index_list++;
      });
    }
  }

  void down_index() {
    if (index_list > 0) {
      setState(() {
        index_list--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildsearch(context),
        _Get_list(context),
        _button(context),
      ],
    );
  }

  Widget _button(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: Up_index,
          child: Icon(Icons.update),
        ),
        ElevatedButton(
          onPressed: down_index,
          child: Icon(Icons.access_alarms),
        ),
      ],
    );
  }

  Widget _buildsearch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            Positioned(
              left: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Blizzard",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _Get_list(BuildContext context) {
    return Container(
      height: 240,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Flow(
            delegate: _FlowDelegate(animationValue: _controller.value),
            children: <Widget>[
              if (index_list - 1 >= 0&& index_list - 1 < locations.length)
                AnimatedPositioned(
                    child: LocationListItem(
                      imageUrl: locations[index_list - 1].imageUrl,
                      name: locations[index_list - 1].name,
                      country: locations[index_list - 1].place,
                    ),
                    duration: Duration(seconds: 2),
                ),


              LocationListItem(
                imageUrl: locations[index_list].imageUrl,
                name: locations[index_list].name,
                country: locations[index_list].place,
              ),

              if (index_list + 1 <locations.length)
                LocationListItem(
                  imageUrl: locations[index_list + 1].imageUrl,
                  name: locations[index_list + 1].name,
                  country: locations[index_list + 1].place,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FlowDelegate extends FlowDelegate {
  final double animationValue;

  _FlowDelegate({required this.animationValue}) : super(repaint: Listenable.merge([]));

  @override
  void paintChildren(FlowPaintingContext context) {
     if(index_list==0){
       context.paintChild(0, transform: Matrix4.translationValues(0, 20, 10));
     }
     else if(index_list==locations.length){
       context.paintChild(2, transform: Matrix4.rotationZ(0));
     }
     else{
       context.paintChild(0, transform: Matrix4.translationValues(-80.0, 20, 10)..scale(0.9 ));
       context.paintChild(2, transform: Matrix4.translationValues(80.0, 20, 10)..scale(0.9  ));
       context.paintChild(1, transform: Matrix4.rotationZ(0));
     }


  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return true;
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),

    );
  }


  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
      child:Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
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
        IconButton(
          onPressed: () {

              _isLiked = !_isLiked; // 切换按钮状态

          },
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : Colors.black, // 根据状态设置颜色
            size: 30, // 设置图标的大小
          ),
        ),
        ],
      ),

    );
  }
}

bool _isLiked=false;
class Location {
  const Location({
    required this.name,
    required this.place,
    required this.imageUrl,
  });

  final String name;
  final String place;
  final String imageUrl;
}

const urlPrefix =
    'https://docs.flutter.dev/cookbook/img-files/effects/parallax';
const locations = [
  Location(
    name: 'Mount Rushmore',
    place: 'U.S.A',
    imageUrl: '$urlPrefix/01-mount-rushmore.jpg',
  ),
  Location(
    name: 'Gardens By The Bay',
    place: 'Singapore',
    imageUrl: '$urlPrefix/02-singapore.jpg',
  ),
  Location(
    name: 'Machu Picchu',
    place: 'Peru',
    imageUrl: '$urlPrefix/03-machu-picchu.jpg',
  ),
  Location(
    name: 'Vitznau',
    place: 'Switzerland',
    imageUrl: '$urlPrefix/04-vitznau.jpg',
  ),
  Location(
    name: 'Bali',
    place: 'Indonesia',
    imageUrl: '$urlPrefix/05-bali.jpg',
  ),
  Location(
    name: 'Mexico City',
    place: 'Mexico',
    imageUrl: '$urlPrefix/06-mexico-city.jpg',
  ),
  Location(
    name: 'Cairo',
    place: 'Egypt',
    imageUrl: '$urlPrefix/07-cairo.jpg',
  ),
];
