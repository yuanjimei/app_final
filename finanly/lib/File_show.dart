import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:sliding_up_panel/sliding_up_panel.dart'; // Sliding up panel library

// Comment class definition
class Comment {
  final String username;
  final String content;
  final DateTime timestamp;
  final List<Comment> replies; // List of replies

  Comment({
    required this.username,
    required this.content,
    required this.timestamp,
    List<Comment>? replies,
  }) : replies = replies ?? [];

  // Method to add a reply to this comment
  void addReply(Comment reply) {
    replies.add(reply);
  }

  // Method to check if this comment has replies
  bool hasReplies() {
    return replies.isNotEmpty;
  }

  @override
  String toString() {
    return 'Comment(username: $username, content: $content, timestamp: $timestamp, replies: $replies)';
  }
}

// CommentItem widget
class CommentItem extends StatelessWidget {
  final Comment comment;
  final Function(Comment)? onReply; 

  CommentItem({
    required this.comment,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(comment.timestamp);

    // Calculate left padding based on the depth of the comment (number of replies)
    double leftPadding = comment.replies.isNotEmpty ? 16.0 : 0.0;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: 16.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero, 
            leading: CircleAvatar(
              child: Image.asset('assets/$HeadImage'),
            ),
            title: Text(comment.username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(comment.content),
                Text(formattedTime),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.reply),
              onPressed: () {
                if (onReply != null) {
                  onReply!(comment); 
                }
              },
            ),
          ),
          
          if (comment.hasReplies())
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comment.replies.length,
              itemBuilder: (context, index) {
                return CommentItem(
                  comment: comment.replies[index],
                  onReply: onReply,
                );
              },
            ),
        ],
      ),
    );
  }
}

// CommentSection widget
class CommentSection extends StatefulWidget {
  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<Comment> _comments = [];

  Comment? _selectedComment; // Track the comment being replied to

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Comment Section'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 2),

                height: 300,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    ImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(1),
                margin: EdgeInsets.fromLTRB(15, 2, 10, 10),
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(10.0),
                ),

                child: Text("safd",),
              ),
              // Assuming SlidingUpPanel is here, adjust its properties accordingly
              SlidingUpPanel(
                minHeight: 50.0,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                panel: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            Icon(
                            like ? Icons.favorite : Icons.favorite_border,
                            color:  like ? Colors.red : Colors.grey,
                          ),

                            Text(
                            '$likeAmount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          const  Icon(
                            Icons.chat,
                            color: Colors.cyanAccent,
                          ),
                          SizedBox(width: 10),
                          const  Text(
                            "10",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 32,
                              child: TextField(
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),  // 调整内边距
                                  labelText: _selectedComment != null ? 'Reply to ${_selectedComment!.username}' : 'Add a comment',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),  
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0), 
                                    borderSide: BorderSide(
                                      color: Colors.blue,  
                                      width: 2.0,  
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),  
                                    borderSide: BorderSide(
                                      color: Colors.grey,  
                                      width: 1.0, 
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) {
                                  _addComment();
                                },
                              ),
                            ),


                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: CommentItem(
                              comment: _comments[index],
                              onReply: (comment) {
                                setState(() {
                                  _selectedComment = comment;
                                  _textEditingController.text = '';
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                body: Container(
                  // Placeholder container, adjust as needed
                  child: Text('Body content'),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }

  void _addComment() {
    String commentContent = _textEditingController.text.trim();
    if (commentContent.isNotEmpty) {
      Comment newComment = Comment(
        username: name, 
        content: commentContent,
        timestamp: DateTime.now(),
      );

      
      if (_selectedComment == null) {
        setState(() {
          _comments.insert(0, newComment); 
          _textEditingController.clear();
        });
      } else {
        setState(() {
          _selectedComment!.addReply(newComment); 
          _textEditingController.clear();
          _selectedComment = null; 
        });
      }

      
    }
  }
}



late String ImageUrl;
late String name;
late String HeadImage;
 bool like=false;
 int likeAmount=0;
class FileShow extends StatelessWidget {

  FileShow({required this.imageUrl,required this.Name,required this.headimage,required this.like,required this.likeAmount}){
    ImageUrl=this.imageUrl;
    name=this.Name;
    HeadImage=this.headimage;
    like=this.like;
    likeAmount=this.likeAmount;
  }
    final String headimage;
    final String imageUrl;
    final String Name;
    late bool like;
    late int likeAmount;
  @override
  Widget build(BuildContext context) {
    return CommentSection();
  }
}