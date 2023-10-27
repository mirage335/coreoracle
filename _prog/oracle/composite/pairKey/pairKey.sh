
# NOTICE: Legacy. Configures and uses YubiKey OAUTH to generate matching time dependent passwords .


_pair-generate() {
	#_gatherEntropy
	_extractEntropyBin 10 | base32
}

_pair-create() {
	local current_sharedSecret
	current_sharedSecret=$(_pair-generate)
	[[ "$1" != "" ]] && current_sharedSecret="$1"
	
	_messagePlain_Request 'request: Ctrl+c or connect YubiKey and Enter .'
	while read
	do
		_messageNormal 'write: YubiKey'
		ykman oath accounts delete 3/pair- --force 2>/dev/null
		ykman oath accounts delete pair- --force 2>/dev/null
		echo "$current_sharedSecret" | ykman oath accounts add --digits 8 --oath-type TOTP --algorithm SHA512 --period 60 pair-
		[[ "$?" != "0" ]] && _messageFAIL
		_messagePlain_good 'done: write: YubiKey'
		_messagePlain_Request 'request: Ctrl+c or connect YubiKey and Enter .'
	done
	
	return 0
}

_pair-grab() {
	if [[ $(date +%S) -lt 30 ]]
	then
		echo 'wait: '$(bc <<< '60 + '$(date +%S))
		while ! [[ $(date +%S) -ge 59 ]] ; do sleep 0.3 ; done
		while [[ $(date +%S) -gt 14 ]] ; do sleep 7 ; done
		while [[ $(date +%S) -gt 0 ]] ; do sleep 0.3 ; done
	else
		echo 'wait: '$(bc <<< '60 - '$(date +%S))
		while [[ $(date +%S) -gt 14 ]] ; do sleep 7 ; done
		while [[ $(date +%S) -gt 0 ]] ; do sleep 0.3 ; done
	fi
	sleep 0.1
	
	ykman oath accounts code pair-
	sleep 3
	sleep 0.1
	ykman oath accounts code pair-
	sleep 3
	sleep 0.1
	ykman oath accounts code pair-
	
}

# NOTICE: Encrypt-and-MAC/Prepend differs from usual ORACLE reference implementation practice of Encrypt-then-MAC intentionally.
#  Multi-user pure ciphertext within a noisy channel necessitates search for authentic ciphertext.
#  By contrast, mere integrity with single shared secret may be better maintained for complicated computer systems by authenticating human readable plaintext.
_pair-enc() {
	_start
	
	mkfifo "$safeTmp"/keyPipe
	
	
	# encrypt/decrypt (symmetric encryption should also be decryption?)
	# Encrypt-and-MAC/Prepend
	# MAC + ciphertext -> rx
	# pad (MAC length equivalent, zero values) + plaintext -> tx
	
	local currentExitStatus
	
	local current_message
	current_message=$(cat | base64) # ???
	
	local current_mac
	
	# named pipe for key
	
	#echo "$current_message" | base64 -d | base64 -d | tee >(head -c 123 > "$safeTmp"/HMAC-input) | tee >(tail -c+123 | openssl enc | HMAC > "$safeTmp"/HMAC-output)
	
	#if "$safeTmp"/HMAC-input == "$safeTmp"/HMAC-output
		# decrypting
		#echo "$current_message" | base64 -d | base64 -d | tail -c+123 | openssl enc
		#currentExitStatus=0
	
	#if "$safeTmp"/HMAC-input != "$safeTmp"/HMAC-output
		# encrypting
		#current_mac=$(echo "$current_message" | base64 -d | HMAC)
		#echo "$current_message" | sed 's/^/'"$current_mac"'/' | tail -c+123 | openssl enc | base64
		#currentExitStatus=10
	
	
	# grab ...
	true
	
	
	
	
	_stop
}


_test_pairKey() {
	if ! type ykman > /dev/null 2>&1
	then
		echo 'missing: ykman'
		return 1
	fi
	
	return 0
}
 
