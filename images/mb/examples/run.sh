#!/bin/sh

### Docker image
docker_image="jmencak/mb"

### Container variables
RUN=mb					# which app to execute inside the container
RUN_TIME=60				# benchmark run-time in seconds
MB_PORT=80				# target port
MB_DELAY=0				# maximum delay between client requests in ms
MB_TARGETS="."				# extended RE (egrep) to filter target routes
MB_CONNS_PER_TARGET=40			# how many connections per target route
MB_KA_REQUESTS=10			# how many HTTP keep-alive requests to send before sending "Connection: close"
MB_TLS_SESSION_REUSE="y"		# use TLS session reuse [yn]
MB_RAMP_UP=15				# thread ramp-up time in seconds
URL_PATH="/"				# target path for HTTP(S) requests
SERVER_RESULTS=results@172.16.113.254:/home/results/tmp		# [user@]host:/path, if undefined results are not copied
SERVER_RESULTS_SSH_KEY=/home/mencak/.ssh/rh/perf/id_rsa_perf	# private ssh key to copy the results to $SERVER_RESULTS

### Container volumes
targets_list=$(realpath ./targets.txt)
targets_json=$(realpath ./targets.json)

example_list() {
  local now benchmark_test_config conns_per_thread_f delay_f ka_f page_size_kb page_size_kb_f

  for page_size_kb in 1 32 ; do
    for MB_KA_REQUESTS in 1 10 ; do
      now=$(date '+%Y-%m-%d_%H.%M.%S')

      URL_PATH="/$(expr $page_size_kb \* 1024).html"	# make sure your server servers these pages!
      conns_per_thread_f=$(printf "%03d" $MB_CONNS_PER_TARGET)
      delay_f=$(printf "%04d" $MB_DELAY)
      ka_f=$(printf "%03d" $MB_KA_REQUESTS)
      page_size_kb_f=$(printf "%02d" $page_size_kb)
      benchmark_test_config="${conns_per_thread_f}cpt-${delay_f}d_ms-${ka_f}ka-${page_size_kb_f}kB-${RUN_TIME}s-$now"
  
      docker run -it --rm \
        --net=host \
        --name "${RUN}" \
        -e RUN=${RUN} \
        -e RUN_TIME=${RUN_TIME} \
        -e MB_RAMP_UP=${MB_RAMP_UP} \
        -e MB_PORT=${MB_PORT} \
        -e MB_DELAY=${MB_DELAY} \
        -v ${targets_list:-/tmp/targets.txt}:/opt/wlg/targets.txt:z,ro \
        -e MB_TARGETS=${MB_TARGETS} \
        -e MB_CONNS_PER_TARGET=${MB_CONNS_PER_TARGET} \
        -e MB_KA_REQUESTS=${MB_KA_REQUESTS} \
        -e MB_TLS_SESSION_REUSE=${MB_TLS_SESSION_REUSE} \
        -e URL_PATH=${URL_PATH} \
        -e RESULTS_DIR="$(hostname)-${RUN}-${benchmark_test_config}" \
        -e SERVER_RESULTS=${SERVER_RESULTS} \
        -v ${SERVER_RESULTS_SSH_KEY}:/root/.ssh/id_rsa:z,ro \
        $docker_image
    done
  done
}

example_json() {
  docker run -it --rm \
    --net=host \
    --name "${RUN}" \
    -e RUN=${RUN} \
    -e RUN_TIME=${RUN_TIME} \
    -e MB_RAMP_UP=${MB_RAMP_UP} \
    -v ${targets_json:-/tmp/targets.json}:/opt/wlg/targets.json:z,ro \
    -e RESULTS_DIR="$(hostname)-${RUN}" \
    -e SERVER_RESULTS=${SERVER_RESULTS} \
    -v ${SERVER_RESULTS_SSH_KEY}:/root/.ssh/id_rsa:z,ro \
    $docker_image
}

#example_list
example_json
