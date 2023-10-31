
# NOTICE: Transmits relatively long symmetric key, assuming much stronger signal-to-noise ratio for the intended receiver. Can be a post-quantum technique to establish a separate, shared secret, though only through a longer protocol, not by itself, as it would be far more efficient to bidirectionally agree which messages have or have not been received, than to rely on complete reception of a single large key.

# ATTENTION: May also be used as an 'all-or-nothing' proof of reception of the entire key (which is also plainly sent). For now, this is more or less the expected use case, if any.


_band-output() {
	if [[ "$FORCE_PURE" ]]
	then
		cat
		return
	else
		base64
		return
	fi
}

_band() {
	_start
	
	local currentMessageSimple
	currentMessageSimple=$(cat | base64)
	
	# Key size. Maybe think of bytes entropy (7B), redundancy (4s/B), minimum transmit power (10dB S/N == 10), relative gain (-10dB == 0.1), decibels (6dB == 2*2) .
	# 7 * 4 * 10 * 0.1 * 2*2
	# 112Bytes
	
	# 80Bytes or 17980Bytes key
	local currentKeySize
	currentKeySize="80"
	
	# DANGER: STRONGLY DISCOURAGED. Expected very detrimental in most situations. Please do not use this unless you can imagine exactly a good reason why you would want it.
	[[ "$FORCE_HUGE" == "true" ]] && currentKeySize="17980"
	
	local currentKeyTail
	let currentKeyTail="$currentKeySize"+1
	
	local currentDataSize
	currentDataSize=20
	
	local currentMessageSize
	#currentMessageSize=100
	#[[ "$FORCE_HUGE" == "true" ]] && currentMessageSize=18000
	let currentMessageSize="$currentKeySize"+"$currentDataSize"
	
	
	
	if [[ $(echo "$currentMessageSimple" | base64 -d | wc -c | tr -dc '0-9') -ge "$currentKeySize" ]]
	then
		# decrypt
		echo "$currentMessageSimple" | base64 -d | head -c "$currentKeySize" > "$safeTmp"/key
		echo "$currentMessageSimple" | base64 -d | head -c "$currentMessageSize" | tail -c+"$currentKeyTail" | openssl enc -d -aes-256-ofb -nosalt -iter 16777216 -pass file:"$safeTmp"/key -out /dev/stdout -in /dev/stdin
	else
		# encrypt
		_extractEntropyBin "$currentKeySize" > "$safeTmp"/key
		echo "$currentMessageSimple" | base64 -d | head -c "$currentDataSize" | openssl enc -e -aes-256-ofb -nosalt -iter 16777216 -pass file:"$safeTmp"/key -out /dev/stdout -in /dev/stdin | _band-output
	fi
	
	
	
	
	_sweep "$safeTmp"/key
	
	
	_stop
}








_band_clipboard() {
	if _if_cygwin
	then
		cat /dev/clipboard | _band | cat > /dev/clipboard
		echo > /dev/tty
	else
		xclip -out -selection clipboard | _band | xclip -in -selection clipboard
		echo > /dev/tty
	fi
}







