#!/bin/sh -eux

addgroup --system --gid 999 "$GROUP"
adduser --system --uid 999 --home "$HOME" --shell /bin/bash --ingroup "$GROUP" "$USER"
