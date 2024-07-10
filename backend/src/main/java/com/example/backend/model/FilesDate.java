package com.example.backend.model;

public class FilesDate {
    private String id;
    private  String fileName;
    private String contentType;

    public FilesDate(String id,String fileName,String contentType){
        this.id=id;
        this.fileName=fileName;
        this.contentType=contentType;
    }
}
