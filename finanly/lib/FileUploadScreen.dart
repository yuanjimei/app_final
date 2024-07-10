import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  final String name;
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
  ImageUploadScreen({required this.name});
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  List<String> addLab = [];

  late String title_file;
  late String description;
  late String lab_file;
  Uint8List? _imageBytes;
  List<String> setlab = ['风景', '科技', '游戏动漫'];
  bool isSb = false;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void selectLab(int index) {
    setState(() {
      lab_file = setlab[index];
      addLab.add(setlab[index]);
    });
  }

  Future<void> _uploadFile() async {
    if (_imageBytes == null) {
      // Handle case where no image is selected
      return;
    }

    String url = "http://localhost:31091/file/upload"; // Replace with your server URL
    var uri = Uri.parse(url);
    var request = http.MultipartRequest("POST", uri);

    // Create multipart file from memory
    var multipartFile = http.MultipartFile.fromBytes(
      'file',
      _imageBytes!,
      filename: 'uploaded_image.jpg',
    );

    request.fields['user'] = widget.name; // Replace with actual user data
    request.fields['description'] = description; // Replace with actual description data
    request.fields['title'] = lab_file; // Fix: Use title_file instead of lab_file
    request.fields['lab'] = title_file; // Fix: Use lab_file instead of title_file

    request.files.add(multipartFile);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Successful upload
        response.stream.transform(utf8.decoder).listen((value) {
          print("上传文件的结果: $value");
          // Handle response from server
        });
      } else {
        // Handle error
        print("上传文件失败，状态码: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network or other errors
      print("上传文件出错: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imageBytes == null
                      ? GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          size: 48,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                      : Image.memory(
                    _imageBytes!,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        title_file = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '填写标题会有更多赞哦~',
                      labelText: '标题',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: '添加正文...',
                      labelText: '正文',
                    ),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var sg in addLab)
                        Chip(
                          label: Text(sg),
                          onDeleted: () {
                            setState(() {
                              addLab.remove(sg);
                            });
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 5,
                          top: 5,
                          child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            transform: isSb
                                ? Matrix4.translationValues(120, 0, 0)
                                : Matrix4.identity(),
                            child: ElevatedButton(
                              onPressed: () => selectLab(0),
                              child: Text('风景'),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 5,
                          top: 5,
                          child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            transform: isSb
                                ? Matrix4.translationValues(200, 0, 0)
                                : Matrix4.identity(),
                            child: ElevatedButton(
                              onPressed: () => selectLab(1),
                              child: Text('科技'),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 5,
                          top: 5,
                          child: Container(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isSb = !isSb;
                                });
                              },
                              child: Text('添加标签'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Positioned the Publish button here
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _uploadFile,
                child: Text('发布'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


