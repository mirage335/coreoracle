# WARNING: Not intended for volume or communications encryption.
# PREREQUSITE: _construct_passKey_salts
_expand_passKey() {
	local currentKeyNumber
	currentKeyNumber="$1"
	
	local currentSaltDerivationNumber
	currentSaltDerivationNumber="$2"
	
	local currentIterationCount
	
	# Iteration counts generated from "$RANDOM", selected for lack of repeated digits within approximate range of 4096-8192.
	[[ "$currentKeyNumber" == "1" ]] && currentIterationCount=8969
	[[ "$currentKeyNumber" == "2" ]] && currentIterationCount=6754
	[[ "$currentKeyNumber" == "3" ]] && currentIterationCount=9165
	[[ "$currentKeyNumber" == "4" ]] && currentIterationCount=5787
	[[ "$currentKeyNumber" == "5" ]] && currentIterationCount=8855
	[[ "$currentKeyNumber" == "6" ]] && currentIterationCount=4827
	
	cat "$safeTmp"/passKey "$safeTmp"/passKey_salt_"$currentKeyNumber" > "$safeTmp"/passKey_cat_"$currentKeyNumber"
	_php_pbkdf2 "$safeTmp"/passKey_cat_"$currentKeyNumber" "$safeTmp"/passKey_salt_"$currentSaltDerivationNumber" "$currentIterationCount" > "$safeTmp"/passKey_ex_"$currentKeyNumber"
	
	_messagePlain_probe 'cat '"$safeTmp"'/passKey '"$safeTmp"'/passKey_salt_'"$currentKeyNumber"' > '"$safeTmp"'/passKey_cat_'"$currentKeyNumber"'
	_php_pbkdf2 '"$safeTmp"'/passKey_cat_'"$currentKeyNumber"' '"$safeTmp"'/passKey_salt_'"$currentSaltDerivationNumber"' '"$currentIterationCount"' > '"$safeTmp"'/passKey_ex_'"$currentKeyNumber"
	
	cat "$safeTmp"/passKey_ex_"$currentKeyNumber" | xxd -p | tr -d '\n' > "$safeTmp"/passKey_ex_"$currentKeyNumber".hex
	
	[[ -e "$safeTmp"/passKey_ex_"$currentKeyNumber" ]] && _messagePlain_good 'pass: exists: key (expanded): '"$currentKeyNumber"
}

_assemble_passKey() {
	_messagePlain_nominal 'init: _assemble_passKey'
	
	_construct_passKey_salts
	
	_expand_passKey 01 07
	_expand_passKey 02 08
	_expand_passKey 03 09
	_expand_passKey 04 10
	_expand_passKey 05 11
	_expand_passKey 06 12
}

_schedule_passKey() {
	_messagePlain_nominal 'init: _schedule_passKey'
	
	
	cp "$safeTmp"/passKey_ex_01 "$safeTmp"/key_encrypt_1
	cp "$safeTmp"/passKey_ex_01.hex "$safeTmp"/key_encrypt_1.hex
	cp "$safeTmp"/passKey_ex_02 "$safeTmp"/key_encrypt_2
	cp "$safeTmp"/passKey_ex_02.hex "$safeTmp"/key_encrypt_2.hex
	cp "$safeTmp"/passKey_ex_03 "$safeTmp"/key_encrypt_3
	cp "$safeTmp"/passKey_ex_03.hex "$safeTmp"/key_encrypt_3.hex
	cp "$safeTmp"/passKey_ex_04 "$safeTmp"/key_encrypt_4
	cp "$safeTmp"/passKey_ex_04.hex "$safeTmp"/key_encrypt_4.hex
	
	cp "$safeTmp"/passKey_ex_05 "$safeTmp"/key_auth_1
	cp "$safeTmp"/passKey_ex_05.hex "$safeTmp"/key_auth_1.hex
	
	cp "$safeTmp"/passKey_ex_06 "$safeTmp"/key_extra_1
	cp "$safeTmp"/passKey_ex_06.hex "$safeTmp"/key_extra_1.hex
}

_passEncrypt_sequence() {
	_start
	
	_messageNormal 'init: passEncrypt'
	
	local currentPlaintextFile
	currentPlaintextFile="$1"
	
	local currentCiphertextFile
	currentCiphertextFile="$2"
	
	! [[ -e "$currentPlaintextFile" ]] && _messagePlain_bad 'fail: missing: input (file): '"$currentPlaintextFile" && _stop 1
	
	[[ "$currentCiphertextFile" == "" ]] && _messagePlain_bad 'fail: blank: output (path): '"$currentCiphertextFile" && _stop 1
	
	_messagePlain_nominal '-----REQUEST: password . Type password, send '"'"'Ctrl+d'"'"' (twice) .'
	stty -echo > /dev/null 2>&1
	cat > "$safeTmp"/passKey
	stty echo > /dev/null 2>&1
	echo
	
	local currentPasswordCharCount
	currentPasswordCharCount=$(cat "$safeTmp"/passKey | wc -c | tr -dc '0-9')
	[[ "$currentPasswordCharCount" -lt '12' ]] && _messagePlain_bad 'reject: insufficient password characters (minimum: 12)' && _stop 1
	[[ "$currentPasswordCharCount" -ge '12' ]] && _messagePlain_good 'accept: password'
	
	_assemble_passKey
	
	_schedule_passKey
	
	
	_messagePlain_nominal 'reach: encryption'
	
	
	_openssl_e_enc "$currentPlaintextFile" "$safeTmp"/ciphertext "$safeTmp"/key_encrypt_1
	_php_hmac "$safeTmp"/ciphertext "$safeTmp"/authentication "$safeTmp"/key_auth_1
	
	cat "$safeTmp"/ciphertext "$safeTmp"/authentication > "$safeTmp"/transmission
	
	rm -f "$currentCiphertextFile"
	cat "$safeTmp"/key_extra_1.hex | gpg --quiet --homedir "$shortTmp" --batch --output "$currentCiphertextFile" --passphrase-fd 0 --symmetric --s2k-cipher-algo AES256 --s2k-digest-algo SHA512 --s2k-mode 3 --s2k-count 29225671 "$safeTmp"/transmission
	
	
	
	[[ -e "$currentCiphertextFile" ]] && _messagePlain_good 'pass: exists: output (path): '"$currentCiphertextFile"
	! [[ -e "$currentCiphertextFile" ]] && _messagePlain_bad 'fail: missing: output (path): '"$currentCiphertextFile" && _stop 1
	
	_stop
}

_passEncrypt() {
	"$scriptAbsoluteLocation" _passEncrypt_sequence "$@"
}

_passDecrypt_sequence() {
	_start
	
	_messageNormal 'init: passDecrypt'
	
	local currentPlaintextFile
	currentPlaintextFile="$1"
	
	local currentCiphertextFile
	currentCiphertextFile="$2"
	
	! [[ -e "$currentCiphertextFile" ]] && _messagePlain_bad 'fail: missing: input (file): '"$currentCiphertextFile" && _stop 1
	
	[[ "$currentPlaintextFile" == "" ]] && _messagePlain_bad 'fail: blank: output (path): '"$currentPlaintextFile" && _stop 1
	
	[[ -e "$currentPlaintextFile" ]] && _messagePlain_bad 'fail: exists: output (path): '"$currentPlaintextFile" && _stop 1
	
	_messagePlain_nominal '-----REQUEST: password . Type password, send '"'"'Ctrl+d'"'"' (twice) .'
	stty -echo > /dev/null 2>&1
	cat > "$safeTmp"/passKey
	stty echo > /dev/null 2>&1
	echo
	
	local currentPasswordCharCount
	currentPasswordCharCount=$(cat "$safeTmp"/passKey | wc -c | tr -dc '0-9')
	[[ "$currentPasswordCharCount" -lt '12' ]] && _messagePlain_bad 'reject: insufficient password characters (minimum: 12)' && _stop 1
	[[ "$currentPasswordCharCount" -ge '12' ]] && _messagePlain_good 'accept: password'
	
	_assemble_passKey
	
	_schedule_passKey
	
	
	_messagePlain_nominal 'reach: decryption'
	
	# GPG used primarily for "TWOFISH" cipher, with "AES256" specified as well to ensure a reasonably secure fallback.
	if ! cat "$safeTmp"/key_extra_1.hex | gpg --quiet --homedir "$shortTmp" --batch --output "$safeTmp"/transmission --passphrase-fd 0 --decrypt --s2k-cipher-algo AES256 --s2k-digest-algo SHA512 --s2k-mode 3 --s2k-count 56902035 --cipher-algo TWOFISH "$currentCiphertextFile"
	then
		_messageError 'fail: gpg'
		_stop 1
	fi
	
	cp "$safeTmp"/transmission "$safeTmp"/ciphertext
	_php_hmac_remove "$safeTmp"/ciphertext
	_php_hmac-extract "$safeTmp"/transmission > "$safeTmp"/authentication
	
	_php_hmac "$safeTmp"/ciphertext "$safeTmp"/authentication-calc "$safeTmp"/key_auth_1
	
	! diff "$safeTmp"/authentication "$safeTmp"/authentication-calc > /dev/null 2>&1 && _messageError 'fail: auth: diff' && _stop 1
	
	_openssl_d_enc "$currentPlaintextFile" "$safeTmp"/ciphertext "$safeTmp"/key_encrypt_1
	
	
	[[ -e "$currentPlaintextFile" ]] && _messagePlain_good 'pass: exists: output (path): '"$currentPlaintextFile"
	! [[ -e "$currentPlaintextFile" ]] && _messagePlain_bad 'fail: missing: output (path): '"$currentPlaintextFile" && _stop 1
	
	_stop
}

_passDecrypt() {
	"$scriptAbsoluteLocation" _passDecrypt_sequence "$@"
}


