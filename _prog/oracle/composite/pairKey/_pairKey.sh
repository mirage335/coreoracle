
# NOTICE: Legacy. Configures and uses YubiKey OAUTH to generate matching time dependent passwords .


_pair-generate() {
	#_gatherEntropy
	_extractEntropyBin 10 | base32
}

_pair-create() {
	#local current_sharedSecret
	#current_sharedSecret=$(_pair-generate)
	#[[ "$1" != "" ]] && current_sharedSecret="$1"
	
	local current_sharedSecret1
	current_sharedSecret1=$(_pair-generate)
	[[ "$1" != "" ]] && current_sharedSecret1="$1"
	
	local current_sharedSecret2
	current_sharedSecret2=$(_pair-generate)
	[[ "$1" != "" ]] && current_sharedSecret2="$2"
	
	local current_sharedSecret3
	current_sharedSecret3=$(_pair-generate)
	[[ "$1" != "" ]] && current_sharedSecret3="$3"
	
	_messagePlain_request 'request: Ctrl+c or connect YubiKey and Enter .'
	while read
	do
		_messageNormal 'write: YubiKey'
		#ykman oath accounts delete 60/pair-oracle --force > /dev/null 2>&1
		#ykman oath accounts delete 3/pair-oracle --force > /dev/null 2>&1
		#ykman oath accounts delete pair-oracle --force > /dev/null 2>&1
		ykman oath accounts delete 60/pair-oracle-1 --force > /dev/null 2>&1
		#ykman oath accounts delete 3/pair-oracle-1 --force > /dev/null 2>&1
		#ykman oath accounts delete pair-oracle-1 --force > /dev/null 2>&1
		ykman oath accounts delete 60/pair-oracle-2 --force > /dev/null 2>&1
		#ykman oath accounts delete 3/pair-oracle-2 --force > /dev/null 2>&1
		#ykman oath accounts delete pair-oracle-2 --force > /dev/null 2>&1
		ykman oath accounts delete 60/pair-oracle-3 --force > /dev/null 2>&1
		#ykman oath accounts delete 3/pair-oracle-3 --force > /dev/null 2>&1
		#ykman oath accounts delete pair-oracle-3 --force > /dev/null 2>&1
		#echo "$current_sharedSecret" | ykman oath accounts add --digits 8 --oath-type TOTP --algorithm SHA512 --period 3 pair-oracle
		echo "$current_sharedSecret1" | ykman oath accounts add --digits 8 --oath-type TOTP --algorithm SHA512 --period 60 --touch pair-oracle-1
		echo "$current_sharedSecret2" | ykman oath accounts add --digits 8 --oath-type TOTP --algorithm SHA512 --period 60 --touch pair-oracle-2
		echo "$current_sharedSecret3" | ykman oath accounts add --digits 8 --oath-type TOTP --algorithm SHA512 --period 60 --touch pair-oracle-3
		[[ "$?" != "0" ]] && _messageFAIL
		_messagePlain_good 'done: write: YubiKey'
		_messagePlain_request 'request: Ctrl+c or connect YubiKey and Enter .'
	done
	
	return 0
}

_pair-grab-stdout() {
	#local currentPID
	
	# WARNING: May be untested .
	#_messagePlain_request 'request: Choose minute, close to the minute, press ENTER.'
	#( while date +%M:%S ; do sleep 1 ; done ) 2>/dev/null &
	#currentPID="$!"
	#read > /dev/null 2>&1
	#kill "$currentPID" > /dev/null 2>&1
	#kill -KILL "$currentPID" > /dev/null 2>&1
	
	#if [[ $(date +%S | sed 's/^0//') -lt 30 ]]
	#hen
		#echo 'wait: '$(bc <<< '60 + '$(date +%S))
		#while ! [[ $(date +%S | sed 's/^0//') -ge 59 ]] ; do sleep 0.3 ; done
		#while [[ $(date +%S | sed 's/^0//') -gt 14 ]] ; do sleep 7 ; done
		#while [[ $(date +%S | sed 's/^0//') -gt 0 ]] ; do sleep 0.3 ; done
	#else
		#echo 'wait: '$(bc <<< '60 - '$(date +%S))
		#while [[ $(date +%S | sed 's/^0//') -gt 14 ]] ; do sleep 7 ; done
		#while [[ $(date +%S | sed 's/^0//') -gt 0 ]] ; do sleep 0.3 ; done
	#fi
	#sleep 0.1
	
	_messagePlain_request 'request: Please confirm presence at YubiKey at the minute.' > /dev/tty
	while [[ $(date +%S | sed 's/^0//') -gt 0 ]]
	do
		date +%S > /dev/tty
		sleep 1 > /dev/tty
	done
	
	
	
	#ykman oath accounts code pair-oracle
	#sleep 3
	#sleep 0.1
	#ykman oath accounts code pair-oracle
	#sleep 3
	#sleep 0.1
	#ykman oath accounts code pair-oracle
	
	ykman oath accounts code pair-oracle-1 | tr -dc '0-9'
	ykman oath accounts code pair-oracle-2 | tr -dc '0-9'
	ykman oath accounts code pair-oracle-3 | tr -dc '0-9'
	
	echo -n 'Minute: ' > /dev/tty
	date +%M > /dev/tty
}

_pair-grab() {
	[[ -e "$HOME"/.pair ]] && _pair-purge
	
	echo -n > "$HOME"/.pair
	chmod 600 "$HOME"/.pair
	#_pair-grab-stdout > "$HOME"/.pair
	
	# ATTENTION: Since pair keys are expected ephemeral, algorithm may change, or may be disregarded, invalidating existing pair keys.
	_pair-grab-stdout | xxd -p | tr -d '\n' | openssl enc -e -aes-256-cbc -pass stdin -nosalt -pbkdf2 -in /dev/zero 2>/dev/null | xxd -p | tr -d '\n' | dd of="$HOME"/.pair bs=1M count=10 status=progress iflag=fullblock
}

_pair-purge() {
	! [[ -e "$HOME"/.pair ]] && return 0
	_sweep "$HOME"/.pair
}

# ATTENTION: Since pair keys are expected ephemeral, algorithm may change, or may be disregarded, invalidating existing pair keys.
_pair-summary() {
	cat "$HOME"/.pair | xxd -p | tr -d '\n' | openssl enc -e -aes-256-cbc -pass stdin -nosalt -pbkdf2 -in /dev/zero 2>/dev/null | xxd -p | tr -d '\n' | head -c 20
}

# NOTICE: Encrypt-and-MAC/Prepend differs from usual ORACLE reference implementation practice of Encrypt-then-MAC intentionally.
#  Multi-user pure ciphertext within a noisy channel necessitates search for authentic ciphertext.
#  By contrast, mere integrity with single shared secret may be better maintained for complicated computer systems by authenticating human readable plaintext.
# ATTENTION: Structure is deliberately chosen to prioritize integrty through minimal processing and human readability. Thus, the structure, using Keccak instead of HMAC, and using Encrypt-and-MAC/Prepend, has been deliberately chosen to use only the OpenSSL program (NOT php), and to allow manual checking from other computers (at least of a sample).
#  DANGER: As usual, think very carefully about the structure before revising the algorithm.
# https://en.wikipedia.org/wiki/HMAC
#  'The Keccak hash function, that was selected by NIST as the SHA-3 competition winner, doesn't need this nested approach and can be used to generate a MAC by simply prepending the key to the message, as it is not susceptible to length-extension attacks.'
# https://en.wikipedia.org/wiki/Authenticated_encryption
#  'Encrypt-and-MAC' ... Same key is used.
_pair-enc() {
	_start
	
	mkfifo "$safeTmp"/key-pipe
	#_pair-summary > "$safeTmp"/key &
	
	
	# encrypt/decrypt (symmetric encryption should also be decryption?)
	# Encrypt-and-MAC/Prepend
	# MAC + ciphertext -> rx
	# pad (MAC length equivalent, zero values) + plaintext -> tx
	
	local currentExitStatus
	
	local current_message
	current_message=$(cat | base64 | base64)
	
	#local current_mac
	#current_mac=$(echo "$current_message" | base64 -d | base64 -d | openssl dgst -sha3-512)
	#echo $current_mac
	
	
	
	head -c 20 "$HOME"/.pair > "$safeTmp"/keyAuth
	
	echo "$current_message" | base64 -d | base64 -d | cat "$safeTmp"/keyAuth - | openssl dgst -sha3-512 -binary | xxd -p -c 64 | tr -d '\n' | head -c 128 > "$safeTmp"/HMAC-output
	
	if [[ $(cat "$safeTmp"/HMAC-output) == $(echo "$current_message" | base64 -d | base64 -d | head -c 128 | tr -dc 'a-zA-Z0-9') ]]
	then
		# decrypting
		true
	else
		# encrypting
		# DANGER: TODO: OpenSSL may ignore much of the keyfile .
		echo "$current_message" | base64 -d | base64 -d | openssl enc -e -aes-256-cbc -nosalt -pbkdf2 -pass file:"$HOME"/.pair -out /dev/stdout -in /dev/stdin | cat "$safeTmp"/HMAC-output -
	fi
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# ATTENTION: scrap
	
	
	#echo "$current_message" | base64 -d | base64 -d | tee >(head -c 123 > "$safeTmp"/HMAC-input) | tee >(tail -c+123 | openssl enc | HMAC > "$safeTmp"/HMAC-output)
	
	
	
	
	
	
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
 
