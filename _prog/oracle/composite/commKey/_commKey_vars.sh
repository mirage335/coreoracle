# "$1" == "commFields" (directory)
_set_commFields_unit_privilege_true() {
	_set_commFields "$1"
	! _check_commFields && return 1
	_set_commFields_privilege_true
}

_set_commFields_privilege_true() {
	echo -n '1' | _assign_commFields_unit_privilege
}

# stdin == '0' || '1'
_assign_commFields_unit_privilege() {
	head -c '1' > "$internalFile_privilege"
}

_random_commfields_iV() {
	head -c 48 /dev/urandom > "$commFields_alt"/randiv.tmp
	mv "$commFields_alt"/randiv.tmp "$commFields_alt"/randiv
	rm -f "$commFields_alt"/randiv.tmp
	
	return 0
}

_convert_commFields_unit_hex_static() {
	xxd -p "$keyFile_auth" | tr -d '\n' > "$keyFile_auth".hex
	xxd -p "$keyFile_data" | tr -d '\n' > "$keyFile_data".hex
	xxd -p "$keyFile_extra" | tr -d '\n' > "$keyFile_extra".hex
	
	xxd -p "$keyFile_parity" | tr -d '\n' > "$keyFile_parity".hex
	
	xxd -p "$keyFile_excessa" | tr -d '\n' > "$keyFile_excessa".hex
	xxd -p "$keyFile_excessb" | tr -d '\n' > "$keyFile_excessb".hex
	xxd -p "$keyFile_excessc" | tr -d '\n' > "$keyFile_excessc".hex
	xxd -p "$keyFile_excessd" | tr -d '\n' > "$keyFile_excessd".hex
	
	xxd -p "$commFields_alt"/randiv | tr -d '\n' > "$commFields_alt"/randiv.hex
}

# "$1" == "commFields" (directory)
# "$2" == "commid" (24bytes limited char)
_generate_commFields_unit() {
	# DO NOT OVERWRITE.
	[[ -e "$1" ]] && return 0
	
	! _set_commFields "$1" && return 1
	_prepare_commFields
	
	echo -n '0' > "$internalFile_privilege"
	_get_vectortime_local > "$internalFile_addrate"
	
	#UserID need not be unique to each key.
	echo -n "$2" > "$internalFile_userid"
	
	_extractEntropyBin 48 > "$keyFile_auth"
	_extractEntropyBin 48 > "$keyFile_data"
	_extractEntropyBin 48 > "$keyFile_extra"
	
	#_extractEntropyBin 48 > "$keyFile_counter"
	#echo > "$commFields_keyConfig"/randctr
	echo -n '000000000000000000000000000000000000000000000000' > "$keyFile_counter"
	
	#ClientID always unique to each key.
	_extractEntropyBin 48 > "$keyFile_clientid"
	
	_extractEntropyBin 48 > "$keyFile_status"
	
	_extractEntropyBin 48 > "$keyFile_parity"
	
	_extractEntropyBin 48 > "$keyFile_excessa"
	_extractEntropyBin 48 > "$keyFile_excessb"
	_extractEntropyBin 48 > "$keyFile_excessc"
	_extractEntropyBin 48 > "$keyFile_excessd"
	
	head -c 48 /dev/urandom > "$commFields_alt"/randiv
	
	ssh-keygen -q -f "$commFields_alt"/id_rsa -N '' -b 4096 -t rsa -C 'oracle@'"$generate_commid"
	
	_convert_commFields_unit_hex_static
	
	! _check_commFields && return 1
	
	echo -n '1' > "$internalFile_readiness"
	return 0
}

# "$1" == "commid" (optional, 24bytes limited char)
# "$2" == "name/" (optional)
_generate_commFields_commid() {
	local generate_commid
	
	generate_commid="$1"
	[[ "$generate_commid" == "" ]] && generate_commid=$(_extractEntropyAlpha 24)
	
	local currentNamePath
	currentNamePath="$2"
	[[ "$currentNamePath" == "" ]] && currentNamePath="anon"/
	
	
	#! _generate_commFields_unit "$dataDir"/"$generate_commid" "$generate_commid" && return 1
	! _generate_commFields_unit "$dataDir"/"$currentNamePath""$generate_commid"_1 "$generate_commid" && return 1
	! _generate_commFields_unit "$dataDir"/"$currentNamePath""$generate_commid"_2 "$generate_commid" && return 1
	! _generate_commFields_unit "$dataDir"/"$currentNamePath""$generate_commid"_3 "$generate_commid" && return 1
}

_generate_commFields_config() {
	true
	
	#_generate_commFields_commid "" "servername"/
}

_generate_commFields() {
	mkdir -p "$dataDir"/anon
	
	_generate_commFields_commid "" "test"/
	_generate_commFields_commid "" "default"/
	
	find "$dataDir"/test -mindepth 1 -maxdepth 1 -type d -exec "$scriptAbsoluteLocation" _set_commFields_unit_privilege_true {} \;
	find "$dataDir"/default -mindepth 1 -maxdepth 1 -type d -exec "$scriptAbsoluteLocation" _set_commFields_unit_privilege_true {} \;
	
	_reset_commFields
	
	return 0
}

_generate_commFields-anon() {
	local generate_commid
	generate_commid=$(_extractEntropyAlpha 24)
	
	
	! _generate_commFields_unit "$dataDir"/anon/"$generate_commid" "$generate_commid" > /dev/null 2>&1 && return 1
	
	echo -n "$generate_commid"
	
	return 0
}

_prepare_commFields() {
	mkdir -p -m 700 "$commFields_internal"
	
	mkdir -p -m 700 "$commFields_alt"
	
	mkdir -p -m 700 "$commFields_key"
	mkdir -p -m 700 "$commFields_keyConfig"
	mkdir -p -m 700 "$commFields_keyLog"
	
	mkdir -p -m 700 "$commFields_time"
	mkdir -p -m 700 "$commFields_stats"
	
	mkdir -p -m 700 "$commFields_diag"
}

_reset_commFields() {
	export commFields_absolute=''
	export commFields_commid_basename=''
	
	export internalFile_userid=''
	export internalFile_privilege=''
	export internalFile_addrate=''
	export internalFile_readiness=''
	
	export commFields_internal=''
	export commFields_alt=''
	export commFields_key=''
	export commFields_keyConfig=''
	export commFields_keyLog=''
	export commFields_time=''
	export commFields_stats=''
	export commFields_diag=''
	
	export keyFile_auth=''
	export keyFile_data=''
	export keyFile_extra=''
	
	export keyFile_counter=''
	
	export keyFile_clientid=''
	
	export keyFile_status=''
	
	export keyFile_parity=''
	
	export commfields_fileDir=''
	
	return 0
}

# "$1" == commFields (directory)
_check_commFields_dir() {
	[[ ! -d "$commFields_absolute" ]] && _messageError 'fail: commFields: not dir' && _reset_commFields && return 1
	
	local commFields_absolute_count=$(echo -n "$commFields_commid_basename" | wc -c | tr -dc '0-9')
	
	[[ "$commFields_absolute_count" -lt  "24" ]] && _messageError 'fail: commFields_userid_basename: insufficient bytes' && _reset_commFields && return 1
	
	return 0
}

_check_commFields_userid() {
	! [[ -e "$internalFile_userid" ]] && _messageError 'fail: missing: internalFile_userid= '"$internalFile_userid" && return 1
	
	local currentUseridFileReadoutCount
	currentUseridFileReadoutCount=$(cat "$internalFile_userid" | tr -dc 'a-zA-Z0-9' | wc -c | tr -dc '0-9')
	
	! [[ "$currentUseridFileReadoutCount" -ge '24' ]] && _messageError 'fail: internalFile_userid: insufficient bytes' && return 1
	! [[ "$currentUseridFileReadoutCount" -le '96' ]] && _messageError 'fail: internalFile_userid: overflow bytes' && return 1
	
	local currentUseridFileReadout
	currentUseridFileReadout=$(cat "$internalFile_userid" | tr -dc 'a-zA-Z0-9')
	
	if ! echo -n "$commFields_commid_basename" | grep "$currentUseridFileReadout" >/dev/null 2>&1
	then
		_messageError 'fail: mismatch: dir: commid' && _reset_commFields && return 1
	fi
	
	#_messageError 'fail: experiment' && return 1
	
	return 0
}

# "$1" == commFields (directory)
_check_commFields() {
	! _check_commFields_dir && return 1
	! _check_commFields_userid && return 1
	
	
	local currentVarCharCount
	
	currentVarCharCount=$(cat "$keyFile_auth" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_auth: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_data" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_data: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_extra" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_extra: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_counter" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_counter: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_clientid" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_clientid: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_status" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_status: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_parity" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_parity: insufficient bytes' && _reset_commFields && return 1
	
	currentVarCharCount=$(cat "$keyFile_excessa" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_excessa: insufficient bytes' && _reset_commFields && return 1
	currentVarCharCount=$(cat "$keyFile_excessb" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_excessb: insufficient bytes' && _reset_commFields && return 1
	currentVarCharCount=$(cat "$keyFile_excessc" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_excessc: insufficient bytes' && _reset_commFields && return 1
	currentVarCharCount=$(cat "$keyFile_excessd" | wc -c | tr -dc '0-9')
	[[ "$currentVarCharCount" != "48" ]] && _messageError 'fail: keyFile_excessd: insufficient bytes' && _reset_commFields && return 1
	
	return 0
}

_check_set_commfields-default() {
	! _set_commFields-default && return 1
	
	! _check_commFields && return 1
	
	! [[ "$commFields_absolute" == "$currentAbsoluteDataDir"* ]] && return 1
	
	return 0
}

_set_commFields-test() {
	local currentFiles
	#currentFiles=( "$dataDir""/test/"*"_1" )
	#_set_commFields "${currentFiles[0]}"
	
	currentFiles=$(find "$dataDir"/test -name '*_1' 2> /dev/null | head -n 1)
	[[ "$currentFiles" != "" ]] && [[ -d "$currentFiles" ]] && _set_commFields "$currentFiles"
}

_set_commFields_test() {
	local currentAbsoluteDataDir=$(_getAbsoluteLocation "$dataDir")
	
	[[ "$commFields_absolute" == "$currentAbsoluteDataDir"* ]] && return 0
	
	_set_commFields-test
}

_set_commFields-default() {
	#https://unix.stackexchange.com/questions/156205/how-can-i-get-the-first-match-from-wildcard-expansion
	local currentFiles
	#currentFiles=( "$dataDir""/default/"*"_1" )
	#_set_commFields "${currentFiles[0]}"
	
	currentFiles=$(find "$dataDir"/default -name '*_1' 2> /dev/null | head -n 1)
	[[ "$currentFiles" != "" ]] && [[ -d "$currentFiles" ]] && _set_commFields "$currentFiles"
}

_set_commFields_default() {
	local currentAbsoluteDataDir=$(_getAbsoluteLocation "$dataDir")
	
	[[ "$commFields_absolute" == "$currentAbsoluteDataDir"* ]] && return 0
	
	_set_commFields-default
}

# "$1" == commid file
_set_commFields_anon() {
	local currentAnonCommID
	currentAnonCommID=$(_safeEcho "$1" | head -c 26 | tr -dc 'a-zA-Z0-9' )
	local currentAnonCommIDcount
	currentAnonCommIDcount=$(echo "$currentAnonCommID" | wc -c | tr -dc '0-9')
	
	if [[ "$currentAnonCommIDcount" -lt '24' ]]
	then
		_set_commFields_default
		return 1
	fi
	
	_set_commFields "$dataDir"/anon/"$currentAnonCommID"
	
	_set_commFields_default
}

# "$1" == commFields (directory)
_set_commFields() {
	_messagePlain_probe '_set_commFields '"$1"
	mkdir -p -m 700 "$1"
	
	export commFields_absolute=$(_getAbsoluteLocation "$1")
	export commFields_commid_basename=$(basename "$commFields_absolute")
	
	! _check_commFields_dir && return 1
	
	export commFields_internal="$commFields_absolute"/internal
	
	export commFields_alt="$commFields_absolute"/alt
	
	export commFields_key="$commFields_absolute"/kd
	export commFields_keyConfig="$commFields_absolute"/kc
	export commFields_keyLog="$commFields_absolute"/kl
	
	export commFields_time="$commFields_absolute"/time
	export commFields_stats="$commFields_absolute"/stats
	
	export commFields_diag="$commFields_absolute"/diag
	
	! _set_commFields_internal "$1" && return 1
	
	! _set_commFields_key "$1" && return 1
	
	#! _set_commFields_fileDir && return 1
	
	return 0
}

_set_commFields_internal() {
	# No production use.
	export internalFile_userid="$commFields_internal"/userid
	
	export internalFile_privilege="$commFields_internal"/privilege
	
	export internalFile_addrate="$commFields_internal"/addrate
	
	export internalFile_readiness="$commFields_internal"/readiness
}

_set_commFields_key() {
	export keyFile_auth="$commFields_key"/auth
	export keyFile_data="$commFields_key"/data
	export keyFile_extra="$commFields_key"/extra
	
	export keyFile_excessa="$commFields_key"/excessa
	export keyFile_excessb="$commFields_key"/excessb
	export keyFile_excessc="$commFields_key"/excessc
	export keyFile_excessd="$commFields_key"/excessd
	
	export keyFile_counter="$commFields_key"/counter
	
	export keyFile_clientid="$commFields_key"/clientid
	
	export keyFile_status="$commFields_key"/status
	
	export keyFile_parity="$commFields_key"/parity
}

_set_commFields_fileDir() {
	! _check_commFields_userid && return 1
	
	local currentUseridFileReadout
	currentUseridFileReadout=$(cat "$internalFile_userid" | tr -dc 'a-zA-Z0-9')
	
	export commfields_fileDir="$fileDir"/"$currentUseridFileReadout"
	mkdir -p -m 700 "$commfields_fileDir"
	
	! [[ -e "$commfields_fileDir" ]] && return 1
	return 0
}

#Counts valid characters in commFields file
_count_commFields_file() {
	head -c 50 "$1" 2>/dev/null | wc -c | tr -dc '0-9'
}

_count_commFields_file_alpha() {
	head -c 50 "$1" 2>/dev/null | tr -dc 'a-zA-Z0-9' | wc -c | tr -dc '0-9'
}

_check_commFields_file_24() {
	[[ ! -e "$1" ]] && return 0
	[[ $(_count_commFields_file "$1") != '24' ]] && return 1
	return 0
}
_check_commFields_file_24_alpha() {
	[[ ! -e "$1" ]] && return 0
	[[ $(_count_commFields_file_alpha "$1") != '24' ]] && return 1
	return 0
}

_check_commFields_file_48() {
	[[ ! -e "$1" ]] && return 0
	[[ $(_count_commFields_file "$1") != '48' ]] && return 1
	return 0
}

_check_commFields_file_48_alpha() {
	[[ ! -e "$1" ]] && return 0
	[[ $(_count_commFields_file_alpha "$1") != '48' ]] && return 1
	return 0
}




