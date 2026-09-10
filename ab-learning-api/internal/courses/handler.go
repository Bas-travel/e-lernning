package courses

import (
	"net/http"
	"strings"

	"github.com/ablearning/api/pkg/httpx"
)

type Course struct {
	ID    string `json:"id"`
	Title string `json:"title"`
}

func RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("/api/v1/courses", listCourses)
	mux.HandleFunc("/api/v1/courses/", courseByID)
}

func listCourses(w http.ResponseWriter, r *http.Request) {
	courses := []Course{{ID: "c001", Title: "Go Backend Professional"}, {ID: "c002", Title: "Flutter Professional"}}
	httpx.JSON(w, http.StatusOK, courses)
}

func courseByID(w http.ResponseWriter, r *http.Request) {
	id := strings.TrimPrefix(r.URL.Path, "/api/v1/courses/")
	if id == "" {
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "missing id"})
		return
	}
	c := Course{ID: id, Title: "Course " + id}
	httpx.JSON(w, http.StatusOK, c)
}
