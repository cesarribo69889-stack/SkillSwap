#!/usr/bin/env bash
# Migra los formatos con cantidad a recursos <plurals>.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
A="$ROOT/app/src/main/java/com/skillswap/adapter"
V="$ROOT/app/src/main/java/com/skillswap/view"
S="$ROOT/app/src/main/res/values/strings.xml"

p() { perl -0pi -e "$2" "$1"; }

p "$A/MatchAdapter.java" '
s{holder\.b\.txtExchanges\.setText\(holder\.itemView\.getContext\(\)\.getString\(\s*\n\s*R\.string\.fmt_exchanges_count, u\.getExchangesCount\(\)\)\);}
 {holder.b.txtExchanges.setText(holder.itemView.getResources().getQuantityString(\n                R.plurals.plu_exchanges, u.getExchangesCount(), u.getExchangesCount()));}s'

p "$A/ChallengeAdapter.java" '
s{holder\.b\.txtParticipants\.setText\(holder\.itemView\.getContext\(\)\.getString\(\s*\n\s*R\.string\.fmt_participants_of,\s*\n\s*c\.getParticipantsCount\(\), c\.getMaxParticipants\(\)\)\);}
 {holder.b.txtParticipants.setText(holder.itemView.getResources().getQuantityString(\n                R.plurals.plu_participants_of, c.getMaxParticipants(),\n                c.getParticipantsCount(), c.getMaxParticipants()));}s'

p "$V/challenges/ChallengeDetailActivity.java" '
s{binding\.txtDeadline\.setText\(getString\(R\.string\.fmt_deadline_participants,\s*\n\s*DateUtils\.daysLeft\(c\.getDeadline\(\)\),\s*\n\s*c\.getParticipantsCount\(\), c\.getMaxParticipants\(\)\)\);}
 {binding.txtDeadline.setText(getResources().getQuantityString(\n                R.plurals.plu_deadline_participants, c.getMaxParticipants(),\n                DateUtils.daysLeft(c.getDeadline()),\n                c.getParticipantsCount(), c.getMaxParticipants()));}s'

p "$V/exchange/ExchangeDetailActivity.java" '
s{binding\.txtContractStatus\.setText\(getString\(R\.string\.fmt_contract_active,\s*\n\s*contract\.getSessions\(\), contract\.getSessionDuration\(\)\)\);}
 {binding.txtContractStatus.setText(getResources().getQuantityString(\n                    R.plurals.plu_contract_active, contract.getSessions(),\n                    contract.getSessions(), contract.getSessionDuration()));}s'

p "$V/matches/ExploreFragment.java" '
s{binding\.txtCount\.setText\(getString\(count == 1\s*\n\s*\? R\.string\.fmt_compatible_student\s*\n\s*: R\.string\.fmt_compatible_students, count\)\);}
 {binding.txtCount.setText(getResources().getQuantityString(\n                                R.plurals.plu_compatible_students, count, count));}s'

# Elimina los strings que sustituyen los plurales
for n in fmt_exchanges_count fmt_participants_of fmt_deadline_participants \
         fmt_contract_active fmt_compatible_student fmt_compatible_students \
         exchanges_count; do
  awk -v n="$n" '{ if (index($0, "<string name=\"" n "\">") > 0) next; print }' "$S" > "$S.tmp"
  mv "$S.tmp" "$S"
done

echo "Plurales aplicados."
