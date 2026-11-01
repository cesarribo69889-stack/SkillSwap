package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;

import com.skillswap.R;
import com.skillswap.adapter.OnboardingAdapter;
import com.skillswap.databinding.ActivityOnboardingBinding;
import com.skillswap.utils.PrefsManager;
import com.skillswap.utils.UiUtils;

/** Onboarding de 3 pantallas. */
public class OnboardingActivity extends AppCompatActivity {

    private ActivityOnboardingBinding binding;
    private OnboardingAdapter adapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityOnboardingBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        adapter = new OnboardingAdapter();
        binding.pager.setAdapter(adapter);

        buildDots();
        selectDot(0);

        binding.pager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                selectDot(position);
                binding.btnNext.setText(position == adapter.getItemCount() - 1
                        ? R.string.start : R.string.continue_label);
            }
        });

        binding.btnNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int current = binding.pager.getCurrentItem();
                if (current < adapter.getItemCount() - 1) {
                    binding.pager.setCurrentItem(current + 1, true);
                } else {
                    finishOnboarding();
                }
            }
        });

        binding.btnSkip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finishOnboarding();
            }
        });
    }

    private void buildDots() {
        binding.dots.removeAllViews();
        for (int i = 0; i < adapter.getItemCount(); i++) {
            View dot = new View(this);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                    UiUtils.dp(this, 8), UiUtils.dp(this, 8));
            params.setMarginEnd(UiUtils.dp(this, 6));
            dot.setLayoutParams(params);
            dot.setBackgroundResource(R.drawable.bg_dot_default);
            binding.dots.addView(dot);
        }
    }

    private void selectDot(int index) {
        for (int i = 0; i < binding.dots.getChildCount(); i++) {
            View dot = binding.dots.getChildAt(i);
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) dot.getLayoutParams();
            params.width = UiUtils.dp(this, i == index ? 24 : 8);
            dot.setLayoutParams(params);
            dot.setBackgroundResource(i == index
                    ? R.drawable.bg_dot_selected : R.drawable.bg_dot_default);
        }
    }

    private void finishOnboarding() {
        PrefsManager.get(this).setOnboardingDone(true);
        startActivity(new Intent(this, LoginActivity.class));
        finish();
    }
}
