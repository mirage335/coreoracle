# DANGER: Dangerous command! Root required!
# WARNING: Untested.
# WARNING: Persistent swap is NOT recommended.
# Configures computer with randomly encrypted (nonpersistent) swap.
# https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption#UUID_and_LABEL
_flagSwap() {
	local currentDevice
	currentDevice="$1"
	
	local currentLabel
	currentLabel="$2"
	[[ "$currentLabel" == "" ]] && currentLabel="cryptswap"
	
	local currentName
	currentName="$currentLabel"
	
	_mustGetSudo
	
	_messagePlain_warn 'DANGEROUS command! Enter to continue!'
	read
	
	! [[ -e "$currentDevice" ]] && _messagePlain_bad 'missing: device' && _messageFAIL
	
	sudo -n blkid "$currentDevice" | grep ext4 > /dev/null 2>&1 && _messagePlain_bad 'FAIL: filesystem found, must be removed' && _messageFAIL
	
	_messagePlain_nominal 'label: '"$currentDevice"
	sudo -n mkfs.ext2 -L "$currentLabel" "$currentDevice" 1M
	
	sudo -n blkid "$currentDevice"
	
	_messagePlain_nominal 'configure: /etc/crypttab'
	! grep "$currentLabel" /etc/crypttab > /dev/null 2>&1 && echo "$currentName"'     LABEL='"$currentLabel"'  /dev/urandom swap,offset=2048,cipher=aes-xts-plain64,size=512' | sudo -n tee -a /etc/crypttab
	
	_messagePlain_nominal 'configure: /etc/fstab'
	! grep '/dev/mapper/'"$currentName" /etc/fstab > /dev/null 2>&1 && echo '/dev/mapper/'"$currentName"'  none   swap    defaults   0       0' | sudo -n tee -a /etc/fstab
	
	#_messagePlain_nominal 'enable: swapon'
	#sudo -n swapon -a
	
	#_messagePlain_probe 'results: '
	#free -m
	
	_messagePlain_request 'request: reboot'
}
