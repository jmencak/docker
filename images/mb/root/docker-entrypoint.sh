#!/bin/bash

ProgramName=${0##*/}

# Global variables
pctl_bin=pctl

fail() {
  echo $@ >&2
}

warn() {
  fail "$ProgramName: $@"
}

die() {
  local err=$1
  shift
  fail "$ProgramName: $@"
  exit $err
}

usage() {
  cat <<EOF 1>&2
Usage: $ProgramName
EOF
}

use_option() {
  local option="$1"
  local env_var="$2"
  local empty_sets="${3:-n}"
  local neg="${4:-n}"
  eval local env_var_val='$'"$env_var"

  test "$env_var_val" || {
    if test "$empty_sets" = y ; then
      echo -n $option
    else
      :
    fi
    return 0
  }

  case "$env_var_val" in
    [Yy]) 
      if test "$neg" = y ; then
        :
      else
        echo -n "$option"
      fi
      ;;

    [Nn])
      if test "$neg" = y ; then
        echo -n "$option"
      else
        :
      fi
      ;;
    
    *)
      die 1 "invalid value \`$env_var_val\` for $env_var"
      ;;
  esac
}

have_server() {
  local server="$1"
  if test "${server}" = "127.0.0.1" || test "${server}" = "" ; then
    # server not defined
    return 1
  fi 
}

# basic checks for toybox/busybox/coreutils timeout
define_timeout_bin() {
  test "${RUN_TIME}" || return	# timeout empty, do not define it and just return

  timeout -t 0 /bin/sleep 0 >/dev/null 2>&1

  case $? in
    # we have a busybox timeout with '-t' option for number of seconds
    0)
      timeout="timeout -t ${RUN_TIME}"
      ;;

    # we have toybox's timeout without the '-t' option for number of seconds
    1)   
      timeout="timeout ${RUN_TIME}"
      ;;

    # we have coreutil's timeout without the '-t' option for number of seconds
    125)
      timeout="timeout ${RUN_TIME}"
      ;;

    # couldn't find timeout or unknown version
    *)
      warn "running without timeout"
      timeout=""
      ;;
  esac
}

timeout_exit_status() {
  local err="${1:-$?}"

  case $err in
    # coreutil's return code for timeout
    124)
      return 0
      ;;

    # timeout also sends SIGKILL if a process fails to respond
    137)
      return 0
      ;;

    # busybox's return code for timeout with default signal TERM
    143)
      return 0
      ;;

    *)
      return $err
      ;;
  esac
}

main() {
  define_timeout_bin

  case "${RUN}" in
    mb)
      local requests_awk=requests-mb.awk
      local dir_out=${RESULTS_DIR:-${RUN}-${HOSTNAME:-${IDENTIFIER:-0}}}
      local mb_log=$dir_out/${RUN}.log
      local targets_list=/opt/wlg/targets.txt
      local targets_json=/opt/wlg/targets.json
      local requests_json=$dir_out/requests.json
      local mb=/usr/local/bin/mb
      local env_out=$dir_out/environment	# for debugging
      local results_csv=$dir_out/results.csv
      local graph_dir=gnuplot/${RUN}
      local graph_sh=gnuplot/$RUN/graph.sh
      local interval=10				# sample interval for d3js graphs [s]
      local tls_session_reuse=""

      rm -rf ${dir_out} && mkdir -p ${dir_out}
      ulimit -n 1048576				# use the same limits as HAProxy pod
      #sysctl -w net.ipv4.tcp_tw_reuse=1	# safe to use on client side
      env > $env_out				# dump out the environment for debugging

      local tls_session_reuse=$(use_option "true" MB_TLS_SESSION_REUSE n n)		# TLS session reuse is disabled by default

      if test -r "${targets_json}" ; then
        cp ${targets_json} ${requests_json}
      elif test -r "${targets_list}" ; then
        cat ${targets_list} | grep -E "${MB_TARGETS:-.}" | awk \
          -vtls_session_reuse=${tls_session_reuse:-false} \
          -vport=${MB_PORT:-80} \
          -vka_requests=${MB_KA_REQUESTS:-100} -vclients=${MB_CONNS_PER_TARGET:-10} \
          -vpath=${URL_PATH:-/} -vdelay_min=0 -vdelay_max=${MB_DELAY:-1000} \
          -f ${requests_awk} > ${requests_json} || \
          die $? "${RUN} failed: $?: unable to retrieve mb targets list \`targets'"
      else
        die 1 "${RUN} failed: 1: no targets provided."
      fi

      $timeout \
        $mb \
          -d${RUN_TIME:-600} \
          -r${MB_RAMP_UP:-0} \
          -i ${requests_json} \
          -o ${results_csv}.$$ > $mb_log 2>&1
      timeout_exit_status || die $? "${RUN} failed: $?"
      LC_ALL=C sort -t, -n -k1 ${results_csv}.$$ > ${results_csv}
      rm -f ${results_csv}.$$
      $graph_sh ${graph_dir} ${results_csv} $dir_out/graphs $interval
      xz -0 -T0 ${results_csv}

      if have_server "${SERVER_RESULTS}" ; then
        scp -o StrictHostKeyChecking=false -rp ${dir_out} ${SERVER_RESULTS}
      fi
      timeout_exit_status || die $? "${RUN} failed: scp: $?"
      ;;

    *)
      die 1 "No harness for RUN=\"$RUN\"."
      ;;
  esac
  timeout_exit_status
}

main
