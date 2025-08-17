package com.ec2demo.ec2demo.catalog.service;

import com.ec2demo.ec2demo.catalog.converter.ProductConverter;
import com.ec2demo.ec2demo.catalog.dto.ProductDto;
import com.ec2demo.ec2demo.catalog.entity.Product;
import com.ec2demo.ec2demo.catalog.entity.ProductCategory;
import com.ec2demo.ec2demo.catalog.repository.ProductCategoryRepository;
import com.ec2demo.ec2demo.catalog.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductCategoryRepository categoryRepository;
    private final ProductConverter converter;

    public ProductService(ProductRepository productRepository,
                          ProductCategoryRepository categoryRepository,
                          ProductConverter converter) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.converter = converter;
    }

    public ProductDto create(ProductDto dto) {
        ProductCategory category = null;
        if (dto.getCategoryId() != null) {
            category = categoryRepository.findById(dto.getCategoryId()).orElse(null);
        }
        Product entity = converter.toEntity(dto, category);
        return converter.toDto(productRepository.save(entity));
    }

    public List<ProductDto> list() {
        return productRepository.findAll().stream().map(converter::toDto).toList();
    }

    public ProductDto get(UUID id) {
        return productRepository.findById(id)
                .map(converter::toDto)
                .orElseThrow(() -> new RuntimeException("Product not found"));
    }

    public ProductDto update(UUID id, ProductDto dto) {
        Product entity = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        ProductCategory category = null;
        if (dto.getCategoryId() != null) {
            category = categoryRepository.findById(dto.getCategoryId()).orElse(null);
        }
        converter.updateEntity(dto, entity, category);
        return converter.toDto(productRepository.save(entity));
    }
}
