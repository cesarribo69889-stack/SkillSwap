#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ DETALLE DE INTERCAMBIO
cat > "$L/activity_exchange_detail.xml" <<'EOF'
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
            android:paddingStart="16dp"
            android:paddingEnd="16dp">

            <!-- Participante -->
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
                    android:background="@drawable/bg_gradient_purple"
                    android:gravity="center_vertical"
                    android:orientation="horizontal"
                    android:padding="18dp">

                    <de.hdodenhof.circleimageview.CircleImageView
                        android:id="@+id/imgAvatar"
                        android:layout_width="58dp"
                        android:layout_height="58dp"
                        android:src="@drawable/ic_avatar_placeholder"
                        app:civ_border_color="#66FFFFFF"
                        app:civ_border_width="2dp" />

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="14dp"
                        android:layout_weight="1"
                        android:orientation="vertical">

                        <TextView
                            android:id="@+id/txtName"
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:textColor="@color/white"
                            android:textSize="18sp"
                            android:textStyle="bold" />

                        <TextView
                            android:id="@+id/txtStatus"
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:alpha="0.9"
                            android:textColor="@color/white"
                            android:textSize="13sp" />
                    </LinearLayout>
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Habilidades -->
            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
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
                        android:text="El intercambio"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                    <LinearLayout
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="12dp"
                        android:orientation="horizontal">

                        <LinearLayout
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:background="@drawable/bg_rounded_soft"
                            android:orientation="vertical"
                            android:padding="12dp">

                            <TextView
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:text="Habilidad enseñada"
                                android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                                android:textSize="10sp" />

                            <TextView
                                android:id="@+id/txtITeach"
                                android:layout_width="match_parent"
                                android:layout_height="wrap_content"
                                android:textColor="@color/brand_secondary_dark"
                                android:textSize="15sp"
                                android:textStyle="bold" />
                        </LinearLayout>

                        <LinearLayout
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_marginStart="10dp"
                            android:layout_weight="1"
                            android:background="@drawable/bg_rounded_soft"
                            android:orientation="vertical"
                            android:padding="12dp">

                            <TextView
                                android:layout_width="wrap_content"
                                android:layout_height="wrap_content"
                                android:text="Habilidad aprendida"
                                android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                                android:textSize="10sp" />

                            <TextView
                                android:id="@+id/txtILearn"
                                android:layout_width="match_parent"
                                android:layout_height="wrap_content"
                                android:textColor="@color/brand_primary"
                                android:textSize="15sp"
                                android:textStyle="bold" />
                        </LinearLayout>
                    </LinearLayout>

                    <TextView
                        android:id="@+id/txtModality"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="14dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                        app:drawableStartCompat="@drawable/ic_video" />

                    <TextView
                        android:id="@+id/txtSchedule"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="8dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                        app:drawableStartCompat="@drawable/ic_clock" />

                    <TextView
                        android:id="@+id/txtDate"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="8dp"
                        android:drawablePadding="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                        app:drawableStartCompat="@drawable/ic_calendar" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Progreso -->
            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
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
                        android:orientation="horizontal">

                        <TextView
                            android:layout_width="0dp"
                            android:layout_height="wrap_content"
                            android:layout_weight="1"
                            android:text="Progreso"
                            android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

                        <TextView
                            android:id="@+id/txtProgressValue"
                            android:layout_width="wrap_content"
                            android:layout_height="wrap_content"
                            android:textColor="@color/brand_primary"
                            android:textSize="15sp"
                            android:textStyle="bold" />
                    </LinearLayout>

                    <com.google.android.material.progressindicator.LinearProgressIndicator
                        android:id="@+id/progressBar"
                        style="@style/Widget.SkillSwap.Progress"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="10dp"
                        app:trackColor="@color/divider" />

                    <TextView
                        android:id="@+id/txtSessions"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="8dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

                    <com.google.android.material.button.MaterialButton
                        android:id="@+id/btnSession"
                        style="@style/Widget.SkillSwap.Button.Small.Outlined"
                        android:layout_width="match_parent"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="10dp"
                        android:text="Registrar sesión realizada"
                        app:icon="@drawable/ic_check" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Contrato de aprendizaje -->
            <com.google.android.material.card.MaterialCardView
                android:id="@+id/cardContract"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="14dp"
                android:clickable="true"
                android:focusable="true"
                app:cardCornerRadius="20dp"
                app:cardElevation="0dp"
                app:strokeWidth="1dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:gravity="center_vertical"
                    android:orientation="horizontal"
                    android:padding="16dp">

                    <FrameLayout
                        android:layout_width="42dp"
                        android:layout_height="42dp"
                        android:background="@drawable/bg_circle_secondary">

                        <ImageView
                            android:layout_width="22dp"
                            android:layout_height="22dp"
                            android:layout_gravity="center"
                            android:contentDescription="@null"
                            android:src="@drawable/ic_contract"
                            app:tint="@color/brand_secondary_dark" />
                    </FrameLayout>

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="12dp"
                        android:layout_weight="1"
                        android:orientation="vertical">

                        <TextView
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:text="@string/learning_contract"
                            android:textColor="?attr/colorOnSurface"
                            android:textSize="15sp"
                            android:textStyle="bold" />

                        <TextView
                            android:id="@+id/txtContractStatus"
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                    </LinearLayout>

                    <ImageView
                        android:layout_width="20dp"
                        android:layout_height="20dp"
                        android:contentDescription="@null"
                        android:src="@drawable/ic_chevron_right"
                        app:tint="@color/text_tertiary" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <!-- Validacion de aprendizaje -->
            <com.google.android.material.card.MaterialCardView
                android:id="@+id/cardEvidence"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                android:clickable="true"
                android:focusable="true"
                app:cardCornerRadius="20dp"
                app:cardElevation="0dp"
                app:strokeWidth="1dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:gravity="center_vertical"
                    android:orientation="horizontal"
                    android:padding="16dp">

                    <FrameLayout
                        android:layout_width="42dp"
                        android:layout_height="42dp"
                        android:background="@drawable/bg_circle_accent">

                        <ImageView
                            android:layout_width="22dp"
                            android:layout_height="22dp"
                            android:layout_gravity="center"
                            android:contentDescription="@null"
                            android:src="@drawable/ic_target"
                            app:tint="@color/brand_accent" />
                    </FrameLayout>

                    <LinearLayout
                        android:layout_width="0dp"
                        android:layout_height="wrap_content"
                        android:layout_marginStart="12dp"
                        android:layout_weight="1"
                        android:orientation="vertical">

                        <TextView
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:text="@string/learning_evidence"
                            android:textColor="?attr/colorOnSurface"
                            android:textSize="15sp"
                            android:textStyle="bold" />

                        <TextView
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:text="Registra la actividad que realizaste"
                            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                    </LinearLayout>

                    <ImageView
                        android:layout_width="20dp"
                        android:layout_height="20dp"
                        android:contentDescription="@null"
                        android:src="@drawable/ic_chevron_right"
                        app:tint="@color/text_tertiary" />
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
            android:id="@+id/btnChat"
            style="@style/Widget.SkillSwap.Button.Outlined"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Chat"
            app:icon="@drawable/ic_chat" />

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnPrimary"
            style="@style/Widget.SkillSwap.Button"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="10dp"
            android:layout_weight="1.4"
            android:text="@string/mark_completed" />
    </LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ CALIFICAR
cat > "$L/activity_rate_exchange.xml" <<'EOF'
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
        app:layout_constraintBottom_toTopOf="@id/btnSubmit"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/toolbarInc">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:paddingStart="20dp"
            android:paddingEnd="20dp"
            android:paddingBottom="20dp">

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="88dp"
                android:layout_height="88dp"
                android:layout_gravity="center_horizontal"
                android:src="@drawable/ic_avatar_placeholder"
                app:civ_border_color="@color/brand_primary_container"
                app:civ_border_width="3dp" />

            <TextView
                android:id="@+id/txtName"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:gravity="center"
                android:textAppearance="@style/TextAppearance.SkillSwap.Title" />

            <TextView
                android:id="@+id/txtSkill"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:gravity="center"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="22dp"
                android:gravity="center"
                android:text="¿Cómo fue la experiencia?"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <com.google.android.material.card.MaterialCardView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="10dp"
                app:cardCornerRadius="20dp"
                app:cardElevation="0dp"
                app:strokeWidth="1dp">

                <LinearLayout
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:gravity="center"
                    android:orientation="vertical"
                    android:padding="18dp">

                    <RatingBar
                        android:id="@+id/ratingGeneral"
                        style="?android:attr/ratingBarStyle"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:isIndicator="false"
                        android:numStars="5"
                        android:stepSize="1" />

                    <TextView
                        android:id="@+id/txtRatingLabel"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content"
                        android:layout_marginTop="6dp"
                        android:textAppearance="@style/TextAppearance.SkillSwap.Body" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="Detalles"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <include
                android:id="@+id/rowPunctuality"
                layout="@layout/item_rating_criteria"
                android:layout_width="match_parent"
                android:layout_height="wrap_content" />

            <include
                android:id="@+id/rowCommunication"
                layout="@layout/item_rating_criteria"
                android:layout_width="match_parent"
                android:layout_height="wrap_content" />

            <include
                android:id="@+id/rowTeaching"
                layout="@layout/item_rating_criteria"
                android:layout_width="match_parent"
                android:layout_height="wrap_content" />

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilComment"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:hint="@string/rate_comment"
                app:counterEnabled="true"
                app:counterMaxLength="300">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtComment"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:gravity="top"
                    android:inputType="textMultiLine|textCapSentences"
                    android:maxLength="300"
                    android:minLines="3" />
            </com.google.android.material.textfield.TextInputLayout>
        </LinearLayout>
    </androidx.core.widget.NestedScrollView>

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnSubmit"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="Enviar calificación"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_rating_criteria.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/criteriaRoot"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="center_vertical"
    android:orientation="horizontal"
    android:paddingTop="10dp"
    android:paddingBottom="10dp">

    <TextView
        android:id="@+id/txtCriteria"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
        android:textColor="?attr/colorOnSurface" />

    <RatingBar
        android:id="@+id/ratingCriteria"
        style="?android:attr/ratingBarStyleSmall"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:isIndicator="false"
        android:numStars="5"
        android:stepSize="1" />
</LinearLayout>
EOF

cat > "$L/item_rating.xml" <<'EOF'
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

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="38dp"
                android:layout_height="38dp"
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
                android:id="@+id/txtStars"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:drawablePadding="4dp"
                android:textColor="@color/star_gold"
                android:textSize="14sp"
                android:textStyle="bold"
                app:drawableStartCompat="@drawable/ic_star" />
        </LinearLayout>

        <TextView
            android:id="@+id/txtComment"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:textAppearance="@style/TextAppearance.SkillSwap.Body" />

        <TextView
            android:id="@+id/txtDate"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="4dp"
            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ HISTORIAL
cat > "$L/activity_history.xml" <<'EOF'
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

    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvHistory"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:clipToPadding="false"
            android:paddingStart="16dp"
            android:paddingTop="12dp"
            android:paddingEnd="16dp"
            android:paddingBottom="16dp"
            app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

        <include
            android:id="@+id/empty"
            layout="@layout/layout_empty_state"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:visibility="gone" />
    </FrameLayout>
</LinearLayout>
EOF

cat > "$L/item_history.xml" <<'EOF'
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

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="44dp"
                android:layout_height="44dp"
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
                    android:textColor="?attr/colorOnSurface"
                    android:textSize="15sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/txtDate"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
            </LinearLayout>

            <TextView
                android:id="@+id/txtRating"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:drawablePadding="4dp"
                android:textColor="@color/star_gold"
                android:textSize="14sp"
                android:textStyle="bold"
                app:drawableStartCompat="@drawable/ic_star" />
        </LinearLayout>

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
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
                    android:text="Enseñaste"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtTaught"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textColor="@color/brand_secondary_dark"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>

            <LinearLayout
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:orientation="vertical">

                <TextView
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Aprendiste"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtLearned"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:textColor="@color/brand_primary"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>
        </LinearLayout>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnRate"
            style="@style/Widget.SkillSwap.Button.Small.Outlined"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="@string/rate_exchange"
            app:icon="@drawable/ic_star"
            app:iconSize="16dp" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ NOTIFICACIONES
cat > "$L/activity_notifications.xml" <<'EOF'
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

    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnMarkAll"
        style="@style/Widget.SkillSwap.Button.Text"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_gravity="end"
        android:layout_marginEnd="8dp"
        android:text="Marcar todas como leídas"
        android:textSize="13sp" />

    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvNotifications"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:clipToPadding="false"
            android:paddingStart="16dp"
            android:paddingEnd="16dp"
            android:paddingBottom="16dp"
            app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

        <include
            android:id="@+id/empty"
            layout="@layout/layout_empty_state"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="center"
            android:visibility="gone" />
    </FrameLayout>
</LinearLayout>
EOF

cat > "$L/item_notification.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<com.google.android.material.card.MaterialCardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/root"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginTop="8dp"
    android:clickable="true"
    android:focusable="true"
    app:cardCornerRadius="18dp"
    app:cardElevation="0dp"
    app:strokeWidth="1dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="14dp">

        <FrameLayout
            android:id="@+id/iconWrap"
            android:layout_width="42dp"
            android:layout_height="42dp"
            android:background="@drawable/bg_circle_light">

            <ImageView
                android:id="@+id/imgIcon"
                android:layout_width="20dp"
                android:layout_height="20dp"
                android:layout_gravity="center"
                android:contentDescription="@null"
                android:src="@drawable/ic_notifications"
                app:tint="@color/brand_primary" />
        </FrameLayout>

        <LinearLayout
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="12dp"
            android:layout_weight="1"
            android:orientation="vertical">

            <TextView
                android:id="@+id/txtTitle"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:textColor="?attr/colorOnSurface"
                android:textSize="14sp"
                android:textStyle="bold" />

            <TextView
                android:id="@+id/txtBody"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="2dp"
                android:textAppearance="@style/TextAppearance.SkillSwap.Body"
                android:textSize="13sp" />

            <TextView
                android:id="@+id/txtTime"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="4dp"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>

        <View
            android:id="@+id/dotUnread"
            android:layout_width="10dp"
            android:layout_height="10dp"
            android:layout_marginStart="6dp"
            android:background="@drawable/bg_badge_dot" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

echo "Layouts G (intercambio/calificaciones/notificaciones) generados."
