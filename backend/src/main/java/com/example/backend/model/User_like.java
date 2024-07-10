package com.example.backend.model;

import org.springframework.data.annotation.Id;

public class User_like {
    @Id
    public String id;
    public String userid;
    public  String User_like_id;

    public User_like(String id){
        this.id=id;
    }

    public User_like(String userid,String User_like_id){
        this.User_like_id=User_like_id;
        this.userid=userid;

    }
    public User_like() {

    }

    public User_like(String id,String userid,String User_like_id){
        this.id=id;
        this.userid=userid;
        this.User_like_id=User_like_id;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
    public String getUserid(){return userid;}

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public String getUser_like_id() {
        return User_like_id;
    }

    public void setUser_like_id(String user_like_id) {
        User_like_id = user_like_id;
    }
}
