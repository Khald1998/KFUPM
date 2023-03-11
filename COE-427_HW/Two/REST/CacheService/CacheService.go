package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

// Model the service with an interface
// Capital 'S' in the identifier means the interface is public
type CacheService interface {
	PostCache(x int, y int, op string)
	GetCache(x int, y int, op string) (data int)
	PutCache(x int, y int, op string)
	DeleteCache(x int, y int, op string)
}








// Make the service available on the network (i.e., callable by other services)
// Function name must be 'ServeHTTP'
 func ServeHTTP(w http.ResponseWriter, r *http.Request) {
	

	
			//result := jsonData["result"]

			switch r.Method {
			case "POST":
				
				var jsonData map[string]string
				reqBody := json.NewDecoder(r.Body).Decode(&jsonData)
				fmt.Println(reqBody)
				x := jsonData["x"]
				y := jsonData["y"]
				op := jsonData["op"]

				packet := map[string]string{
					"x": x,
					"y": y,
					"op": op,
					"result": jsonData["result"],
				}
				bufferPacket := new(bytes.Buffer)
				json.NewEncoder(bufferPacket).Encode(packet)
				
		
				if checkCache(x, y, op) == "nil" {
				resp, _ := http.Post("http://localhost:9991", "application/json", bufferPacket)
				body, _ := ioutil.ReadAll(resp.Body)
				fmt.Fprintf(w, string(body))
		
				} else {
					fmt.Fprintf(w, "data already is exist in cache!")
				}
			case "GET":
				x := r.URL.Query()["x"][0]
				y := r.URL.Query()["y"][0]
				op := r.URL.Query()["op"][0]
				data := checkCache(x, y, op)
				
				if  data == "nil" {
					fmt.Fprintf(w, "Data does not exist!!!")
				} else {
					fmt.Fprintf(w, "data = %v", data)
				}
			case "PUT":
			case "DELETE":
				x := r.URL.Query()["x"][0]
				y := r.URL.Query()["y"][0]
				op := r.URL.Query()["op"][0]
				req, err := http.NewRequest("DELETE", "http://localhost:9991?x="+x+"&y="+y+"&op="+op, nil)

				if err != nil {
					fmt.Println(err)
					return
				}

				resp, err := (&http.Client{}).Do(req)
				if err != nil {
					fmt.Println(err)
					return
				}
				body, _ := ioutil.ReadAll(resp.Body)
				fmt.Fprintf(w, string(body))
			default:
				fmt.Fprintf(w, "Unsupported HTTP method!")
			}
}

func checkCache(x string, y string, op string) string {
	resp, _ := http.Get("http://localhost:9991?x="+x+"&y="+y+"&op="+op )
	body, _ := ioutil.ReadAll(resp.Body)
	return string(body)
}

func main() {
	http.HandleFunc("/", ServeHTTP)

	err := http.ListenAndServe("localhost:9990", nil)

	if err != nil {
		log.Fatal(err)
	}
}
