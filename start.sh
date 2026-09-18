#!/bin/sh
# Starts EaglerSPRelay from the folder this script lives in.
# Any arguments are passed through, for example:  ./start.sh --debug
cd "$(dirname "$0")" || exit 1

if ! command -v java >/dev/null 2>&1; then
	echo "ERROR: java is not on your PATH, install a JRE 8 or newer" >&2
	exit 1
fi

# Force UTF-8 so the Chinese help text and config comments render instead of turning into mojibake.
# sun.stdout.encoding is what Java 8 reads, stdout.encoding is what Java 19+ reads; setting both
# keeps the output UTF-8 on any of them and is harmless where it is not recognised.
exec java -Dfile.encoding=UTF-8 -Dsun.stdout.encoding=UTF-8 -Dstdout.encoding=UTF-8 -jar EaglerSPRelay.jar "$@"
