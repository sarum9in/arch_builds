#!/bin/bash -e

script="$(readlink -f "$0")"
root="$(cd "$(dirname "$(dirname "$script")")" && pwd)"
scriptsdir="$root/scripts"
bindir="$scriptsdir/bin"
libdir="$scriptsdir/lib"

repo_name="mirror.cs.istu.ru"
