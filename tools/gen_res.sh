#!/usr/bin/env bash
set -e
R="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res"
mkdir -p "$R/menu" "$R/anim" "$R/xml" "$R/values"

cat > "$R/menu/menu_bottom_nav.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@+id/nav_home" android:icon="@drawable/ic_home" android:title="@string/nav_home" />
    <item android:id="@+id/nav_explore" android:icon="@drawable/ic_search" android:title="@string/nav_explore" />
    <item android:id="@+id/nav_exchanges" android:icon="@drawable/ic_swap" android:title="@string/nav_exchanges" />
    <item android:id="@+id/nav_chats" android:icon="@drawable/ic_chat" android:title="@string/nav_chats" />
    <item android:id="@+id/nav_profile" android:icon="@drawable/ic_person" android:title="@string/nav_profile" />
</menu>
XEOF

cat > "$R/values/arrays.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="cycles">
        <item>Ciclo I</item>
        <item>Ciclo II</item>
        <item>Ciclo III</item>
        <item>Ciclo IV</item>
        <item>Ciclo V</item>
        <item>Ciclo VI</item>
        <item>Ciclo VII</item>
        <item>Ciclo VIII</item>
        <item>Ciclo IX</item>
        <item>Ciclo X</item>
        <item>Egresado</item>
    </string-array>

    <string-array name="modalities">
        <item>Presencial</item>
        <item>Virtual</item>
        <item>Ambas</item>
    </string-array>

    <string-array name="levels">
        <item>Básico</item>
        <item>Intermedio</item>
        <item>Avanzado</item>
    </string-array>

    <string-array name="availability_slots">
        <item>Lunes a Viernes - Mañana</item>
        <item>Lunes a Viernes - Tarde</item>
        <item>Lunes a Viernes - Noche</item>
        <item>Sábados - Mañana</item>
        <item>Sábados - Tarde</item>
        <item>Domingos - Mañana</item>
        <item>Domingos - Tarde</item>
    </string-array>
</resources>
XEOF

cat > "$R/xml/backup_rules.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="skillswap_prefs.xml" />
</full-backup-content>
XEOF

cat > "$R/xml/data_extraction_rules.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="sharedpref" path="skillswap_prefs.xml" />
    </cloud-backup>
    <device-transfer>
        <exclude domain="sharedpref" path="skillswap_prefs.xml" />
    </device-transfer>
</data-extraction-rules>
XEOF

anim() {
cat > "$R/anim/$1.xml" <<XEOF
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android">
$2
</set>
XEOF
}
anim slide_in_right '    <translate android:fromXDelta="100%" android:toXDelta="0%" android:duration="250" />
    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="250" />'
anim slide_out_left '    <translate android:fromXDelta="0%" android:toXDelta="-30%" android:duration="250" />
    <alpha android:fromAlpha="1.0" android:toAlpha="0.0" android:duration="250" />'
anim slide_in_left '    <translate android:fromXDelta="-30%" android:toXDelta="0%" android:duration="250" />
    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="250" />'
anim slide_out_right '    <translate android:fromXDelta="0%" android:toXDelta="100%" android:duration="250" />
    <alpha android:fromAlpha="1.0" android:toAlpha="0.0" android:duration="250" />'
anim fade_in '    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="300" />'
anim fade_out '    <alpha android:fromAlpha="1.0" android:toAlpha="0.0" android:duration="300" />'
anim item_fall_down '    <translate android:fromYDelta="18%" android:toYDelta="0" android:duration="260" />
    <alpha android:fromAlpha="0.0" android:toAlpha="1.0" android:duration="260" />'

cat > "$R/anim/layout_animation_fall_down.xml" <<'XEOF'
<?xml version="1.0" encoding="utf-8"?>
<layoutAnimation xmlns:android="http://schemas.android.com/apk/res/android"
    android:animation="@anim/item_fall_down"
    android:delay="12%"
    android:animationOrder="normal" />
XEOF

echo "Recursos auxiliares generados."
