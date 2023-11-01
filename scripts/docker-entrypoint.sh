#!/bin/bash
set -e

RUN_ON_INIT="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/master/scripts/run_on_init"
RUN_ON_INIT_PATH="/usr/local/bin/run_on_init"

get_latest_init_script() {
    wget -O - "$RUN_ON_INIT" > "$RUN_ON_INIT_PATH" 2>/dev/null ||:
    chmod 775 "$RUN_ON_INIT_PATH" 2>/dev/null ||:
}

if [ "$SETUP_STATUS" = "production" ]; then
    get_latest_init_script ||:
fi

"$RUN_ON_INIT_PATH"

exec "$@"