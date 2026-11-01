#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ EDITAR PERFIL
cat > "$L/activity_edit_profile.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <include
        android:id="@+id/toolbarInc"
        layout="@layout/layout_toolbar"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:layout_constraintTop_toTopOf="parent" />

    <androidx.core.widget.NestedScrollView
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:clipToPadding="false"
        android:paddingBottom="24dp"
        app:layout_constraintBottom_toTopOf="@id/btnSave"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp">

            <FrameLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_gravity="center_horizontal"
                android:layout_marginTop="4dp">

                <de.hdodenhof.circleimageview.CircleImageView
                    android:id="@+id/imgAvatar"
                    android:layout_width="112dp"
                    android:layout_height="112dp"
                    android:src="@drawable/ic_avatar_placeholder"
                    app:civ_border_color="@color/brand_primary_container"
                    app:civ_border_width="3dp" />

                <com.google.android.material.floatingactionbutton.FloatingActionButton
                    android:id="@+id/fabPhoto"
                    android:layout_width="40dp"
                    android:layout_height="40dp"
                    android:layout_gravity="bottom|end"
                    android:contentDescription="@string/edit"
                    app:fabCustomSize="40dp"
                    app:maxImageSize="20dp"
                    app:srcCompat="@drawable/ic_camera" />
            </FrameLayout>

            <com.google.android.material.progressindicator.LinearProgressIndicator
                android:id="@+id/progressPhoto"
                style="@style/Widget.SkillSwap.Progress"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:indeterminate="true"
                android:visibility="gone" />

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilFirstName"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:hint="@string/hint_names">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtFirstName"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textPersonName|textCapWords" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilLastName"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="@string/hint_lastnames">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtLastName"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textPersonName|textCapWords" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilUniversity"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="@string/hint_university"
                app:startIconDrawable="@drawable/ic_school">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtUniversity"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textCapWords" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilCareer"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="@string/hint_career">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtCareer"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textCapWords" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilCycle"
                style="@style/Widget.Material3.TextInputLayout.OutlinedBox.ExposedDropdownMenu"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="@string/hint_cycle">

                <com.google.android.material.textfield.MaterialAutoCompleteTextView
                    android:id="@+id/edtCycle"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="none" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilDescription"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="@string/hint_description"
                app:counterEnabled="true"
                app:counterMaxLength="280">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtDescription"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:gravity="top"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="280"
                    android:minLines="3" />
            </com.google.android.material.textfield.TextInputLayout>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:text="@string/modality"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsModality"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                app:singleSelection="true">

                <com.google.android.material.chip.Chip
                    android:id="@+id/chipPresencial"
                    style="@style/Widget.SkillSwap.Chip.Choice"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/modality_presencial" />

                <com.google.android.material.chip.Chip
                    android:id="@+id/chipVirtual"
                    style="@style/Widget.SkillSwap.Chip.Choice"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/modality_virtual" />

                <com.google.android.material.chip.Chip
                    android:id="@+id/chipBoth"
                    style="@style/Widget.SkillSwap.Chip.Choice"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/modality_both" />
            </com.google.android.material.chip.ChipGroup>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:text="@string/hint_availability"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Elige los bloques en los que puedes coordinar sesiones"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsAvailability"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp" />
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnSave"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="@string/save"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ MIS HABILIDADES
cat > "$L/activity_my_skills.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical">

        <include
            android:id="@+id/toolbarInc"
            layout="@layout/layout_toolbar"
            android:layout_width="match_parent"
            android:layout_height="wrap_content" />

        <com.google.android.material.tabs.TabLayout
            android:id="@+id/tabs"
            style="@style/Widget.SkillSwap.TabLayout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            app:tabMode="fixed">

            <com.google.android.material.tabs.TabItem
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Enseño" />

            <com.google.android.material.tabs.TabItem
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Quiero aprender" />
        </com.google.android.material.tabs.TabLayout>

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvSkills"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1"
            android:clipToPadding="false"
            android:paddingStart="16dp"
            android:paddingTop="12dp"
            android:paddingEnd="16dp"
            android:paddingBottom="90dp"
            app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
    </LinearLayout>

    <include
        android:id="@+id/empty"
        layout="@layout/layout_empty_state"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:visibility="gone" />

    <com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton
        android:id="@+id/fabAdd"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|end"
        android:layout_margin="16dp"
        android:text="@string/add_skill"
        app:icon="@drawable/ic_add" />
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

cat > "$L/item_user_skill.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="10dp"
    app:cardCornerRadius="18dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:padding="14dp">

        <FrameLayout
            android:id="@+id/iconWrap"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:background="@drawable/bg_circle_light">

            <ImageView
                android:id="@+id/imgIcon"
                android:layout_width="22dp"
                android:layout_height="22dp"
                android:layout_gravity="center"
                android:contentDescription="@null"
                android:src="@drawable/ic_code" />
        </FrameLayout>

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="12dp"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/txtName"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:ellipsize="end"
                android:maxLines="1"
                android:textColor="?attr/colorOnSurface"
                android:textSize="15sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/txtCategory"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>

        <TextView
            android:id="@+id/txtLevel"
            style="@style/SkillSwap.StatePill"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginEnd="4dp" />

        <ImageButton
            android:id="@+id/btnEdit"
            android:layout_width="36dp"
            android:layout_height="36dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:contentDescription="@string/edit"
            android:src="@drawable/ic_edit"
            app:tint="@color/text_secondary" />

        <ImageButton
            android:id="@+id/btnDelete"
            android:layout_width="36dp"
            android:layout_height="36dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:contentDescription="@string/delete"
            android:src="@drawable/ic_delete"
            app:tint="@color/state_rejected" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ CATALOGO DE HABILIDADES
cat > "$L/activity_skill_catalog.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground"
    android:orientation="vertical">

    <include
        android:id="@+id/toolbarInc"
        layout="@layout/layout_toolbar"
        android:layout_width="match_parent"
        android:layout_height="wrap_content" />

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/tilSearch"
        style="@style/Widget.SkillSwap.TextInput"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:layout_marginEnd="16dp"
        android:hint="@string/search"
        app:startIconDrawable="@drawable/ic_search">

        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/edtSearch"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:inputType="text"
            android:maxLines="1" />
    </com.google.android.material.textfield.TextInputLayout>

    <HorizontalScrollView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:paddingStart="16dp"
        android:paddingEnd="16dp"
        android:scrollbars="none">

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipsCategory"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            app:singleLine="true"
            app:singleSelection="true" />
    </HorizontalScrollView>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rvSkills"
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:clipToPadding="false"
        android:paddingStart="16dp"
        android:paddingTop="8dp"
        android:paddingEnd="16dp"
        android:paddingBottom="16dp"
        app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
</LinearLayout>
EOF

cat > "$L/item_skill_catalog.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="8dp"
    android:clickable="true"
    android:focusable="true"
    app:cardCornerRadius="16dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:padding="14dp">

        <FrameLayout
            android:id="@+id/iconWrap"
            android:layout_width="40dp"
            android:layout_height="40dp"
            android:background="@drawable/bg_circle_light">

            <ImageView
                android:id="@+id/imgIcon"
                android:layout_width="20dp"
                android:layout_height="20dp"
                android:layout_gravity="center"
                android:contentDescription="@null"
                android:src="@drawable/ic_code" />
        </FrameLayout>

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="12dp"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/txtName"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textColor="?attr/colorOnSurface"
                android:textSize="15sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/txtCategory"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>

        <ImageView
            android:id="@+id/imgCheck"
            android:layout_width="22dp"
            android:layout_height="22dp"
            android:contentDescription="@null"
            android:src="@drawable/ic_chevron_right"
            app:tint="@color/text_tertiary" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ BOTTOM SHEET: AGREGAR HABILIDAD
cat > "$L/sheet_add_skill.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.core.widget.NestedScrollView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@drawable/bg_sheet_top">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="20dp">

        <View
            android:layout_width="44dp"
            android:layout_height="4dp"
            android:layout_gravity="center_horizontal"
            android:background="@drawable/bg_sheet_handle" />

        <TextView
            android:id="@+id/txtTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="@string/add_skill"
            android:textAppearance="@style/TextAppearance.SkillSwap.Title" />

        <TextView
            android:id="@+id/txtSubtitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

        <com.google.android.material.textfield.TextInputLayout
            android:id="@+id/tilCategory"
            style="@style/Widget.Material3.TextInputLayout.OutlinedBox.ExposedDropdownMenu"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="18dp"
            android:hint="Categoría">

            <com.google.android.material.textfield.MaterialAutoCompleteTextView
                android:id="@+id/edtCategory"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="none" />
        </com.google.android.material.textfield.TextInputLayout>

        <com.google.android.material.textfield.TextInputLayout
            android:id="@+id/tilSkill"
            style="@style/Widget.Material3.TextInputLayout.OutlinedBox.ExposedDropdownMenu"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:hint="Habilidad">

            <com.google.android.material.textfield.MaterialAutoCompleteTextView
                android:id="@+id/edtSkill"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="text" />
        </com.google.android.material.textfield.TextInputLayout>

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="@string/skill_level"
            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipsLevel"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            app:selectionRequired="true"
            app:singleSelection="true">

            <com.google.android.material.chip.Chip
                android:id="@+id/chipBasic"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:checked="true"
                android:text="@string/level_basic" />

            <com.google.android.material.chip.Chip
                android:id="@+id/chipIntermediate"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/level_intermediate" />

            <com.google.android.material.chip.Chip
                android:id="@+id/chipAdvanced"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/level_advanced" />
        </com.google.android.material.chip.ChipGroup>

        <com.google.android.material.textfield.TextInputLayout
            android:id="@+id/tilNote"
            style="@style/Widget.SkillSwap.TextInput"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:hint="Nota (opcional)">

            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/edtNote"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="textMultiLine|textCapSentences"
                android:maxLength="140"
                android:minLines="2" />
        </com.google.android.material.textfield.TextInputLayout>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnSave"
            style="@style/Widget.SkillSwap.Button"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="20dp"
            android:text="@string/save" />
    </LinearLayout>
</androidx.core.widget.NestedScrollView>
EOF

# ============================================================ BOTTOM SHEET: FILTROS
cat > "$L/sheet_filters.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.core.widget.NestedScrollView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:background="@drawable/bg_sheet_top">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="20dp">

        <View
            android:layout_width="44dp"
            android:layout_height="4dp"
            android:layout_gravity="center_horizontal"
            android:background="@drawable/bg_sheet_handle" />

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="@string/filters"
            android:textAppearance="@style/TextAppearance.SkillSwap.Title" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="Categoría"
            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipsCategory"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            app:singleSelection="true" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="Habilidad"
            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

        <com.google.android.material.textfield.TextInputLayout
            android:id="@+id/tilSkill"
            style="@style/Widget.Material3.TextInputLayout.OutlinedBox.ExposedDropdownMenu"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:hint="Todas">

            <com.google.android.material.textfield.MaterialAutoCompleteTextView
                android:id="@+id/edtSkill"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="none" />
        </com.google.android.material.textfield.TextInputLayout>

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="@string/skill_level"
            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipsLevel"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            app:singleSelection="true">

            <com.google.android.material.chip.Chip
                android:id="@+id/chipLvlBasic"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/level_basic" />

            <com.google.android.material.chip.Chip
                android:id="@+id/chipLvlIntermediate"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/level_intermediate" />

            <com.google.android.material.chip.Chip
                android:id="@+id/chipLvlAdvanced"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/level_advanced" />
        </com.google.android.material.chip.ChipGroup>

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="@string/modality"
            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipsModality"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            app:singleSelection="true">

            <com.google.android.material.chip.Chip
                android:id="@+id/chipModPresencial"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/modality_presencial" />

            <com.google.android.material.chip.Chip
                android:id="@+id/chipModVirtual"
                style="@style/Widget.SkillSwap.Chip.Choice"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="@string/modality_virtual" />
        </com.google.android.material.chip.ChipGroup>

        <com.google.android.material.textfield.TextInputLayout
            android:id="@+id/tilUniversity"
            style="@style/Widget.SkillSwap.TextInput"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:hint="@string/hint_university"
            app:startIconDrawable="@drawable/ic_school">

            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/edtUniversity"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="textCapWords"
                android:maxLines="1" />
        </com.google.android.material.textfield.TextInputLayout>

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:text="Compatibilidad mínima"
            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

        <TextView
            android:id="@+id/txtMinValue"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="0 %"
            android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

        <com.google.android.material.slider.Slider
            android:id="@+id/sliderMin"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:stepSize="5"
            android:value="0"
            android:valueFrom="0"
            android:valueTo="95" />

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:orientation="horizontal">

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnClear"
                style="@style/Widget.SkillSwap.Button.Outlined"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="@string/clear" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnApply"
                style="@style/Widget.SkillSwap.Button"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="10dp"
                android:layout_weight="1"
                android:text="@string/apply" />
        </LinearLayout>
    </LinearLayout>
</androidx.core.widget.NestedScrollView>
EOF

echo "Layouts E (perfil/habilidades/sheets) generados."
