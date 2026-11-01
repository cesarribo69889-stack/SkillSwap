#!/usr/bin/env bash
# Sustituye las concatenaciones de setText() por getString() con placeholders.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
A="$ROOT/app/src/main/java/com/skillswap/adapter"
V="$ROOT/app/src/main/java/com/skillswap/view"

p() { perl -0pi -e "$2" "$1"; }

# ============================================================ adapters
p "$A/ChatAdapter.java" '
s{String prefix = myUid\.equals\(c\.getLastSenderId\(\)\) \? "Tú: " : "";\s*\n\s*holder\.b\.txtLastMessage\.setText\(prefix \+ c\.getLastMessage\(\)\);}
 {holder.b.txtLastMessage.setText(myUid.equals(c.getLastSenderId())\n                ? holder.itemView.getContext().getString(\n                        R.string.fmt_you_said, c.getLastMessage())\n                : c.getLastMessage());}s'

p "$A/ExchangeAdapter.java" '
s{holder\.b\.txtProgress\.setText\("Sesión " \+ e\.getSessionsDone\(\) \+ " de "\s*\n\s*\+ e\.getSessionsTotal\(\)\);}
 {holder.b.txtProgress.setText(holder.itemView.getContext().getString(\n                    R.string.fmt_session_of, e.getSessionsDone(), e.getSessionsTotal()));}s;
s{holder\.b\.txtProgress\.setText\(e\.getProgress\(\) \+ " % completado"\);}
 {holder.b.txtProgress.setText(holder.itemView.getContext().getString(\n                    R.string.fmt_percent_completed, e.getProgress()));}s'

p "$A/MatchHomeAdapter.java" '
s{holder\.b\.txtTeaches\.setText\("Enseña " \+ join\(m\.getTheyTeachYouWant\(\)\)\);}
 {holder.b.txtTeaches.setText(holder.itemView.getContext().getString(\n                    R.string.fmt_teaches, join(m.getTheyTeachYouWant())));}s;
s{holder\.b\.txtTeaches\.setText\("Busca " \+ join\(m\.getYouTeachTheyWant\(\)\)\);}
 {holder.b.txtTeaches.setText(holder.itemView.getContext().getString(\n                    R.string.fmt_searches, join(m.getYouTeachTheyWant())));}s'

p "$A/MatchAdapter.java" '
s{holder\.b\.txtExchanges\.setText\(u\.getExchangesCount\(\) \+ " intercambios"\);}
 {holder.b.txtExchanges.setText(holder.itemView.getContext().getString(\n                R.string.fmt_exchanges_count, u.getExchangesCount()));}s'

p "$A/ChallengeAdapter.java" '
s{holder\.b\.txtParticipants\.setText\(c\.getParticipantsCount\(\) \+ " de "\s*\n\s*\+ c\.getMaxParticipants\(\) \+ " participantes"\);}
 {holder.b.txtParticipants.setText(holder.itemView.getContext().getString(\n                R.string.fmt_participants_of,\n                c.getParticipantsCount(), c.getMaxParticipants()));}s;
s{holder\.b\.txtProgress\.setText\(c\.getProgress\(\) \+ " %"\);}
 {holder.b.txtProgress.setText(holder.itemView.getContext().getString(\n                R.string.fmt_percent, c.getProgress()));}s'

p "$A/PassportAdapter.java" '
s{holder\.b\.txtRole\.setText\(labelFor\(e\.getRole\(\)\) \+ " · " \+ category\);}
 {holder.b.txtRole.setText(holder.itemView.getContext().getString(\n                R.string.fmt_role_category, labelFor(e.getRole()), category));}s'

p "$A/PointEntryAdapter.java" '
s{holder\.b\.txtPoints\.setText\(\(p\.getPoints\(\) >= 0 \? "\+" : ""\) \+ p\.getPoints\(\)\);}
 {holder.b.txtPoints.setText(holder.itemView.getContext().getString(\n                R.string.fmt_points_delta,\n                p.getPoints() >= 0 ? "+" : "", p.getPoints()));}s'

p "$A/ChallengeParticipantAdapter.java" '
s{holder\.b\.txtSkill\.setText\("Aporta " \+ p\.getSkill\(\)\);}
 {holder.b.txtSkill.setText(holder.itemView.getContext().getString(\n                R.string.fmt_contributes, p.getSkill()));}s'

# ============================================================ imports de R
for f in "$A/ChatAdapter.java" "$A/ExchangeAdapter.java" "$A/MatchHomeAdapter.java" \
         "$A/MatchAdapter.java" "$A/PassportAdapter.java" "$A/PointEntryAdapter.java" \
         "$A/ChallengeParticipantAdapter.java"; do
  grep -q "^import com.skillswap.R;" "$f" || \
    perl -0pi -e 's|^(import com\.skillswap\.databinding\.)|import com.skillswap.R;\n$1|m' "$f"
done

echo "Adapters listos."
