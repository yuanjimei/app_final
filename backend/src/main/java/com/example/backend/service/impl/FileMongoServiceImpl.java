package com.example.backend.service.impl;
import cn.hutool.core.io.IoUtil;
import cn.hutool.core.util.IdUtil;
import com.example.backend.model.MongoFile;
import com.example.backend.model.User;
import com.example.backend.model.User_favoriter;
import com.example.backend.model.User_like;
import com.example.backend.repository.MongoFileRepository;
import com.example.backend.service.FileUploadService;
import com.example.backend.util.MD5Util;
import com.example.backend.vo.FileExportVo;
import com.mongodb.client.gridfs.GridFSBucket;
import com.mongodb.client.gridfs.GridFSDownloadStream;
import com.mongodb.client.gridfs.model.GridFSFile;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.bson.types.Binary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.gridfs.GridFsResource;
import org.springframework.data.mongodb.gridfs.GridFsTemplate;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * @Description MongoDB文件上传实现类
 * @author coisini
 * @date Apr 17, 2022
 * @version 1.0
 */
@Slf4j
@Service("fileMongoServiceImpl")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class FileMongoServiceImpl  implements FileUploadService {

    private final MongoFileRepository mongoFileRepository;
    private final MongoTemplate mongoTemplate;
    private final GridFsTemplate gridFsTemplate;
    private final GridFSBucket gridFSBucket;

    /**
     * 多文件上传
     * @param files
     * @return
     */
    @Override
    public List<FileExportVo> uploadFiles(List<MultipartFile> files,String userID,String description,String title,String lab) {

        return files.stream().map(file -> {
            try {
                return this.uploadFile(file, userID,description,lab,title);
            } catch (Exception e) {
                log.error("文件上传失败", e);
                return null;
            }
        }).filter(Objects::nonNull).collect(Collectors.toList());
    }

    /**
     * 创建用户
     * @param name
     * @param parsed
     * @param share_parsed
     */
     @Override
     public boolean createUser(String name,String parsed,String share_parsed,String Proflie_picture){
        if(!check_name(name))
            return false;
        else {
            User user = new User(name, parsed, share_parsed,Proflie_picture);
            mongoTemplate.save(user);
            return true;
        }

     }

     public boolean check_name(String name){
         Query query = new Query(Criteria.where("name").is(name));
         List<User> users = mongoTemplate.find(query, User.class);
         return users.isEmpty();
     }
     @Override
     public boolean logon_User(String name, String parsed) {
         if (!check_name(name)) {
             Query query = new Query(Criteria.where("name").is(name));
             List<User> users = mongoTemplate.find(query, User.class);
             for (User u : users) {
                 if (u.getParsed().equals(parsed)) {
                     return true;
                 }
             }
             return false; // 如果没有找到匹配的用户，返回 false
         } else {
             return false; // 如果用户名不合法，返回 false
         }
     }

     public boolean inspect_User(String name,String share_parsed){
         if (!check_name(name)) {
             Query query = new Query(Criteria.where("name").is(name));
             List<User> users = mongoTemplate.find(query, User.class);
             for (User u : users) {
                 if (u.getParsed().equals(share_parsed)) {
                     return true;
                 }
             }
             return false; // 如果没有找到匹配的用户，返回 false
         } else {
             return false; // 如果用户名不合法，返回 false
         }
     }
    /**
     * 文件上传
     * @param file
     * @return
     * @throws Exception
     */
    @Override
    public FileExportVo uploadFile(MultipartFile file,String userID,String description,String title,String lab) throws Exception {
        if (file.getSize() > 16777216) {
            return this.saveGridFsFile(file,userID);
        } else {
            return this.saveBinaryFile(file,userID,description,lab,title);
        }
    }

    /**
     * 文件下载
     * @param fileId
     * @return
     */
    @Override
    public FileExportVo downloadFile(String fileId) {
        Optional<MongoFile> option = this.getBinaryFileById(fileId);

        if (option.isPresent()) {
            MongoFile mongoFile = option.get();
            if(Objects.isNull(mongoFile.getContent())){
                option = this.getGridFsFileById(fileId);
            }
        }

        return option.map(FileExportVo::new).orElse(null);
    }


    @Override
    public void removeFile(String fileId) {
        Optional<MongoFile> option = this.getBinaryFileById(fileId);

        if (option.isPresent()) {
            if (Objects.nonNull(option.get().getGridFsId())) {
                this.removeGridFsFile(fileId);
            } else {
                this.removeBinaryFile(fileId);
            }
        }
    }

    /**
     * 删除Binary文件
     * @param fileId
     */
    public void removeBinaryFile(String fileId) {
        mongoFileRepository.deleteById(fileId);
    }

    /**
     * 删除GridFs文件
     * @param fileId
     */
    public void removeGridFsFile(String fileId) {
        // TODO 根据id查询文件
        MongoFile mongoFile = mongoTemplate.findById(fileId, MongoFile.class );
        if(Objects.nonNull(mongoFile)){
            // TODO 根据文件ID删除fs.files和fs.chunks中的记录
            Query deleteFileQuery = new Query().addCriteria(Criteria.where("filename").is(mongoFile.getGridFsId()));
            gridFsTemplate.delete(deleteFileQuery);
            // TODO 删除集合mongoFile中的数据
            Query deleteQuery = new Query(Criteria.where("id").is(fileId));
            mongoTemplate.remove(deleteQuery, MongoFile.class);
        }
    }

    /**
     * 保存Binary文件（小文件）
     * @param file
     * @return
     * @throws Exception
     */
    public FileExportVo saveBinaryFile(MultipartFile file, String userID,String description,String title,String lab) throws Exception {

        String suffix = getFileSuffix(file);

        MongoFile mongoFile = mongoFileRepository.save(
                MongoFile.builder()
                        .fileName(file.getOriginalFilename())
                        .fileSize(file.getSize())
                        .content(new Binary(file.getBytes()))
                        .contentType(file.getContentType())
                        .uploadDate(new Date())
                        .suffix(suffix)
                        .md5(MD5Util.getMD5(file.getInputStream()))
                        .userID(userID)
                        .description(description)
                        .lab(lab)
                        .title(title)
                        .build()
        );

        return new FileExportVo(mongoFile);
    }

    /**
     * 保存GridFs文件（大文件）
     * @param file
     * @return
     * @throws Exception
     */
    public FileExportVo saveGridFsFile(MultipartFile file,String userID) throws Exception {
        String suffix = getFileSuffix(file);

        String gridFsId = this.storeFileToGridFS(file.getInputStream(), file.getContentType());

        MongoFile mongoFile = mongoTemplate.save(
                MongoFile.builder()
                        .fileName(file.getOriginalFilename())
                        .fileSize(file.getSize())
                        .contentType(file.getContentType())
                        .uploadDate(new Date())
                        .suffix(suffix)
                        .md5(MD5Util.getMD5(file.getInputStream()))
                        .gridFsId(gridFsId)
                        .userID(userID)
                        .build()
        );

        return new FileExportVo(mongoFile);
    }

    /**
     * 上传文件到Mongodb的GridFs中
     * @param in
     * @param contentType
     * @return
     */
    public String storeFileToGridFS(InputStream in, String contentType){
        String gridFsId = IdUtil.simpleUUID();
        // TODO 将文件存储进GridFS中
        gridFsTemplate.store(in, gridFsId , contentType);
        return gridFsId;
    }

    /**
     * 获取Binary文件
     * @param id
     * @return
     */
    public Optional<MongoFile> getBinaryFileById(String id) {
        return mongoFileRepository.findById(id);
    }

    /**
     * 获取Grid文件
     * @param id
     * @return
     */
    public Optional<MongoFile> getGridFsFileById(String id){
        MongoFile mongoFile = mongoTemplate.findById(id , MongoFile.class );
        if(Objects.nonNull(mongoFile)){
            Query gridQuery = new Query().addCriteria(Criteria.where("filename").is(mongoFile.getGridFsId()));
            try {
                // TODO 根据id查询文件
                GridFSFile fsFile = gridFsTemplate.findOne(gridQuery);
                // TODO 打开流下载对象
                GridFSDownloadStream in = gridFSBucket.openDownloadStream(fsFile.getObjectId());
                if(in.getGridFSFile().getLength() > 0){
                    // TODO 获取流对象
                    GridFsResource resource = new GridFsResource(fsFile, in);
                    // TODO 获取数据
                    mongoFile.setContent(new Binary(IoUtil.readBytes(resource.getInputStream())));
                    return Optional.of(mongoFile);
                }else {
                    return Optional.empty();
                }
            }catch (IOException e){
                log.error("获取MongoDB大文件失败", e);
            }
        }

        return Optional.empty();
    }

    /**
     * 获取文件后缀
     * @param file
     * @return
     */
    private String getFileSuffix(MultipartFile file) {
        String suffix = "";
        if (Objects.requireNonNull(file.getOriginalFilename()).contains(".")) {
            suffix = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf("."));
        }
        return suffix;
    }
//获得某用户下的全部文件
    public List<Map<String, String>> getFilesByUserId(String userID) {
        // 构建查询条件
        Query query = new Query(Criteria.where("userID").is(userID));
        List<MongoFile> mongoFiles = mongoTemplate.find(query, MongoFile.class);
        // 将查询结果转换为指定格式的列表
        List<Map<String, String >> files = new ArrayList<>();
        for (MongoFile file : mongoFiles) {
            Map<String, String> fileMap = new HashMap<>();
            fileMap.put("id", file.getId()); // Assuming the method to get file ID is getId()
            fileMap.put("fileName", file.getFileName());
            fileMap.put("contentType", file.getContentType());
            fileMap.put("userID",file.getUserID());
            files.add(fileMap);
        }
        return files;
    }
    //获得文件
  public   List<Map<String, String>> FilesByUserId(String lab){
      // 构建查询条件
      Query query = new Query(Criteria.where("lab").is(lab));
      List<MongoFile> mongoFiles = mongoTemplate.find(query, MongoFile.class);
      // 将查询结果转换为指定格式的列表
      List<Map<String, String >> files = new ArrayList<>();
      for (MongoFile file : mongoFiles) {
          Map<String, String> fileMap = new HashMap<>();
          fileMap.put("id", file.getId()); // Assuming the method to get file ID is getId()
          fileMap.put("title", file.getTitle());
          fileMap.put("description", file.getDescription());
          fileMap.put("userID",file.getUserID());
          fileMap.put("lab",file.getLab());
          files.add(fileMap);
      }
      return files;
  }

/*
通过正则表达式获取用户
 */
   public List<String>  SearchUser(String name){
       Pattern pattern = Pattern.compile(name);
       // 构建查询条件
       Query query = new Query(Criteria.where("name").regex(pattern));
       List<User> users = mongoTemplate.find(query, User.class);
       List<String> files = new ArrayList<>();
       for (User file : users){
           String r=file.getName();
           files.add(r);
       }
       return files;
   }

   //获得用户信息
    public Map<String, String> get_User_imforaction(String name){
        Query query = new Query(Criteria.where("name").is(name));
        User user=mongoTemplate.findOne(query, User.class);
        Map<String, String> file= new HashMap<>();
        if(user!=null){
            file.put("id",user.getId());
            file.put("name",user.getName());
            file.put("share_parsed",user.getShare_Parsed());
            file.put("Proflie_picture",user.getProflie_picture());
        }
        return  file;
    }

    public  List<Map<String,String>> get_AllUser_list(){
       List<User> users=mongoTemplate.findAll(User.class);
        List<Map<String, String >> files = new ArrayList<>();
        for(User user:users){
            Map<String, String> file=new HashMap<>();
            file.put("id",user.getId());
            file.put("name",user.getName());
            file.put("Proflie_picture", user.getProflie_picture());
            files.add(file);
        }
        return files;
    }

    public void remove_user(String User_name){
        Query query = new Query(Criteria.where("name").is(User_name));
        List<User> users=mongoTemplate.find(query, User.class);
        for(User user:users){
            mongoTemplate.remove(user);
        }
    }

    public boolean add_user_like(String userid, String User_like_id) {
        boolean iscunzai = false;
        String User_id = "";
        Query query = new Query(Criteria.where("userid").is(userid));
        List<User_like> users = mongoTemplate.find(query, User_like.class);
        for (User_like user : users) {
            if (user.getUser_like_id().equals(User_like_id)) {
                iscunzai = true;
                User_id = user.getId();
                break;
            }
        }
        if (iscunzai) {
            User_like user = mongoTemplate.findById(User_id, User_like.class);
            mongoTemplate.remove(user);
            return false;
        } else {
            User_like userLike = new User_like(userid, User_like_id);
            mongoTemplate.save(userLike);
            return true;
        }
    }

    public  boolean add_user_favourite(String userid,String User_favourite_id){
        boolean iscunzai=false;
        String User_id="";
        Query query = new Query(Criteria.where("userid").is(userid));
        List<User_favoriter> users=mongoTemplate.find(query, User_favoriter.class);
        for (var user : users){
            if(user.user_favoriter_id.equals(User_favourite_id)){
                iscunzai=true;
                User_id=user.getId();
                break;
            }
        }
        if(iscunzai){
            User_favoriter user = mongoTemplate.findById(User_id, User_favoriter.class);
            mongoTemplate.remove(user);
            return false;
        }
        else {
            User_favoriter userLike=new User_favoriter(userid,User_favourite_id);
            mongoTemplate.save(userLike);
            return true;
        }

    }
    //获取点赞数
    public   int getuser_like(String User_like_id){
        Query query = new Query(Criteria.where("User_like_id").is(User_like_id));
        List<User_like> users = mongoTemplate.find(query, User_like.class);
        return  users.size();
    }
    //检测某个人是否点赞该作品
    public boolean chacke_user_like(String userid, String User_like_id){
        boolean iscunzai = false;

        Query query = new Query(Criteria.where("userid").is(userid));
        List<User_like> users = mongoTemplate.find(query, User_like.class);
        for (User_like user : users) {
            if (user.getUser_like_id().equals(User_like_id)) {
                iscunzai = true;
                break;
            }
        }
       return  iscunzai;
    }
    //获得某个作品的收藏数
    public  int getuser_favourite(String User_favourite_id){
        Query query = new Query(Criteria.where("user_favoriter_id").is(User_favourite_id));
        List<User_favoriter> users = mongoTemplate.find(query, User_favoriter.class);
        return  users.size();
    }
    //检测某个人是否收藏该作品
    public boolean chacke_user_favourite(String userid,String User_favourite_id){
        boolean iscunzai = false;

        Query query = new Query(Criteria.where("userid").is(userid));
        List<User_favoriter> users = mongoTemplate.find(query, User_favoriter.class);
        for (User_favoriter user : users) {
            if (user.user_favoriter_id.equals(User_favourite_id)) {
                iscunzai = true;
                break;
            }
        }
        return  iscunzai;
    }
    //获得某个人的所有点赞的作品
    public  List<Map<String,String>> get_like_list(String userid){
        Query query = new Query(Criteria.where("userid").is(userid));
        List<User_like> users = mongoTemplate.find(query, User_like.class);
        List<Map<String, String >> likes = new ArrayList<>();
        for (User_like user : users) {
            Map<String, String> file=new HashMap<>();
            file.put("User_like_id",user.getUser_like_id());
            likes.add(file);
        }
        return  likes;
    }
    //获得某个人的所有收藏的作品
    public  List<Map<String,String>> get_favourite_list(String userid){
        Query query = new Query(Criteria.where("userid").is(userid));
        List<User_favoriter> users = mongoTemplate.find(query, User_favoriter.class);
        List<Map<String, String >> favourites = new ArrayList<>();
        for (User_favoriter user : users) {
            Map<String, String> file=new HashMap<>();
            file.put("user_favoriter_id",user.user_favoriter_id);
            favourites.add(file);
        }
        return  favourites;
    }
    //随机获得图片
   public List<Map<String, String>> getFiles1(){
       List<MongoFile> mongoFiles = mongoTemplate.findAll(MongoFile.class);
       // 将查询结果转换为指定格式的列表
       List<Map<String, String >> files = new ArrayList<>();
       Random random = new Random();
       Set<Integer> generated = new HashSet<>();
       int count=0;
       while (count<mongoFiles.size()){
           Map<String, String> fileMap = new HashMap<>();

           int randomNumber = random.nextInt(mongoFiles.size());
           if (!generated.contains(randomNumber)) {
               generated.add(randomNumber);

               MongoFile file= mongoFiles.get(randomNumber);
               fileMap.put("id", file.getId());
               fileMap.put("title", file.getTitle());
               fileMap.put("description", file.getDescription());
               fileMap.put("userID",file.getUserID());
               fileMap.put("lab",file.getLab());
               files.add(fileMap);count++;
           }
       }
       return files;
   }
}
