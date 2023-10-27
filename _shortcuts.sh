#!/usr/bin/env bash

_sweep() {
	"$shortcutsPath_coreoracle" ${FUNCNAME[0]} "$@"
}


_rand() {
	"$shortcutsPath_coreoracle" ${FUNCNAME[0]} "$@"
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


