#!/bin/bash

# A script that downloads DMARC report messages and passes them to a parser.
# These can be viewed in the Grafana report dashboard that is opened when finished.

# Typical bash incantation to make it behave more like a "real" programming language.
# Exit on errors and also treat fails in the middle of a pipeline as an error.
set -e -o pipefail

# First we download my email the `mbsync` command from isync, preconfigured with a
# profile named "journeyfront".

mbsync journeyfront

# Next we index the downloaded mail with `notmuchh`

notmuch new --quiet 2> /dev/null

# Now we use the notmuch index to get the filenames of DMARC report emails that have not
# been processed, and hardlink those files into the input directory.
notmuch search --output=files --format=text0 to:dmarc@journeyfront.com AND NOT tag:parsed \
        | xargs -0 ln -ft files 2> /dev/null \
	|| echo "No new mail. Goodbye" \
	; exit 1

# Remove duplicate files, just in case.
fdupes -H files

# Run the `parsedmarc` container.
docker compose run --rm parsedmarc

# Mark exported files as parsed.
notmuch tag +parsed -unread -inbox to:dmarc@journeyfront.com AND NOT tag:parsed

# Open the browser into the report dashboard.
xdg-open http://localhost:3000/d/SDksirRWz/dmarc-reports
