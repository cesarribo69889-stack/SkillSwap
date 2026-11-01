package com.skillswap.view.matches;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.android.material.chip.Chip;
import com.skillswap.R;
import com.skillswap.databinding.SheetFiltersBinding;
import com.skillswap.model.ExploreFilter;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.List;

/** Hoja inferior con los filtros de la pantalla Explorar. */
public class FiltersSheet extends BottomSheetDialogFragment {

    public interface OnFiltersApplied {
        void onApplied(ExploreFilter filter);
    }

    private static final String ARG_FILTER = "arg_filter";

    private SheetFiltersBinding binding;
    private ExploreFilter filter = new ExploreFilter();
    private OnFiltersApplied listener;

    public static FiltersSheet newInstance(ExploreFilter current) {
        FiltersSheet sheet = new FiltersSheet();
        Bundle args = new Bundle();
        args.putSerializable(ARG_FILTER, current);
        sheet.setArguments(args);
        return sheet;
    }

    public void setListener(OnFiltersApplied listener) {
        this.listener = listener;
    }

    @Override
    public int getTheme() {
        return R.style.Theme_SkillSwap_BottomSheet;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = SheetFiltersBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (getArguments() != null && getArguments().getSerializable(ARG_FILTER) != null) {
            filter = (ExploreFilter) getArguments().getSerializable(ARG_FILTER);
        }

        buildCategories();
        buildSkills();
        restoreSelection();

        binding.sliderMin.addOnChangeListener((slider, value, fromUser) ->
                binding.txtMinValue.setText(getString(R.string.fmt_percent, (int) value)));

        binding.btnClear.setOnClickListener(v -> {
            filter.clearFilters();
            if (listener != null) listener.onApplied(filter);
            dismiss();
        });

        binding.btnApply.setOnClickListener(v -> {
            collect();
            if (listener != null) listener.onApplied(filter);
            dismiss();
        });
    }

    private void buildCategories() {
        binding.chipsCategory.removeAllViews();
        for (String category : SkillCatalog.getCategories()) {
            Chip chip = ChipFactory.choiceChip(requireContext(), category,
                    category.equals(filter.getCategory()));
            chip.setTag(category);
            binding.chipsCategory.addView(chip);
        }
    }

    private void buildSkills() {
        List<String> skills = new ArrayList<>();
        skills.add("Todas");
        skills.addAll(SkillCatalog.getAllSkillNames());
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(),
                android.R.layout.simple_list_item_1, skills);
        if (binding.tilSkill.getEditText() instanceof
                com.google.android.material.textfield.MaterialAutoCompleteTextView) {
            ((com.google.android.material.textfield.MaterialAutoCompleteTextView)
                    binding.tilSkill.getEditText()).setAdapter(adapter);
        }
        if (binding.tilSkill.getEditText() != null
                && filter.getSkill() != null && !filter.getSkill().isEmpty()) {
            ((com.google.android.material.textfield.MaterialAutoCompleteTextView)
                    binding.tilSkill.getEditText()).setText(filter.getSkill(), false);
        }
    }

    private void restoreSelection() {
        binding.chipLvlBasic.setChecked(Constants.LEVEL_BASIC.equals(filter.getLevel()));
        binding.chipLvlIntermediate.setChecked(Constants.LEVEL_INTERMEDIATE.equals(filter.getLevel()));
        binding.chipLvlAdvanced.setChecked(Constants.LEVEL_ADVANCED.equals(filter.getLevel()));

        binding.chipModPresencial.setChecked(Constants.MODALITY_PRESENCIAL.equals(filter.getModality()));
        binding.chipModVirtual.setChecked(Constants.MODALITY_VIRTUAL.equals(filter.getModality()));

        if (binding.tilUniversity.getEditText() != null) {
            binding.tilUniversity.getEditText().setText(filter.getUniversity());
        }
        binding.sliderMin.setValue(filter.getMinCompatibility());
        binding.txtMinValue.setText(getString(R.string.fmt_percent, filter.getMinCompatibility()));
    }

    private void collect() {
        String category = "";
        for (int i = 0; i < binding.chipsCategory.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsCategory.getChildAt(i);
            if (chip.isChecked()) category = String.valueOf(chip.getTag());
        }
        filter.setCategory(category);

        String skill = binding.tilSkill.getEditText() == null ? ""
                : binding.tilSkill.getEditText().getText().toString();
        filter.setSkill("Todas".equals(skill) ? "" : skill);

        if (binding.chipLvlBasic.isChecked()) filter.setLevel(Constants.LEVEL_BASIC);
        else if (binding.chipLvlIntermediate.isChecked()) filter.setLevel(Constants.LEVEL_INTERMEDIATE);
        else if (binding.chipLvlAdvanced.isChecked()) filter.setLevel(Constants.LEVEL_ADVANCED);
        else filter.setLevel("");

        if (binding.chipModPresencial.isChecked()) filter.setModality(Constants.MODALITY_PRESENCIAL);
        else if (binding.chipModVirtual.isChecked()) filter.setModality(Constants.MODALITY_VIRTUAL);
        else filter.setModality("");

        filter.setUniversity(binding.tilUniversity.getEditText() == null ? ""
                : binding.tilUniversity.getEditText().getText().toString().trim());
        filter.setMinCompatibility((int) binding.sliderMin.getValue());
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
