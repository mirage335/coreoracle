_generate_fragKey_header() {
	_messageNormal 'init: _generate_fragKey_header'
	if ! "$scriptAbsoluteLocation" _generate_fragKey_header_sequence "$@"
	then
		_messageError 'FAIL'
		return 1
	fi
}

_generate_fragKey_container_procedure() {
	_messagePlain_nominal 'init: _generate_fragKey_container'
	
	[[ -e "$fragKey_container" ]] && _messagePlain_bad 'fail: exists: container' && _stop 1
	[[ -e "$fragKey_registration" ]] && _messagePlain_bad 'fail: exists: registration' && _stop 1
	
	local currentBytes
	local currentOutFile
	
	#100MB default
	currentBytes="$1"
	[[ "$currentBytes" == "" ]] && currentBytes=100000000
	
	currentOutFile="$fragKey_container"
	
	_cipherRand_parallel | head -c "$currentBytes" > "$currentOutFile"
	
	_uid 26 > "$fragKey_registration"
	
	_messagePlain_good 'pass: _generate_fragKey_container'
}

_generate_fragKey_container_sequence() {
	_start
	
	_set_fragKey
	_set_fragKey_key_rand
	_set_fragKey_key_assembly
	_set_fragKey_key_volume
	
	_prepare_fragKey
	_prepare_fragKey_assembly
	_prepare_fragKey_volume
	
	#if ! _generate_fragKey_header_procedure
	#then
	#	_stop 1
	#fi
	
	if ! _generate_fragKey_container_procedure "$1"
	then
		_stop 1
	fi
	
	_stop_fragKey_noempty
}

_generate_fragKey_container() {
	_messageNormal 'init: _generate_fragKey_container'
	if ! "$scriptAbsoluteLocation" _generate_fragKey_container_sequence "$@"
	then
		_messageError 'FAIL'
		return 1
	fi
}

# DANGER: Deletes active header key.
_purge_fragKey_header_procedure() {
	_messagePlain_nominal 'init: _purge_fragKey_header'
	
	[[ ! -e "$fragKey_active" ]] && _messagePlain_warn 'warn: missing: key: header' && return 0
	
	_sweep "$fragKey_active"
	[[ -e "$fragKey_active" ]] && _messagePlain_bad 'fail: exists: key: header' && return 1
	_messagePlain_good 'pass: _purge_fragKey_header'
}

_purge_fragKey_header_sequence() {
	_start
	
	_set_fragKey
	_set_fragKey_key_rand
	_set_fragKey_key_assembly
	_set_fragKey_key_volume
	
	_prepare_fragKey
	_prepare_fragKey_assembly
	_prepare_fragKey_volume
	
	if ! _purge_fragKey_header_procedure
	then
		_stop 1
	fi
	
	_stop_fragKey_noempty
}

_purge_fragKey_header() {
	_messageNormal 'init: _purge_fragKey_header'
	if ! "$scriptAbsoluteLocation" _purge_fragKey_header_sequence "$@"
	then
		_messageError 'FAIL'
		return 1
	fi
}

_purge_fragKey_container_procedure() {
	#! _purge_fragKey_header_procedure && return 1
	
	_messagePlain_nominal 'init: _purge_fragKey_container'
	
	[[ ! -e "$fragKey_container" ]] && _messagePlain_warn 'warn: missing: container' && return 0
	
	rm -f "$fragKey_container"
	[[ -e "$fragKey_container" ]] && _messagePlain_bad 'fail: exists: container' && return 1
	
	rm -f "$fragKey_registration"
	[[ -e "$fragKey_registration" ]] && _messagePlain_bad 'fail: exists: registration' && return 1
	
	_messagePlain_good 'pass: _purge_fragKey_container'
}

_purge_fragKey_container_sequence() {
	_start
	
	_set_fragKey
	_set_fragKey_key_rand
	_set_fragKey_key_assembly
	_set_fragKey_key_volume
	
	_prepare_fragKey
	_prepare_fragKey_assembly
	_prepare_fragKey_volume
	
	if ! _purge_fragKey_container_procedure
	then
		_stop 1
	fi
	
	_stop_fragKey_noempty
}

# DANGER: Deletes container (and registration), destroying all data (if any).
_purge_fragKey_container() {
	_messageNormal 'init: _purge_fragKey_container'
	if ! "$scriptAbsoluteLocation" _purge_fragKey_container_sequence "$@"
	then
		_messageError 'FAIL'
		return 1
	fi
}
