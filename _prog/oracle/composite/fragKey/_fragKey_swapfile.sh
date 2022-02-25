_set_fragKey_swapfile() {
	export swapfileSize=32000
	export swapfileLocation="$scriptLocal"/swapfile
}

_prepare_fragKey_swapfile() {
	_set_fragKey_swapfile
	mkdir -p "$scriptLocal"
}

_fragKey_swapfile_check() {
	#https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption#Using_a_swap_file
	if mount | grep -i 'btrfs' > /dev/null 2>&1
	then
		_messageFAIL 'FAIL: SEVERE filesystem CORRUPTION with swapfile under BTRFS'
	fi
}

_fragKey_swapfile_create() {
	_prepare_fragKey_swapfile
	
	[[ "$swapfileLocation" == "" ]] && return 1
	
	[[ -e "$swapfileLocation" ]] && return 0
	
	
	_messageNormal 'swapfile: create'
	dd if=/dev/zero of="$swapfileLocation" bs=1M count="$swapfileSize" status=progress
	chmod 600 "$swapfileLocation"
	mkswap "$swapfileLocation"
}


_fragKey_swapfile_sequence() {
	_start
	_prepare_fragKey_swapfile
	
	_fragKey_swapfile_create
	
	_stop
}

# DANGER: Placeholder.
# WARNING: Best practice is apparently to use an swapfile placed on an encrypted filesystem.
#https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption#Using_a_swap_file
#https://unix.stackexchange.com/questions/64551/how-do-i-set-up-an-encrypted-swap-file-in-linux
_fragKey_swapfile() {
	"$scriptAbsoluteLocation" _fragKey_swapfile_sequence "$@"
}
