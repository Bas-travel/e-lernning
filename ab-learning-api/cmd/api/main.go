// package main

// import (
// 	"log"
// 	"net/http"

// 	"github.com/ablearning/api/internal/auth"
// 	"github.com/ablearning/api/internal/certificate"
// 	"github.com/ablearning/api/internal/courses"
// 	"github.com/ablearning/api/internal/future"
// 	"github.com/ablearning/api/internal/learning"
// 	"github.com/ablearning/api/internal/quiz"
// )

// func main() {
// 	mux := http.NewServeMux()

// 	// Health
// 	mux.HandleFunc("/api/v1/health", func(w http.ResponseWriter, r *http.Request) {
// 		w.Write([]byte("ok"))
// 	})

// 	// Register domain routes
// 	auth.RegisterRoutes(mux)
// 	courses.RegisterRoutes(mux)
// 	learning.RegisterRoutes(mux)
// 	quiz.RegisterRoutes(mux)
// 	certificate.RegisterRoutes(mux)
// 	future.RegisterRoutes(mux)

// 	addr := ":8080"
// 	log.Printf("Starting AB LEARNING API on %s\n", addr)
// 	log.Fatal(http.ListenAndServe(addr, mux))
// }

package main

import (
	"log"
	"net/http"

	"github.com/ablearning/api/internal/auth"
	"github.com/ablearning/api/internal/certificate"
	"github.com/ablearning/api/internal/courses"
	"github.com/ablearning/api/internal/future"
	"github.com/ablearning/api/internal/learning"
	"github.com/ablearning/api/internal/quiz"
)

func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	mux := http.NewServeMux()

	// Health
	mux.HandleFunc("/api/v1/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})

	// Register domain routes
	auth.RegisterRoutes(mux)
	courses.RegisterRoutes(mux)
	learning.RegisterRoutes(mux)
	quiz.RegisterRoutes(mux)
	certificate.RegisterRoutes(mux)
	future.RegisterRoutes(mux)

	addr := ":8080"
	log.Printf("Starting AB LEARNING API on %s\n", addr)
	log.Fatal(http.ListenAndServe(addr, enableCORS(mux)))
}
