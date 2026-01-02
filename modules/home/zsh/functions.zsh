# Timestamp helper: auto-detect seconds/ms/us/ns and print local/UTC time.
# timestamp() {
#   local input="$1"
#   local len secs ms
#
#   if [ -z "$input" ]; then
#     secs=$(date +%s)
#     ms=$((secs * 1000))
#     echo "epoch_s: $secs"
#     echo "epoch_ms: $ms"
#     return 0
#   fi
#
#   if [[ "$input" != <-> ]]; then
#     echo "ts: expected a numeric timestamp" >&2
#     return 1
#   fi
#
#   len=${#input}
#   if [ "$len" -le 10 ]; then
#     secs=$input
#     ms=$((input * 1000))
#   elif [ "$len" -le 13 ]; then
#     secs=$((input / 1000))
#     ms=$input
#   elif [ "$len" -le 16 ]; then
#     secs=$((input / 1000000))
#     ms=$((input / 1000))
#   else
#     secs=$((input / 1000000000))
#     ms=$((input / 1000000))
#   fi
#
#   echo "input:    $input"
#   echo "epoch_s:  $secs"
#   echo "epoch_ms: $ms"
#   echo "local:    $(date -r "$secs" '+%Y-%m-%d %H:%M:%S %z')"
#   echo "utc:      $(TZ=UTC date -r "$secs" '+%Y-%m-%d %H:%M:%S %Z')"
# }
