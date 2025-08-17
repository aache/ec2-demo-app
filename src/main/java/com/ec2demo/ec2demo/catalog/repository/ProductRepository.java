package com.ec2demo.ec2demo.catalog.repository;

import com.ec2demo.ec2demo.catalog.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
}
