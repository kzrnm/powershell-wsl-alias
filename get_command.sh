#!/bin/sh
echo -n "$PATH" |
awk -v RS=: '! /^\/mnt\// {print $1}' |
xargs -I{} find {} -type f -follow -executable -maxdepth 1 2>/dev/null |
awk -F"/" '/./{print $NF}' |
grep -v -e '\[' -e '\]' -e '&' -e '-' -e '\\' -e '/' -e '\$' -e '\^' -e ';' -e ':' -e '"' -e "'" -e '<' -e '>' -e '|' -e '?' -e '@' -e '`' -e '%' -e '+' -e '=' -e '~' |
sort |
uniq

