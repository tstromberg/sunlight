#!/bin/sh
ls -la /proc/*/exe 2>/dev/null | grep '(deleted)'

