
export ops_name=$(basename "$scriptAbsoluteFolder")
export ops_category=$(dirname "$scriptAbsoluteFolder")
export ops_category=$(basename "$ops_category")

# ATTENTION: Configure if appropriate. Replace or set "$netName" as desired. Comment alternatives as desired.
#[[ ! -e "$ops_cautossh_location" ]] && export ops_cautossh_location="$scriptAbsoluteFolder"/../_backing/ssh/"$netName"/cautossh

[[ ! -e "$ops_cautossh_location" ]] && export ops_cautossh_location="$scriptAbsoluteFolder"/../../../_backing/ssh/"$ops_category"/cautossh
[[ ! -e "$ops_cautossh_location" ]] && export ops_cautossh_location=~/core/infrastructure/ssh/"$ops_category"/cautossh
[[ ! -e "$ops_cautossh_location" ]] && export ops_cautossh_location=~/core/"$ops_category"/cautossh
[[ ! -e "$ops_cautossh_location" ]] && export ops_cautossh_location="$scriptAbsoluteFolder"/../../../../50_network/ssh/entity/"$ops_category"/cautossh


###
#commKey
###
# ATTENTION: Typically included client side only.
_ops_ssh() {
	"$ops_cautossh_location" _ssh "$@"
}
_ops_scp() {
	"$ops_cautossh_location" _scp "$@"
}
_ops_rsync() {
	"$ops_cautossh_location" _rsync "$@"
}

_ops_ssh_mkdir() {
	#_ops_ssh "$@" 'mkdir -p core/infrastructure
	#mkdir -m 0700 -p core/infrastructure/oracle
	#chmod 0700 core/infrastructure/oracle
	
	#mkdir -m 0700 -p core/infrastructure/oracle/'"$ops_name"'
	#chmod 0700 core/infrastructure/oracle/'"$ops_name"
	
	_ops_ssh "$@" 'mkdir -p core/infrastructure
	mkdir -m 0700 -p core/infrastructure/oracle
	chmod 0700 core/infrastructure/oracle
	
	mkdir -m 0700 -p core/infrastructure/oracle/'"$ops_category"'
	chmod 0700 core/infrastructure/oracle/'"$ops_category"'
	
	mkdir -m 0700 -p core/infrastructure/oracle/'"$ops_category"/"$ops_name"'
	chmod 0700 core/infrastructure/oracle/'"$ops_category"/"$ops_name"
}

# ATTENTION: Typical.
# DANGER: Includes "default".
# WARNING: Remote script must run from its own directory.
_upload_ops_ssh() {
	_ops_ssh_mkdir "$@"
	#_ops_rsync -avzx "$scriptAbsoluteFolder" "$@":core/infrastructure/oracle/
	#_ops_scp -r "$scriptAbsoluteFolder"/commKey "$scriptAbsoluteFolder"/temple "$@":core/infrastructure/oracle/"$ops_name"/
	
	_ops_scp -r "$scriptAbsoluteFolder"/commKey "$scriptAbsoluteFolder"/temple "$@":core/infrastructure/oracle/"$ops_category"/"$ops_name"/
}

_client_commKey_cssh() {
	local anon_id="$1"
	shift
	
	_client_commKey "$anon_id" _ops_ssh "$@" core/infrastructure/oracle/"$ops_category"/"$ops_name"/commKey _commKey_interpreter "$anon_id"
}


_upload-machine() {
	_upload_ops_ssh machine-network
}

_upload_all() {
	_upload-machine
}

_machine() {
	_client_commKey_cssh "" machine-network
}

_machine-Nq9Fd9B9HNdKKPy81lvKGRQL() {
	_client_commKey_cssh Nq9Fd9B9HNdKKPy81lvKGRQL machine-network
}

_machine__NEWU() {
	_client_commKey_generate "" _ops_ssh machine-network core/infrastructure/oracle/"$ops_category"/"$ops_name"/commKey _commKey_interpreter ""
}
_machine__PASS() {
	echo -n PASS | _machine
}
_machine__LOGO() {
	echo -n LOGO | _machine
}
_machine__LOGA() {
	echo -n LOGA | _machine
}
_machine__LOGR() {
	echo -n LOGR | _machine
}

# Client "mobile" .
_machine-Nq9Fd9B9HNdKKPy81lvKGRQL__PASS() {
	echo -n PASS | _machine-Nq9Fd9B9HNdKKPy81lvKGRQL
}
_machine-Nq9Fd9B9HNdKKPy81lvKGRQL__LOGO() {
	echo -n LOGO | _machine-Nq9Fd9B9HNdKKPy81lvKGRQL
}
_machine-Nq9Fd9B9HNdKKPy81lvKGRQL__LOGA() {
	echo -n LOGA | _machine-Nq9Fd9B9HNdKKPy81lvKGRQL
}
_machine-Nq9Fd9B9HNdKKPy81lvKGRQL__LOGR() {
	echo -n LOGR | _machine-Nq9Fd9B9HNdKKPy81lvKGRQL
}







###
#fragKey
###

export containerPath="$scriptAbsoluteFolder"/container
export fsPath="$scriptLocal"/fs


_pull_frag_keyID() {
	cd "$scriptAbsoluteFolder"
	_start
	
	local current_keyID
	current_keyID="keyID"
	
	_messagePlain_nominal 'pull: '"$current_keyID"
	
	# ! _checkPort host port && _messagePlain_warn 'missing: net' && _stop 1
	! true && _stop 1
	
	# ! [[ -e /dev/disk/by-uuid/tokenid ]] && _messagePlain_warn 'missing: token' && _stop 1
	! true && _stop 1
	
	# _messagePlain_nominal '-----REQUEST: user interaction . Send "ENTER" (3sec) .' ; ! read -t 3 && _messagePlain_warn 'missing: user' && _stop 1
	! true && _stop 1
	
	local current_keyPath
	if ! current_keyPath=$(_path_fragKey_distributed "$current_keyID")
	then
		 _messagePlain_warn 'fail: path'
		_stop 1
	fi
	
	if ! ssh user@machine 'cat keys/'"$current_keyID"/sub_01 > "$current_keyPath"/sub_01
	then
		 _messagePlain_warn 'fail: net'
		_stop 1
	fi
	
	mkdir -p -m 700 "$safeTmp"/token
	sudo mount -o ro /dev/disk/by-uuid/tokenid "$safeTmp"/token
	sudo cat keys/"$current_keyID"/sub_02 > "$current_keyPath"/sub_02
	sudo umount -o ro /dev/disk/by-uuid/tokenid "$safeTmp"/token
	! [[ -e "$current_keyPath"/sub_02 ]] && _messagePlain_warn 'fail: token' && _stop 1
	
	! ./fragKey _password_fragKey "$current_keyID" && _messagePlain_warn 'fail: user' && _stop 1
	
	
	! _recover_fragKey_distributed "$current_keyID" && _stop 1
	_stop 0
}

_pull_frag() {
	cd "$scriptAbsoluteFolder"
	
	_messageNormal '*****pull'
	
	"$scriptAbsoluteLocation" _pull_frag_keyID && return 0
	
	return 1
}

_attempt() {
	cd "$scriptAbsoluteFolder"
	
	local currentStatus
	currentStatus='false'
	
	_messageNormal '*****attempt'
	
	_messageNormal 'create'
	
	_create_container
	
	_messageNormal 'mount'
	
	_mount_container && _messagePlain_good '...done' && currentStatus='true'
	
	_purge_fragKey_project
	
	[[ "$currentStatus" == 'true' ]] && return 0
	return 1
}

_grab() {
	cd "$scriptAbsoluteFolder"
	
	_messageNormal '*****grab'
	
	_attempt && return 0
	
	! _pull_frag
	
	_attempt && return 0
	
	
}




_create_container() {
	# WARNING: Enable only ONE of the following.
	
	_generic_fragKey_container _create_container_procedure_stable "$@"
	
	#_generic_fragKey_container _create_container_procedure_legacy "$@"
	
	# DANGER: Serious security, integrity, and performance issues. See "_fragKey_volume.sh" .
	#_generic_fragKey_container _create_container_procedure_discard "$@"
}
