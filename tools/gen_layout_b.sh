#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ HOME
cat > "$L/fragment_home.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.swiperefreshlayout.widget.SwipeRefreshLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/swipeRefresh"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <androidx.core.widget.NestedScrollView
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:clipToPadding="false"
        android:paddingBottom="24dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical">

            <!-- ============ Cabecera ============ -->
            <androidx.constraintlayout.widget.ConstraintLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:background="@drawable/bg_header_curve"
                android:paddingStart="20dp"
                android:paddingTop="20dp"
                android:paddingEnd="20dp"
                android:paddingBottom="46dp">

                <de.hdodenhof.circleimageview.CircleImageView
                    android:id="@+id/imgAvatar"
                    android:layout_width="46dp"
                    android:layout_height="46dp"
                    android:src="@drawable/ic_avatar_placeholder"
                    app:civ_border_color="#55FFFFFF"
                    app:civ_border_width="2dp"
                    app:layout_constraintStart_toStartOf="parent"
                    app:layout_constraintTop_toTopOf="parent" />

                <TextView
                    android:id="@+id/txtGreeting"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="12dp"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:text="@string/app_name"
                    android:textColor="@color/white"
                    android:textSize="18sp"
                    android:textStyle="bold"
                    app:layout_constraintEnd_toStartOf="@id/btnNotifications"
                    app:layout_constraintStart_toEndOf="@id/imgAvatar"
                    app:layout_constraintTop_toTopOf="@id/imgAvatar" />

                <TextView
                    android:id="@+id/txtLevel"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="12dp"
                    android:alpha="0.85"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="@color/white"
                    android:textSize="12sp"
                    app:layout_constraintEnd_toStartOf="@id/btnNotifications"
                    app:layout_constraintStart_toEndOf="@id/imgAvatar"
                    app:layout_constraintTop_toBottomOf="@id/txtGreeting" />

                <ImageButton
                    android:id="@+id/btnNotifications"
                    android:layout_width="44dp"
                    android:layout_height="44dp"
                    android:background="?attr/selectableItemBackgroundBorderless"
                    android:contentDescription="@string/notifications"
                    android:src="@drawable/ic_notifications"
                    app:layout_constraintEnd_toEndOf="parent"
                    app:layout_constraintTop_toTopOf="parent"
                    app:tint="@color/white" />

                <TextView
                    android:id="@+id/txtNotifBadge"
                    android:layout_width="18dp"
                    android:layout_height="18dp"
                    android:background="@drawable/bg_badge_dot"
                    android:gravity="center"
                    android:textColor="@color/white"
                    android:textSize="10sp"
                    android:textStyle="bold"
                    android:visibility="gone"
                    app:layout_constraintEnd_toEndOf="@id/btnNotifications"
                    app:layout_constraintTop_toTopOf="@id/btnNotifications" />

                <TextView
                    android:id="@+id/txtQuestion"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="22dp"
                    android:text="@string/home_question"
                    android:textColor="@color/white"
                    android:textSize="24sp"
                    android:textStyle="bold"
                    app:layout_constraintTop_toBottomOf="@id/imgAvatar" />

                <com.google.android.material.card.MaterialCardView
                    android:id="@+id/cardSearch"
                    android:layout_width="match_parent"
                    android:layout_height="52dp"
                    android:layout_marginTop="16dp"
                    app:cardBackgroundColor="@color/white"
                    app:cardCornerRadius="18dp"
                    app:cardElevation="6dp"
                    app:layout_constraintTop_toBottomOf="@id/txtQuestion"
                    app:strokeWidth="0dp">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="match_parent"
                        android:gravity="center_vertical"
                        android:orientation="horizontal"
                        android:paddingStart="16dp"
                        android:paddingEnd="16dp">

                        <ImageView
                            android:layout_width="20dp"
                            android:layout_height="20dp"
                            android:contentDescription="@null"
                            android:src="@drawable/ic_search"
                            app:tint="@color/text_tertiary" />

                        <TextView
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:layout_marginStart="12dp"
                            android:text="Busca una habilidad o estudiante"
                            android:textColor="@color/text_tertiary"
                            android:textSize="14sp" />
                    </LinearLayout>
                </com.google.android.material.card.MaterialCardView>
            </androidx.constraintlayout.widget.ConstraintLayout>

            <!-- ============ Accesos rapidos ============ -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="16dp"
                android:layout_marginTop="-32dp"
                android:layout_marginEnd="16dp"
                android:orientation="horizontal"
                android:weightSum="4">

                <include
                    android:id="@+id/quickPassport"
                    layout="@layout/item_quick_action"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1" />

                <include
                    android:id="@+id/quickPoints"
                    layout="@layout/item_quick_action"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1" />

                <include
                    android:id="@+id/quickChallenges"
                    layout="@layout/item_quick_action"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1" />

                <include
                    android:id="@+id/quickRequests"
                    layout="@layout/item_quick_action"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1" />
            </LinearLayout>

            <!-- ============ Habilidades populares ============ -->
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginTop="24dp"
                android:text="@string/home_popular"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvPopular"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:clipToPadding="false"
                android:orientation="horizontal"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <!-- ============ Matches ============ -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginTop="24dp"
                android:layout_marginEnd="12dp"
                android:gravity="center_vertical"
                android:orientation="horizontal">

                <TextView
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="@string/home_matches"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnAllMatches"
                    style="@style/Widget.SkillSwap.Button.Text"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/see_all"
                    android:textSize="13sp" />
            </LinearLayout>

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvMatches"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:clipToPadding="false"
                android:orientation="horizontal"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <TextView
                android:id="@+id/txtNoMatches"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginEnd="20dp"
                android:text="Agrega habilidades a tu perfil para descubrir estudiantes compatibles."
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:visibility="gone" />

            <!-- ============ Intercambios activos ============ -->
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginTop="24dp"
                android:text="@string/home_active"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvActiveExchanges"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:nestedScrollingEnabled="false"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <TextView
                android:id="@+id/txtNoExchanges"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginEnd="20dp"
                android:text="Todavía no tienes intercambios activos."
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:visibility="gone" />

            <!-- ============ Retos ============ -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginStart="20dp"
                android:layout_marginTop="24dp"
                android:layout_marginEnd="12dp"
                android:gravity="center_vertical"
                android:orientation="horizontal">

                <TextView
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:text="@string/home_challenges"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnAllChallenges"
                    style="@style/Widget.SkillSwap.Button.Text"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/see_all"
                    android:textSize="13sp" />
            </LinearLayout>

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvChallenges"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:clipToPadding="false"
                android:orientation="horizontal"
                android:paddingStart="16dp"
                android:paddingEnd="16dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>
</androidx.swiperefreshlayout.widget.SwipeRefreshLayout>
EOF

cat > "$L/item_quick_action.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/quickCard"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="4dp"
    app:cardBackgroundColor="?attr/colorSurface"
    app:cardCornerRadius="18dp"
    app:cardElevation="4dp"
    app:strokeWidth="0dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center"
        android:orientation="vertical"
        android:paddingTop="14dp"
        android:paddingBottom="12dp">

        <ImageView
            android:id="@+id/quickIcon"
            android:layout_width="26dp"
            android:layout_height="26dp"
            android:contentDescription="@null"
            android:src="@drawable/ic_passport"
            app:tint="@color/brand_primary" />

        <TextView
            android:id="@+id/quickLabel"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:ellipsize="end"
            android:gravity="center"
            android:maxLines="1"
            android:text="@string/passport"
            android:textColor="?attr/colorOnSurface"
            android:textSize="11sp"
            android:textStyle="bold" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/item_popular_skill.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="112dp"
    android:layout_height="wrap_content"
    android:layout_margin="4dp"
    app:cardCornerRadius="20dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center"
        android:orientation="vertical"
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

        <TextView
            android:id="@+id/txtName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:ellipsize="end"
            android:gravity="center"
            android:maxLines="1"
            android:text="Java"
            android:textColor="?attr/colorOnSurface"
            android:textSize="13sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/txtCategory"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:ellipsize="end"
            android:gravity="center"
            android:maxLines="1"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
            android:textSize="10sp" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/item_match_home.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="164dp"
    android:layout_height="wrap_content"
    android:layout_margin="4dp"
    app:cardCornerRadius="22dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_horizontal"
        android:orientation="vertical"
        android:padding="16dp">

        <de.hdodenhof.circleimageview.CircleImageView
            android:id="@+id/imgAvatar"
            android:layout_width="64dp"
            android:layout_height="64dp"
            android:src="@drawable/ic_avatar_placeholder"
            app:civ_border_color="@color/brand_primary_container"
            app:civ_border_width="3dp" />

        <TextView
            android:id="@+id/txtName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:ellipsize="end"
            android:gravity="center"
            android:maxLines="1"
            android:textColor="?attr/colorOnSurface"
            android:textSize="14sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/txtCareer"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:ellipsize="end"
            android:gravity="center"
            android:maxLines="1"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

        <TextView
            android:id="@+id/txtScore"
            style="@style/SkillSwap.StatePill"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:text="95 %"
            android:textColor="@color/white" />

        <TextView
            android:id="@+id/txtTeaches"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:ellipsize="end"
            android:gravity="center"
            android:maxLines="2"
            android:textAppearance="@style/TextAppearance.SkillSwap.Body"
            android:textSize="12sp" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

echo "Layouts B (home) generados."
