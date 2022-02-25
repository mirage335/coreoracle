_assemble_fragKey_flexible_procedure() {
	_messagePlain_nominal 'init: _assemble_fragKey_flexible_procedure'
	
	echo -n > "$fragKey_set"
	
	_select_fragKey_password
	
	! _select_fragKey "$fragKey_flexible"/sub_01 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_02 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_03 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_04 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_05 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_06 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_07 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_08 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_09 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_10 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_11 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
	! _select_fragKey "$fragKey_flexible"/sub_12 && _messagePlain_bad 'fail: missing: key' && _stop_fragKey_noempty 1
}

# WARNING: PREREQUSITE: "_generate_container"
_generate_fragKey_flexible_procedure() {
	_messagePlain_nominal 'init: _generate_fragKey_flexible'
	
	[[ ! -e "$fragKey_container" ]] && _messagePlain_bad 'fail: missing: container' && _stop_fragKey_noempty 1
	[[ ! -e "$fragKey_active" ]] && _messagePlain_bad 'fail: missing: key: header' && _stop_fragKey_noempty 1
	
	mkdir -p -m 700 "$fragKey_flexible_project"
	_extractEntropyAlpha 12 > "$fragKey_flexible_project"/sub_01
	_extractEntropyAlpha 24 > "$fragKey_flexible_project"/sub_02
	_extractEntropyAlpha 48 > "$fragKey_flexible_project"/sub_03
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_04
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_05
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_06
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_07
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_08
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_09
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_10
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_11
	_extractEntropyAlpha 96 > "$fragKey_flexible_project"/sub_12
	
	_messagePlain_nominal '-----REQUEST: mv '"$fragKey_project" "$fragKey_portal"
	_messagePlain_nominal '-----REQUEST: _deploy_fragKey_flexible '"$fragKey_id"
	
	#_deploy_fragKey_flexible_procedure "$fragKey_id"
}

_generate_fragKey_flexible() {
	_generic_fragKey_sub _generate_fragKey_flexible_procedure
}

_deploy_fragKey_flexible_procedure() {
	# Validates use of key_id. Must already be set before other variable set and prepare functions.
	if ! _assign_fragKey_key_id "$1"
	then
		_messageError 'fail: bad: fragKey_id' && _stop_fragKey_noempty 1
	fi
	
	_assemble_fragKey_flexible_procedure
	
	[[ ! -e "$fragKey_container" ]] && _messagePlain_bad 'fail: missing: container' && _stop_fragKey_noempty 1
	[[ ! -e "$fragKey_active" ]] && _messagePlain_bad 'fail: missing: key: header' && _stop_fragKey_noempty 1
	
	# Encrypt header key pack
	_pack_header
	
	# No production use.
	echo -n '1' > "$fragKey_readiness"
	
	_messagePlain_nominal '-----REQUEST: _purge_fragKey_header'
}

_deploy_fragKey_flexible() {
	_generic_fragKey_sub _deploy_fragKey_flexible_procedure "$@"
}

_recover_fragKey_flexible() {
	_generic_fragKey_sub _recover_fragKey_flexible_procedure "$@"
}

# PREREQUSITE: _assign_fragKey_key_id
_recover_fragKey_flexible_procedure() {
	# TODO: Beware a "_fetch" routine or similar may be needed to retrieve keys from sources first
	
	# Validates use of key_id. Must already be set before other variable set and prepare functions.
	if ! _assign_fragKey_key_id "$1"
	then
		_messageError 'fail: bad: fragKey_id' && _stop_fragKey_noempty 1
	fi
	
	_assemble_fragKey_flexible_procedure
	
	_unpack_header
}

_import_fragKey_flexible_procedure() {
	cp "$1" "$fragKey_flexible_project"/"$2"
}

# "$1" == keyID
# "$2" == file
_import_fragKey_flexible() {
	_generic_fragKey_sub _import_fragKey_flexible_procedure "$@"
}

_path_fragKey_flexible_procedure() {
	echo "$fragKey_flexible_project"
	! _assign_fragKey_key_id "$1" && return 1
	mkdir -p -m 700 "$fragKey_flexible_project" > /dev/null 2>&1
}

# "$1" == keyID
_path_fragKey_flexible() {
	_generic_fragKey_sub_silent _path_fragKey_flexible_procedure "$@"
}

