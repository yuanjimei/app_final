package com.example.backend.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;


@Document(collection = "users")
public class User {
    @Id
    private String id;
    private String name;
    private String parsed;

    public String share_parsed;

    public String Proflie_picture;


    // 添加无参构造函数
    public User() {
    }
    public User(String name) {
        this.name = name;
    }
    public User( String name, String parsed) {

        this.name = name;
        this.parsed = parsed;
    }
    public User( String name, String parsed,String share_parsed) {

        this.name = name;
        this.parsed = parsed;
        this.share_parsed=share_parsed;
    }
    // 添加带参构造函数
    public User(String name, String parsed,String share_parsed,String Proflie_picture) {

        this.name = name;
        this.parsed = parsed;
        this.share_parsed=share_parsed;
        this.Proflie_picture=Proflie_picture;
    }
    public User(String id, String name, String parsed,String share_parsed,String Proflie_picture) {
        this.id = id;
        this.name = name;
        this.parsed = parsed;
        this.share_parsed=share_parsed;
        this.Proflie_picture=Proflie_picture;
    }

    // 添加对应的 getters 和 setters 方法
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getParsed() {
        return parsed;
    }

    public void setParsed(String parsed) {
        this.parsed = parsed;
    }
    public String getShare_Parsed() {
        return share_parsed;
    }

    public void setShare_parsedParsed(String share_parsed) {
        this.share_parsed = share_parsed;
    }

    public void setProflie_picture(String proflie_picture) {
        Proflie_picture = proflie_picture;
    }

    public String getProflie_picture() {
        return Proflie_picture;
    }
}