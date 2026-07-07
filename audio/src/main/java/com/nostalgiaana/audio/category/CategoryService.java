package com.nostalgiaana.audio.category;

import com.nostalgiaana.audio.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public Category createCategory(String name, String description, User createdBy) {
        if (categoryRepository.existsByName(name)) {
            throw new RuntimeException("Category already exists: " + name);
        }

        Category category = Category.builder()
                .name(name)
                .description(description)
                .createdBy(createdBy)
                .build();

        return categoryRepository.save(category);
    }

    public List<Category> getAllCategories() {
        return categoryRepository.findAllByOrderByCreatedAtDesc();
    }

    public Category getCategoryById(UUID id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found"));
    }

    public Category updateCategory(UUID id, String name, String description) {
        Category category = getCategoryById(id);
        category.setName(name);
        category.setDescription(description);
        return categoryRepository.save(category);
    }

    public void deleteCategory(UUID id) {
        Category category = getCategoryById(id);
        categoryRepository.delete(category);
    }
}