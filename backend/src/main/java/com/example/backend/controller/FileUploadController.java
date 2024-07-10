package com.example.backend.controller;
import com.example.backend.model.*;
import com.example.backend.service.FileUploadService;
import com.example.backend.vo.FileExportVo;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import javax.annotation.Resource;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * @Description 文件上传接口
 * @author coisini
 * @date Apr 17, 2022
 * @version 1.0
 */
@Slf4j
@RestController
@RequestMapping("/file")
public class FileUploadController {

    /**
     * 文件上传实现类
     */
    @Autowired
    @Qualifier("fileMongoServiceImpl")
    private FileUploadService fileUploadService;

    /**
     * 文件上传
     * @param file
     * @return
     */
    @PostMapping("/upload")
    public ResponseEntity<?> uploadFile(@RequestParam("file") MultipartFile file,
                                        @RequestParam("user") String userID,
                                        @RequestParam("description") String description,
                                        @RequestParam("title") String title,
                                        @RequestParam("lab") String lab
    )
    {
        try {
            FileExportVo uploadedFile = fileUploadService.uploadFile(file, userID,description,title,lab);

            // 构建响应数据，包括成功标志、消息、上传的文件数据以及用户 ID
            Map<String, Object> responseData = Map.of(
                    "success", true,
                    "message", "上传成功",
                    "data", uploadedFile

            );

            // 返回响应
            return ResponseEntity.ok().body(responseData);
        } catch (Exception e) {
            log.error("文件上传失败：", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("success", false,
                    "message", "文件上传失败：" + e.getMessage()));
        }
    }
    /**
     * 创建用户
     */

    @PostMapping("/createUser")
    public ResponseEntity<Boolean> createUser(@RequestBody User request) {
        boolean is_repeat= fileUploadService.createUser(request.getName(),
                request.getParsed(),
                request.getShare_Parsed(),
                request.getProflie_picture());
        if(is_repeat)
           return ResponseEntity.ok(is_repeat);
        else
            return ResponseEntity.ok(is_repeat);

    }


    /**
     * 文件下载
     * @param fileId
     * @return
     */
    @GetMapping("/download/{fileId}")
    public ResponseEntity<Object> fileDownload(@PathVariable(name = "fileId") String fileId) {
        FileExportVo fileExportVo = fileUploadService.downloadFile(fileId);

        if (Objects.nonNull(fileExportVo)) {
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "fileName=\"" + fileExportVo.getFileName() + "\"")
                    .header(HttpHeaders.CONTENT_TYPE, fileExportVo.getContentType())
                    .header(HttpHeaders.CONTENT_LENGTH, fileExportVo.getFileSize() + "").header("Connection", "close")
                    .body(fileExportVo.getData());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("file does not exist");
        }
    }

    /**
     * 文件删除
     * @param fileId
     * @return
     */
    @DeleteMapping("/remove/{fileId}")
    public ResponseMessage<?> removeFile(@PathVariable(name = "fileId") String fileId) {
        fileUploadService.removeFile(fileId);
        return ResponseMessage.ok("删除成功");
    }

    /**
     * 用户登录
     * @param loginRequest
     * @return
     */
    @PostMapping("/login")
    public ResponseEntity<Boolean> login(@RequestBody User loginRequest) {
        String name = loginRequest.getName();
        String parsed = loginRequest.getParsed();

        boolean loggedIn = fileUploadService.logon_User(name, parsed);
        return ResponseEntity.ok(loggedIn);
    }
    //判断分享码正不正确
    @PostMapping("/enterfile")
    public ResponseEntity<Boolean> enterfile(@RequestBody User enterFiler){
        String name=enterFiler.getName();
        String share_parsed=enterFiler.getShare_Parsed();
        boolean enterfiler=fileUploadService.inspect_User(name,share_parsed);
        return ResponseEntity.ok(enterfiler);
    }
//获得用户名下的所有文件
    @GetMapping("/user/id/{userId}")
    public List<Map<String, String>> getUserFiles(@PathVariable String userId) {
        return fileUploadService.getFilesByUserId(userId);
    }
    @GetMapping("/user/files/{lab}")
    public List<Map<String, String>> getFiles(@PathVariable String lab) {
        return fileUploadService.FilesByUserId(lab);
    }
    //获得图片
    @GetMapping("/files/23")
    public List<Map<String, String>> getFiles1() {
        return fileUploadService.getFiles1();
    }
    //获得用户信息
    @GetMapping("/user/name/{name}")
    public Map<String, String> getUserInformation(@PathVariable String name) {
        return fileUploadService.get_User_imforaction(name);
    }
    @GetMapping("User/All/list")
    public ResponseEntity<List<Map<String, String>>> getAllUserList() {
        List<Map<String, String>> userList = fileUploadService.get_AllUser_list();
        return ResponseEntity.ok(userList);
    }

    @GetMapping("remove/user/{name}")
    public ResponseMessage<?> remove_user(@PathVariable String name){
        fileUploadService.remove_user(name);
        return ResponseMessage.ok("删除成功");
    }

    @PostMapping("add/User_like")
    public ResponseEntity<Boolean> User_like(@RequestBody User_like userLike) {
        System.out.println("Received userLike: " + userLike);
        boolean is_repeat = fileUploadService.add_user_like(
                userLike.getUserid(),
                userLike.getUser_like_id()
        );
        return ResponseEntity.ok(is_repeat);
    }
//添加收藏
    @PostMapping("add/User_favorite")
    public ResponseEntity<Boolean> User_like(@RequestBody User_favoriter userFavoriter){
        boolean is_repeat= fileUploadService.add_user_favourite(
               userFavoriter.getUserid(),
               userFavoriter.getUser_favoriter_id()
        );
        return ResponseEntity.ok(is_repeat);
    }
    //某个作品的点赞数
    @GetMapping("/user-like/{User_like_id}")
    public ResponseEntity<Integer> getUserLikeCount(@PathVariable  String User_like_id) {
        int count = fileUploadService.getuser_like(User_like_id);
        return ResponseEntity.ok(count);
    }
    //判断该用户是否点赞该作品
    @GetMapping("/check")
    public boolean checkUserLike(@RequestParam("userid") String userid,
                                 @RequestParam("likeId") String userLikeId) {
        return fileUploadService.chacke_user_like(userid, userLikeId);
    }
    //某个作品的收藏数
    @GetMapping("/user-favoriter/{User_like_id}")
    public ResponseEntity<Integer> getUserfavouriteCount(@PathVariable  String User_like_id) {
        int count = fileUploadService.getuser_favourite(User_like_id);
        return ResponseEntity.ok(count);
    }
    //判断该用户是否收藏该作品
    @GetMapping("favoriter/check")
    public boolean checkUserfavourite(@RequestParam("userid") String userid,
                                 @RequestParam("likeId") String userLikeId) {
        return fileUploadService.chacke_user_favourite(userid, userLikeId);
    }
    @GetMapping("/like-list/{userid}")
    public List<Map<String, String>> getUserLikeList(@PathVariable String userid) {
        return fileUploadService.get_like_list(userid);
    }

    @GetMapping("/like-favourite/{userid}")
    public List<Map<String, String>> getUserfavouriteList(@PathVariable String userid) {
        return fileUploadService.get_favourite_list(userid);
    }
}

