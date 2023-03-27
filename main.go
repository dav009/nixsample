package main

import (
	"fmt"

	"github.com/fatih/color"
)

func main() {
	someVar := "othervar"
	color.Cyan(fmt.Sprintf("Yay! Hello world in blue, %s", someVar))

}
