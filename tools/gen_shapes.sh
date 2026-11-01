#!/usr/bin/env bash
# Genera shapes, gradientes y fondos de SkillSwap
set -e
D="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/drawable"
mkdir -p "$D"

# ---------- Gradientes ----------
grad() {
cat > "$D/bg_gradient_$1.xml" <<XEOF
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <gradient
        android:angle="$4"
        android:startColor="$2"
        android:endColor="$3"
        android:type="linear" />
    <corners android:radius="$5" />
</shape>
XEOF
}
grad brand   "#7C5CFF" "#4B2FD0" 270 "0dp"
grad purple  "#8B6CFF" "#5B3AE0" 315 "24dp"
grad teal    "#22E0C6" "#00A892" 315 "24dp"
grad coral   "#FF8A8A" "#F0554F" 315 "24dp"
grad orange  "#FFC93C" "#FF8A00" 315 "24dp"
grad blue    "#60A5FA" "#2563EB" 315 "24dp"
grad hero    "#7C5CFF" "#00D2B8" 315 "28dp"
grad match   "#6C4DF6" "#B06CFF" 315 "20dp"

# ---------- Pills / rounded ----------
round() {
cat > "$D/bg_$1.xml" <<XEOF
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="$2" />
    <corners android:radius="$3" />
</shape>
XEOF
}
round pill            "@android:color/white" "100dp"
round rounded_12      "?attr/colorSurface"   "12dp"
round rounded_16      "?attr/colorSurface"   "16dp"
round rounded_20      "?attr/colorSurface"   "20dp"
round rounded_soft    "@color/bg_surface_variant" "16dp"
round dot_selected    "@color/white"         "100dp"
round badge_dot       "@color/brand_accent"  "100dp"

# ---------- Con borde ----------
stroked() {
cat > "$D/bg_$1.xml" <<XEOF
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="$2" />
    <stroke android:width="$4" android:color="$3" />
    <corners android:radius="$5" />
</shape>
XEOF
}
stroked search_field  "?attr/colorSurface" "@color/divider" "1dp" "18dp"
stroked chip_outline  "@color/transparent" "@color/divider" "1dp" "14dp"
stroked dashed_box    "@color/transparent" "@color/brand_primary_light" "2dp" "16dp"
stroked card_outline  "?attr/colorSurface" "@color/divider" "1dp" "20dp"

# ---------- Circulos ----------
circle() {
cat > "$D/bg_circle_$1.xml" <<XEOF
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="oval">
    <solid android:color="$2" />
</shape>
XEOF
}
circle white     "@android:color/white"
circle primary   "@color/brand_primary"
circle light     "@color/brand_primary_container"
circle secondary "@color/brand_secondary_container"
circle accent    "@color/brand_accent_container"
circle yellow    "@color/brand_yellow_container"
circle surface   "?attr/colorSurfaceVariant"
circle dot       "#33FFFFFF"

# ---------- Burbujas de chat ----------
cat > "$D/bg_bubble_sent.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="@color/chat_bubble_sent" />
    <corners
        android:topLeftRadius="18dp"
        android:topRightRadius="18dp"
        android:bottomLeftRadius="18dp"
        android:bottomRightRadius="4dp" />
</shape>
XEOF

cat > "$D/bg_bubble_received.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="@color/chat_bubble_received" />
    <stroke android:width="1dp" android:color="@color/divider" />
    <corners
        android:topLeftRadius="18dp"
        android:topRightRadius="18dp"
        android:bottomLeftRadius="4dp"
        android:bottomRightRadius="18dp" />
</shape>
XEOF

# ---------- Hoja superior redondeada ----------
cat > "$D/bg_sheet_top.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="?attr/colorSurface" />
    <corners android:topLeftRadius="28dp" android:topRightRadius="28dp" />
</shape>
XEOF

cat > "$D/bg_sheet_handle.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="@color/divider" />
    <corners android:radius="4dp" />
    <size android:width="44dp" android:height="4dp" />
</shape>
XEOF

# ---------- Cabecera curva (auth / perfil) ----------
cat > "$D/bg_header_curve.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <gradient android:angle="315" android:startColor="#7C5CFF" android:endColor="#4B2FD0" />
    <corners android:bottomLeftRadius="36dp" android:bottomRightRadius="36dp" />
</shape>
XEOF

# ---------- Indicador onboarding ----------
cat > "$D/bg_dot_default.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#4DFFFFFF" />
    <corners android:radius="100dp" />
</shape>
XEOF

# ---------- Avatar placeholder ----------
cat > "$D/ic_avatar_placeholder.xml" <<'XEOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="96dp" android:height="96dp"
    android:viewportWidth="96" android:viewportHeight="96">
    <path android:fillColor="#E9E3FF" android:pathData="M0,0h96v96h-96z" />
    <path android:fillColor="#9B85FF"
        android:pathData="M48,50c7.73,0 14,-6.27 14,-14s-6.27,-14 -14,-14 -14,6.27 -14,14 6.27,14 14,14zM48,57c-9.34,0 -28,4.69 -28,14v7h56v-7c0,-9.31 -18.66,-14 -28,-14z" />
</vector>
XEOF

# ---------- Logo SkillSwap ----------
cat > "$D/ic_logo.xml" <<'XEOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="120dp" android:height="120dp"
    android:viewportWidth="120" android:viewportHeight="120">
    <path android:fillColor="#FFFFFF" android:fillAlpha="0.18"
        android:pathData="M60,4L60,4A56,56 0,0 1,116 60L116,60A56,56 0,0 1,60 116L60,116A56,56 0,0 1,4 60L4,60A56,56 0,0 1,60 4z" />
    <path android:fillColor="#FFFFFF"
        android:pathData="M36,50h34v-9l16,15 -16,15v-9H36c-2.2,0 -4,-1.8 -4,-4v-4c0,-2.2 1.8,-4 4,-4z" />
    <path android:fillColor="#00D2B8"
        android:pathData="M84,70H50v9L34,64l16,-15v9h34c2.2,0 4,1.8 4,4v4c0,2.2 -1.8,4 -4,4z" />
</vector>
XEOF

# ---------- Launcher ----------
cat > "$D/ic_launcher_background.xml" <<'XEOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:pathData="M0,0h108v108h-108z">
        <aapt:attr xmlns:aapt="http://schemas.android.com/aapt" name="android:fillColor">
            <gradient android:startX="0" android:startY="0" android:endX="108" android:endY="108"
                android:type="linear">
                <item android:offset="0" android:color="#FF7C5CFF" />
                <item android:offset="1" android:color="#FF4B2FD0" />
            </gradient>
        </aapt:attr>
    </path>
</vector>
XEOF

cat > "$D/ic_launcher_foreground.xml" <<'XEOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <group android:scaleX="0.62" android:scaleY="0.62" android:translateX="20.5" android:translateY="20.5">
        <path android:fillColor="#FFFFFF"
            android:pathData="M30,44h34v-9l17,15.5 -17,15.5v-9H30c-2.2,0 -4,-1.8 -4,-4v-5c0,-2.2 1.8,-4 4,-4z" />
        <path android:fillColor="#00D2B8"
            android:pathData="M78,72H44v9L27,65.5 44,50v9h34c2.2,0 4,1.8 4,4v5c0,2.2 -1.8,4 -4,4z" />
    </group>
</vector>
XEOF

echo "Shapes generados: $(ls "$D"/bg_*.xml | wc -l) fondos"
