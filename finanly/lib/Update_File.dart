import 'dart:convert';

import 'package:http/http.dart';

class UpdateFile{


    _uploadFile(String filePath,String user,String description,String title,String lab) async{
    String url = "http://localhost:31091/file/upload";
    print("YM------->上传的路径:$url");
    var uri = Uri.parse(url);
    var request = new MultipartRequest("POST",uri);

    var multipartFile = await MultipartFile.fromPath("headpic",filePath);
    request.fields['user']=user;
    request.fields['description']=description;
    request.fields['title']=lab;
    request.fields['lab']=title;

    request.files.add(multipartFile);

    StreamedResponse response = await request.send();


    response.stream.transform(utf8.decoder).listen((value){
       print("上传文件的结果:$value");
     });



  }

}

