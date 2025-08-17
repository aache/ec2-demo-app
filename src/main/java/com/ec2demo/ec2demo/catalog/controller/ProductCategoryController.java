package com.ec2demo.ec2demo.catalog.controller;

import com.ec2demo.ec2demo.catalog.dto.ProductCategoryDto;
import com.ec2demo.ec2demo.catalog.service.ProductCategoryService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/categories")
public class ProductCategoryController {

    private final ProductCategoryService service;

    public ProductCategoryController(ProductCategoryService service) {
        this.service = service;
    }

    @PostMapping
    public ProductCategoryDto create(@RequestBody ProductCategoryDto dto) {
        return service.create(dto);
    }

    @GetMapping
    public List<ProductCategoryDto> list() {
        return service.list();
    }
}
