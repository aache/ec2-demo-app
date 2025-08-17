package com.ec2demo.ec2demo.catalog.converter;

import com.ec2demo.ec2demo.catalog.dto.ProductCategoryDto;
import com.ec2demo.ec2demo.catalog.entity.ProductCategory;
import org.springframework.stereotype.Component;

@Component
public class ProductCategoryConverter {

    public ProductCategoryDto toDto(ProductCategory entity) {
        ProductCategoryDto dto = new ProductCategoryDto();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        if (entity.getParent() != null) {
            dto.setParentId(entity.getParent().getId());
        }
        return dto;
    }

    public ProductCategory toEntity(ProductCategoryDto dto, ProductCategory parent) {
        ProductCategory entity = new ProductCategory();
        entity.setId(dto.getId());
        entity.setName(dto.getName());
        entity.setParent(parent);
        return entity;
    }
}
