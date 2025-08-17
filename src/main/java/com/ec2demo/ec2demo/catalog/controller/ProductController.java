package com.ec2demo.ec2demo.catalog.controller;

import com.ec2demo.ec2demo.catalog.dto.ProductDto;
import com.ec2demo.ec2demo.catalog.service.ProductService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/products")
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @PostMapping
    public ProductDto create(@RequestBody ProductDto dto) {
        return service.create(dto);
    }

    @GetMapping
    public List<ProductDto> list() {
        return service.list();
    }

    @GetMapping("/{id}")
    public ProductDto get(@PathVariable UUID id) {
        return service.get(id);
    }

    @PatchMapping("/{id}")
    public ProductDto update(@PathVariable UUID id, @RequestBody ProductDto dto) {
        return service.update(id, dto);
    }
}
