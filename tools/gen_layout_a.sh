#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ Splash
cat > "$L/activity_splash.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@drawable/bg_gradient_brand">

    <ImageView
        android:id="@+id/imgLogo"
        android:layout_width="132dp"
        android:layout_height="132dp"
        android:contentDescription="@string/app_name"
        android:src="@drawable/ic_logo"
        app:layout_constraintBottom_toTopOf="@id/txtAppName"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintVertical_chainStyle="packed" />

    <TextView
        android:id="@+id/txtAppName"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="20dp"
        android:letterSpacing="0.04"
        android:text="@string/app_name"
        android:textColor="@color/white"
        android:textSize="34sp"
        android:textStyle="bold"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/imgLogo" />

    <TextView
        android:id="@+id/txtTagline"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="6dp"
        android:alpha="0.85"
        android:text="@string/app_tagline"
        android:textColor="@color/white"
        android:textSize="15sp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtAppName" />

    <com.google.android.material.progressindicator.CircularProgressIndicator
        android:id="@+id/progress"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginBottom="56dp"
        android:indeterminate="true"
        app:indicatorColor="@color/white"
        app:indicatorSize="28dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:trackThickness="3dp" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ Onboarding
cat > "$L/activity_onboarding.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@drawable/bg_gradient_brand">

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnSkip"
        style="@style/Widget.SkillSwap.Button.Text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_margin="8dp"
        android:text="@string/skip"
        android:textColor="@color/white"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <androidx.viewpager2.widget.ViewPager2
        android:id="@+id/pager"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toTopOf="@id/dots"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/btnSkip" />

    <LinearLayout
        android:id="@+id/dots"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginBottom="28dp"
        android:gravity="center"
        android:orientation="horizontal"
        app:layout_constraintBottom_toTopOf="@id/btnNext"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnNext"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="24dp"
        android:layout_marginEnd="24dp"
        android:layout_marginBottom="36dp"
        android:backgroundTint="@color/white"
        android:text="@string/continue_label"
        android:textColor="@color/brand_primary"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_onboarding.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:gravity="center"
    android:orientation="vertical"
    android:paddingStart="36dp"
    android:paddingEnd="36dp">

    <FrameLayout
        android:layout_width="180dp"
        android:layout_height="180dp"
        android:background="@drawable/bg_circle_dot">

        <ImageView
            android:id="@+id/imgIcon"
            android:layout_width="84dp"
            android:layout_height="84dp"
            android:layout_gravity="center"
            android:contentDescription="@null"
            android:src="@drawable/ic_swap"
            app:tint="@color/white"
            xmlns:app="http://schemas.android.com/apk/res-auto" />
    </FrameLayout>

    <TextView
        android:id="@+id/txtTitle"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="44dp"
        android:gravity="center"
        android:text="@string/ob1_title"
        android:textColor="@color/white"
        android:textSize="26sp"
        android:textStyle="bold" />

    <TextView
        android:id="@+id/txtDesc"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="14dp"
        android:alpha="0.9"
        android:gravity="center"
        android:lineSpacingExtra="4dp"
        android:text="@string/ob1_desc"
        android:textColor="@color/white"
        android:textSize="15sp" />
</LinearLayout>
EOF

# ============================================================ Login
cat > "$L/activity_login.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.core.widget.NestedScrollView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground"
    android:fillViewport="true">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <View
            android:id="@+id/header"
            android:layout_width="match_parent"
            android:layout_height="220dp"
            android:background="@drawable/bg_header_curve"
            app:layout_constraintTop_toTopOf="parent" />

        <ImageView
            android:layout_width="72dp"
            android:layout_height="72dp"
            android:layout_marginTop="42dp"
            android:contentDescription="@null"
            android:src="@drawable/ic_logo"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

        <TextView
            android:id="@+id/txtTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="124dp"
            android:text="@string/login_title"
            android:textColor="@color/white"
            android:textSize="26sp"
            android:textStyle="bold"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:alpha="0.9"
            android:text="@string/login_subtitle"
            android:textColor="@color/white"
            android:textSize="14sp"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintTop_toBottomOf="@id/txtTitle" />

        <com.google.android.material.card.MaterialCardView
            android:id="@+id/card"
            style="@style/Widget.SkillSwap.Card.Highlight"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="20dp"
            android:layout_marginTop="180dp"
            android:layout_marginEnd="20dp"
            app:cardElevation="10dp"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="24dp">

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilEmail"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="@string/hint_email"
                    app:startIconDrawable="@drawable/ic_email">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtEmail"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textEmailAddress"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilPassword"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="14dp"
                    android:hint="@string/hint_password"
                    app:endIconMode="password_toggle"
                    app:startIconDrawable="@drawable/ic_lock">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtPassword"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPassword"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnForgot"
                    style="@style/Widget.SkillSwap.Button.Text"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:layout_gravity="end"
                    android:text="@string/forgot_password"
                    android:textSize="13sp" />

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnLogin"
                    style="@style/Widget.SkillSwap.Button"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="6dp"
                    android:text="@string/action_login" />

                <com.google.android.material.progressindicator.LinearProgressIndicator
                    android:id="@+id/progress"
                    style="@style/Widget.SkillSwap.Progress"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:indeterminate="true"
                    android:visibility="gone" />
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnGoRegister"
            style="@style/Widget.SkillSwap.Button.Text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="16dp"
            android:layout_marginBottom="28dp"
            android:text="@string/no_account"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@id/card" />
    </androidx.constraintlayout.widget.ConstraintLayout>
</androidx.core.widget.NestedScrollView>
EOF

# ============================================================ Register
cat > "$L/activity_register.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.core.widget.NestedScrollView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground"
    android:fillViewport="true">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content">

        <View
            android:layout_width="match_parent"
            android:layout_height="180dp"
            android:background="@drawable/bg_header_curve"
            app:layout_constraintTop_toTopOf="parent" />

        <ImageButton
            android:id="@+id/btnBack"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:layout_margin="10dp"
            android:background="?attr/selectableItemBackgroundBorderless"
            android:contentDescription="@string/back"
            android:src="@drawable/ic_arrow_back"
            app:tint="@color/white"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

        <TextView
            android:id="@+id/txtTitle"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="66dp"
            android:text="@string/register_title"
            android:textColor="@color/white"
            android:textSize="26sp"
            android:textStyle="bold"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:alpha="0.9"
            android:text="@string/register_subtitle"
            android:textColor="@color/white"
            android:textSize="14sp"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@id/txtTitle" />

        <com.google.android.material.card.MaterialCardView
            android:id="@+id/card"
            style="@style/Widget.SkillSwap.Card.Highlight"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="20dp"
            android:layout_marginTop="140dp"
            android:layout_marginEnd="20dp"
            app:cardElevation="10dp"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="vertical"
                android:padding="22dp">

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilFirstName"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:hint="@string/hint_names"
                    app:startIconDrawable="@drawable/ic_person">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtFirstName"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPersonName|textCapWords"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilLastName"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:hint="@string/hint_lastnames"
                    app:startIconDrawable="@drawable/ic_person">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtLastName"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPersonName|textCapWords"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilEmail"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:hint="@string/hint_email"
                    app:startIconDrawable="@drawable/ic_email">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtEmail"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textEmailAddress"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilPassword"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:hint="@string/hint_password"
                    app:endIconMode="password_toggle"
                    app:helperText="Mínimo 6 caracteres con letras y números"
                    app:startIconDrawable="@drawable/ic_lock">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtPassword"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPassword"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilConfirm"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:hint="@string/hint_confirm_password"
                    app:endIconMode="password_toggle"
                    app:startIconDrawable="@drawable/ic_lock">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtConfirm"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="textPassword"
                        android:maxLines="1" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.button.MaterialButton
                    android:id="@+id/btnRegister"
                    style="@style/Widget.SkillSwap.Button"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="20dp"
                    android:text="@string/action_register" />

                <com.google.android.material.progressindicator.LinearProgressIndicator
                    android:id="@+id/progress"
                    style="@style/Widget.SkillSwap.Progress"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:layout_marginTop="12dp"
                    android:indeterminate="true"
                    android:visibility="gone" />
            </LinearLayout>
        </com.google.android.material.card.MaterialCardView>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnGoLogin"
            style="@style/Widget.SkillSwap.Button.Text"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:layout_marginBottom="28dp"
            android:text="@string/have_account"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@id/card" />
    </androidx.constraintlayout.widget.ConstraintLayout>
</androidx.core.widget.NestedScrollView>
EOF

# ============================================================ Forgot password
cat > "$L/activity_forgot_password.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <View
        android:layout_width="match_parent"
        android:layout_height="190dp"
        android:background="@drawable/bg_header_curve"
        app:layout_constraintTop_toTopOf="parent" />

    <ImageButton
        android:id="@+id/btnBack"
        android:layout_width="44dp"
        android:layout_height="44dp"
        android:layout_margin="10dp"
        android:background="?attr/selectableItemBackgroundBorderless"
        android:contentDescription="@string/back"
        android:src="@drawable/ic_arrow_back"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:tint="@color/white" />

    <TextView
        android:id="@+id/txtTitle"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="76dp"
        android:text="@string/recover_title"
        android:textColor="@color/white"
        android:textSize="24sp"
        android:textStyle="bold"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="4dp"
        android:alpha="0.9"
        android:text="@string/recover_subtitle"
        android:textColor="@color/white"
        android:textSize="14sp"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/txtTitle" />

    <com.google.android.material.card.MaterialCardView
        style="@style/Widget.SkillSwap.Card.Highlight"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="20dp"
        android:layout_marginTop="150dp"
        android:layout_marginEnd="20dp"
        app:cardElevation="10dp"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="24dp">

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilEmail"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="@string/hint_email"
                app:startIconDrawable="@drawable/ic_email">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtEmail"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textEmailAddress"
                    android:maxLines="1" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnSend"
                style="@style/Widget.SkillSwap.Button"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:text="@string/action_recover" />

            <com.google.android.material.progressindicator.LinearProgressIndicator
                android:id="@+id/progress"
                style="@style/Widget.SkillSwap.Progress"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:indeterminate="true"
                android:visibility="gone" />
        </LinearLayout>
    </com.google.android.material.card.MaterialCardView>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ Main
cat > "$L/activity_main.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <FrameLayout
        android:id="@+id/fragmentContainer"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toTopOf="@id/bottomNav"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <View
        android:layout_width="match_parent"
        android:layout_height="1dp"
        android:background="?attr/colorOutline"
        app:layout_constraintBottom_toTopOf="@id/bottomNav" />

    <com.google.android.material.bottomnavigation.BottomNavigationView
        android:id="@+id/bottomNav"
        style="@style/Widget.SkillSwap.BottomNav"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:layout_constraintBottom_toBottomOf="parent"
        app:menu="@menu/menu_bottom_nav" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ Empty state reutilizable
cat > "$L/layout_empty_state.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/emptyRoot"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="32dp">

    <FrameLayout
        android:layout_width="96dp"
        android:layout_height="96dp"
        android:background="@drawable/bg_circle_light">

        <ImageView
            android:id="@+id/imgEmpty"
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:layout_gravity="center"
            android:contentDescription="@null"
            android:src="@drawable/ic_inbox"
            app:tint="@color/brand_primary" />
    </FrameLayout>

    <TextView
        android:id="@+id/txtEmptyTitle"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="18dp"
        android:gravity="center"
        android:text="@string/empty_generic"
        android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

    <TextView
        android:id="@+id/txtEmptyDesc"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginTop="6dp"
        android:gravity="center"
        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnEmptyAction"
        style="@style/Widget.SkillSwap.Button.Outlined"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="18dp"
        android:visibility="gone" />
</LinearLayout>
EOF

# ============================================================ Toolbar reutilizable
cat > "$L/layout_toolbar.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.appbar.MaterialToolbar
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/toolbar"
    style="@style/Widget.SkillSwap.Toolbar"
    android:layout_width="match_parent"
    android:layout_height="?attr/actionBarSize"
    app:navigationIcon="@drawable/ic_arrow_back"
    app:titleTextColor="?attr/colorOnSurface" />
EOF

echo "Layouts A (auth + main) generados."
