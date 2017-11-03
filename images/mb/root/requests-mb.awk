/./ {
  if (i) {printf "\n  },\n" }
  printf "  {\n"
  printf "    \"scheme\": \"http\",\n"
  printf "    \"tls-session-reuse\": %s,\n", tls_session_reuse
  printf "    \"host\": \"%s\",\n", $1
  printf "    \"port\": %s,\n", port
  printf "    \"method\": \"GET\",\n"
  printf "    \"path\": \"%s\",\n", path
  printf "    \"keep-alive-requests\": %s,\n", ka_requests
  printf "    \"clients\": %s,\n", clients
  printf "    \"delay\": {\n"
  printf "      \"min\": %s,\n", delay_min
  printf "      \"max\": %s\n", delay_max
  printf "    }"
  i++
}
BEGIN { i=0; printf "[\n" }
END {
  if (i) { printf "\n  }" }
  printf "\n]\n"
}
