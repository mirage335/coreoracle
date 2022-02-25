_vector_cryptsetup_sequence() {
	_start
	
	#echo -n 'deadc0de' | xxd -r -p > "$safeTmp"/testContainer
	dd if=/dev/zero of="$safeTmp"/testContainer bs=1M count=1 > /dev/null 2>&1
	
	
	echo -n '8badf00d' | sudo -n /sbin/cryptsetup --hash whirlpool --key-size=256 --cipher aes-xts-plain64 --key-file=- create test_"$sessionid"_1 "$safeTmp"/testContainer
	
	sudo -n head -c 1024 /dev/mapper/test_"$sessionid"_1 > "$safeTmp"/testOut
	
	echo -n 'baaaaaad' | xxd -r -p > "$safeTmp"/testKey_hmac
	
	# DANGER: Documentation only, in case of future syntax changes. Do NOT uncomment.
	#sudo -n dmsetup table --showkeys | grep "$sessionid" > "$safeTmp"/exampleTable
	#test_YsHBAy1TRzrOGqhwotD5tc2oqs_1: 0 2048 crypt aes-xts-plain64 02fd665823be05b8aa9d892b0ed111b26271b0b31fcb280b23d4e11afe26ba5c 0 7:1 0
	
	
	sudo -n /sbin/cryptsetup remove test_"$sessionid"_1
	[[ -e /dev/mapper/test_"$sessionid"_1 ]] && echo 'exists: '/dev/mapper/test_"$sessionid"_1 && _stop 1
	
	
	_php_hmac "$safeTmp"/testContainer "$safeTmp"/testHash "$safeTmp"/testKey_hmac
	
	
	_php_hmac "$safeTmp"/testOut "$safeTmp"/testOutHash "$safeTmp"/testKey_hmac
	[[ "3f4f2f24fac21d05bc4e4a61b134e21fe64b447f0cd97dc5" != $(head -c 128 "$safeTmp"/testOut | xxd -p | tr -d '\n' | head -c 48) ]] && echo 'input: mismatch' && _stop 1
	[[ "31c828d562d3fa3805adc0f43bbab03aae752af7a7532d58" != $(head -c 128 "$safeTmp"/testOutHash | xxd -p | tr -d '\n' | head -c 48) ]] && echo 'output: mismatch' && _stop 1
	
	_stop
}

_vector_cryptsetup() {
	_messageNormal "Vectors (cryptsetup)..."
	
	if _if_cygwin
	then
		echo 'warn: accepted: cygwin: missing: mount: cryptsetup'
		_messagePASS
		return 0
	fi
	
	if ! "$scriptAbsoluteLocation" _vector_cryptsetup_sequence
	then
		_messageFAIL
		_stop 1
	fi
	
	_messagePASS
}

_test_cryptsetup() {
	if _if_cygwin
	then
		echo 'warn: accepted: cygwin: missing: mountpoint'
		echo 'warn: accepted: cygwin: missing: mount: features'
		return 0
	fi
	
	_getDep cryptsetup
	_getDep mkfs.ext4
}

_test_fragKey() {
	_test_cryptsetup
}
