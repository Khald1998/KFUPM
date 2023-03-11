package main

import (
	// "bytes"
	// "encoding/json"
	// "fmt"
	// "io/ioutil"
	"fmt"
	"log"
	"net/http"
	"net/rpc"
)

type Args struct {
	A, B, op, result string
}

type Arith int

func (t *Arith) Checker(args *Args, reply *int) error {
	fmt.Printf("hi %s", args.op)
	*reply = 8
	return nil
}

func main() {

	arith := new(Arith)
	rpc.Register(arith)
	rpc.HandleHTTP()

	err := http.ListenAndServe("localhost:9990", nil)

	if err != nil {
		log.Fatal(err)
	}
}
