#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ CONTRATO DE APRENDIZAJE
cat > "$L/activity_contract.xml" <<'EOF'
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
        android:paddingBottom="20dp"
        app:layout_constraintBottom_toTopOf="@id/actions"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp">

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                app:cardBackgroundColor="@color/transparent"
                app:cardCornerRadius="22dp"
                app:cardElevation="0dp"
                app:strokeWidth="0dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:background="@drawable/bg_gradient_teal"
                    android:orientation="vertical"
                    android:padding="18dp">

                    <TextView
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:text="@string/learning_contract"
                        android:textColor="@color/white"
                        android:textSize="18sp"
                        android:textStyle="bold" />

                    <TextView
                        android:id="@+id/txtContractStatus"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="4dp"
                        android:alpha="0.9"
                        android:text="Definan juntos el objetivo antes de iniciar"
                        android:textColor="@color/white"
                        android:textSize="13sp" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilObjective"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:hint="Objetivo del intercambio"
                app:startIconDrawable="@drawable/ic_target">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtObjective"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="200"
                    android:minLines="2" />
            </com.google.android.material.textfield.TextInputLayout>

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:orientation="horizontal">

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilSessions"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:hint="Sesiones">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtSessions"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="number"
                        android:maxLines="1"
                        android:text="3" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilDuration"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="10dp"
                    android:layout_weight="1"
                    android:hint="Minutos por sesión">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtDuration"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="number"
                        android:maxLines="1"
                        android:text="60" />
                </com.google.android.material.textfield.TextInputLayout>
            </LinearLayout>

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
                app:selectionRequired="true"
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
                    android:checked="true"
                    android:text="@string/modality_virtual" />
            </com.google.android.material.chip.ChipGroup>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilGoal"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:hint="Meta concreta">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtGoal"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="160"
                    android:minLines="2" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilActivity"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="Actividad final"
                app:helperText="Ejemplo: crear una calculadora en Java">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtActivity"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="160"
                    android:minLines="2" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                app:cardCornerRadius="18dp"
                app:cardElevation="0dp"
                app:strokeWidth="1dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:orientation="vertical"
                    android:padding="14dp">

                    <TextView
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:text="Aceptación del acuerdo"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                    <TextView
                        android:id="@+id/txtAcceptA"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="8dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

                    <TextView
                        android:id="@+id/txtAcceptB"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="6dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <LinearLayout
        android:id="@+id/actions"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="?attr/colorSurface"
        android:orientation="horizontal"
        android:padding="12dp"
        app:layout_constraintBottom_toBottomOf="parent">

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnSave"
            style="@style/Widget.SkillSwap.Button.Outlined"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Guardar" />

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnAccept"
            style="@style/Widget.SkillSwap.Button"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="10dp"
            android:layout_weight="1"
            android:text="Aceptar acuerdo" />
    </LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ RETOS
cat > "$L/activity_challenges.xml" <<'EOF'
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

        <TextView
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginStart="20dp"
            android:layout_marginEnd="20dp"
            android:text="Únete a un equipo, aporta tu habilidad y construyan algo juntos."
            android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

        <androidx.swiperefreshlayout.widget.SwipeRefreshLayout
            android:id="@+id/swipeRefresh"
            android:layout_width="match_parent"
            android:layout_height="0dp"
            android:layout_weight="1">

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvChallenges"
                android:layout_width="match_parent"
                android:layout_height="match_parent"
                android:clipToPadding="false"
                android:paddingStart="16dp"
                android:paddingTop="12dp"
                android:paddingEnd="16dp"
                android:paddingBottom="90dp"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />
        </androidx.swiperefreshlayout.widget.SwipeRefreshLayout>
    </LinearLayout>

    <include
        android:id="@+id/empty"
        layout="@layout/layout_empty_state"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="center"
        android:visibility="gone" />

    <com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton
        android:id="@+id/fabCreate"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom|end"
        android:layout_margin="16dp"
        android:text="Crear reto"
        app:icon="@drawable/ic_add" />
</androidx.coordinatorlayout.widget.CoordinatorLayout>
EOF

cat > "$L/item_challenge.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginBottom="12dp"
    android:clickable="true"
    android:focusable="true"
    app:cardCornerRadius="22dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical">

        <LinearLayout
            android:id="@+id/banner"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:background="@drawable/bg_gradient_blue"
            android:orientation="vertical"
            android:padding="16dp">

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:gravity="center_vertical"
                android:orientation="horizontal">

                <ImageView
                    android:layout_width="22dp"
                    android:layout_height="22dp"
                    android:contentDescription="@null"
                    android:src="@drawable/ic_challenge"
                    app:tint="@color/white" />

                <TextView
                    android:id="@+id/txtDeadline"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="8dp"
                    android:layout_weight="1"
                    android:alpha="0.9"
                    android:textColor="@color/white"
                    android:textSize="11sp" />

                <TextView
                    android:id="@+id/txtStatus"
                    style="@style/SkillSwap.StatePill"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content" />
            </LinearLayout>

            <TextView
                android:id="@+id/txtTitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="8dp"
                android:ellipsize="end"
                android:maxLines="2"
                android:textColor="@color/white"
                android:textSize="17sp"
                android:textStyle="bold" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="16dp">

            <TextView
                android:id="@+id/txtObjective"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:ellipsize="end"
                android:maxLines="3"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:text="Se necesita"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsSkills"
                android:layout_width="match_parent"
                android:layout_height="wrap_content" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:gravity="center_vertical"
                android:orientation="horizontal">

                <ImageView
                    android:layout_width="16dp"
                    android:layout_height="16dp"
                    android:contentDescription="@null"
                    android:src="@drawable/ic_group"
                    app:tint="@color/text_secondary" />

                <TextView
                    android:id="@+id/txtParticipants"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="6dp"
                    android:layout_weight="1"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

                <TextView
                    android:id="@+id/txtProgress"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textStyle="bold" />
            </LinearLayout>

            <com.google.android.material.progressindicator.LinearProgressIndicator
                android:id="@+id/progressBar"
                style="@style/Widget.SkillSwap.Progress"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                app:trackColor="@color/divider" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnJoin"
                style="@style/Widget.SkillSwap.Button.Small"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:text="Quiero participar"
                app:icon="@drawable/ic_person_add"
                app:iconSize="16dp" />
        </LinearLayout>
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/item_challenge_home.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="236dp"
    android:layout_height="wrap_content"
    android:layout_margin="4dp"
    app:cardBackgroundColor="@color/transparent"
    app:cardCornerRadius="22dp"
    app:cardElevation="0dp"
    app:strokeWidth="0dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="@drawable/bg_gradient_blue"
        android:orientation="vertical"
        android:padding="16dp">

        <ImageView
            android:layout_width="24dp"
            android:layout_height="24dp"
            android:contentDescription="@null"
            android:src="@drawable/ic_challenge"
            app:tint="@color/white" />

        <TextView
            android:id="@+id/txtTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:ellipsize="end"
            android:maxLines="2"
            android:minLines="2"
            android:textColor="@color/white"
            android:textSize="15sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/txtSkills"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="6dp"
            android:alpha="0.9"
            android:ellipsize="end"
            android:maxLines="1"
            android:textColor="@color/white"
            android:textSize="11sp" />

        <TextView
            android:id="@+id/txtDeadline"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:alpha="0.85"
            android:textColor="@color/white"
            android:textSize="11sp" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/activity_challenge_detail.xml" <<'EOF'
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
        android:paddingBottom="20dp"
        app:layout_constraintBottom_toTopOf="@id/btnJoin"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

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
                    android:background="@drawable/bg_gradient_blue"
                    android:orientation="vertical"
                    android:padding="20dp">

                    <TextView
                        android:id="@+id/txtTitle"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:textColor="@color/white"
                        android:textSize="21sp"
                        android:textStyle="bold" />

                    <TextView
                        android:id="@+id/txtDeadline"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="6dp"
                        android:alpha="0.9"
                        android:textColor="@color/white"
                        android:textSize="13sp" />

                    <com.google.android.material.progressindicator.LinearProgressIndicator
                        android:id="@+id/progressBar"
                        style="@style/Widget.SkillSwap.Progress"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="14dp"
                        app:indicatorColor="@color/white"
                        app:trackColor="#55FFFFFF" />

                    <TextView
                        android:id="@+id/txtProgress"
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
                android:layout_marginTop="18dp"
                android:text="Objetivo"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <TextView
                android:id="@+id/txtObjective"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="4dp"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:text="Descripción"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <TextView
                android:id="@+id/txtDescription"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="4dp"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:text="Habilidades requeridas"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsSkills"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="4dp" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:text="Participantes"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <androidx.recyclerview.widget.RecyclerView
                android:id="@+id/rvParticipants"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                android:nestedScrollingEnabled="false"
                app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

            <LinearLayout
                android:id="@+id/ownerBox"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:orientation="vertical"
                android:visibility="gone">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Avance del reto"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                <com.google.android.material.slider.Slider
                    android:id="@+id/sliderProgress"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:stepSize="10"
                    android:value="0"
                    android:valueFrom="0"
                    android:valueTo="100" />
            </LinearLayout>
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnJoin"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="Quiero participar"
        app:icon="@drawable/ic_person_add"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_challenge_participant.xml" <<'EOF'
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
        android:orientation="vertical"
        android:padding="12dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:gravity="center_vertical"
            android:orientation="horizontal">

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:src="@drawable/ic_avatar_placeholder" />

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="10dp"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:id="@+id/txtName"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textColor="?attr/colorOnSurface"
                    android:textSize="14sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/txtSkill"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
            </LinearLayout>

            <TextView
                android:id="@+id/txtStatus"
                style="@style/SkillSwap.StatePill"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content" />
        </LinearLayout>

        <LinearLayout
            android:id="@+id/actions"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:orientation="horizontal"
            android:visibility="gone">

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnReject"
                style="@style/Widget.SkillSwap.Button.Small.Outlined"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:text="@string/reject"
                android:textColor="@color/state_rejected"
                app:strokeColor="@color/state_rejected" />

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnAccept"
                style="@style/Widget.SkillSwap.Button.Small"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_marginStart="8dp"
                android:layout_weight="1"
                android:text="@string/accept" />
        </LinearLayout>
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

cat > "$L/activity_create_challenge.xml" <<'EOF'
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
        android:paddingBottom="20dp"
        app:layout_constraintBottom_toTopOf="@id/btnCreate"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp">

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilTitle"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:hint="Título del reto"
                app:helperText="Ejemplo: Crear una página web en 7 días">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtTitle"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textCapSentences"
                    android:maxLength="90" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilObjective"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="Objetivo">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtObjective"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="200"
                    android:minLines="2" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilDescription"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="Descripción">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtDescription"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="400"
                    android:minLines="3" />
            </com.google.android.material.textfield.TextInputLayout>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:text="Habilidades requeridas"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Selecciona los perfiles que necesitas en el equipo"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsSkills"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp" />

            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:orientation="horizontal">

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilMax"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_weight="1"
                    android:hint="Participantes">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtMax"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="number"
                        android:maxLines="1"
                        android:text="4" />
                </com.google.android.material.textfield.TextInputLayout>

                <com.google.android.material.textfield.TextInputLayout
                    android:id="@+id/tilDays"
                    style="@style/Widget.SkillSwap.TextInput"
                    android:layout_width="0dp"
                    android:layout_height="wrap_content"
                    android:layout_marginStart="10dp"
                    android:layout_weight="1"
                    android:hint="Días">

                    <com.google.android.material.textfield.TextInputEditText
                        android:id="@+id/edtDays"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:inputType="number"
                        android:maxLines="1"
                        android:text="7" />
                </com.google.android.material.textfield.TextInputLayout>
            </LinearLayout>
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnCreate"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="Publicar reto"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ EVIDENCIA
cat > "$L/activity_evidence.xml" <<'EOF'
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
        android:paddingBottom="20dp"
        app:layout_constraintBottom_toTopOf="@id/btnSubmit"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp">

            <TextView
                android:id="@+id/txtSkill"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Title" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="4dp"
                android:text="Registra qué practicaste y qué lograste."
                android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilActivity"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:hint="Actividad realizada"
                app:helperText="Ejemplo: crear una calculadora">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtActivity"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="200"
                    android:minLines="2" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.materialswitch.MaterialSwitch
                android:id="@+id/switchAchieved"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:text="Se cumplió el objetivo del contrato"
                android:textColor="?attr/colorOnSurface" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:text="Autoevaluación"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <RatingBar
                android:id="@+id/ratingSelf"
                style="?android:attr/ratingBarStyle"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                android:numStars="5"
                android:rating="3"
                android:stepSize="1" />

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilNotes"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:hint="Notas (opcional)">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtNotes"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="300"
                    android:minLines="2" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.button.MaterialButton
                android:id="@+id/btnAttach"
                style="@style/Widget.SkillSwap.Button.Outlined"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:text="Adjuntar evidencia (opcional)"
                app:icon="@drawable/ic_upload" />

            <ImageView
                android:id="@+id/imgPreview"
                android:layout_width="match_parent"
                android:layout_height="170dp"
                android:layout_marginTop="12dp"
                android:contentDescription="@null"
                android:scaleType="centerCrop"
                android:visibility="gone" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:background="@drawable/bg_rounded_soft"
                android:padding="14dp"
                android:text="@string/evidence_disclaimer"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnSubmit"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="Registrar actividad"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ DETALLE DE MATCH
cat > "$L/activity_match_detail.xml" <<'EOF'
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
        android:paddingBottom="20dp"
        app:layout_constraintBottom_toTopOf="@id/btnRequest"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

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
                    android:background="@drawable/bg_gradient_match"
                    android:gravity="center_horizontal"
                    android:orientation="vertical"
                    android:padding="22dp">

                    <de.hdodenhof.circleimageview.CircleImageView
                        android:id="@+id/imgAvatar"
                        android:layout_width="84dp"
                        android:layout_height="84dp"
                        android:src="@drawable/ic_avatar_placeholder"
                        app:civ_border_color="#66FFFFFF"
                        app:civ_border_width="3dp" />

                    <TextView
                        android:id="@+id/txtName"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="10dp"
                        android:gravity="center"
                        android:textColor="@color/white"
                        android:textSize="19sp"
                        android:textStyle="bold" />

                    <TextView
                        android:id="@+id/txtScore"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="8dp"
                        android:gravity="center"
                        android:textColor="@color/white"
                        android:textSize="34sp"
                        android:textStyle="bold" />

                    <TextView
                        android:id="@+id/txtScoreLabel"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:alpha="0.9"
                        android:gravity="center"
                        android:textColor="@color/white"
                        android:textSize="13sp" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:text="¿Por qué son compatibles?"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <LinearLayout
                android:id="@+id/containerReasons"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                android:orientation="vertical" />

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
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
                        android:text="Cómo se calcula"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                    <TextView
                        android:id="@+id/txtFormula"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="6dp"
                        android:lineSpacingExtra="3dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnRequest"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="@string/send_request"
        app:icon="@drawable/ic_swap"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_match_reason.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:paddingTop="5dp"
    android:paddingBottom="5dp">

    <ImageView
        android:id="@+id/imgIcon"
        android:layout_width="18dp"
        android:layout_height="18dp"
        android:contentDescription="@null"
        android:src="@drawable/ic_check" />

    <TextView
        android:id="@+id/txtReason"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="10dp"
        android:layout_weight="1"
        android:textSize="14sp" />
</LinearLayout>
EOF

echo "Layouts I (contratos/retos/evidencia/match) generados."
