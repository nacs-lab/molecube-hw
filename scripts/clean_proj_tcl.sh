#!/bin/bash

exec sed -i "$1" -e '/^#  *Generated by /d' -e '/^#  *IP Build [0-9]* on/d'