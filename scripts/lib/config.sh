#!/bin/bash -e

script="$(readlink -f "$0")"
root="$(cd "$(dirname "$(dirname "$script")")" && pwd)"
