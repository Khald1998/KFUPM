package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func hello(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "URL: http://localhost:9998/add?x=2&y=2\n")
	fmt.Fprintf(w, "URL: http://localhost:9997/sub?x=1&y=2\n")
	fmt.Fprintf(w, "URL: http://localhost:9996/div?x=1&y=2\n")
	fmt.Fprintf(w, "URL: http://localhost:9995/mul?x=1&y=2\n")

}

func add(w http.ResponseWriter, req *http.Request) {
	x := req.URL.Query()["x"][0]
	y := req.URL.Query()["y"][0]

	isSuccessful := sendRequest(req, w, x, y, "add", "9997")
	if isSuccessful {
		return
	}
}

func sub(w http.ResponseWriter, req *http.Request) {
	x := req.URL.Query()["x"][0]
	y := req.URL.Query()["y"][0]

	isSuccessful := sendRequest(req, w, x, y, "sub", "9996")
	if isSuccessful {
		return
	}
}

func div(w http.ResponseWriter, req *http.Request) {
	x := req.URL.Query()["x"][0]
	y := req.URL.Query()["y"][0]

	isSuccessful := sendRequest(req, w, x, y, "div", "9995")
	if isSuccessful {
		return
	}
}

func mul(w http.ResponseWriter, req *http.Request) {
	x := req.URL.Query()["x"][0]
	y := req.URL.Query()["y"][0]

	isSuccessful := sendRequest(req, w, x, y, "mul", "9994")
	if isSuccessful {
		return
	}
}

func sendRequest(req *http.Request, w http.ResponseWriter, x string, y string, op string, portNumber string) bool {
	req, err := http.NewRequest(req.Method, "http://localhost:"+portNumber+"/"+op+"?x="+x+"&y="+y, nil)
	if err != nil {
		fmt.Println(err)
		return true
	}

	resp, err := (&http.Client{}).Do(req)
	if err != nil {
		fmt.Println(err)
		return true
	}
	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Fprintf(w, string(body))
	return false
}

func main() {
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/add", add)
	http.HandleFunc("/sub", sub)
	http.HandleFunc("/div", div)
	http.HandleFunc("/mul", mul)

	err := http.ListenAndServe("localhost:9999", nil)

	if err != nil {
		log.Fatal(err)
	}
}
