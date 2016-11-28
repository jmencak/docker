package main

import (
	"fmt"
	"net/http"
	"os"
	"strconv"   // Atoi()
	"time"      // Sleep()
)

/* Constants */
const (
	D_USECS       = 0 // default delay in microseconds
)

/* Options */
var usecs = D_USECS // sleep delay before serving a request

func helloHandler(w http.ResponseWriter, r *http.Request) {
	response := os.Getenv("RESPONSE")
	if len(response) == 0 {
		response = "Hello OpenShift!"
	}

	if usecs != 0 {
		time.Sleep(time.Duration(usecs) * time.Microsecond)
	}

	fmt.Fprintln(w, response)
	fmt.Printf("%s --> %s %s%s\n", r.RemoteAddr, r.Method, r.Host, r.URL.Path)
}

func listenAndServe(port string) {
	fmt.Printf("serving on %s\n", port)
	err := http.ListenAndServe(":"+port, nil)
	if err != nil {
		panic("ListenAndServe: " + err.Error())
	}
}

func main() {
	var e error

	http.HandleFunc("/", helloHandler)
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}
	go listenAndServe(port)

	port = os.Getenv("SECOND_PORT")
	if len(port) == 0 {
		port = "8888"
	}

	delay := os.Getenv("DELAY")
	if len(delay) == 0 {
		usecs = 0
	} else {
		usecs, e = strconv.Atoi(delay)
		if e != nil {
			fmt.Fprintf(os.Stderr, "<DELAY> `%s' not an integer\n", os.Args[1])
			os.Exit(1)
		}
	}

	fmt.Printf("DELAY=%d\n", usecs)
	
//	go listenAndServe(port)

	select {}
}
