package com.example.backend.repository;

import com.example.backend.model.MongoFile;
import org.springframework.data.mongodb.repository.MongoRepository;


public interface MongoFileRepository extends MongoRepository<MongoFile, String> {

}
