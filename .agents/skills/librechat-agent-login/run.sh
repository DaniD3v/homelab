#!/bin/sh
set -e
py=$(nix build --no-link --print-out-paths --impure --expr '(builtins.getFlake "nixpkgs").legacyPackages.${builtins.currentSystem}.python3.withPackages (p: [ p.playwright ])')
browsers=$(nix build --no-link --print-out-paths nixpkgs#playwright-driver.browsers)
# An inherited LD_LIBRARY_PATH can load libraries built against a newer glibc and crash Chromium.
exec env -u LD_LIBRARY_PATH PLAYWRIGHT_BROWSERS_PATH="$browsers" "$py/bin/python3" -I "$(dirname "$0")/librechat.py" "$@"
