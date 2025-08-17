package com.ec2demo.ec2demo.catalog.repository;

import com.ec2demo.ec2demo.catalog.entity.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProductCategoryRepository extends JpaRepository<ProductCategory, UUID> {
}
