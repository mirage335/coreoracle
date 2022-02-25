# TODO: Sample sync number, broadcast schedule time.

# WARNING: Error handling part of failure chain. Always to be called unusually, so as to cause calling function to return 1, or call "_stop 1".
#! _me_internal_commKey_checkReady && ! _me_internal_fail_confidence && return 1
_me_internal_commKey_checkReady() {
	! [[ -e "$internalFile_readiness" ]] && _messageError 'fail: commFields: readiness: missing' && return 1
	
	[[ $(head -c 1 "$internalFile_readiness") != '1' ]] && _messageError 'fail: commFields: readiness: reject' && return 1
	
	! _check_commFields && _messageError 'fail: commFields: check' && return 1
	
	return 0
}


_me_internal_wait_confidence() {
	while ! [[ -e "$metaDir"/bi/confidence ]] && ! [[ -e "$metaConfidence" ]]
	do
		sleep 0.1
	done
	
	while [[ $(head -c 1 "$metaDir"/bi/confidence) != '1' ]] && [[ $(head -c 1 "$metaDir"/bi/confidence) != '0' ]]
	#&& ! [[ -e "$metaConfidence" ]]
	do
		sleep 0.1
	done
	
	[[ $(head -c 1 "$metaDir"/bi/confidence) != '1' ]] && return 1
	[[ -e "$metaConfidence" ]] && return 1
	
	return 0
}

# WARNING: Error handling part of failure chain. Always to be called unusually, so as to always cause calling function to return 1, or call "_stop 1".
#! _me_internal_fail_confidence && return 1
_me_internal_fail_confidence() {
	# DANGER: Doing "_stop" instead of "_return" will erase "$safeTmp, "$metaTmp", "$metaProc", and related directories, breaking multiple-input-single-output multithreaded chains.
	[[ "$metaThread" == "true" ]] && return 1
	
	_messageError 'fail: confidence'
	
	[[ $(head -c 1 "$metaConfidence" 2> /dev/null) != '0' ]] && echo -n '0' > "$metaConfidence"
	
	_stop 1
	
	return 1
}

#Counter appended to end (tail -c 48), random IV prepended to beginning (head -c 48), message at middle (tail -c +49 | head -c -48) .
_me_internal_assemble_message() {
	mkdir -p "$metaDir"/assembly
	head -c 48 "$commFields_alt"/randiv > "$metaDir"/assembly/randiv
	head -c 48 "$keyFile_counter" > "$metaDir"/assembly/counter
	
	cat "$commFields_alt"/randiv "$metaDir"/ai/plaintext "$keyFile_counter" > "$metaDir"/ao/salted
}

_me_internal_disassemble_message() {
	mkdir -p "$metaDir"/assembly
	
	tail -c 48 "$metaDir"/ao/salted > "$metaDir"/assembly/counter
	head -c 48 "$metaDir"/ao/salted > "$metaDir"/assembly/randiv
	
	tail -c +49 "$metaDir"/ao/salted > "$metaDir"/ao/plaintext
	#https://www.quora.com/How-do-I-chop-off-just-the-last-byte-of-a-file-in-Bash
	perl -e 'truncate $ARGV[0], ((-s $ARGV[0]) - 48)' "$metaDir"/ao/plaintext
}

#Truncate Counter and IV. Confidentiality and authentication may be compromised, 1/2^16, or will be after 1/2^64. Emergency transmission over noisy channel, or exceptional request for new communications channel, only.
_me_internal_assemble_message_short() {
	mkdir -p "$metaDir"/assembly
	head -c 4 "$commFields_alt"/randiv > "$metaDir"/assembly/randiv
	tail -c 8 "$keyFile_counter" > "$metaDir"/assembly/counter
	
	cat "$commFields_alt"/randiv "$metaDir"/ai/plaintext "$keyFile_counter" > "$metaDir"/ao/salted
}

#Truncate Hash. Requesting new communications channels only. Such communications channel must incorporate stronger authentication. Assumes rare and worst case scenario is setup of a channel that will not be used.
_me_internal_truncate_authentication_short() {
	head -c 4 "$metaDir"/ao/authentication > "$metaDir"/ao/authentication.tmp
	mv "$metaDir"/ao/authentication.tmp "$metaDir"/ao/authentication
}




#IN
	#"$metaDir"/ai/plaintext
	#"$metaDir"/ai/transmission
	#"$metaDir"/bi/samplenumber
	#"$metaDir"/bi/confidence ("0" || "1")
#OUT
	# "$1" == confidence (file)
	# "$2" == message (file)
	# "$3" == samplenumber (file)
_me_processor_commKey_me_out_plaintext() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	! _me_internal_wait_confidence && ! _me_internal_fail_confidence && return 1
	
	if [[ "$2" != "" ]]
	then
		cat "$metaDir"/ai/plaintext > "$2".tmp
		mv "$2".tmp "$2"
	fi
	
	if [[ "$3" != "" ]]
	then
		cat "$metaDir"/bi/samplenumber > "$3".tmp
		mv "$3".tmp "$3"
	fi
	
	#Confidence. Only one processor will reach this point.
	[[ "$1" != "" ]] && echo -n '1' > "$1"
	
	_relink_metaengine_out
	
	_stop
}



# Input "message" copied as both plaintext and transmission (ciphertext/authentication).
#IN
	# "$1" == message (file)
	# "$2" == samplenumber (file)
#OUT
	#"$metaDir"/ao/plaintext
	#"$metaDir"/ao/transmission
	#"$metaDir"/bo/samplenumber
	#"$metaDir"/bo/confidence ("0" || "1")
_me_processor_commKey_file_in() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	
	! [[ -e "$1" ]] && _messagePlain_warn 'outbound: blank: message'
	#! [[ -e "$2" ]] && _messagePlain_warn 'outbound: blank: samplenumber'
	
	[[ "$1" != "" ]] && [[ -e "$1" ]] && cat "$1" > "$metaDir"/ao/plaintext
	[[ "$1" != "" ]] && [[ -e "$1" ]] && cat "$1" > "$metaDir"/ao/transmission
	[[ "$2" != "" ]] && [[ -e "$2" ]] && echo -n "$2" > "$metaDir"/bo/samplenumber
	! [[ -e "$metaDir"/ao/plaintext ]] && echo -n > "$metaDir"/ao/plaintext
	! [[ -e "$metaDir"/ao/transmission ]] && echo -n > "$metaDir"/ao/transmission
	echo -n '1' > "$metaDir"/bo/confidence
	
	_relink_metaengine_out
}

#IN
	#"$metaDir"/ai/plaintext
	#"$metaDir"/ai/transmission
	#"$metaDir"/bi/samplenumber
	#"$metaDir"/bi/confidence ("0" || "1")
#OUT
	# "$1" == confidence (file)
	# "$2" == message (file)
	# "$3" == samplenumber (file)
_me_processor_commKey_file_out_plaintext() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	! _me_internal_wait_confidence && ! _me_internal_fail_confidence && return 1
	
	if [[ "$2" != "" ]]
	then
		cat "$metaDir"/ai/plaintext > "$2".tmp
		mv "$2".tmp "$2"
	fi
	
	if [[ "$3" != "" ]]
	then
		cat "$metaDir"/bi/samplenumber > "$3".tmp
		mv "$3".tmp "$3"
	fi
	
	#Confidence. Only one processor will reach this point.
	[[ "$1" != "" ]] && echo -n '1' > "$1"
	
	_relink_metaengine_out
	
	_stop
}

#IN
	#"$metaDir"/ai/plaintext
	#"$metaDir"/ai/transmission
	#"$metaDir"/bi/samplenumber
	#"$metaDir"/bi/confidence ("0" || "1")
#OUT
	# "$1" == confidence (file)
	# "$2" == message (file)
	# "$3" == samplenumber (file)
_me_processor_commKey_file_out_transmission() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	! _me_internal_wait_confidence && ! _me_internal_fail_confidence && return 1
	
	if [[ "$2" != "" ]]
	then
		cat "$metaDir"/ai/transmission > "$2".tmp
		mv "$2".tmp "$2"
	fi
	
	if [[ "$3" != "" ]]
	then
		cat "$metaDir"/bi/samplenumber > "$3".tmp
		mv "$3".tmp "$3"
	fi
	
	#Confidence. Only one processor will reach this point.
	[[ "$1" != "" ]] && echo -n '1' > "$1"
	
	_relink_metaengine_out
	
	_stop
}

_me_processor_commKey_file_out() {
	_me_processor_commKey_file_out_transmission "$@"
}


#IN
	#"$metaDir"/ai/plaintext
	#"$metaDir"/bi/commKey (optional)
	#"$metaDir"/bi/samplenumber
#OUT
	#"$metaDir"/ao/transmission
	#"$metaDir"/ao/salted
	#"$metaDir"/ao/ciphertext
	#"$metaDir"/ao/authentication
	#"$metaDir"/bo/commKey
	#"$metaDir"/bo/samplenumber
	#"$metaDir"/bo/confidence ("0" || "1")
# "$commFields_key"
# "$commFields_keyConfig"
# "$commFields_keyLog"
_me_processor_commKey_ae_tx() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	! _me_internal_wait_confidence && ! _me_internal_fail_confidence && return 1
	mkdir -p "$metaDir"/diag
	
	if [[ -e "$metaDir"/bi/commKey ]]
	then
		_reset_commFields
		local currentCommKeyPath
		currentCommKeyPath=$(readlink -f "$metaDir"/bi/commKey)
		_set_commFields "$currentCommKeyPath"
	fi
	
	cp -r "$commFields_key" "$metaDir"/diag/kd_in
	
	[[ ! -d "$commFields_key" ]] && _messageError 'fail: commFields: not dir' && ! _me_internal_fail_confidence && return 1
	! _me_internal_commKey_checkReady && ! _me_internal_fail_confidence && return 1
	
	#Transmitter always increments at least twice. Replies may be missed without incurring counter reuse.
	! _advance_commFields_counter && _messageError 'fail: commKey: counter: advance' && ! _me_internal_fail_confidence && return 1
	! _advance_commFields_counter && _messageError 'fail: commKey: counter: advance' && ! _me_internal_fail_confidence && return 1
	
	_random_commfields_iV
	
	_me_internal_assemble_message
	
	_openssl_e_enc "$metaDir"/ao/salted "$metaDir"/ao/ciphertext "$keyFile_data"
	
	_php_hmac "$metaDir"/ao/ciphertext "$metaDir"/ao/authentication "$keyFile_auth"
	
	#_me_internal_truncate_authentication_short
	
	cat "$metaDir"/ao/ciphertext "$metaDir"/ao/authentication > "$metaDir"/ao/transmission
	cp "$metaDir"/bi/samplenumber "$metaDir"/bo/samplenumber > /dev/null 2>&1
	
	_relink_relative "$commFields_absolute" "$metaDir"/bo/commKey
	
	echo -n '1' > "$metaDir"/bo/confidence
	
	cp -r "$commFields_key" "$metaDir"/diag/kd_out
	
	_relink_metaengine_out
	
	#optional, closes host upon completion
	#_stop
}


# WARNING: If any "rx" processor blocks, entire search is expected to block.
# "$1" == "commFields" (directory)
#IN
	#"$metaDir"/ai/transmission
	#"$metaDir"/bi/samplenumber
	#"$metaDir"/bi/confidence ("0" || "1")
#OUT
	#"$metaDir"/ao/plaintext
	#"$metaDir"/ao/clientid
	#"$metaDir"/ao/privilege
	#"$metaDir"/ao/salted
	#"$metaDir"/ao/ciphertext
	#"$metaDir"/ao/authentication
	#"$metaDir"/ao/authentication-calc
	
	#"$metaDir"/bo/commKey
	#"$metaDir"/bo/samplenumber
	#"$metaDir"/bo/confidence ("0" || "1")
# "$commFields_key"
# "$commFields_keyConfig"
# "$commFields_keyLog"
_me_processor_commKey_ae_rx() {
	_messageNormal 'launch: '"$metaObjName"
	
	[[ "$1" != "" ]] && _set_commFields "$1"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	! _me_internal_wait_confidence && ! _me_internal_fail_confidence && return 1
	
	#_messageError 'fail: experiment' && _stop 1
	
	mkdir -p "$metaDir"/diag
	
	cp -r "$commFields_key" "$metaDir"/diag/kd_in
	
	[[ ! -d "$commFields_key" ]] && _messageError 'fail: commFields: not dir' && ! _me_internal_fail_confidence && return 1
	! _me_internal_commKey_checkReady && ! _me_internal_fail_confidence && return 1
	
	#https://www.quora.com/How-do-I-chop-off-just-the-last-byte-of-a-file-in-Bash
	cp "$metaDir"/ai/transmission "$metaDir"/ao/ciphertext
	perl -e 'truncate $ARGV[0], ((-s $ARGV[0]) - 64)' "$metaDir"/ao/ciphertext
	tail -c 64 "$metaDir"/ai/transmission > "$metaDir"/ao/authentication
	
	_php_hmac "$metaDir"/ao/ciphertext "$metaDir"/ao/authentication-calc "$keyFile_auth"
	
	! diff "$metaDir"/ao/authentication "$metaDir"/ao/authentication-calc > /dev/null 2>&1 && _messageError 'fail: auth: diff' && ! _me_internal_fail_confidence && return 1
	
	_openssl_d_enc "$metaDir"/ao/salted "$metaDir"/ao/ciphertext "$keyFile_data"
	
	_me_internal_disassemble_message
	
	if ! _verify_commFields_counter "$metaDir"/assembly/counter
	then
		#_tryExec '_contingency'
		_messageError 'fail: counter: replay'
	fi
	
	! _set_commFields_counter "$metaDir"/assembly/counter && _messageError 'fail: commKey: counter: advance' && ! _me_internal_fail_confidence && return 1
	
	cp "$keyFile_clientid" "$metaDir"/ao/clientid
	cp "$internalFile_privilege" "$metaDir"/ao/privilege
	
	cp "$metaDir"/bi/samplenumber "$metaDir"/bo/samplenumber > /dev/null 2>&1
	
	_relink_relative "$commFields_absolute" "$metaDir"/bo/commKey
	
	
	echo -n '1' > "$metaDir"/bo/confidence
	
	cp -r "$commFields_key" "$metaDir"/diag/kd_out
	
	_relink_metaengine_out
	
	#optional, closes host upon completion
	#_stop
}

# Variant of "tx", advances counter once.
#IN
	#"$metaDir"/ai/plaintext
	#"$metaDir"/bi/commKey (optional)
	#"$metaDir"/bi/samplenumber
#OUT
	#"$metaDir"/ao/transmission
	#"$metaDir"/ao/salted
	#"$metaDir"/ao/ciphertext
	#"$metaDir"/ao/authentication
	#"$metaDir"/bo/commKey
	#"$metaDir"/bo/samplenumber
	#"$metaDir"/bo/confidence ("0" || "1")
# "$commFields_key"
# "$commFields_keyConfig"
# "$commFields_keyLog"
_me_processor_commKey_ae_xc() {
	_messageNormal 'launch: '"$metaObjName"
	
	! _wait_metaengine && ! _me_internal_fail_confidence && return 1
	_start_metaengine
	_relink_metaengine_in
	! _me_internal_wait_confidence && ! _me_internal_fail_confidence && return 1
	mkdir -p "$metaDir"/diag
	
	if [[ -e "$metaDir"/bi/commKey ]]
	then
		_reset_commFields
		local currentCommKeyPath
		currentCommKeyPath=$(readlink -f "$metaDir"/bi/commKey)
		_set_commFields "$currentCommKeyPath"
	fi
	
	cp -r "$commFields_key" "$metaDir"/diag/kd_in
	
	
	[[ ! -d "$commFields_key" ]] && _messageError 'fail: commFields: not dir' && ! _me_internal_fail_confidence && return 1
	! _me_internal_commKey_checkReady && ! _me_internal_fail_confidence && return 1
	
	#Reply always increments only once.
	! _advance_commFields_counter && _messageError 'fail: commKey: counter: advance' && ! _me_internal_fail_confidence && return 1
	
	_random_commfields_iV
	
	_me_internal_assemble_message
	
	_openssl_e_enc "$metaDir"/ao/salted "$metaDir"/ao/ciphertext "$keyFile_data"
	
	_php_hmac "$metaDir"/ao/ciphertext "$metaDir"/ao/authentication "$keyFile_auth"
	
	#_me_internal_truncate_authentication_short
	
	cat "$metaDir"/ao/ciphertext "$metaDir"/ao/authentication > "$metaDir"/ao/transmission
	cp "$metaDir"/bi/samplenumber "$metaDir"/bo/samplenumber > /dev/null 2>&1
	
	_relink_relative "$commFields_absolute" "$metaDir"/bo/commKey
	
	echo -n '1' > "$metaDir"/bo/confidence
	
	cp -r "$commFields_key" "$metaDir"/diag/kd_out
	
	_relink_metaengine_out
	
	#optional, closes host upon completion
	#_stop
}



