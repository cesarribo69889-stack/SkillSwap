#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ PERFIL PROPIO
cat > "$L/fragment_profile.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.core.widget.NestedScrollView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground"
    android:clipToPadding="false"
    android:paddingBottom="24dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical">

        <!-- Cabecera -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="@drawable/bg_header_curve"
            android:gravity="center_horizontal"
            android:orientation="vertical"
            android:paddingTop="28dp"
            android:paddingBottom="46dp">

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="104dp"
                android:layout_height="104dp"
                android:src="@drawable/ic_avatar_placeholder"
                app:civ_border_color="#66FFFFFF"
                app:civ_border_width="3dp" />

            <TextView
                android:id="@+id/txtName"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:gravity="center"
                android:textColor="@color/white"
                android:textSize="21sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/txtAcademic"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:alpha="0.9"
                android:gravity="center"
                android:textColor="@color/white"
                android:textSize="13sp" />

            <TextView
                android:id="@+id/txtUniversity"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:alpha="0.8"
                android:gravity="center"
                android:textColor="@color/white"
                android:textSize="12sp" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnEditProfile"
                style="@style/Widget.SkillSwap.Button.Small"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:backgroundTint="@color/white"
                android:text="@string/profile_edit"
                android:textColor="@color/brand_primary"
                app:icon="@drawable/ic_edit"
                app:iconSize="16dp"
                app:iconTint="@color/brand_primary" />
        </LinearLayout>

        <!-- Estadisticas -->
        <com.google.android.material.card.MaterialCardView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:layout_marginTop="-32dp"
            android:layout_marginEnd="16dp"
            app:cardCornerRadius="22dp"
            app:cardElevation="6dp"
            app:strokeWidth="0dp">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:paddingTop="16dp"
                android:paddingBottom="16dp">

                <LinearLayout
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:gravity="center"
                    android:orientation="vertical">

                    <TextView
                        android:id="@+id/txtReputation"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="0.0"
                        android:textColor="@color/star_gold"
                        android:textSize="19sp"
                        android:textStyle="bold" />

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Reputación"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                </LinearLayout>

                <View
                    android:layout_width="1dp"
                    android:layout_height="match_parent"
                    android:background="@color/divider" />

                <LinearLayout
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:gravity="center"
                    android:orientation="vertical">

                    <TextView
                        android:id="@+id/txtExchanges"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="0"
                        android:textColor="@color/brand_primary"
                        android:textSize="19sp"
                        android:textStyle="bold" />

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Intercambios"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                </LinearLayout>

                <View
                    android:layout_width="1dp"
                    android:layout_height="match_parent"
                    android:background="@color/divider" />

                <LinearLayout
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:gravity="center"
                    android:orientation="vertical">

                    <TextView
                        android:id="@+id/txtPoints"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="0"
                        android:textColor="@color/brand_secondary_dark"
                        android:textSize="19sp"
                        android:textStyle="bold" />

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="SkillPoints"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                </LinearLayout>
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>

        <!-- Descripcion -->
        <com.google.android.material.card.MaterialCardView
            android:id="@+id/cardAbout"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:layout_marginTop="14dp"
            android:layout_marginEnd="16dp"
            app:cardCornerRadius="20dp"
            app:cardElevation="0dp"
            app:strokeWidth="1dp">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="16dp">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Sobre mí"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                <TextView
                    android:id="@+id/txtDescription"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="6dp"
                    android:lineSpacingExtra="3dp"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:gravity="center_vertical"
                    android:orientation="horizontal">

                    <ImageView
                        android:layout_width="18dp"
                        android:layout_height="18dp"
                        android:contentDescription="@null"
                        android:src="@drawable/ic_video"
                        app:tint="@color/brand_primary" />

                    <TextView
                        android:id="@+id/txtModality"
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="8dp"
                        android:layout_weight="1"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />
                </LinearLayout>

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="8dp"
                    android:orientation="horizontal">

                    <ImageView
                        android:layout_width="18dp"
                        android:layout_height="18dp"
                        android:contentDescription="@null"
                        android:src="@drawable/ic_clock"
                        app:tint="@color/brand_primary" />

                    <TextView
                        android:id="@+id/txtAvailability"
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="8dp"
                        android:layout_weight="1"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />
                </LinearLayout>
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>

        <!-- Habilidades -->
        <com.google.android.material.card.MaterialCardView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:layout_marginTop="14dp"
            android:layout_marginEnd="16dp"
            app:cardCornerRadius="20dp"
            app:cardElevation="0dp"
            app:strokeWidth="1dp">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="16dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:gravity="center_vertical"
                    android:orientation="horizontal">

                    <TextView
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_weight="1"
                        android:text="@string/my_skills"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                    <com.google.android.material.button.MaterialButton
                        android:id="@+id/btnManageSkills"
                        style="@style/Widget.SkillSwap.Button.Text"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Gestionar"
                        android:textSize="13sp" />
                </LinearLayout>

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="6dp"
                    android:text="@string/profile_teaches"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

                <com.google.android.material.chip.ChipGroup
                    android:id="@+id/chipsTeach"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="4dp" />

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:text="@string/profile_learns"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

                <com.google.android.material.chip.ChipGroup
                    android:id="@+id/chipsLearn"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="4dp" />
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>

        <!-- Menu -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:layout_marginTop="14dp"
            android:layout_marginEnd="16dp"
            android:orientation="vertical">

            <include android:id="@+id/rowPassport" layout="@layout/item_profile_row" />
            <include android:id="@+id/rowPoints" layout="@layout/item_profile_row" />
            <include android:id="@+id/rowChallenges" layout="@layout/item_profile_row" />
            <include android:id="@+id/rowHistory" layout="@layout/item_profile_row" />
            <include android:id="@+id/rowRequests" layout="@layout/item_profile_row" />
            <include android:id="@+id/rowNotifications" layout="@layout/item_profile_row" />
        </LinearLayout>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnLogout"
            style="@style/Widget.SkillSwap.Button.Outlined"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="16dp"
            android:layout_marginTop="18dp"
            android:layout_marginEnd="16dp"
            android:text="@string/logout"
            android:textColor="@color/state_rejected"
            app:icon="@drawable/ic_logout"
            app:iconTint="@color/state_rejected"
            app:strokeColor="@color/state_rejected" />

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="20dp"
            android:layout_marginTop="18dp"
            android:layout_marginEnd="20dp"
            android:gravity="center"
            android:text="@string/skillpoints_disclaimer"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
            android:textSize="10sp" />
    </LinearLayout>
</androidx.core.widget.NestedScrollView>
EOF

cat > "$L/item_profile_row.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/rowRoot"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="8dp"
    android:clickable="true"
    android:focusable="true"
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
            android:layout_width="38dp"
            android:layout_height="38dp"
            android:background="@drawable/bg_circle_light">

            <ImageView
                android:id="@+id/rowIcon"
                android:layout_width="20dp"
                android:layout_height="20dp"
                android:layout_gravity="center"
                android:contentDescription="@null"
                android:src="@drawable/ic_passport"
                app:tint="@color/brand_primary" />
        </FrameLayout>

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="12dp"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/rowTitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textColor="?attr/colorOnSurface"
                android:textSize="14sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/rowSubtitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>

        <TextView
            android:id="@+id/rowBadge"
            style="@style/SkillSwap.StatePill"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginEnd="6dp"
            android:visibility="gone" />

        <ImageView
            android:layout_width="20dp"
            android:layout_height="20dp"
            android:contentDescription="@null"
            android:src="@drawable/ic_chevron_right"
            app:tint="@color/text_tertiary" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ PERFIL DE OTRO ESTUDIANTE
cat > "$L/activity_user_profile.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <androidx.core.widget.NestedScrollView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:clipToPadding="false"
        android:paddingBottom="90dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical">

            <RelativeLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:background="@drawable/bg_header_curve"
                android:paddingBottom="46dp">

                <ImageButton
                    android:id="@+id/btnBack"
                    android:layout_width="44dp"
                    android:layout_height="44dp"
                    android:layout_margin="8dp"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:contentDescription="@string/back"
                    android:src="@drawable/ic_arrow_back"
                    app:tint="@color/white" />

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_below="@id/btnBack"
                    android:gravity="center_horizontal"
                    android:orientation="vertical">

                    <de.hdodenhof.circleimageview.CircleImageView
                        android:id="@+id/imgAvatar"
                        android:layout_width="104dp"
                        android:layout_height="104dp"
                        android:src="@drawable/ic_avatar_placeholder"
                        app:civ_border_color="#66FFFFFF"
                        app:civ_border_width="3dp" />

                    <TextView
                        android:id="@+id/txtName"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="12dp"
                        android:gravity="center"
                        android:textColor="@color/white"
                        android:textSize="21sp"
                        android:textStyle="bold" />

                    <TextView
                        android:id="@+id/txtAcademic"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:alpha="0.9"
                        android:gravity="center"
                        android:textColor="@color/white"
                        android:textSize="13sp" />

                    <TextView
                        android:id="@+id/txtUniversity"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:alpha="0.8"
                        android:gravity="center"
                        android:textColor="@color/white"
                        android:textSize="12sp" />
                </LinearLayout>
            </RelativeLayout>

            <!-- Compatibilidad -->
            <com.google.android.material.card.MaterialCardView
                android:id="@+id/cardMatch"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="16dp"
                android:layout_marginTop="-34dp"
                android:layout_marginEnd="16dp"
                app:cardBackgroundColor="@color/transparent"
                app:cardCornerRadius="22dp"
                app:cardElevation="6dp"
                app:strokeWidth="0dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:background="@drawable/bg_gradient_match"
                    android:orientation="vertical"
                    android:padding="18dp">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:gravity="center_vertical"
                        android:orientation="horizontal">

                        <TextView
                            android:id="@+id/txtScore"
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:text="0 % compatible"
                            android:textColor="@color/white"
                            android:textSize="22sp"
                            android:textStyle="bold" />

                        <ImageView
                            android:layout_width="30dp"
                            android:layout_height="30dp"
                            android:contentDescription="@null"
                            android:src="@drawable/ic_target"
                            app:tint="@color/white" />
                    </LinearLayout>

                    <TextView
                        android:id="@+id/txtScoreLabel"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:alpha="0.9"
                        android:textColor="@color/white"
                        android:textSize="13sp" />

                    <LinearLayout
                        android:id="@+id/containerReasons"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="12dp"
                        android:orientation="vertical" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Estadisticas -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="16dp"
                android:layout_marginTop="14dp"
                android:layout_marginEnd="16dp"
                android:orientation="horizontal">

                <com.google.android.material.card.MaterialCardView
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    app:cardCornerRadius="18dp"
                    app:cardElevation="0dp"
                    app:strokeWidth="1dp">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:gravity="center"
                        android:orientation="vertical"
                        android:padding="14dp">

                        <TextView
                            android:id="@+id/txtReputation"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:textColor="@color/star_gold"
                            android:textSize="18sp"
                            android:textStyle="bold" />

                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Reputación"
                            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                    </LinearLayout>
                </com.google.android.material.card.MaterialCardView>

                <com.google.android.material.card.MaterialCardView
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="10dp"
                    android:layout_weight="1"
                    app:cardCornerRadius="18dp"
                    app:cardElevation="0dp"
                    app:strokeWidth="1dp">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:gravity="center"
                        android:orientation="vertical"
                        android:padding="14dp">

                        <TextView
                            android:id="@+id/txtExchanges"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:textColor="@color/brand_primary"
                            android:textSize="18sp"
                            android:textStyle="bold" />

                        <TextView
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Intercambios"
                            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                    </LinearLayout>
                </com.google.android.material.card.MaterialCardView>
            </LinearLayout>

            <!-- Sobre -->
            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="16dp"
                android:layout_marginTop="14dp"
                android:layout_marginEnd="16dp"
                app:cardCornerRadius="20dp"
                app:cardElevation="0dp"
                app:strokeWidth="1dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:padding="16dp">

                    <TextView
                        android:id="@+id/txtDescription"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:lineSpacingExtra="3dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

                    <TextView
                        android:id="@+id/txtModality"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="10dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                        app:drawableStartCompat="@drawable/ic_video" />

                    <TextView
                        android:id="@+id/txtAvailability"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="8dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                        app:drawableStartCompat="@drawable/ic_clock" />

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="14dp"
                        android:text="@string/profile_teaches"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

                    <com.google.android.material.chip.ChipGroup
                        android:id="@+id/chipsTeach"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content" />

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="10dp"
                        android:text="@string/profile_learns"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

                    <com.google.android.material.chip.ChipGroup
                        android:id="@+id/chipsLearn"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Calificaciones -->
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginTop="20dp"
                android:text="Calificaciones recibidas"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvRatings"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:nestedScrollingEnabled="false"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <TextView
                android:id="@+id/txtNoRatings"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginEnd="20dp"
                android:text="Todavía no tiene calificaciones."
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:visibility="gone" />
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnRequest"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:layout_margin="16dp"
        android:text="@string/send_request"
        app:icon="@drawable/ic_swap" />
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

echo "Layouts D (perfil) generados."
