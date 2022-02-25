_commKey_search_sequence() {
	_start
	
	cat > "$safeTmp"/stdin
	
	_set_commKey_metaLog
	echo > "$metaLogFile" 2>&1
	
	"$scriptAbsoluteLocation" _process_commKey_search "$safeTmp"/stdin "$safeTmp"/stdout >> "$metaLogFile" 2>&1
	
	_log_commKey_metaLog_data
	
	! [[ -e "$safeTmp"/stdout ]] && _stop 1
	cat "$safeTmp"/stdout
	_stop
}
_commKey_search() {
	"$scriptAbsoluteLocation" _commKey_search_sequence
}

_set_commKey_metaLog() {
	if [[ "$metaLog" == "" ]] || ! mkdir -p "$metaLog"
	then
		export metaLogFile='/dev/null'
		return 1
	fi
	
	export metaLogFile="$metaLog".log
}

_log_commKey_metaLog_data() {
	if [[ "$metaLog" == "" ]] || ! mkdir -p "$metaLog"
	then
		return 1
	fi
	
	cp -a "$dataDir" "$metaLog"/temple
}

# DANGER: Must NOT set commKey variables outside of script's intended current directory (ie. must not derive from "$dataDir" in any parent process).
# DANGER: Must pass:
#[[ "$commFields_absolute" == "$currentAbsoluteDataDir"* ]] && return 0
_commKey_tx_sequence() {
	_start
	
	cat > "$safeTmp"/stdin
	
	_set_commKey_metaLog
	echo > "$metaLogFile" 2>&1
	
	[[ "$1" != "" ]] && [[ -e "$dataDir"/anon/"$1" ]] && ! _set_commFields_anon "$1" > /dev/null 2>&1 && return 1
	shift
	
	# DANGER: Must NOT override any existing commFields setting, which must be accepted!
	! _set_commFields_default  >> "$metaLogFile" 2>&1 && _stop 1
	
	# DANGER: Although a lock file should prevent it, any attempt to generate transmission twice simultaneously is a user error.
	_messageNormal 'wait: transmission lock' >> "$metaLogFile" 2>&1
	( flock 200
_messagePASS >> "$metaLogFile" 2>&1
"$scriptAbsoluteLocation" _process_commKey_tx "$safeTmp"/stdin "$safeTmp"/stdout  >> "$metaLogFile" 2>&1
) 200>"$internalFile_readiness".lck
	
	_log_commKey_metaLog_data
	
	! [[ -e "$safeTmp"/stdout ]] && _stop 1
	cat "$safeTmp"/stdout
	_stop
}

_commKey_tx() {
	"$scriptAbsoluteLocation" _commKey_tx_sequence "$@"
}

_commKey_rx_sequence() {
	_start
	
	cat > "$safeTmp"/stdin
	
	_set_commKey_metaLog
	echo > "$metaLogFile" 2>&1
	
	[[ "$1" != "" ]] && [[ -e "$dataDir"/anon/"$1" ]] && ! _set_commFields_anon "$1" > /dev/null 2>&1 && return 1
	shift
	
	# WARNING: Must NOT override any existing commFields setting, which must be accepted!
	! _set_commFields_default  >> "$metaLogFile" 2>&1 && _stop 1
	
	"$scriptAbsoluteLocation" _process_commKey_rx "$safeTmp"/stdin "$safeTmp"/stdout  >> "$metaLogFile" 2>&1
	
	_log_commKey_metaLog_data
	
	! [[ -e "$safeTmp"/stdout ]] && _stop 1
	cat "$safeTmp"/stdout
	_stop
}

_commKey_rx() {
	"$scriptAbsoluteLocation" _commKey_rx_sequence "$@"
}

_commKey_xc_sequence() {
	_start
	
	cat > "$safeTmp"/stdin
	
	_set_commKey_metaLog
	echo > "$metaLogFile" 2>&1
	
	"$scriptAbsoluteLocation" _process_commKey_xc "$safeTmp"/stdin "$safeTmp"/stdout >> "$metaLogFile" 2>&1
	
	_log_commKey_metaLog_data
	
	! [[ -e "$safeTmp"/stdout ]] && _stop 1
	cat "$safeTmp"/stdout
	_stop
}

_commKey_xc() {
	"$scriptAbsoluteLocation" _commKey_xc_sequence
}

_commKey_interpreter_sequence() {
	_start
	
	cat > "$safeTmp"/stdin
	
	_set_commKey_metaLog
	echo > "$metaLogFile" 2>&1
	
	"$scriptAbsoluteLocation" _process_commKey_interpreter "$safeTmp"/stdin "$safeTmp"/stdout >> "$metaLogFile" 2>&1
	
	_log_commKey_metaLog_data
	
	! [[ -e "$safeTmp"/stdout ]] && _stop 1
	cat "$safeTmp"/stdout
	_stop
}

_commKey_interpreter() {
	"$scriptAbsoluteLocation" _commKey_interpreter_sequence
}

_setup_commKey() {
	_messageNormal "Generate (commKey)..."
	if ! _check_set_commfields-default > /dev/null
	then
		if ! _generate_commFields
		then
			_messageFAIL
			_stop 1
		fi
	fi
	_messagePASS
	
	if type _check_set_commfields-default > /dev/null 2>&1
	then
		_messageNormal "Configuration..."
		! _check_set_commfields-default > /dev/null && _messageFAIL && _stop 1
		_messagePASS
	fi
	
	if type _query_commKey > /dev/null 2>&1
	then
		_messageNormal "Query..."
		echo -n PASS | "$scriptAbsoluteLocation" _query_commKey > "$safeTmp"/queryResult
		if [[ $(head -c 4 "$safeTmp"/queryResult | tr -dc 'a-zA-Z0-9') != "PASS" ]]
		then
			_messageFAIL
			_stop 1
		fi
		_messagePASS
	fi
}

