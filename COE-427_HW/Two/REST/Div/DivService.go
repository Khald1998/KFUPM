package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
)

// Model the service with an interface
// Capital 'S' in the identifier means the interface is public
type DivService interface {
	// PostSum(x int, y int)
	// GetSum(x int, y int) (sum int)
	// PutSum(x int, y int)
	// DeleteSum(x int, y int)
}

func /*(ss *addService) */ ServeHTTP(w http.ResponseWriter, r *http.Request) {
	x := r.URL.Query()["x"][0]
	y := r.URL.Query()["y"][0]
	op := "div"


	
	
	switch r.Method {
	case "POST":
		
			
			num1,_ := strconv.Atoi(x) 
			num2,_ := strconv.Atoi(y) 
			result := num1 / num2
			packet := map[string]string{
				"x": x,
				"y": y,
				"op": op,
				"result": strconv.Itoa(result),
			}
			bufferPacket := new(bytes.Buffer)
			json.NewEncoder(bufferPacket).Encode(packet)
			
			resp, _ := http.Post("http://localhost:9990", "application/json", bufferPacket)
			body, _ := ioutil.ReadAll(resp.Body)
			fmt.Fprintf(w, string(body))
		 
	case "GET":
		
		body := checkCache(x, y, op)
		fmt.Fprint(w, body)
		
	case "PUT":
	case "DELETE":
		// API gateway calls the SumService
		req, err := http.NewRequest("DELETE", "http://localhost:9990?x="+x+"&y="+y+"&op="+op, nil)
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
	resp, _ := http.Get("http://localhost:9990?x="+x+"&y="+y+"&op="+op )
	body, _ := ioutil.ReadAll(resp.Body)
	return string(body)
}

func main() {
	http.HandleFunc("/div", ServeHTTP)


	err := http.ListenAndServe("localhost:9995", nil /*ss*/)

	
	if err != nil {
		log.Fatal(err)
	}
}
