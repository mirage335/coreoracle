#!/usr/bin/env bash

_sweep() {
	"$shortcutsPath_coreoracle"/pairKey ${FUNCNAME[0]} "$@"
}


_rand() {
	"$shortcutsPath_coreoracle"/pairKey _extractEntropyAlpha 16
}
rand() {
	_rand "$@"
}


_pair_copy() {
	"$shortcutsPath_coreoracle"/pairKey ${FUNCNAME[0]} "$@"
}

_pair_paste() {
	"$shortcutsPath_coreoracle"/pairKey ${FUNCNAME[0]} "$@"
}

_pair-emit() {
	"$shortcutsPath_coreoracle"/pairKey ${FUNCNAME[0]} "$@"
}

_pair() {
	"$shortcutsPath_coreoracle"/pairKey ${FUNCNAME[0]} "$@"
}
pair() {
	_pair "$@"
}




_plan() {
	"$shortcutsPath_coreoracle"/planKey ${FUNCNAME[0]} "$@"
}
plan() {
	_plan "$@"
}


