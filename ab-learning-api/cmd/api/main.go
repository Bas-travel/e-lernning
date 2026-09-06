package main

import (
	"log"
	"net/http"

	"github.com/ablearning/api/internal/auth"
	"github.com/ablearning/api/internal/courses"
)

func main() {
	mux := http.NewServeMux()

	// Health
	mux.HandleFunc("/api/v1/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})

	// Register domain routes
	auth.RegisterRoutes(mux)
	courses.RegisterRoutes(mux)

	addr := ":8080"
	log.Printf("Starting AB LEARNING API on %s\n", addr)
	log.Fatal(http.ListenAndServe(addr, mux))
}
