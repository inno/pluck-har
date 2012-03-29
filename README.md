# Overview

Replay a HTTP Archive file as close as possible to the request section. If request is successful, store it.

# Usage

1. Open google chrome
2. Open developer console
3. Load page you'd like to pluck something from
4. Right-click on the item in the Network tab and click "Save Entry as HAR"
5. Run this

pluck-har.pl THENAMEOFTHEHARFILE.har

5. Enjoy you're downloads

# Caveats

We have no control over any session information (ala IP or time) stored on the remote system. Some sites expire fast. Something like this might work to pluck things quickly from an expected path.

while (sleep 1); do echo Looking...; find . -name '*.har' -exec perl pluck_har.pl {} \;; done
