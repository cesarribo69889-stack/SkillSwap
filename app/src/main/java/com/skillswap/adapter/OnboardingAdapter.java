package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemOnboardingBinding;

/** Paginas del onboarding. */
public class OnboardingAdapter extends RecyclerView.Adapter<OnboardingAdapter.VH> {

    private static final int[] ICONS = {
            R.drawable.ic_swap, R.drawable.ic_target, R.drawable.ic_trophy
    };
    private static final int[] TITLES = {
            R.string.ob1_title, R.string.ob2_title, R.string.ob3_title
    };
    private static final int[] DESCS = {
            R.string.ob1_desc, R.string.ob2_desc, R.string.ob3_desc
    };

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemOnboardingBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        holder.binding.imgIcon.setImageResource(ICONS[position]);
        holder.binding.txtTitle.setText(TITLES[position]);
        holder.binding.txtDesc.setText(DESCS[position]);
    }

    @Override
    public int getItemCount() {
        return ICONS.length;
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemOnboardingBinding binding;

        VH(ItemOnboardingBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
    }
}
