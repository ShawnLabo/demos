package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"
)

var errorRate float64

func main() {
	rand.Seed(time.Now().UnixNano())

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	var err error
	errorRate, err = strconv.ParseFloat(os.Getenv("ERROR_RATE"), 64)
	if err != nil {
		panic(err)
	}

	http.HandleFunc("/", handler)

	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	if rand.Float64() < errorRate {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "error")
	} else {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "ok")
	}
}
