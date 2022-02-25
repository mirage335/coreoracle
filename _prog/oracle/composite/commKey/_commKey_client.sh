# SERVER function must be a separate ORACLE installation. Typically this will be an ssh command.
# Equivalent in functionality to "_query_interpreter" or "_query_test", using encryption/authentication with remote server.
# "$@" == (_SERVERfunction)
_client_commKey() {
	[[ "$1" != "" ]] && [[ -e "$dataDir"/anon/"$1" ]] && ! _set_commFields_anon "$1" > /dev/null 2>&1 && return 1
	shift
	
	! _set_commFields_default  > /dev/null 2>&1 && return 1
	
	_commKey_tx | "$@" | _commKey_rx
}


_client_commKey_generate_commFields-anon_request() {
	
	_messagePlain_nominal 'request: userid'
	
	echo -n NEWU | "$@" | head -c 26 | tr -dc 'a-zA-Z0-9' > "$safeTmp"/userid
	
	! _check_commFields_file_24_alpha "$safeTmp"/userid && _messagePlain_bad 'fail: request' && return 1
	
	_messagePlain_good 'pass: request' && return 0
}

_client_commKey_generate_commFields-anon_RDYU() {
	
	local currentReadiness
	
	_messagePlain_nominal 'request: readiness'
	
	echo -n RDYU_$(head -c 24 "$safeTmp"/userid) | "$@" | head -c 4 | tr -dc 'a-zA-Z0-9' > "$safeTmp"/readiness
	currentReadiness=$(head -c 4 "$safeTmp"/readiness)
	
	[[ "$currentReadiness" != "PASS" ]] && _messagePlain_bad 'fail: readiness' && return 1
	
	_messagePlain_good 'pass: readiness' && return 0
}

_client_commKey_generate_commFields-anon_key() {
	local currentCommand="$1"
	local currentFileOut="$2"
	shift
	shift
	
	_messagePlain_nominal 'request: '"$currentFileOut"
	
	echo -n "$currentCommand"_$(head -c 24 "$safeTmp"/userid) | "$@" | head -c 50 > "$safeTmp"/"$currentFileOut"
	
	! _check_commFields_file_48 "$safeTmp"/"$currentFileOut" && _messagePlain_bad 'fail: request' && return 1
	
	_messagePlain_good 'pass: request' && return 0
}

#Generates new ORACLE installation, including remotely generated anonymous account.
# "$@" == (_CLIENTfunction)
_client_commKey_generate_commFields-anon() {
	_start
	
	_messageNormal 'init: _client_commKey_generate_commFields-anon'
	_safeEcho_newline "$@"
	_messagePlain_probe 'printed: "$@"'
	
	while ! _client_commKey_generate_commFields-anon_request "$@"
	do sleep 1 ; done
	
	while ! _client_commKey_generate_commFields-anon_RDYU "$@"
	do sleep 1 ; done
	
	! _client_commKey_generate_commFields-anon_key GKAU auth "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKDA data "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKEX extra "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKCO counter "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKID clientid "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKST status "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKPA parity "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKEA excessa "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKEB excessb "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKEC excessc "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	! _client_commKey_generate_commFields-anon_key GKED excessd "$@" && _messageError 'FAIL: reject: invalid' && _stop 1
	
	
	! _client_commKey_generate_commFields-anon_RDYU "$@" && _messageError 'FAIL: server: lost: readiness' && _stop 1
	
	_reset_commFields
	
	local currentUserID
	currentUserID=$(head -c 24 "$safeTmp"/userid)
	
	[[ -e "$dataDir"/anon/"$currentUserID" ]]
	! _set_commFields "$dataDir"/anon/"$currentUserID" && _messageError 'FAIL: local: _set_commFields' && _stop 1
	_prepare_commFields
	
	echo -n '0' > "$internalFile_privilege"
	_get_vectortime_local > "$internalFile_addrate"
	
	_prepare_commFields
	
	cp "$safeTmp"/userid "$internalFile_userid"
	
	cp "$safeTmp"/auth "$keyFile_auth"
	cp "$safeTmp"/data "$keyFile_data"
	cp "$safeTmp"/extra "$keyFile_extra"
	cp "$safeTmp"/counter "$keyFile_counter"
	cp "$safeTmp"/clientid "$keyFile_clientid"
	cp "$safeTmp"/status "$keyFile_status"
	cp "$safeTmp"/parity "$keyFile_parity"
	cp "$safeTmp"/excessa "$keyFile_excessa"
	cp "$safeTmp"/excessb "$keyFile_excessb"
	cp "$safeTmp"/excessc "$keyFile_excessc"
	cp "$safeTmp"/excessd "$keyFile_excessd"
	
	head -c 48 /dev/urandom > "$commFields_alt"/randiv
	
	_convert_commFields_unit_hex_static
	
	! _check_commFields && _messageError 'FAIL: local: _check_commFields' && _stop 1
	
	echo -n '1' > "$internalFile_readiness"
	_stop 0
	
	
	_stop
}

# SERVER function must be a separate ORACLE installation. Typically this will be an ssh command.
# "$@" == (_SERVERfunction)
_client_commKey_generate() {
	_client_commKey_generate_commFields-anon "_client_commKey" "$@"
}

_client_commKey_generate_test() {
	_client_commKey_generate_commFields-anon "_query_test"
}

