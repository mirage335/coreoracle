_process_commKey_search_thread() {
	_messagePlain_nominal 'thread: commKey'
	export metaThread="true"
	_processor_launch _me_processor_commKey_ae_rx
}

_process_commKey_search_stack() {
	[[ "$1" == "$dataDir"'/_'* ]] > /dev/null 2>&1 && return 0
	
	_messagePlain_nominal 'stack: commKey'
	! mkdir -p "$metaProc"/_active && return 1
	
	export processThreadID=$(_uid)
	echo "$$" > "$metaProc"/_active/"$processThreadID"
	
	_set_commFields "$1"
	
	_cycle_me
	#_assign_me_rand_out
	_assign_me_name_out "$2"
	
	_active_me "$processThreadID"
	
	"$scriptAbsoluteLocation" --embed _process_commKey_search_thread "$@" &
}

_process_commKey_search_fork() {
	[[ "$1" == "$dataDir"'/_'* ]] > /dev/null 2>&1 && return 0
	
	_messagePlain_nominal 'fork: commKey'
	_confidence_metaengine && return 0
	
	_self_background > /dev/null 2>&1
	
	local hostThreadCount
	hostThreadCount=$(cat /proc/cpuinfo 2>/dev/null | grep MHz | wc -l | tr -dc '0-9')
	[[ "$hostThreadCount" -gt 48 ]] && hostThreadCount=48
	let hostThreadCount="$hostThreadCount"/2
	[[ "$hostThreadCount" == 0 ]] && hostThreadCount=1
	
	
	local currentActiveProcs
	currentActiveProcs=$(ls -1 "$metaProc"/_active/ | wc -l | tr -dc '0-9')
	
	_messagePlain_probe 'currentActiveProcs= '"$currentActiveProcs"
	
	while [[ "$currentActiveProcs" -gt "$hostThreadCount" ]]
	do
		
		_confidence_metaengine && return 0
		currentActiveProcs=$(ls -1 "$metaProc"/_active/ | wc -l | tr -dc '0-9')
		_messagePlain_probe 'currentActiveProcs= '"$currentActiveProcs"
		sleep 1
	done
	
	#ls -1 "$metaProc"/_active/
	
	"$scriptAbsoluteLocation" --embed _process_commKey_search_stack "$@"
}


# "$1" == in file (message)
# "$2" == out file (response)
_process_commKey_search() {
	! [[ -e "$1" ]] && _messageError 'fail: missing: in file' && return 1
	[[ -e "$2" ]] && _messageError 'fail: exists: out file' && return 1
	
	
	_start_metaengine_host
	
	#_set_commFields_default
	
	_set_me_null_in
	_assign_me_name_out "01_file_in"
	_processor_launch _me_processor_commKey_file_in "$1"
	
	find "$dataDir" -maxdepth 2 -mindepth 2 -type d -exec "$scriptAbsoluteLocation" --embed _process_commKey_search_fork {} "90_search_rx" \;
	#find "$dataDir" -maxdepth 2 -mindepth 2 -type d -exec "$scriptAbsoluteLocation" --embed _process_commKey_search_stack {} "90_search_rx" \;
	
	#_cycle_me
	_assign_me_name_in "90_search_rx"
	_set_me_null_out
	_processor_launch _me_processor_commKey_file_out_plaintext "$metaConfidence" "$2"
	
	#_reset_me_host
	
	_stop_metaengine_wait "$metaConfidence"
	#_stop_metaengine_wait
}

# "$1" == in file (message)
# "$2" == out file (response)
_process_commKey_tx() {
	! [[ -e "$1" ]] && _messageError 'fail: missing: in file' && return 1
	[[ -e "$2" ]] && _messageError 'fail: exists: out file' && return 1
	
	
	_start_metaengine_host
	
	#_set_commFields_default
	
	_set_me_null_in
	_assign_me_name_out "01_file_in"
	_processor_launch _me_processor_commKey_file_in "$1"
	
	_cycle_me
	_assign_me_name_out "02_client_tx"
	_processor_launch _me_processor_commKey_ae_tx
	
	_cycle_me
	_set_me_null_out
	_processor_launch _me_processor_commKey_file_out_transmission "$metaConfidence" "$2"
	
	#_reset_me_host
	
	_stop_metaengine_wait "$metaConfidence"
	#_stop_metaengine_wait
}

# "$1" == in file (message)
# "$2" == out file (response)
_process_commKey_rx() {
	! [[ -e "$1" ]] && _messageError 'fail: missing: in file' && return 1
	[[ -e "$2" ]] && _messageError 'fail: exists: out file' && return 1
	
	
	_start_metaengine_host
	
	#_set_commFields_default
	
	_set_me_null_in
	_assign_me_name_out "01_file_in"
	_processor_launch _me_processor_commKey_file_in "$1"
	
	_cycle_me
	_assign_me_name_out "05_client_rx"
	_processor_launch _me_processor_commKey_ae_rx
	
	_cycle_me
	_set_me_null_out
	_processor_launch _me_processor_commKey_file_out_plaintext "$metaConfidence" "$2"
	
	#_reset_me_host
	
	_stop_metaengine_wait "$metaConfidence"
	#_stop_metaengine_wait
}

# "$1" == in file (message)
# "$2" == out file (response)
_process_commKey_xc() {
	! [[ -e "$1" ]] && _messageError 'fail: missing: in file' && return 1
	[[ -e "$2" ]] && _messageError 'fail: exists: out file' && return 1
	
	
	_start_metaengine_host
	
	#_set_commFields_default
	
	_set_me_null_in
	_assign_me_name_out "01_file_in"
	_processor_launch _me_processor_commKey_file_in "$1"
	
	find "$dataDir" -maxdepth 2 -mindepth 2 -type d -exec "$scriptAbsoluteLocation" --embed _process_commKey_search_fork {} "03_server_search_rx" \;
	
	#_cycle_me
	_assign_me_name_in "03_server_search_rx"
	_assign_me_name_out "04_server_tx"
	_processor_launch _me_processor_commKey_ae_xc
	
	_cycle_me
	_set_me_null_out
	_processor_launch _me_processor_commKey_file_out_transmission "$metaConfidence" "$2"
	
	#_reset_me_host
	
	_stop_metaengine_wait "$metaConfidence"
	#_stop_metaengine_wait
}

# "$1"/shift == in file (message)
# "$2"/shift == out file (response)
_process_commKey_interpreter() {
	! [[ -e "$1" ]] && _messageError 'fail: missing: in file' && return 1
	[[ -e "$2" ]] && _messageError 'fail: exists: out file' && return 1
	
	local currentInFile
	currentInFile="$1"
	shift
	
	local currentOutFile
	currentOutFile="$1"
	shift
	
	
	_start_metaengine_host
	
	#_set_commFields_default
	
	_set_me_null_in
	_assign_me_name_out "01_file_in"
	_processor_launch _me_processor_commKey_file_in "$currentInFile"
	
	find "$dataDir" -maxdepth 2 -mindepth 2 -type d -exec "$scriptAbsoluteLocation" --embed _process_commKey_search_fork {} "03_server_search_rx" \;
	
	#_cycle_me
	_assign_me_name_in "03_server_search_rx"
	_assign_me_name_out "04_server_interpreter"
	_processor_launch _me_processor_commKey_interpreter
	
	_cycle_me
	_assign_me_name_out "05_server_tx"
	_processor_launch _me_processor_commKey_ae_xc
	
	_cycle_me
	_set_me_null_out
	_processor_launch _me_processor_commKey_file_out_transmission "$metaConfidence" "$currentOutFile"
	
	#_reset_me_host
	
	#_stop_metaengine_wait "$currentOutFile"
	_stop_metaengine_wait "$metaConfidence"
	#_stop_metaengine_wait
}
