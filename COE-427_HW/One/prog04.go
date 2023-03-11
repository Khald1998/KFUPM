package main

import (
	"fmt"
	"math/rand"
	"time"
)

func sum(nums []int, c chan int) {
	sum := 0
	for _, v := range nums {
		sum += v
	}
	c <- sum
}

func main() {
	nums := []int{}
	size := 1_000_000_000_000

	for i := 0; i < size; i++ {
		nums = append(nums, rand.Intn(1000))
	}

	c := make(chan int)
	numParts := 1000
	partSize := size / numParts

	for i := 0; i < numParts; i++ {
		go sum(nums[i*partSize:(i+1)*partSize], c)
	}

	start := time.Now()

	sum := 0
	for i := 0; i < numParts; i++ {
		sum += <-c
	}

	fmt.Println("Sum = ", sum)

	elapsed := time.Since(start)
	fmt.Println("Runtime = ", elapsed)
}
