package main

import (
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	log.Println("Starting pushsvc...")

	// Get data path
	if len(os.Args) < 2 {
		log.Fatal("Enter data path.")
	}
	dataPath := os.Args[1]

	// Initialize ticker
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	// Initialize HTTP client
	client := http.Client{}

	// Start looping
	for {
		<-ticker.C

		log.Println("Now pushing data.")

		// Open file
		file, err := os.Open(dataPath)
		if err != nil {
			log.Fatal("Cannot open file.")
		}

		// Create request
		req, err := http.NewRequest(
			"POST",
			"https://oscilloscope.ilharper.com/post-data",
			file)
		if err != nil {
			log.Fatal("Error occurred when creating HTTP clients.")
		}
		req.Header.Set("Authorization", "There's no authorization")

		// Do request
		res, err := client.Do(req)
		if err != nil {
			log.Fatal("Error occurred when sending requests.")
		}

		// Parse result
		if res.StatusCode != 200 {
			log.Fatalf("Invalid response status: %d", res.StatusCode)
		}

		// Close request
		err = res.Body.Close()
		if err != nil {
			log.Println("Res body close error.")
		}
	}
}
