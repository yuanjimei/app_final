import 'package:http/http.dart' as http;

import 'dart:convert';

class ObtainUserList{



  Future<List<Map<String, dynamic>>> getUserList() async {
    List<Map<String, dynamic>> file_list = [];
    final url = Uri.parse('http://127.0.0.1:31091/file/User/All/list');
    try {
      final response = await http.get(url);

      // 检查响应的状态码
      if (response.statusCode == 200) {
        // 响应成功，处理响应数据
        final responseBody = response.body;
        // 将JSON字符串解析为Dart对象
        List<dynamic> jsonList = jsonDecode(responseBody);
        // 将Dart对象转换为适当的类型并存储到_fileList中
        file_list = jsonList.map((item) {
          return {
            'name': item['name'] ?? '',
            'id': item['id'] ?? '',
            'Proflie_picture': item['Proflie_picture'] ?? '',
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
