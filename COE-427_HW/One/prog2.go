package main

import "fmt"

func main() {
	var a = [4][4]int{
		{1, 1, 1, 1},
		{1, 1, 1, 1},
		{1, 1, 1, 1},
		{1, 1, 1, 1},
	}

	var b = [4][4]int{
		{1, 1, 1, 1},
		{1, 1, 1, 1},
		{1, 1, 1, 1},
		{1, 1, 1, 1},
	}

	var res [4][4]int

	for row := 0; row < 4; row++ {
		for col := 0; col < 4; col++ {
			for k := 0; k < 4; k++ {
				res[row][col] = res[row][col] + a[row][k]*b[k][col]
			}
		}
	}

	fmt.Println(res)
}
