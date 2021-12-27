package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	var listen string

	// Check listen address
	if len(os.Args) < 2 {
		log.Fatal("Provide listen address.")
	} else {
		listen = os.Args[1]
	}

	var data []byte

	postHandler := func(w http.ResponseWriter, req *http.Request) {
		if req.Header.Get("Authorization") != "There's no authorization" {
			log.Print("Post forbidden")
			w.WriteHeader(403)
			return
		}
		if req.Method != "POST" {
			w.WriteHeader(400)
			return
		}
		body, err := ioutil.ReadAll(req.Body)
		if err != nil {
			log.Print("Bad request")
			w.WriteHeader(400)
			return
		}
		data = body
		w.WriteHeader(200)
		log.Print("Post success")
	}

	getHandler := func(w http.ResponseWriter, req *http.Request) {
		if req.Header.Get("Authorization") != "There's no authorization" {
			log.Print("Get forbidden")
			w.WriteHeader(403)
			return
		}
		if req.Method != "GET" {
			w.WriteHeader(400)
			return
		}
		w.Header().Add("Content-Type", "text/plain")
		w.WriteHeader(200)
		_, err := w.Write(data)
		if err != nil {
			log.Print("Data write failed")
			return
		}
		log.Print("Get success")
	}

	log.Printf("Starting cloudsvc at %s...", listen)
	// Start server
	http.HandleFunc("/post-data", postHandler)
	http.HandleFunc("/get-data", getHandler)
	log.Fatal(http.ListenAndServe(listen, nil))
}
