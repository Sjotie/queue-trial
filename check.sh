#!/bin/bash
# The toy gate. A file under things/ decides by one whole line:
#   red    the gate fails, every attempt
#   flaky-until <unix seconds>   the gate fails while the clock is before that moment (a failure that goes away by itself)
#   slow   the gate takes 90 seconds longer (room to do something while it runs)
set -u
rc=0
n=0
for f in things/*.txt; do
  [ -e "$f" ] || continue
  n=$((n + 1))
  if grep -qx 'red' "$f"; then echo "RED: $f"; rc=1; fi
  u=$(sed -n 's/^flaky-until \([0-9][0-9]*\)$/\1/p' "$f" | head -n 1)
  if [ -n "$u" ] && [ "$(date +%s)" -lt "$u" ]; then echo "FLAKY until $u (now $(date +%s)): $f"; rc=1; fi
  if grep -qx 'slow' "$f"; then echo "slow: $f"; sleep 90; fi
done
grep -q '^<<<<<<<' shared.txt && { echo "RED: conflict marker in shared.txt"; rc=1; }
echo "checked $n things: rc $rc"
exit $rc
