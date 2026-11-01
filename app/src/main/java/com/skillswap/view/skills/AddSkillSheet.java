package com.skillswap.view.skills;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.skillswap.R;
import com.skillswap.databinding.SheetAddSkillBinding;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.Validators;

import java.util.List;

/** Hoja inferior para agregar o editar una habilidad. */
public class AddSkillSheet extends BottomSheetDialogFragment {

    public interface OnSkillSaved {
        void onSaved(UserSkill skill, boolean editing);
    }

    private static final String ARG_TYPE = "arg_type";
    private static final String ARG_SKILL = "arg_skill";

    private SheetAddSkillBinding binding;
    private OnSkillSaved listener;
    private String type = UserSkill.TYPE_TEACH;
    private UserSkill editing;

    public static AddSkillSheet newInstance(String type, @Nullable UserSkill skill) {
        AddSkillSheet sheet = new AddSkillSheet();
        Bundle args = new Bundle();
        args.putString(ARG_TYPE, type);
        args.putSerializable(ARG_SKILL, skill);
        sheet.setArguments(args);
        return sheet;
    }

    public void setListener(OnSkillSaved listener) {
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
        binding = SheetAddSkillBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (getArguments() != null) {
            type = getArguments().getString(ARG_TYPE, UserSkill.TYPE_TEACH);
            editing = (UserSkill) getArguments().getSerializable(ARG_SKILL);
        }

        boolean teach = UserSkill.TYPE_TEACH.equals(type);
        binding.txtTitle.setText(editing == null
                ? getString(R.string.add_skill) : "Editar habilidad");
        binding.txtSubtitle.setText(teach
                ? "Una habilidad que puedes enseñar"
                : "Una habilidad que quieres aprender");

        setupCategories();
        setupSkills(SkillCatalog.getAllSkillNames());

        if (editing != null) restore(editing);

        binding.btnSave.setOnClickListener(v -> save());
    }

    private void setupCategories() {
        List<String> categories = SkillCatalog.getCategories();
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(),
                android.R.layout.simple_list_item_1, categories);
        if (binding.tilCategory.getEditText() instanceof MaterialAutoCompleteTextView) {
            MaterialAutoCompleteTextView field =
                    (MaterialAutoCompleteTextView) binding.tilCategory.getEditText();
            field.setAdapter(adapter);
            field.setOnItemClickListener((parent, view, position, id) ->
                    setupSkills(SkillCatalog.getSkillNames(categories.get(position))));
        }
    }

    private void setupSkills(List<String> skills) {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(),
                android.R.layout.simple_list_item_1, skills);
        if (binding.tilSkill.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilSkill.getEditText()).setAdapter(adapter);
        }
    }

    private void restore(UserSkill skill) {
        if (binding.tilCategory.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilCategory.getEditText())
                    .setText(skill.getCategory(), false);
        }
        if (binding.tilSkill.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilSkill.getEditText())
                    .setText(skill.getName(), false);
        }
        binding.tilSkill.setEnabled(false);
        if (binding.tilNote.getEditText() != null) {
            binding.tilNote.getEditText().setText(skill.getNote());
        }
        binding.chipBasic.setChecked(Constants.LEVEL_BASIC.equals(skill.getLevel()));
        binding.chipIntermediate.setChecked(Constants.LEVEL_INTERMEDIATE.equals(skill.getLevel()));
        binding.chipAdvanced.setChecked(Constants.LEVEL_ADVANCED.equals(skill.getLevel()));
    }

    private void save() {
        String name = Validators.text(binding.tilSkill).trim();
        if (!Validators.apply(binding.tilSkill,
                Validators.validateMinLength(name, 2, "La habilidad"))) return;

        String category = Validators.text(binding.tilCategory).trim();
        if (category.isEmpty()) category = SkillCatalog.categoryOf(name);

        String level = Constants.LEVEL_BASIC;
        if (binding.chipIntermediate.isChecked()) level = Constants.LEVEL_INTERMEDIATE;
        else if (binding.chipAdvanced.isChecked()) level = Constants.LEVEL_ADVANCED;

        UserSkill skill = new UserSkill(SkillCatalog.slug(name), name, category, level, type);
        skill.setNote(Validators.text(binding.tilNote).trim());
        if (editing != null) skill.setAddedAt(editing.getAddedAt());

        if (listener != null) listener.onSaved(skill, editing != null);
        dismiss();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
