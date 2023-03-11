package main

import (
	"fmt"
	"math/rand"
	"time"
)

func sum(nums []int) int {
	sum := 0
	for _, v := range nums {
		sum += v
	}
	return sum
}

func main() {
	fmt.Print("work?")
	nums := []int{}
	size := 10000

	for i := 0; i < size; i++ {
		nums = append(nums, rand.Intn(10))
	}

	start := time.Now()

	fmt.Println("Sum = ", sum(nums))

	elapsed := time.Since(start)
	fmt.Println("Runtime = ", elapsed)
}
