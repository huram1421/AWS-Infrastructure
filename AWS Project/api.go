package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func api(w http.ResponseWriter, req *http.Request) {

	// reply
	fmt.Fprintf(w, "OK")
	fmt.Println("first api")

	// HTTP POST Request
	request, error := http.NewRequest("POST", "http://10.0.1.50:8888/logic", req.Body)
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")
	client := &http.Client{}
	response, error := client.Do(request)
	
	if error != nil {
		panic(error)
	}

	// Closing TCP Connections
	defer response.Body.Close()
	client.CloseIdleConnections()
	req.Close = true


	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))
	fmt.Println("last api")
}

func main() {

	http.HandleFunc("/api", api)

	err := http.ListenAndServe(":9999", nil)

	if err != nil {
		log.Fatal(err)
	}
}
