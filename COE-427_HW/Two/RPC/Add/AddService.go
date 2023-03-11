package main

import (
	// "bytes"
	// "encoding/json"
	// "fmt"
	// "io/ioutil"

	// "fmt"
	"log"
	"net/http"
	"net/rpc"
	"strconv"
	// "strconv"
)

type Args struct {
	A, B int
	op   string
}

type Arith int

func (t *Arith) Add(args *Args, reply *int) error {

	result := args.A + args.B
	*reply = result
	client, err := rpc.DialHTTP("tcp", "localhost:9990")
	if err != nil {
		log.Fatal("dialing:", err)
	}

	packet := map[string]string{
		"x":      strconv.Itoa(args.A),
		"y":      strconv.Itoa(args.B),
		"op":     args.op,
		"result": strconv.Itoa(result),
	}

	var reply1 int
	err = client.Call("Arith.Checker", packet, &reply1)
	if err != nil {
		log.Fatal("arith error:", err)
	}
	return nil
}

func main() {

	arith := new(Arith)
	rpc.Register(arith)
	rpc.HandleHTTP()

	err := http.ListenAndServe("localhost:9997", nil /*ss*/)
	if err != nil {
		log.Fatal(err)
	}
}
