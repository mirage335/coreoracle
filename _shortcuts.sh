#!/usr/bin/env bash

_rand() {
	"$shortcutsPath_coreoracle" _extractEntropy "$@"
}
rand() {
	_rand "$@"
}



_pair() {
	"$shortcutsPath_coreoracle"/pairKey "$@"
}
pair() {
	_pair "$@"
}

_plan() {
	"$shortcutsPath_coreoracle"/planKey "$@"
}
plan() {
	_plan "$@"
}

