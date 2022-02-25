_prepare_query_prog_copy() {
	cp -a "$dataDir" "$ub_queryclientdir"/temple
	cp -a "$dataDir" "$ub_queryserverdir"/temple
	
	mkdir -p "$fileDir"
	cp -a "$fileDir" "$ub_queryclientdir"/pyre
	cp -a "$fileDir" "$ub_queryserverdir"/pyre
}

_prepare_query_prog_relink() {
	cp -a "$dataDir" "$ub_queryclientdir"/temple
	_relink_relative "$dataDir" "$ub_queryserverdir"/temple
	
	mkdir -p "$fileDir"
	cp -a "$fileDir" "$ub_queryclientdir"/pyre
	_relink_relative "$fileDir" "$ub_queryserverdir"/pyre
}

_query_diag_sequence() {
	_start
	
	_timeout 1 cat - > "$safeTmp"/stdin
	
	[[ $(cat "$safeTmp"/stdin | wc -c | tr -dc '0-9') == '0' ]] && echo -n PASS > "$safeTmp"/stdin
	
	cat "$safeTmp"/stdin | "$@"
	local currentExitStatus="$?"
	
	echo
	_messagePlain_nominal 'diag: tx.log'
	_report_query_stdout "$queryTmp"/01_tx.log
	
	_messagePlain_nominal 'diag: xc.log'
	_report_query_stdout "$queryTmp"/02_xc.log
	
	_messagePlain_nominal 'diag: rx.log'
	_report_query_stdout "$queryTmp"/03_rx.log
	
	sleep 9999
	
	_stop "$currentExitStatus"
}

_query_diag() {
	#_set_commFields-test
	#_set_commFields_default
	"$scriptAbsoluteLocation" _query_diag_sequence _query_search "$@"
}

_query_diag_interpreter() {
	#_set_commFields-test
	#_set_commFields_default
	"$scriptAbsoluteLocation" _query_diag_sequence _query_interpreter "$@"
}

# WARNING: Intended to make changes to local directories (server). Do not expect typical query sandboxed diagnostics.
_query_interpreter_persistent() {
	_reset_commFields
	
	_prepare_query
	_prepare_query_prog_relink
	
	#! _set_commFields_default  > /dev/null 2>&1 && _stop 1
	
	cat | ( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_01_client_tx ; _queryClient _bin tee "$queryTmp"/in | _log_query "$queryTmp"/01_tx.log ) > /dev/null 2>&1
	
	
	( cd "$qs" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_02_server_xc ; _queryServer _interpreter "$queryTmp"/in "$queryTmp"/out "$internalFile_privilege" | _log_query "$queryTmp"/02_xc.log ) > /dev/null 2>&1
	
	
	if [[ -e "$queryTmp"/out ]]
	then
		cat "$queryTmp"/out | ( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
		! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
		export metaLog="$queryTmp"/_03_client_rx ; _queryClient _bin cat | _log_query "$queryTmp"/03_rx.log ; return "${PIPESTATUS[0]}")
	fi
}

_query_interpreter() {
	"$scriptAbsoluteLocation" _query_interpreter_persistent "$@"
}

# WARNING: Intended to make changes to local directories (server, test). Do not expect typical query sandboxed diagnostics.
_query_test_persistent() {
	_reset_commFields
	
	_prepare_query
	_prepare_query_prog_relink
	
	#! _set_commFields_test  > /dev/null 2>&1 && _stop 1
	
	cat | ( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_test  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_01_client_tx ; _queryClient _bin tee "$queryTmp"/in | _log_query "$queryTmp"/01_tx.log ) > /dev/null 2>&1
	
	
	( cd "$qs" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_test  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_02_server_xc ; _queryServer _interpreter "$queryTmp"/in "$queryTmp"/out "$internalFile_privilege" | _log_query "$queryTmp"/02_xc.log ) > /dev/null 2>&1
	
	
	if [[ -e "$queryTmp"/out ]]
	then
		cat "$queryTmp"/out | ( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
		! _set_commFields_test  > /dev/null 2>&1 && _stop 1 ;
		export metaLog="$queryTmp"/_03_client_rx ; _queryClient _bin cat | _log_query "$queryTmp"/03_rx.log ; return "${PIPESTATUS[0]}")
	fi
}

_query_test() {
	"$scriptAbsoluteLocation" _query_test_persistent "$@"
}

_query_search() {
	_reset_commFields
	
	_prepare_query
	_prepare_query_prog_copy
	
	( cd "$qc" ;# _set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_01_client_tx ; _queryClient _commKey_tx | _log_query "$queryTmp"/01_tx.log |
	
	( cd "$qs" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_02_server_xc ; _queryServer _commKey_interpreter | _log_query "$queryTmp"/02_xc.log |
	
	( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_03_client_rx ; _queryClient _commKey_search | _log_query "$queryTmp"/03_rx.log
	return "${PIPESTATUS[0]}")))
}

# Example and test case only. Does not directly reflect any expected real use case.
_query_direct() {
	_reset_commFields
	
	_prepare_query
	_prepare_query_prog_copy
	
	#_set_commFields-test > /dev/null 2>&1
	#! _set_commFields_default  > /dev/null 2>&1 && _stop 1
	
	( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_01_client_tx ; _queryClient _commKey_tx | _log_query "$queryTmp"/01_tx.log |
	
	( cd "$qs" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_02_server_xc ; _queryServer _commKey_interpreter | _log_query "$queryTmp"/02_xc.log |
	
	( cd "$qc" ; #_set_commFields-test > /dev/null 2>&1 ;
	! _set_commFields_default  > /dev/null 2>&1 && _stop 1 ;
	export metaLog="$queryTmp"/_03_client_rx ; _queryClient _commKey_rx | _log_query "$queryTmp"/03_rx.log
	return "${PIPESTATUS[0]}")))
}

_query() {
	_query_search "$@"
}

# Used as test within "_setup" or similar.
_query_commKey() {
	_query "$@"
}
