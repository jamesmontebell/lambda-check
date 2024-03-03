package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize Gin
	r := gin.Default()

	// Define your routes
	r.GET("/search", func(c *gin.Context) {
		message := "none"
		term := c.DefaultQuery("term", "")
		if term == "xmonad-contrib" || term == "happstack-server-tls" || term == "vscode-ghc-simple" {
			message = "vulnerability found"
		}
		c.JSON(http.StatusOK, message)
	})

	// Run the server
	r.Run(":8080")
}
