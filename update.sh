#!/bin/bash
set -e -o pipefail

mbsync journeyfront
notmuch new
notmuch search --output=files --format=text0 to:dmarc@journeyfront.com AND NOT tag:parsed \
        | xargs -0 ln -ft files
fdupes -H files
notmuch tag +parsed to:dmarc@journeyfront.com AND NOT tag:parsed
docker compose run --rm parsedmarc
xdg-open http://localhost:3000/d/SDksirRWz/dmarc-reports
