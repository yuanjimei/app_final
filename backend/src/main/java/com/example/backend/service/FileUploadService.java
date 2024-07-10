package com.example.backend.service;

import com.example.backend.model.MongoFile;
import com.example.backend.model.User;
import com.example.backend.vo.FileExportVo;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.util.Map;


public interface FileUploadService {


    FileExportVo uploadFile(MultipartFile file, String userID,String description,String title,String lab) throws Exception;


    List<FileExportVo> uploadFiles(List<MultipartFile> files,String userID,String description,String title,String lab);


    FileExportVo downloadFile(String fileId);

    boolean createUser(String name,String parsed,String share_parsed,String Proflie_picture);

    boolean logon_User(String name,String parsed);

    boolean inspect_User(String name,String share_parsed);

    void removeFile(String fileId);
    //获得用户名下的文件
    List<Map<String, String>> getFilesByUserId(String userID);
    List<Map<String, String>> FilesByUserId(String userID);
    List<String>  SearchUser(String name);

    //获得用户信息
    Map<String, String> get_User_imforaction(String name);
    //获得用户列表
    List<Map<String,String>> get_AllUser_list();

    void remove_user(String User_name);

    //添加喜欢作品
    boolean add_user_like(String userid,String User_like_id);

    //收藏作品
    boolean add_user_favourite(String userid,String User_favourite_id);
     //获取点赞数
    int getuser_like(String User_like_id);
    //判断是否点赞过
    boolean chacke_user_like(String userid,String User_like_id);
    //获取收藏数
    int getuser_favourite(String User_favourite_id);
    //判断是否收藏过
    boolean chacke_user_favourite(String userid,String User_favourite_id);
    //获得某个人的所有点赞的作品
    List<Map<String,String>> get_like_list(String userid);
    List<Map<String,String>> get_favourite_list(String userid);
    //随机获得图片
    List<Map<String, String>> getFiles1();
}
