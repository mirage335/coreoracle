_mount_container_procedure() {
	! [[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messagePlain_bad 'fail: device: missing' && _stop_container 1
	! _safety_container_mounted_not && _stop_container 1
	
	sudo -n mount /dev/mapper/fragKey_"$fragKey_containerid"_9 "$fragKey_fs"
	
	! cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_9 > /dev/null && _messagePlain_bad 'fail: mount' && _stop_container 1
	_stop_container 0
}
_mount_container() {
	_generic_fragKey_container _mount_container_procedure "$@"
}

_umount_container_procedure() {
	! cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_9 > /dev/null && _messagePlain_warn 'fail: missing: mount' && _stop_container 1
	
	sudo -n umount "$fragKey_fs"
	
	! _safety_container_mounted_not && _stop_container 1
	_stop_container 0
}
_unmount_container() {
	_generic_fragKey_container_remove _umount_container_procedure "$@"
}

_format_container_procedure() {
	! [[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messagePlain_bad 'fail: device: missing' && _stop_container 1
	! _safety_container_mounted_not && _stop_container 1
	
	if type mkfs.ext4 > /dev/null 2>&1 || [[ -e /sbin/mkfs.ext4 ]] || [[ -e /usr/bin/mkfs.ext4 ]] || sudo -n which mkfs.ext4 > /dev/null 2>&1
	then
		sudo -n mkfs.ext4 -m 0 /dev/mapper/fragKey_"$fragKey_containerid"_9
		_stop_container
	fi
	
	_messagePlain_bad 'fail: missing: command: mkfs.ext4'
	_stop_container 1
}
_format_container() {
	_generic_fragKey_container _format_container_procedure "$@"
}

# Places an insignificant filesystem header on device for UUID/labeling .
# "$1" == "/dev/device"
# "$2" == "label" (optional)
_label_device() {
	local currentLabel
	currentLabel="$2"
	[[ "$currentLabel" == "" ]] && currentLabel=""
	sudo -n mkfs.ext2 -L "$currentLabel" "$1" 1M
}

# Enables TRIM (discards) .
# DANGER: Beware enabling TRIM incurrs serious security, integrity, and performance issues. Do not enable without thorough understanding and/or mitigation.
# ATTENTION: Requires overloading "_mount_container_procedure" with "ops.sh" or similar.
# Supposed security benefits of TRIM depend on at least device hardware and absence of untrimmed regions.
# https://www.spinics.net/lists/raid/msg49440.html
# https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
# https://www.saout.de/pipermail/dm-crypt/2011-September/002019.html
# https://www.saout.de/pipermail/dm-crypt/2012-April/002420.html
# http://asalor.blogspot.com/2011/08/trim-dm-crypt-problems.html
_create_container_procedure_discard() {
	! _safety_container_created_not && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messageError 'fail: device: exists' && _stop_container 1
	
	cat "$fragKey_volume"/01 | sudo -n /sbin/cryptsetup --allow-discards --offset 2048 --hash whirlpool --key-size=512 --cipher aes-xts-plain64 --key-file=- create fragKey_"$fragKey_containerid"_9 "$fragKey_container"
	
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _stop_container 0
	_messagePlain_bad 'fail: device: missing'
	_stop_container 1
}

# RESERVED. May not be supported by newer operating system distributions.
_create_container_procedure_legacy() {
	! _safety_container_created_not && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messageError 'fail: device: exists' && _stop_container 1
	
	cat "$fragKey_volume"/01 | sudo -n /sbin/cryptsetup --offset 2048 --hash whirlpool --key-size=512 --cipher aes-xts-plain64 --key-file=- create fragKey_"$fragKey_containerid"_9 "$fragKey_container"
	
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _stop_container 0
	_messagePlain_bad 'fail: device: missing'
	_stop_container 1
}

# Typical.
_create_container_procedure_stable() {
	! _safety_container_created_not && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messageError 'fail: device: exists' && _stop_container 1
	
	cat "$fragKey_volume"/01 | sudo -n /sbin/cryptsetup --offset 2048 --hash whirlpool --key-size=512 --cipher aes-xts-plain64 --key-file=- create fragKey_"$fragKey_containerid"_9 "$fragKey_container"
	
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _stop_container 0
	_messagePlain_bad 'fail: device: missing'
	_stop_container 1
}

_create_container() {
	# WARNING: Enable only ONE of the following.
	
	_generic_fragKey_container _create_container_procedure_stable "$@"
	
	#_generic_fragKey_container _create_container_procedure_legacy "$@"
	
	# DANGER: Serious security, integrity, and performance issues. See "_fragKey_volume.sh" .
	#_generic_fragKey_container _create_container_procedure_discard "$@"
}

_remove_container_procedure() {
	#Do not proceed if container filesystem is mounted.
	! _safety_container_mounted_not && _stop_container 1
	
	! [[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messagePlain_warn 'warn: device: missing'
	
	local cryptToRemove
	
	cryptToRemove=fragKey_"$fragKey_containerid"_0 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_9 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_8 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_7 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_6 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_5 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_4 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_3 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_2 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	cryptToRemove=fragKey_"$fragKey_containerid"_1 ; [[ -e /dev/mapper/"$cryptToRemove" ]] && sudo -n /sbin/cryptsetup remove "$cryptToRemove"
	
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messagePlain_bad 'fail: device: remaining' && _stop_container 1
	_stop_container 0
}
_remove_container() {
	_generic_fragKey_container_remove _remove_container_procedure "$@"
}



_safety_container_mounted_not() {
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_0 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_1 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_2 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_3 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_4 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_5 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_6 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_7 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_8 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	cat /proc/self/mountinfo | grep fragKey_"$fragKey_containerid"_9 > /dev/null && _messageError 'fail: safety: mounted' && _stop_container 1
	return 0
}

_safety_container_created_not() {
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_0 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_1 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_2 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_3 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_4 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_5 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_6 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_7 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_8 ]] && _messageError 'fail: safety: created' && _stop_container 1
	[[ -e /dev/mapper/fragKey_"$fragKey_containerid"_9 ]] && _messageError 'fail: safety: created' && _stop_container 1
	return 0
}


_start_container() {
	_start
	
	_set_fragKey
	_set_fragKey_key_volume
	
	_prepare_fragKey
	_prepare_fragKey_volume
	
	[[ ! -e "$fragKey_active" ]] && _messageError 'fail: missing: key: header' && _stop 1
	[[ ! -e "$fragKey_container" ]] && _messageError 'fail: missing: container' && _stop 1
	[[ ! -e "$fragKey_registration" ]] && _messageError 'fail: missing: registration' && _stop 1
	
	export fragKey_containerid=$(cat "$fragKey_registration" 2>/dev/null)
	
	[[ $(echo -n "$fragKey_containerid" | wc -c | tr -dc '0-9') != '26' ]] && _messageError 'fail: insufficient: registration' && _stop 1
	
	_separate_fragKey_volume
	
	[[ $(cat "$fragKey_volume"/01 | wc -c | tr -dc '0-9') != '96' ]] && _messageError 'fail: insufficient: key: header' && _stop 1
	[[ $(cat "$fragKey_volume"/02 | wc -c | tr -dc '0-9') != '96' ]] && _messageError 'fail: insufficient: key: header' && _stop 1
	[[ $(cat "$fragKey_volume"/03 | wc -c | tr -dc '0-9') != '96' ]] && _messageError 'fail: insufficient: key: header' && _stop 1
	[[ $(cat "$fragKey_volume"/04 | wc -c | tr -dc '0-9') != '96' ]] && _messageError 'fail: insufficient: key: header' && _stop 1
}

_start_container_remove() {
	_start
	
	_set_fragKey
	_set_fragKey_key_volume
	
	_prepare_fragKey
	_prepare_fragKey_volume
	
	[[ ! -e "$fragKey_container" ]] && _messageError 'fail: missing: container' && _stop 1
	[[ ! -e "$fragKey_registration" ]] && _messageError 'fail: missing: registration' && _stop 1
	
	export fragKey_containerid=$(cat "$fragKey_registration" 2>/dev/null)
	
	[[ $(echo -n "$fragKey_containerid" | wc -c | tr -dc '0-9') != '26' ]] && _messageError 'fail: insufficient: registration' && _stop 1
}

_stop_container() {
	_sweep "$fragKey_volume"/01
	_sweep "$fragKey_volume"/02
	_sweep "$fragKey_volume"/03
	_sweep "$fragKey_volume"/04
	_stop
}

_generic_fragKey_container_remove_sequence() {
	_start_container_remove
	
	if ! "$@"
	then
		return 1
	fi
	
	return
}

_generic_fragKey_container_remove() {
	_messageNormal 'init: '"$1"
	if ! "$scriptAbsoluteLocation" _generic_fragKey_container_remove_sequence "$@"
	then
		_messageError 'FAIL'
		return 1
	fi
}

_generic_fragKey_container_sequence() {
	_start_container
	
	if ! "$@"
	then
		return 1
	fi
	
	return
}

_generic_fragKey_container() {
	_messageNormal 'init: '"$1"
	if ! "$scriptAbsoluteLocation" _generic_fragKey_container_sequence "$@"
	then
		_messageError 'FAIL'
		return 1
	fi
}



