package com.example.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class FileUploadRequest {

    @JsonProperty("fileName")
    private String fileName;

    @JsonProperty("fileContent")
    private String fileContent;

    // 这里可以添加其他必要的字段，如文件类型等

}
