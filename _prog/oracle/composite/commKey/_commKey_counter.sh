# "$1" == inputCounterFile
#"$keyFile_counter"
_verify_commFields_counter() {
	[[ -e "$commFields_keyConfig"/randctr ]] && return 0
	
	local currentReplay
	local currentCounter
	local currentCounterTest
	
	currentCounter=$(cat "$keyFile_counter")
	currentComparison=$(cat "$1")
	
	[[ "$currentCounter" == "" ]] && return 1
	[[ "$currentComparison" == "" ]] && return 1
	
	currentReplay=$(bc <<< "$currentComparison"" > ""$currentCounter")
	
	[[ "$currentReplay" != "1" ]] && return 1
	return 0
}

_set_commFields_counter() {
	[[ -e "$commFields_keyConfig"/randctr ]] && cat > /dev/null 2>&1 && head -c 48 /dev/urandom > "$keyFile_counter" && return 0
	
	head -c 48 "$1" > "$keyFile_counter"
}

_advance_commFields_counter_locked() {
	[[ -e "$commFields_keyConfig"/randctr ]] && head -c 48 /dev/urandom > "$keyFile_counter" && return 0
	
	_increment_commFields_counterPlus && return 0
	
	return 1
}

_advance_commFields_counter() {
	( flock 200
_advance_commFields_counter_locked
) 200>"$keyFile_counter".lck
	return
}

_increment_commFields_counterPlus() {
	! [[ -e "$keyFile_counter" ]] && return 1
	
	local keyCounter
	keyCounter=$(cat "$keyFile_counter")
	
	local keyCounterStart
	if [[ "$1" != "" ]] && [[ -e "$1" ]]
	then
		keyCounterStart=$(cat "$1")
	else
		keyCounterStart="$keyCounter"
	fi
	
	local keyCounterNew
	keyCounterNew=$(perl -e 'print sprintf "%048s\n",'\'$(bc <<< "$keyCounterStart"" + ""1")\')
	
	echo -n "$keyCounterNew" > "$keyFile_counter".tmp
	mv "$keyFile_counter".tmp "$keyFile_counter"
	rm -f "$keyFile_counter".tmp
}
