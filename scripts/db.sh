#!/bin/bash
cd "/Users/apple/Library/Containers/com.better.pomodoro.ZenDoro/Data/Documents" &&
find . -name "db*" -0|xargs -I{} rm {}