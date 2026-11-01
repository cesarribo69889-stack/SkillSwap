#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ EXPLORAR
cat > "$L/fragment_explore.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <TextView
        android:id="@+id/txtTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="20dp"
        android:layout_marginTop="20dp"
        android:text="@string/explore_title"
        android:textAppearance="@style/TextAppearance.SkillSwap.Title"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <TextView
        android:id="@+id/txtCount"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="20dp"
        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtTitle" />

    <com.google.android.material.textfield.TextInputLayout
        android:id="@+id/tilSearch"
        style="@style/Widget.SkillSwap.TextInput"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:layout_marginTop="14dp"
        android:hint="@string/search"
        app:layout_constraintEnd_toStartOf="@id/btnFilters"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtCount"
        app:startIconDrawable="@drawable/ic_search">

        <com.google.android.material.textfield.TextInputEditText
            android:id="@+id/edtSearch"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:imeOptions="actionSearch"
            android:inputType="text"
            android:maxLines="1" />
    </com.google.android.material.textfield.TextInputLayout>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnFilters"
        style="@style/Widget.Material3.Button.IconButton.Filled"
        android:layout_width="56dp"
        android:layout_height="56dp"
        android:layout_marginStart="8dp"
        android:layout_marginEnd="16dp"
        android:contentDescription="@string/filters"
        app:cornerRadius="16dp"
        app:icon="@drawable/ic_tune"
        app:iconGravity="textStart"
        app:iconPadding="0dp"
        app:layout_constraintBottom_toBottomOf="@id/tilSearch"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="@id/tilSearch" />

    <HorizontalScrollView
        android:id="@+id/scrollChips"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:paddingStart="16dp"
        android:paddingEnd="16dp"
        android:scrollbars="none"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/tilSearch">

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipGroupActive"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            app:singleLine="true" />
    </HorizontalScrollView>

    <androidx.swiperefreshlayout.widget.SwipeRefreshLayout
        android:id="@+id/swipeRefresh"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/scrollChips">

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvUsers"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:clipToPadding="false"
            android:paddingStart="16dp"
            android:paddingTop="8dp"
            android:paddingEnd="16dp"
            android:paddingBottom="16dp"
            app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
    </androidx.swiperefreshlayout.widget.SwipeRefreshLayout>

    <include
        android:id="@+id/empty"
        layout="@layout/layout_empty_state"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/scrollChips" />

    <com.google.android.material.progressindicator.CircularProgressIndicator
        android:id="@+id/progress"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:indeterminate="true"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/scrollChips" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_match_card.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"
    app:cardCornerRadius="24dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        android:padding="16dp">

        <!-- Cabecera -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal">

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="58dp"
                android:layout_height="58dp"
                android:src="@drawable/ic_avatar_placeholder"
                app:civ_border_color="@color/brand_primary_container"
                app:civ_border_width="2dp" />

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
                    android:textSize="16sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/txtCareer"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                    android:textSize="13sp" />

                <LinearLayout
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="4dp"
                    android:gravity="center_vertical"
                    android:orientation="horizontal">

                    <ImageView
                        android:layout_width="14dp"
                        android:layout_height="14dp"
                        android:contentDescription="@null"
                        android:src="@drawable/ic_star"
                        app:tint="@color/star_gold" />

                    <TextView
                        android:id="@+id/txtRating"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="4dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                        android:textStyle="bold" />

                    <TextView
                        android:id="@+id/txtExchanges"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="10dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                </LinearLayout>
            </LinearLayout>

            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:gravity="center"
                android:orientation="vertical">

                <TextView
                    android:id="@+id/txtScore"
                    android:layout_width="52dp"
                    android:layout_height="52dp"
                    android:background="@drawable/bg_circle_light"
                    android:gravity="center"
                    android:text="95%"
                    android:textColor="@color/brand_primary"
                    android:textSize="15sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/txtScoreLabel"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="2dp"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="9sp" />
            </LinearLayout>
        </LinearLayout>

        <!-- Intercambio propuesto -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="14dp"
            android:background="@drawable/bg_rounded_soft"
            android:orientation="horizontal"
            android:padding="12dp">

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/profile_teaches"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtTeaches"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="@color/brand_secondary_dark"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>

            <ImageView
                android:layout_width="22dp"
                android:layout_height="22dp"
                android:layout_gravity="center_vertical"
                android:layout_marginStart="6dp"
                android:layout_marginEnd="6dp"
                android:contentDescription="@null"
                android:src="@drawable/ic_swap"
                app:tint="@color/text_tertiary" />

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="@string/profile_learns"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtLearns"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="@color/brand_primary"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>
        </LinearLayout>

        <com.google.android.material.chip.ChipGroup
            android:id="@+id/chipsSkills"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            app:chipSpacingVertical="2dp" />

        <!-- Acciones -->
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:orientation="horizontal">

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnProfile"
                style="@style/Widget.SkillSwap.Button.Small.Outlined"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="@string/view_profile" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnExchange"
                style="@style/Widget.SkillSwap.Button.Small"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="10dp"
                android:layout_weight="1"
                android:text="@string/do_exchange" />
        </LinearLayout>
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ INTERCAMBIOS
cat > "$L/fragment_exchanges.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <TextView
        android:id="@+id/txtTitle"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="20dp"
        android:layout_marginTop="20dp"
        android:text="@string/my_exchanges"
        android:textAppearance="@style/TextAppearance.SkillSwap.Title"
        app:layout_constraintEnd_toStartOf="@id/btnRequests"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnRequests"
        style="@style/Widget.SkillSwap.Button.Small.Outlined"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginEnd="16dp"
        android:text="Solicitudes"
        app:icon="@drawable/ic_inbox"
        app:iconSize="16dp"
        app:layout_constraintBottom_toBottomOf="@id/txtTitle"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="@id/txtTitle" />

    <com.google.android.material.tabs.TabLayout
        android:id="@+id/tabs"
        style="@style/Widget.SkillSwap.TabLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="10dp"
        app:layout_constraintTop_toBottomOf="@id/txtTitle"
        app:tabMode="fixed">

        <com.google.android.material.tabs.TabItem
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/tab_upcoming" />

        <com.google.android.material.tabs.TabItem
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/tab_in_progress" />

        <com.google.android.material.tabs.TabItem
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/tab_completed" />
    </com.google.android.material.tabs.TabLayout>

    <androidx.swiperefreshlayout.widget.SwipeRefreshLayout
        android:id="@+id/swipeRefresh"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/tabs">

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvExchanges"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:clipToPadding="false"
            android:paddingStart="16dp"
            android:paddingTop="12dp"
            android:paddingEnd="16dp"
            android:paddingBottom="16dp"
            app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
    </androidx.swiperefreshlayout.widget.SwipeRefreshLayout>

    <include
        android:id="@+id/empty"
        layout="@layout/layout_empty_state"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/tabs" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_exchange.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"
    app:cardCornerRadius="22dp"
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

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="46dp"
                android:layout_height="46dp"
                android:src="@drawable/ic_avatar_placeholder" />

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
                    android:id="@+id/txtModality"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
            </LinearLayout>

            <TextView
                android:id="@+id/txtStatus"
                style="@style/SkillSwap.StatePill"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="14dp"
            android:background="@drawable/bg_rounded_soft"
            android:orientation="horizontal"
            android:padding="12dp">

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Tú enseñas"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtITeach"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="@color/brand_secondary_dark"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>

            <ImageView
                android:layout_width="20dp"
                android:layout_height="20dp"
                android:layout_gravity="center_vertical"
                android:contentDescription="@null"
                android:src="@drawable/ic_swap"
                app:tint="@color/text_tertiary" />

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="8dp"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Tú aprendes"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtILearn"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="@color/brand_primary"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>
        </LinearLayout>

        <com.google.android.material.progressindicator.LinearProgressIndicator
            android:id="@+id/progressBar"
            style="@style/Widget.SkillSwap.Progress"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            app:trackColor="@color/divider" />

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:orientation="horizontal">

            <TextView
                android:id="@+id/txtProgress"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <TextView
                android:id="@+id/txtDate"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:orientation="horizontal">

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnChat"
                style="@style/Widget.SkillSwap.Button.Small.Outlined"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="Chat"
                app:icon="@drawable/ic_chat"
                app:iconSize="16dp" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnDetail"
                style="@style/Widget.SkillSwap.Button.Small"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="10dp"
                android:layout_weight="1"
                android:text="Ver detalle" />
        </LinearLayout>
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ CHATS
cat > "$L/fragment_chats.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <TextView
        android:id="@+id/txtTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="20dp"
        android:layout_marginTop="20dp"
        android:text="@string/nav_chats"
        android:textAppearance="@style/TextAppearance.SkillSwap.Title"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <TextView
        android:id="@+id/txtSubtitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="20dp"
        android:text="El chat se habilita con cada intercambio aceptado"
        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtTitle" />

    <androidx.swiperefreshlayout.widget.SwipeRefreshLayout
        android:id="@+id/swipeRefresh"
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:layout_marginTop="12dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtSubtitle">

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvChats"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:clipToPadding="false"
            android:paddingStart="12dp"
            android:paddingEnd="12dp"
            android:paddingBottom="16dp"
            app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
    </androidx.swiperefreshlayout.widget.SwipeRefreshLayout>

    <include
        android:id="@+id/empty"
        layout="@layout/layout_empty_state"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtSubtitle" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_chat.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginTop="8dp"
    app:cardCornerRadius="20dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:padding="14dp">

        <de.hdodenhof.circleimageview.CircleImageView
            android:id="@+id/imgAvatar"
            android:layout_width="52dp"
            android:layout_height="52dp"
            android:src="@drawable/ic_avatar_placeholder" />

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
                android:id="@+id/txtLastMessage"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="2dp"
                android:ellipsize="end"
                android:maxLines="1"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:textSize="13sp" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:gravity="end"
            android:orientation="vertical">

            <TextView
                android:id="@+id/txtTime"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                android:textSize="11sp" />

            <TextView
                android:id="@+id/txtUnread"
                android:layout_width="22dp"
                android:layout_height="22dp"
                android:layout_marginTop="6dp"
                android:background="@drawable/bg_circle_primary"
                android:gravity="center"
                android:textColor="@color/white"
                android:textSize="11sp"
                android:textStyle="bold"
                android:visibility="gone" />
        </LinearLayout>
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

echo "Layouts C (explorar/intercambios/chats) generados."
