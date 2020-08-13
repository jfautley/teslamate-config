# List of helper functions

function sendPushover () {
  source $(dirname $0)/pushover.creds

  local title="$1"
  local message="$2"

  if [ -f "$err" ]; then
    message=$(printf "$message\n\n$(cat $err)")
    rm $err
  fi

  curl -F "token=$pushover_app_key" \
    -F "user=$pushover_user_key" \
    -F "title=$title" \
    -F "message=$message" \
    https://api.pushover.net/1/messages
}

errCheck() {
  local caller="$1"
  local rc=$2
  local err="$3"

  [ $# -lt 2 ] && { echo "errCheck needs both caller and RC"; exit 1; }

  if [ $rc -ne 0 ]; then
    sendPushover "$title" "Backup failed during '$caller' with return code '$rc'" $err
  fi
}
