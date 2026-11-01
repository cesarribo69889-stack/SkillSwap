#!/usr/bin/env bash
set -e
L="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/layout"
mkdir -p "$L"

# ============================================================ SOLICITUDES
cat > "$L/activity_requests.xml" <<'EOF'
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

    <com.google.android.material.tabs.TabLayout
        android:id="@+id/tabs"
        style="@style/Widget.SkillSwap.TabLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:tabMode="fixed">

        <com.google.android.material.tabs.TabItem
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/requests_received" />

        <com.google.android.material.tabs.TabItem
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/requests_sent" />
    </com.google.android.material.tabs.TabLayout>

    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1">

        <androidx.recyclerview.widget.RecyclerView
            android:id="@+id/rvRequests"
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

cat > "$L/item_request.xml" <<'EOF'
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
                    android:id="@+id/txtTime"
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
                    android:id="@+id/lblOffered"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Ofrece"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtOffered"
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
                    android:id="@+id/lblWanted"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Quiere aprender"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                    android:textSize="10sp" />

                <TextView
                    android:id="@+id/txtWanted"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="@color/brand_primary"
                    android:textSize="13sp"
                    android:textStyle="bold" />
            </LinearLayout>
        </LinearLayout>

        <TextView
            android:id="@+id/txtMessage"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:textAppearance="@style/TextAppearance.SkillSwap.Body"
            android:visibility="gone" />

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:orientation="horizontal">

            <TextView
                android:id="@+id/txtModality"
                android:layout_width="0dp"
                android:layout_height="wrap_content"
                android:layout_weight="1"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <TextView
                android:id="@+id/txtSchedule"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
        </LinearLayout>

        <LinearLayout
            android:id="@+id/actionsReceived"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
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
                android:layout_marginStart="10dp"
                android:layout_weight="1"
                android:text="@string/accept" />
        </LinearLayout>

        <com.google.android.material.button.MaterialButton
            android:id="@+id/btnCancel"
            style="@style/Widget.SkillSwap.Button.Small.Outlined"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="12dp"
            android:text="@string/cancel"
            android:visibility="gone" />
    </LinearLayout>
</com.google.android.material.card.MaterialCardView>
EOF

# ============================================================ ENVIAR SOLICITUD
cat > "$L/activity_send_request.xml" <<'EOF'
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
        app:layout_constraintBottom_toTopOf="@id/btnSend"
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
                        android:layout_width="54dp"
                        android:layout_height="54dp"
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
                            android:textSize="16sp"
                            android:textStyle="bold" />

                        <TextView
                            android:id="@+id/txtCareer"
                            android:layout_width="match_parent"
                            android:layout_height="wrap_content"
                            android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
                    </LinearLayout>

                    <TextView
                        android:id="@+id/txtScore"
                        style="@style/SkillSwap.StatePill"
                        android:layout_width="wrap_content"
                        android:layout_height="wrap_content" />
                </LinearLayout>
            </com.google.android.material.card.MaterialCardView>

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="20dp"
                android:text="Quiero aprender"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Habilidades que este estudiante enseña"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsWanted"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                app:selectionRequired="true"
                app:singleSelection="true" />

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginTop="18dp"
                android:text="Puedo enseñar"
                android:textAppearance="@style/TextAppearance.SkillSwap.Section" />

            <TextView
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:text="Elige lo que ofrecerás a cambio"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />

            <com.google.android.material.chip.ChipGroup
                android:id="@+id/chipsOffered"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="6dp"
                app:selectionRequired="true"
                app:singleSelection="true" />

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
                android:id="@+id/tilSchedule"
                style="@style/Widget.Material3.TextInputLayout.OutlinedBox.ExposedDropdownMenu"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="16dp"
                android:hint="Horario propuesto">

                <com.google.android.material.textfield.MaterialAutoCompleteTextView
                    android:id="@+id/edtSchedule"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:inputType="none" />
            </com.google.android.material.textfield.TextInputLayout>

            <com.google.android.material.textfield.TextInputLayout
                android:id="@+id/tilMessage"
                style="@style/Widget.SkillSwap.TextInput"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:layout_marginTop="12dp"
                android:hint="Mensaje"
                app:counterEnabled="true"
                app:counterMaxLength="300">

                <com.google.android.material.textfield.TextInputEditText
                    android:id="@+id/edtMessage"
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
        android:id="@+id/btnSend"
        style="@style/Widget.SkillSwap.Button"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:text="@string/send_request"
        app:icon="@drawable/ic_send"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# ============================================================ CHAT
cat > "$L/activity_chat.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="?android:colorBackground">

    <com.google.android.material.card.MaterialCardView
        android:id="@+id/header"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:cardBackgroundColor="?attr/colorSurface"
        app:cardCornerRadius="0dp"
        app:cardElevation="2dp"
        app:layout_constraintTop_toTopOf="parent"
        app:strokeWidth="0dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:gravity="center_vertical"
            android:orientation="horizontal"
            android:paddingStart="6dp"
            android:paddingTop="8dp"
            android:paddingEnd="12dp"
            android:paddingBottom="8dp">

            <ImageButton
                android:id="@+id/btnBack"
                android:layout_width="42dp"
                android:layout_height="42dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="@string/back"
                android:src="@drawable/ic_arrow_back"
                app:tint="?attr/colorOnSurface" />

            <de.hdodenhof.circleimageview.CircleImageView
                android:id="@+id/imgAvatar"
                android:layout_width="40dp"
                android:layout_height="40dp"
                android:layout_marginStart="4dp"
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
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textColor="?attr/colorOnSurface"
                    android:textSize="15sp"
                    android:textStyle="bold" />

                <TextView
                    android:id="@+id/txtSubtitle"
                    android:layout_width="match_parent"
                    android:layout_height="wrap_content"
                    android:ellipsize="end"
                    android:maxLines="1"
                    android:textAppearance="@style/TextAppearance.SkillSwap.Caption" />
            </LinearLayout>

            <ImageButton
                android:id="@+id/btnExchange"
                android:layout_width="42dp"
                android:layout_height="42dp"
                android:background="?attr/selectableItemBackgroundBorderless"
                android:contentDescription="@string/my_exchanges"
                android:src="@drawable/ic_swap"
                app:tint="@color/brand_primary" />
        </LinearLayout>
    </com.google.android.material.card.MaterialCardView>

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rvMessages"
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:clipToPadding="false"
        android:paddingStart="12dp"
        android:paddingTop="12dp"
        android:paddingEnd="12dp"
        android:paddingBottom="12dp"
        app:layout_constraintBottom_toTopOf="@id/inputBar"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toBottomOf="@id/header"
        app:layoutManager="androidx.recyclerview.widget.LinearLayoutManager" />

    <TextView
        android:id="@+id/txtEmpty"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginStart="32dp"
        android:layout_marginEnd="32dp"
        android:gravity="center"
        android:text="Escribe el primer mensaje y coordinen su intercambio."
        android:textAppearance="@style/TextAppearance.SkillSwap.Body"
        android:visibility="gone"
        app:layout_constraintBottom_toBottomOf="@id/rvMessages"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="@id/rvMessages" />

    <LinearLayout
        android:id="@+id/inputBar"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:background="?attr/colorSurface"
        android:gravity="center_vertical"
        android:orientation="horizontal"
        android:padding="10dp"
        app:layout_constraintBottom_toBottomOf="parent">

        <com.google.android.material.textfield.TextInputLayout
            android:id="@+id/tilMessage"
            style="@style/Widget.SkillSwap.TextInput"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:hint="Escribe un mensaje…">

            <com.google.android.material.textfield.TextInputEditText
                android:id="@+id/edtMessage"
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:inputType="textMultiLine|textCapSentences"
                android:maxLines="4" />
        </com.google.android.material.textfield.TextInputLayout>

        <com.google.android.material.floatingactionbutton.FloatingActionButton
            android:id="@+id/btnSend"
            android:layout_width="52dp"
            android:layout_height="52dp"
            android:layout_marginStart="8dp"
            android:contentDescription="@string/send"
            app:fabCustomSize="52dp"
            app:maxImageSize="22dp"
            app:srcCompat="@drawable/ic_send" />
    </LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > "$L/item_message_sent.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="end"
    android:orientation="vertical"
    android:paddingStart="56dp"
    android:paddingTop="3dp"
    android:paddingEnd="4dp"
    android:paddingBottom="3dp">

    <TextView
        android:id="@+id/txtDayHeader"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:gravity="center"
        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
        android:visibility="gone" />

    <LinearLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="@drawable/bg_bubble_sent"
        android:orientation="vertical"
        android:paddingStart="14dp"
        android:paddingTop="10dp"
        android:paddingEnd="14dp"
        android:paddingBottom="8dp">

        <TextView
            android:id="@+id/txtMessage"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:lineSpacingExtra="2dp"
            android:textColor="@color/white"
            android:textSize="14sp" />

        <TextView
            android:id="@+id/txtTime"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="end"
            android:layout_marginTop="2dp"
            android:alpha="0.8"
            android:textColor="@color/white"
            android:textSize="10sp" />
    </LinearLayout>
</LinearLayout>
EOF

cat > "$L/item_message_received.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:paddingStart="4dp"
    android:paddingTop="3dp"
    android:paddingEnd="56dp"
    android:paddingBottom="3dp">

    <TextView
        android:id="@+id/txtDayHeader"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="8dp"
        android:gravity="center"
        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
        android:visibility="gone" />

    <LinearLayout
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:gravity="bottom"
        android:orientation="horizontal">

        <de.hdodenhof.circleimageview.CircleImageView
            android:id="@+id/imgAvatar"
            android:layout_width="30dp"
            android:layout_height="30dp"
            android:layout_marginEnd="8dp"
            android:src="@drawable/ic_avatar_placeholder" />

        <LinearLayout
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:background="@drawable/bg_bubble_received"
            android:orientation="vertical"
            android:paddingStart="14dp"
            android:paddingTop="10dp"
            android:paddingEnd="14dp"
            android:paddingBottom="8dp">

            <TextView
                android:id="@+id/txtMessage"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:lineSpacingExtra="2dp"
                android:textColor="?attr/colorOnSurface"
                android:textSize="14sp" />

            <TextView
                android:id="@+id/txtTime"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_gravity="end"
                android:layout_marginTop="2dp"
                android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
                android:textSize="10sp" />
        </LinearLayout>
    </LinearLayout>
</LinearLayout>
EOF

cat > "$L/item_message_system.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="8dp">

    <TextView
        android:id="@+id/txtDayHeader"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_marginBottom="6dp"
        android:gravity="center"
        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
        android:visibility="gone" />

    <TextView
        android:id="@+id/txtMessage"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="@drawable/bg_rounded_soft"
        android:gravity="center"
        android:paddingStart="14dp"
        android:paddingTop="8dp"
        android:paddingEnd="14dp"
        android:paddingBottom="8dp"
        android:textAppearance="@style/TextAppearance.SkillSwap.Caption"
        android:textStyle="bold" />
</LinearLayout>
EOF

echo "Layouts F (solicitudes/chat) generados."
