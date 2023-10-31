
# NOTICE: Transmits relatively long symmetric key, assuming much stronger signal-to-noise ratio for the intended receiver. Can be a post-quantum technique to establish a separate, shared secret, though only through a longer protocol, not by itself, as it would be far more efficient to bidirectionally agree which messages have or have not been received, than to rely on complete reception of a single large key.

# ATTENTION: May also be used as an 'all-or-nothing' proof of reception of the entire key (which is also plainly sent). For now, this is more or less the expected use case, if any.


_band() {
	_start
	
	local currentMessageSimple
	currentMessageSimple=$(cat | base64)
	
	# Key size. Maybe think of bytes entropy (7B), redundancy (4s/B), minimum transmit power (10dB S/N == 10), relative gain (-10dB == 0.1), decibels (6dB == 2*2) .
	# 7 * 4 * 10 * 0.1 * 2*2
	# 112Bytes
	
	# 80Bytes or 17980Bytes key
	echo "$currentMessageSimple" | base64 -d | head -c 80 > "$safeTmp"/key
	echo "$currentMessageSimple" | base64 -d | tail -c+81 | openssl enc -d -aes-256-cfb -nosalt -pbkdf2 -pass file:"$HOME"/.pair -out /dev/stdout -in /dev/stdin
	
	local currentMessageSimple
	currentMessageSimple=$(cat | base64)
	
	
	_stop
}












