#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ PASAPORTE
cat > "$L/activity_passport.xml" <<'EOF'
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

    <androidx.core.widget.NestedScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:clipToPadding="false"
        android:paddingBottom="24dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="16dp"
            android:paddingEnd="16dp">

            <!-- Resumen -->
            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                app:cardBackgroundColor="@color/transparent"
                app:cardCornerRadius="24dp"
                app:cardElevation="0dp"
                app:strokeWidth="0dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:background="@drawable/bg_gradient_hero"
                    android:orientation="vertical"
                    android:padding="20dp">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:gravity="center_vertical"
                        android:orientation="horizontal">

                        <ImageView
                            android:layout_width="30dp"
                            android:layout_height="30dp"
                            android:contentDescription="@null"
                            android:src="@drawable/ic_passport"
                            app:tint="@color/white" />

                        <TextView
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_marginStart="10dp"
                            android:layout_weight="1"
                            android:text="@string/passport"
                            android:textColor="@color/white"
                            android:textSize="18sp"
                            android:textStyle="bold" />
                    </LinearLayout>

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="16dp"
                        android:orientation="horizontal">

                        <LinearLayout
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:orientation="vertical">

                            <TextView
                                android:id="@+id/txtTaughtCount"
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:text="0"
                                android:textColor="@color/white"
                                android:textSize="22sp"
                                android:textStyle="bold" />

                            <TextView
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:alpha="0.85"
                                android:text="Enseñadas"
                                android:textColor="@color/white"
                                android:textSize="11sp" />
                        </LinearLayout>

                        <LinearLayout
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:orientation="vertical">

                            <TextView
                                android:id="@+id/txtLearnedCount"
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:text="0"
                                android:textColor="@color/white"
                                android:textSize="22sp"
                                android:textStyle="bold" />

                            <TextView
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:alpha="0.85"
                                android:text="Aprendidas"
                                android:textColor="@color/white"
                                android:textSize="11sp" />
                        </LinearLayout>

                        <LinearLayout
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:orientation="vertical">

                            <TextView
                                android:id="@+id/txtExchangesCount"
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:text="0"
                                android:textColor="@color/white"
                                android:textSize="22sp"
                                android:textStyle="bold" />

                            <TextView
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:alpha="0.85"
                                android:text="Intercambios"
                                android:textColor="@color/white"
                                android:textSize="11sp" />
                        </LinearLayout>
                    </LinearLayout>
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Insignias -->
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="Insignias"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvBadges"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:clipToPadding="false"
                android:nestedScrollingEnabled="false"
                android:orientation="horizontal"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <!-- Habilidades -->
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="Mis habilidades registradas"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvPassport"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:nestedScrollingEnabled="false"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <TextView
                android:id="@+id/txtEmpty"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:text="Tu pasaporte se llenará cuando completes intercambios."
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:visibility="gone" />

            <!-- Evidencias -->
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="@string/learning_evidence"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvEvidence"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:nestedScrollingEnabled="false"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:background="@drawable/bg_rounded_soft"
                android:padding="14dp"
                android:text="@string/passport_disclaimer"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>
</LinearLayout>
EOF

cat > "$L/item_passport.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="10dp"
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
                    android:id="@+id/txtSkill"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textColor="?attr/colorOnSurface"
                    android:textSize="16sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/txtRole"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
            </LinearLayout>

            <TextView
                android:id="@+id/txtLevel"
                style="@style/SkillSwap.StatePill"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:orientation="horizontal">

            <TextView
                android:id="@+id/txtExchanges"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:textSize="13sp" />

            <TextView
                android:id="@+id/txtRating"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:drawablePadding="4dp"
                android:textColor="@color/star_gold"
                android:textSize="13sp"
                android:textStyle="bold"
                app:drawableStartCompat="@drawable/ic_star" />
        </LinearLayout>

        <com.google.android.material.progressindicator.LinearProgressIndicator
            android:id="@+id/progressBar"
            style="@style/Widget.SkillSwap.Progress"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            app:trackColor="@color/divider" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/item_badge.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="92dp"
    android:layout_height="wrap_content"
    android:gravity="center"
    android:orientation="vertical"
    android:paddingTop="6dp"
    android:paddingEnd="8dp"
    android:paddingBottom="6dp">

    <FrameLayout
        android:id="@+id/iconWrap"
        android:layout_width="62dp"
        android:layout_height="62dp"
        android:background="@drawable/bg_circle_light">

        <ImageView
            android:id="@+id/imgIcon"
            android:layout_width="28dp"
            android:layout_height="28dp"
            android:layout_gravity="center"
            android:contentDescription="@null"
            android:src="@drawable/ic_trophy" />
    </FrameLayout>

    <TextView
        android:id="@+id/txtName"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="6dp"
        android:ellipsize="end"
        android:gravity="center"
        android:maxLines="2"
        android:textColor="?attr/colorOnSurface"
        android:textSize="11sp"
        android:textStyle="bold" />
</LinearLayout>
EOF

# ============================================================ SKILLPOINTS
cat > "$L/activity_skillpoints.xml" <<'EOF'
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

    <androidx.core.widget.NestedScrollView
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1"
        android:clipToPadding="false"
        android:paddingBottom="24dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="16dp"
            android:paddingEnd="16dp">

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                app:cardBackgroundColor="@color/transparent"
                app:cardCornerRadius="24dp"
                app:cardElevation="0dp"
                app:strokeWidth="0dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:background="@drawable/bg_gradient_orange"
                    android:orientation="vertical"
                    android:padding="20dp">

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:gravity="center_vertical"
                        android:orientation="horizontal">

                        <ImageView
                            android:layout_width="30dp"
                            android:layout_height="30dp"
                            android:contentDescription="@null"
                            android:src="@drawable/ic_points"
                            app:tint="@color/white" />

                        <TextView
                            android:id="@+id/txtPoints"
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_marginStart="10dp"
                            android:layout_weight="1"
                            android:text="0"
                            android:textColor="@color/white"
                            android:textSize="30sp"
                            android:textStyle="bold" />

                        <TextView
                            android:id="@+id/txtLevel"
                            style="@style/SkillSwap.StatePill"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:text="Principiante" />
                    </LinearLayout>

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:alpha="0.9"
                        android:text="SkillPoints acumulados"
                        android:textColor="@color/white"
                        android:textSize="13sp" />

                    <com.google.android.material.progressindicator.LinearProgressIndicator
                        android:id="@+id/progressLevel"
                        style="@style/Widget.SkillSwap.Progress"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="14dp"
                        app:indicatorColor="@color/white"
                        app:trackColor="#55FFFFFF" />

                    <TextView
                        android:id="@+id/txtNextLevel"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="6dp"
                        android:alpha="0.9"
                        android:textColor="@color/white"
                        android:textSize="12sp" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="Niveles"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <LinearLayout
                android:id="@+id/containerLevels"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:orientation="vertical" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="Movimientos recientes"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvHistory"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:nestedScrollingEnabled="false"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:background="@drawable/bg_rounded_soft"
                android:padding="14dp"
                android:text="@string/skillpoints_disclaimer"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>
</LinearLayout>
EOF

cat > "$L/item_point_entry.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:paddingTop="10dp"
    android:paddingBottom="10dp">

    <FrameLayout
        android:layout_width="36dp"
        android:layout_height="36dp"
        android:background="@drawable/bg_circle_yellow">

        <ImageView
            android:layout_width="18dp"
            android:layout_height="18dp"
            android:layout_gravity="center"
            android:contentDescription="@null"
            android:src="@drawable/ic_points"
            app:tint="@color/brand_yellow" />
    </FrameLayout>

    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="12dp"
        android:layout_weight="1"
        android:orientation="vertical">

        <TextView
            android:id="@+id/txtReason"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="?attr/colorOnSurface"
            android:textSize="14sp" />

        <TextView
            android:id="@+id/txtDate"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
    </LinearLayout>

    <TextView
        android:id="@+id/txtPoints"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textColor="@color/state_accepted"
        android:textSize="15sp"
        android:textStyle="bold" />
</LinearLayout>
EOF

cat > "$L/item_level.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="8dp"
    app:cardCornerRadius="16dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:padding="14dp">

        <ImageView
            android:id="@+id/imgIcon"
            android:layout_width="24dp"
            android:layout_height="24dp"
            android:contentDescription="@null"
            android:src="@drawable/ic_trophy"
            app:tint="@color/brand_primary" />

        <TextView
            android:id="@+id/txtLevel"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="12dp"
            android:layout_weight="1"
            android:textColor="?attr/colorOnSurface"
            android:textSize="15sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/txtRange"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/item_evidence.xml" <<'EOF'
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
        android:orientation="vertical"
        android:padding="14dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:gravity="center_vertical"
            android:orientation="horizontal">

            <TextView
                android:id="@+id/txtSkill"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:textColor="?attr/colorOnSurface"
                android:textSize="15sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/txtAchieved"
                style="@style/SkillSwap.StatePill"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content" />
        </LinearLayout>

        <TextView
            android:id="@+id/txtActivity"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

        <ImageView
            android:id="@+id/imgEvidence"
            android:layout_width="match_parent"
            android:layout_height="140dp"
            android:layout_marginTop="10dp"
            android:contentDescription="@null"
            android:scaleType="centerCrop"
            android:visibility="gone" />

        <TextView
            android:id="@+id/txtDate"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

echo "Layouts H (pasaporte/skillpoints) generados."
