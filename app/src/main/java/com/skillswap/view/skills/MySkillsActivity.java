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
