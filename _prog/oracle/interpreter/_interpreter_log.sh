_commKey_interpreter_addrate_log() {
	( flock 200

# Put here your commands that must do some writes atomically
_get_vectortime_local 2>/dev/null > "$internalFile_addrate".tmp
mv "$internalFile_addrate".tmp "$internalFile_addrate"

) 200>"$internalFile_addrate".lck
}

_commKey_interpreter_addrate_log_elapsed() {
	! [[ -e "$internalFile_addrate" ]] && return 0
	
	local currentAddRate
	currentAddRate=$(cat "$internalFile_addrate")
	
	local currentTime=$(_get_vectortime_local)
	
	local currentWaitElapsed
	currentWaitElapsed=$(bc <<< "$currentTime - $currentAddRate")
	
	echo "$currentWaitElapsed"
}


_commKey_interpreter_log_recent() {
	! [[ -e "$commFields_keyLog"/kl ]] && return 1
	tail -n 1 "$commFields_keyLog"/kl
}

_commKey_interpreter_log_read() {
	! [[ -e "$commFields_keyLog"/kl ]] && return 1
	cat "$commFields_keyLog"/kl
}

#https://unix.stackexchange.com/questions/274498/performing-atomic-write-operations-in-a-file-in-bash
_commKey_interpreter_log_overwrite() {
	( flock 200

# Put here your commands that must do some writes atomically
_get_vectortime_local > "$commFields_keyLog"/kl.tmp
mv "$commFields_keyLog"/kl.tmp "$commFields_keyLog"/kl

) 200>"$commFields_keyLog"/kl.lck
}

_commKey_interpreter_log_append() {
	_commKey_interpreter_log_append_unlimited "$@"
	_commKey_interpreter_log_truncate_limit "$@"
}

_commKey_interpreter_log_append_unlimited() {
	( flock 200

# Put here your commands that must do some writes atomically
cp "$commFields_keyLog"/kl "$commFields_keyLog"/kl.tmp > /dev/null 2>&1
_get_vectortime_local >> "$commFields_keyLog"/kl.tmp
mv "$commFields_keyLog"/kl.tmp "$commFields_keyLog"/kl

) 200>"$commFields_keyLog"/kl.lck
}

_commKey_interpreter_log_truncate_limit() {
	! [[ -e "$commFields_keyLog"/kl ]] && return 1
	
	( flock 200

# Put here your commands that must do some writes atomically
tail -n 10000 "$commFields_keyLog"/kl > "$commFields_keyLog"/kl.tmp
mv "$commFields_keyLog"/kl.tmp "$commFields_keyLog"/kl

) 200>"$commFields_keyLog"/kl.lck
}

_commKey_interpreter_log_truncate_short() {
	! [[ -e "$commFields_keyLog"/kl ]] && return 1
	
	export currentTruncateOffset="$RANDOM"
	let "currentTruncateOffset %= 10"
	let "currentTruncateOffset += 5"
	
	export currentTruncateOffset
	
	( flock 200

# Put here your commands that must do some writes atomically
tail -n "$currentTruncateOffset" "$commFields_keyLog"/kl > "$commFields_keyLog"/kl.tmp
mv "$commFields_keyLog"/kl.tmp "$commFields_keyLog"/kl

) 200>"$commFields_keyLog"/kl.lck
	export currentTruncateOffset='' > /dev/null 2>&1
	unset currentTruncateOffset > /dev/null 2>&1
}

_commKey_interpreter_log_truncate() {
	_commKey_interpreter_log_truncate_short "$@"
}

_commKey_interpreter_log_sweep() {
	( flock 200

# Put here your commands that must do some writes atomically
mv "$commFields_keyLog"/kl "$commFields_keyLog"/kl.tmp
_sweep "$commFields_keyLog"/kl.tmp

) 200>"$commFields_keyLog"/kl.lck
}
