package com.ec2demo.ec2demo.catalog.converter;

import com.ec2demo.ec2demo.catalog.dto.ProductDto;
import com.ec2demo.ec2demo.catalog.entity.Product;
import com.ec2demo.ec2demo.catalog.entity.ProductCategory;
import org.springframework.stereotype.Component;

@Component
public class ProductConverter {

    public ProductDto toDto(Product entity) {
        ProductDto dto = new ProductDto();
        dto.setId(entity.getId());
        dto.setSku(entity.getSku());
        dto.setName(entity.getName());
        dto.setBarcode(entity.getBarcode());
        if (entity.getCategory() != null) {
            dto.setCategoryId(entity.getCategory().getId());
        }
        dto.setUom(entity.getUom());
        dto.setTrackLot(entity.isTrackLot());
        dto.setTrackSerial(entity.isTrackSerial());
        dto.setPerishable(entity.isPerishable());
        dto.setWeightKg(entity.getWeightKg());
        dto.setLengthCm(entity.getLengthCm());
        dto.setWidthCm(entity.getWidthCm());
        dto.setHeightCm(entity.getHeightCm());
        dto.setStandardCost(entity.getStandardCost());
        dto.setListPrice(entity.getListPrice());
        dto.setTaxCode(entity.getTaxCode());
        dto.setStatus(entity.getStatus());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());
        dto.setDeletedAt(entity.getDeletedAt());
        return dto;
    }

    public Product toEntity(ProductDto dto, ProductCategory category) {
        Product entity = new Product();
        updateEntity(dto, entity, category);
        return entity;
    }

    public void updateEntity(ProductDto dto, Product entity, ProductCategory category) {
        entity.setSku(dto.getSku());
        entity.setName(dto.getName());
        entity.setBarcode(dto.getBarcode());
        entity.setCategory(category);
        entity.setUom(dto.getUom());
        entity.setTrackLot(dto.isTrackLot());
        entity.setTrackSerial(dto.isTrackSerial());
        entity.setPerishable(dto.isPerishable());
        entity.setWeightKg(dto.getWeightKg());
        entity.setLengthCm(dto.getLengthCm());
        entity.setWidthCm(dto.getWidthCm());
        entity.setHeightCm(dto.getHeightCm());
        entity.setStandardCost(dto.getStandardCost());
        entity.setListPrice(dto.getListPrice());
        entity.setTaxCode(dto.getTaxCode());
        entity.setStatus(dto.getStatus());
        entity.setDeletedAt(dto.getDeletedAt());
    }
}
