/*
Convert integer numbers to float before performing division: float32(num1) / float32(num2)
*/

package main

import "fmt"

func main() {
	var num1, num2 int
	var op string

	// Read the two integer numbers
	fmt.Println("Enter number 1: ")
	fmt.Scanf("%d", &num1)
	fmt.Println("Enter number 2: ")
	fmt.Scanf("%d", &num2)

	// Read operation
	fmt.Println("Enter operation: ")
	fmt.Scanf("%s", &op)

	switch op {
	case "+":
		fmt.Println(num1, op, num2, " = ", num1+num2)
	case "-":
		fmt.Println(num1, op, num2, " = ", num1-num2)
	case "/":
		fmt.Println(num1, op, num2, " = ", float32(num1)/float32(num2))
	case "*":
		fmt.Println(num1, op, num2, " = ", num1*num2)
	default:
		fmt.Println("Undefined operation!")
	}
}
