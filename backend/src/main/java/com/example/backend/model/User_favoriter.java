package com.example.backend.model;

import org.springframework.data.annotation.Id;

public class User_favoriter {
    @Id
    private String id;
    public String userid;
    public String  user_favoriter_id;

    public  User_favoriter(String userid,String user_favoriter_id){
        this.userid=userid;
        this.user_favoriter_id=user_favoriter_id;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public String getUserid() {
        return userid;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }

    public String getUser_favoriter_id() {
        return user_favoriter_id;
    }

    public void setUser_favoriter_id(String user_favoriter_id) {
        this.user_favoriter_id = user_favoriter_id;
    }

}
