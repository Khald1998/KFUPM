package main

import (
	"fmt"
	"log"
	"net/http"
	"net/rpc"
	"strconv"
)

type Args struct {
	A, B int
	op   string
}

func hello(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "Hello to the HiCalculator!")
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

	client, err := rpc.DialHTTP("tcp", "localhost:"+portNumber)

	if err != nil {
		log.Fatal("dialing:", err)
	}

	xInt, _ := strconv.Atoi(x)
	yInt, _ := strconv.Atoi(y)
	args := Args{xInt, yInt, op}

	var methodName string
	switch op {
	case "add":
		methodName = "Add"
	case "sub":
		methodName = "Sub"
	case "mul":
		methodName = "Mul"
	case "div":
		methodName = "Div"
	}

	var reply int
	err = client.Call("Arith."+methodName, args, &reply)

	if err != nil {
		log.Fatal("arith error:", err)
	}
	fmt.Fprintf(w, "Arith: %d %s %d = %d\n", args.A, args.op, args.B, reply)
	//body, _ := ioutil.ReadAll(resp.Body)
	//fmt.Fprintf(w, string(body))
	return false
}

func main() {
	http.HandleFunc("/", hello)
	http.HandleFunc("/add", add)
	http.HandleFunc("/sub", sub)
	http.HandleFunc("/div", div)
	http.HandleFunc("/mul", mul)

	err := http.ListenAndServe("localhost:9999", nil)

	if err != nil {
		log.Fatal(err)
	}
}
