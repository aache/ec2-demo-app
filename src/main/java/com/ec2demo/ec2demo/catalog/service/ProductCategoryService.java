package com.ec2demo.ec2demo.catalog.service;

import com.ec2demo.ec2demo.catalog.converter.ProductCategoryConverter;
import com.ec2demo.ec2demo.catalog.dto.ProductCategoryDto;
import com.ec2demo.ec2demo.catalog.entity.ProductCategory;
import com.ec2demo.ec2demo.catalog.repository.ProductCategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ProductCategoryService {

    private final ProductCategoryRepository repository;
    private final ProductCategoryConverter converter;

    public ProductCategoryService(ProductCategoryRepository repository, ProductCategoryConverter converter) {
        this.repository = repository;
        this.converter = converter;
    }

    public ProductCategoryDto create(ProductCategoryDto dto) {
        ProductCategory parent = null;
        if (dto.getParentId() != null) {
            parent = repository.findById(dto.getParentId()).orElse(null);
        }
        ProductCategory entity = converter.toEntity(dto, parent);
        return converter.toDto(repository.save(entity));
    }

    public List<ProductCategoryDto> list() {
        return repository.findAll().stream().map(converter::toDto).toList();
    }

    public ProductCategory findById(UUID id) {
        return repository.findById(id).orElse(null);
    }
}
