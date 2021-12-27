package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

type AppHandler struct {
	Data []byte
}

func (r AppHandler) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	switch req.URL.Path {
	case "/post-data":
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
		r.Data = body
		w.WriteHeader(200)
		log.Print("Post success")
		return
	case "/get-data":
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
		_, err := w.Write(r.Data)
		if err != nil {
			log.Print("Data write failed")
			return
		}
		log.Print("Get success")
		return
	}
}

func main() {
	var listen string

	// Check listen address
	if len(os.Args) < 2 {
		log.Fatal("Provide listen address.")
	} else {
		listen = os.Args[1]
	}

	log.Printf("Starting cloudsvc at %s...", listen)
	// Start server
	log.Fatal(http.ListenAndServe(listen, AppHandler{Data: []byte{}}))
}
