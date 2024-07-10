import 'package:http/http.dart' as http;

import 'dart:convert';

class GetFileList{
  late String User_name;

  GetFileList({required String User_name}){

    this.User_name=User_name;
  }

  Future<List<Map<String, dynamic>>> getFileList() async {
    List<Map<String, dynamic>> fileList = [];
    late String url;

    if (User_name == "推荐") {
      url = 'http://localhost:31091/file/files/23';
    } else {
      url = 'http://localhost:31091/file/user/files/$User_name';
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Accept-Charset': 'utf-8',
      });

      if (response.statusCode == 200) {
        final responseBody = response.body;
        List<dynamic> jsonList = jsonDecode(responseBody);

        fileList = jsonList.map((item) {
          String description = item['description']?.toString() ?? '';
          // Remove invalid characters
          description = description.replaceAll('\uFFFD', '');

          return {
            'fileName': item['title'] ?? '',
            'id': item['id'] ?? '',
            'fileType': item['contentType'] ?? '',
            'userID': item['userID'] ?? '',
            'lab': item['lab'] ?? '',
            'description': description,
          };
        }).toList();
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Caught exception: $e');
    }

    return fileList;
  }

  Future<List<Map<String, dynamic>>> getFileList1() async {
    List<Map<String, dynamic>> file_list = [];
    final url = Uri.parse('http://localhost:31091/file/like-list/$User_name');
    try {
      final response = await http.get(url, headers: {
        'Accept-Charset': 'utf-8'
      });

      // 检查响应的状态码
      if (response.statusCode == 200) {
        // 响应成功，处理响应数据
        final responseBody = response.body;
        // 将JSON字符串解析为Dart对象
        List<dynamic> jsonList = jsonDecode(responseBody);
        // 将Dart对象转换为适当的类型并存储到_fileList中
        file_list = jsonList.map((item) {
          return {
            'id':item['User_like_id'] ?? '',
          };
        }).toList();

      } else {
        // 处理错误
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception catch (e) {
      // 处理异常
      print('Caught exception: $e');
    }
    return file_list;
  }
  Future<List<Map<String, dynamic>>> getFileList2() async {
    List<Map<String, dynamic>> file_list = [];
    final url = Uri.parse('http://localhost:31091/file/like-favourite/$User_name');
    try {
      final response = await http.get(url, headers: {
        'Accept-Charset': 'utf-8'
      });

      // 检查响应的状态码
      if (response.statusCode == 200) {
        // 响应成功，处理响应数据
        final responseBody = response.body;
        // 将JSON字符串解析为Dart对象
        List<dynamic> jsonList = jsonDecode(responseBody);
        // 将Dart对象转换为适当的类型并存储到_fileList中
        file_list = jsonList.map((item) {
          return {
            'id':item['user_favoriter_id'] ?? '',
          };
        }).toList();

      } else {
        // 处理错误
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception catch (e) {
      // 处理异常
      print('Caught exception: $e');
    }
    return file_list;
  }
  Future<List<Map<String, dynamic>>> getFileList3() async {
    List<Map<String, dynamic>> file_list = [];
    final url = Uri.parse('http://localhost:31091/file/user/id/$User_name');
    try {
      final response = await http.get(url, headers: {
        'Accept-Charset': 'utf-8'
      });

      // 检查响应的状态码
      if (response.statusCode == 200) {
        // 响应成功，处理响应数据
        final responseBody = response.body;
        // 将JSON字符串解析为Dart对象
        List<dynamic> jsonList = jsonDecode(responseBody);
        file_list = jsonList.map((item) {
          String description = item['description']?.toString() ?? ''; // 确保字段存在并转换为字符串
          return {
            'fileName': item['title'] ?? '',
            'id': item['id'] ?? '',
            'fileType': item['contentType'] ?? '',
            'userID': item['userID'] ?? '',
            'lab': item['lab'] ?? '',
            'description': description.replaceAll('\uFFFD', ''), // 移除乱码字符
          };
        }).toList();


      } else {
        // 处理错误
        print('Request failed with status: ${response.statusCode}.');
      }
    } on Exception catch (e) {
      // 处理异常
      print('Caught exception: $e');
    }
    return file_list;
  }

}
