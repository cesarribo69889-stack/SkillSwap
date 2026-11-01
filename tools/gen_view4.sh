#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/skills" "$J/view/matches"

# ============================================================ MySkillsActivity
cat > "$J/view/skills/MySkillsActivity.java" <<'EOF'
package com.skillswap.view.skills;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.tabs.TabLayout;
import com.skillswap.R;
import com.skillswap.adapter.UserSkillAdapter;
import com.skillswap.databinding.ActivityMySkillsBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.SkillsViewModel;

/** Gestion de las habilidades del usuario: agregar, editar y eliminar. */
public class MySkillsActivity extends BaseActivity {

    private ActivityMySkillsBinding binding;
    private SkillsViewModel viewModel;
    private UserSkillAdapter adapter;
    private User current;
    private boolean teachTab = true;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMySkillsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(SkillsViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.my_skills));

        adapter = new UserSkillAdapter(new UserSkillAdapter.OnSkillAction() {
            @Override
            public void onEdit(UserSkill skill) {
                openSheet(skill);
            }

            @Override
            public void onDelete(final UserSkill skill) {
                confirm("Eliminar habilidad",
                        "¿Quitar " + skill.getName() + " de tu perfil?",
                        getString(R.string.delete),
                        () -> viewModel.removeSkill(current, skill));
            }
        });
        binding.rvSkills.setLayoutManager(new LinearLayoutManager(this));
        binding.rvSkills.setAdapter(adapter);

        binding.fabAdd.setOnClickListener(v -> openSheet(null));

        binding.tabs.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                teachTab = tab.getPosition() == 0;
                render();
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {
            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {
            }
        });

        viewModel.currentUser().observe(this, new Observer<User>() {
            @Override
            public void onChanged(User user) {
                current = user;
                render();
            }
        });

        viewModel.operation().observe(this, new Observer<Resource<Boolean>>() {
            @Override
            public void onChanged(Resource<Boolean> state) {
                if (state == null) return;
                if (state.isSuccess()) {
                    toast(binding.getRoot(), "Habilidades actualizadas");
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void render() {
        if (current == null) return;
        adapter.submit(teachTab ? current.getTeachSkills() : current.getLearnSkills());

        boolean empty = (teachTab ? current.getTeachSkills() : current.getLearnSkills()).isEmpty();
        UiUtils.visible(binding.empty.getRoot(), empty);
        binding.empty.imgEmpty.setImageResource(R.drawable.ic_apps);
        binding.empty.txtEmptyTitle.setText(teachTab
                ? "Aún no enseñas nada" : "Aún no buscas nada");
        binding.empty.txtEmptyDesc.setText(teachTab
                ? "Agrega las habilidades que puedes compartir con otros estudiantes."
                : "Agrega lo que quieres aprender para que SkillSwap te encuentre match.");
    }

    private void openSheet(UserSkill skill) {
        if (current == null) {
            toast(binding.getRoot(), "Tu perfil aún se está cargando");
            return;
        }
        String type = teachTab ? UserSkill.TYPE_TEACH : UserSkill.TYPE_LEARN;
        AddSkillSheet sheet = AddSkillSheet.newInstance(type, skill);
        sheet.setListener(new AddSkillSheet.OnSkillSaved() {
            @Override
            public void onSaved(UserSkill result, boolean editing) {
                if (current == null) return;
                int limit = Constants.MAX_SKILLS_PER_TYPE;
                boolean isTeach = UserSkill.TYPE_TEACH.equals(result.getType());
                int size = isTeach ? current.getTeachSkills().size() : current.getLearnSkills().size();
                if (!editing && size >= limit) {
                    toast(binding.getRoot(), "Máximo " + limit + " habilidades por lista");
                    return;
                }
                if (editing) viewModel.updateSkill(current, result);
                else viewModel.addSkill(current, result);
            }
        });
        sheet.show(getSupportFragmentManager(), "addSkill");
    }
}
EOF

# ============================================================ AddSkillSheet
cat > "$J/view/skills/AddSkillSheet.java" <<'EOF'
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
EOF

# ============================================================ SkillCatalogActivity
cat > "$J/view/skills/SkillCatalogActivity.java" <<'EOF'
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
EOF

# ============================================================ MatchDetailActivity
cat > "$J/view/matches/MatchDetailActivity.java" <<'EOF'
package com.skillswap.view.matches;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityMatchDetailBinding;
import com.skillswap.databinding.ItemMatchReasonBinding;
import com.skillswap.model.MatchReason;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.SkillMatchEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.exchange.SendRequestActivity;
import com.skillswap.viewmodel.ProfileViewModel;

import java.util.Locale;

/**
 * Detalle del SkillMatch: porcentaje y explicacion de por que son compatibles.
 */
public class MatchDetailActivity extends BaseActivity {

    private ActivityMatchDetailBinding binding;
    private ProfileViewModel viewModel;
    private String userId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMatchDetailBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        userId = getIntent().getStringExtra(Constants.EXTRA_USER_ID);
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, "SkillMatch");

        binding.txtFormula.setText(
                "El porcentaje se calcula con reglas reales sobre 100 puntos:\n\n"
                        + "• " + SkillMatchEngine.W_SKILLS + " pts — coincidencia de habilidades en ambos sentidos\n"
                        + "• " + SkillMatchEngine.W_LEVEL + " pts — nivel de quien enseña\n"
                        + "• " + SkillMatchEngine.W_MODALITY + " pts — modalidad compatible\n"
                        + "• " + SkillMatchEngine.W_AVAILABILITY + " pts — horarios en común\n"
                        + "• " + SkillMatchEngine.W_REPUTATION + " pts — reputación del estudiante\n\n"
                        + "Si no hay habilidades complementarias el resultado es 0 %.");

        binding.btnRequest.setOnClickListener(v -> {
            Intent intent = new Intent(this, SendRequestActivity.class);
            intent.putExtra(Constants.EXTRA_USER_ID, userId);
            startActivity(intent);
        });

        viewModel.profileState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                if (state.isSuccess()) render(state.getData());
                else if (state.isError()) toast(binding.getRoot(), state.getMessage());
            }
        });

        viewModel.loadProfile(userId);
    }

    private void render(User other) {
        if (other == null) return;

        User me = UserRepository.get().currentUserValue();
        MatchResult match = SkillMatchEngine.calculate(me, other);

        binding.txtName.setText(other.getFullName());
        binding.txtScore.setText(String.format(Locale.getDefault(), "%d %%", match.getScore()));
        binding.txtScoreLabel.setText(UiUtils.compatibilityLabel(match.getScore()));
        ImageLoader.avatar(binding.imgAvatar, other.getPhotoUrl());

        binding.containerReasons.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(this);
        for (MatchReason reason : match.getReasons()) {
            ItemMatchReasonBinding row = ItemMatchReasonBinding.inflate(
                    inflater, binding.containerReasons, false);
            row.txtReason.setText(reason.getText());
            row.txtReason.setTextColor(ContextCompat.getColor(this,
                    reason.isPositive() ? R.color.text_primary : R.color.text_secondary));
            row.imgIcon.setImageResource(reason.isPositive()
                    ? R.drawable.ic_check : R.drawable.ic_info);
            row.imgIcon.setImageTintList(android.content.res.ColorStateList.valueOf(
                    ContextCompat.getColor(this,
                            reason.isPositive() ? R.color.state_accepted : R.color.state_pending)));
            binding.containerReasons.addView(row.getRoot());
        }

        binding.btnRequest.setEnabled(match.getScore() > 0);
    }
}
EOF

echo "Vistas 4 (habilidades/match) generadas."
