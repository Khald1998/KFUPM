package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

// Model the service with an interface
// Capital 'S' in the identifier means the interface is public
type Cache interface {
	PostCache(x int, y int, op string)
	GetCache(x int, y int, op string) (data int)
	PutCache(x int, y int, op string)
	DeleteCache(x int, y int, op string)
}

// Define the in-memory (runtime) data store (cache)
// Lower-case letter 's' means the struct is private
type cache struct {
	allData map[key]string
}

type key struct {
	x, y, op string
	
}

func (ss *cache) PostCache(x string, y string, op string, result string) {
	//Perform addition and store data in the cache
	switch op {
	case "add":
		ss.allData[key{x, y, op}] = result
	case "sub":
		ss.allData[key{x, y, op}] = result
	case "div":
		ss.allData[key{x, y, op}] = result

	case "mul":
		ss.allData[key{x, y, op}] = result
	}
}

func (ss *cache) GetCache(x string, y string, op string) (data string) {
	//Check if the data already exists in the cache
	//If data exists, it is returned
	//If data does not exists, return an error (nil)
	data, exists := ss.allData[key{x, y, op}]
	if !exists {
		return "nil" 
	}
	return
}

func (ss *cache) DeleteCache(x string, y string, op string) {
	delete(ss.allData, key{x, y, op})
}

// Make the service available on the network (i.e., callable by other services)
// Function name must be 'ServeHTTP'
func (ss *cache) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	


	switch r.Method {
	case "POST":
		var jsonData map[string]string
		reqBody := json.NewDecoder(r.Body).Decode(&jsonData)
		fmt.Println(reqBody)
		x := jsonData["x"]
		y := jsonData["y"]
		op := jsonData["op"]
		result := jsonData["result"]
		
		
		ss.PostCache(x, y, op,result)
		fmt.Fprintf(w, "New data saved!")

		
	case "GET":
		x := r.URL.Query()["x"][0]
		y := r.URL.Query()["y"][0]
		op := r.URL.Query()["op"][0]
		data := ss.GetCache(x, y, op)
		fmt.Fprintf(w, data)
	case "PUT":
	case "DELETE":
		x := r.URL.Query()["x"][0]
		y := r.URL.Query()["y"][0]
		op := r.URL.Query()["op"][0]
		ss.DeleteCache(x, y, op)
		fmt.Fprintf(w, "data deleted!")
	default:
		fmt.Fprintf(w, "Unsupported HTTP method!")
	}
}

func main() {
	//Create the cache
	ss := &cache{
		allData: map[key]string{
			
		},
	}

	http.ListenAndServe("localhost:9991", ss)
}
