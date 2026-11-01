package com.skillswap.view.skills;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.chip.Chip;
import com.skillswap.adapter.SkillCatalogAdapter;
import com.skillswap.databinding.ActivitySkillCatalogBinding;
import com.skillswap.model.Skill;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.SkillsViewModel;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Catalogo completo de habilidades (seleccionable). */
public class SkillCatalogActivity extends BaseActivity {

    private ActivitySkillCatalogBinding binding;
    private SkillsViewModel viewModel;
    private SkillCatalogAdapter adapter;
    private List<Skill> all = new ArrayList<>();
    private String selectedCategory = "";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySkillCatalogBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(SkillsViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, "Catálogo de habilidades");

        adapter = new SkillCatalogAdapter(skill -> {
            Intent data = new Intent();
            data.putExtra(Constants.EXTRA_SKILL_NAME, skill.getName());
            setResult(Activity.RESULT_OK, data);
            finish();
        });
        binding.rvSkills.setLayoutManager(new LinearLayoutManager(this));
        binding.rvSkills.setAdapter(adapter);

        buildCategoryChips();

        if (binding.tilSearch.getEditText() != null) {
            binding.tilSearch.getEditText().addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    applyFilters();
                }
            });
        }

        viewModel.catalog().observe(this, new Observer<List<Skill>>() {
            @Override
            public void onChanged(List<Skill> skills) {
                all = skills == null ? new ArrayList<>() : skills;
                applyFilters();
            }
        });
        viewModel.loadCatalog();
    }

    private void buildCategoryChips() {
        binding.chipsCategory.removeAllViews();
        for (String category : SkillCatalog.getCategories()) {
            Chip chip = ChipFactory.choiceChip(this, category, false);
            chip.setTag(category);
            chip.setOnCheckedChangeListener((buttonView, isChecked) -> {
                selectedCategory = isChecked ? String.valueOf(buttonView.getTag()) : "";
                applyFilters();
            });
            binding.chipsCategory.addView(chip);
        }
    }

    private void applyFilters() {
        String query = binding.tilSearch.getEditText() == null ? ""
                : binding.tilSearch.getEditText().getText().toString().toLowerCase(Locale.ROOT).trim();

        List<Skill> filtered = new ArrayList<>();
        for (Skill s : all) {
            if (!selectedCategory.isEmpty() && !selectedCategory.equals(s.getCategory())) continue;
            if (!query.isEmpty() && !s.getName().toLowerCase(Locale.ROOT).contains(query)) continue;
            filtered.add(s);
        }
        adapter.submit(filtered);
    }
}
