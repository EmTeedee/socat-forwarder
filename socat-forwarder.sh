#! /bin/bash

UPDATE_INTERVAL=30 # check for new IPv6 addresses every 30 seconds
IPV6_HOST=""
IPV6_FILE=""
TCP_PORTS=()
UDP_PORTS=()

if [ -z "${1:-}" ] || [ ! -r "${1}" ]; then
    echo "No config file provided">&2
else
    # shellcheck source=/dev/null
    source "${1}"
fi

stopping=false

socat_pids=()
function stop_socat() {
    ${stopping} && return
    echo "Stop forwarding"
    for pid in "${socat_pids[@]}"; do
        if [ -e "/proc/${pid}" ]; then
            echo "Kill pid ${pid}"
            kill "${pid}"
        fi
    done
    socat_pids=()
}


# shellcheck disable=2317
function exit_handler() {
    stop_socat
    stopping=true
}
trap 'exit 1' INT SIGINT
trap 'exit 0' TERM SIGTERM
# shellcheck disable=2154
trap 'rc=$?; exit_handler $rc; exit $rc' EXIT

function start_socat {
    ${stopping} && return
    if [ -z "${1}" ]; then
        echo "Got empty IPv6 address"
        return
    fi
    echo "Start forwarding to ${1}"
    for port in "${TCP_PORTS[@]}"; do
        echo "Forward TCP:${port}"
        socat "TCP6-LISTEN:${port},fork,su=nobody,reuseaddr" "TCP6:[${1}]:${port}" &
        socat_pids+=( $! )
    done
    for port in "${UDP_PORTS[@]}"; do
        echo "Forward UDP:${port}"
        socat "UDP6-LISTEN:${port},fork,su=nobody,reuseaddr" "UDP6:[${1}]:${port}" &
        socat_pids+=( $! )
    done
}

function get_ipv6 {
    local result
    if [ -e "${IPV6_FILE}" ]; then
        result=$(cat "${IPV6_FILE}")
    else
        result=$(host -t aaaa "${IPV6_HOST}" | cut -d' ' -f5)
    fi
    if [[ $result =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then
        echo "${result}"
    else
        echo ""
    fi
}

serveraddr=$(get_ipv6)
start_socat "${serveraddr}"

# recreate socat processes if necessary
while ! ${stopping}; do
    serveraddr_new=$(get_ipv6)
    if [ -n "${serveraddr_new}" ] && [ "${serveraddr_new}" != "${serveraddr}" ]; then
        serveraddr=${serveraddr_new}
        echo "New IP address: $serveraddr_new"
	stop_socat
        sleep 5
        start_socat "${serveraddr}"
    fi
    sleep ${UPDATE_INTERVAL}
done
exit 0
