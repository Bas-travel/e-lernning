package future

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/ablearning/api/pkg/httpx"
)

func RegisterRoutes(mux *http.ServeMux) {
	paths := []CareerPath{{ID: "backend", Title: "Senior Backend Developer", Progress: 78, RequiredSkills: []string{"Go", "REST API", "SQL", "Docker", "Kubernetes"}, RecommendedCourseIDs: []string{"c001", "c008", "c012"}}}
	portfolio := Portfolio{UserID: "user-demo", Headline: "Backend developer building dependable services", Skills: []string{"Go", "SQL", "Docker"}, Projects: []PortfolioProject{{Title: "Learning API", Description: "REST API for course progress", URL: "https://example.com"}}}
	jobs := []Job{{ID: "j001", Title: "Backend Developer", Company: "ABC Technology", Location: "Remote", Salary: "฿45,000–65,000", Skills: []string{"Go", "PostgreSQL", "Docker"}, MatchScore: 92}, {ID: "j002", Title: "Platform Engineer", Company: "XYZ Finance", Location: "Bangkok / Hybrid", Salary: "฿55,000–80,000", Skills: []string{"Go", "Kubernetes", "AWS"}, MatchScore: 76}}

	mux.HandleFunc("/api/v1/ai/tutor", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			methodNotAllowed(w)
			return
		}
		var request TutorRequest
		if json.NewDecoder(r.Body).Decode(&request) != nil || strings.TrimSpace(request.Message) == "" {
			badRequest(w, "message is required")
			return
		}
		httpx.JSON(w, http.StatusOK, TutorResponse{Answer: "REST API คือรูปแบบการสื่อสารระหว่างแอปผ่าน HTTP โดยใช้ resource และ method เช่น GET, POST, PUT, DELETE. เริ่มจากออกแบบ resource ให้ชัดเจน แล้วกำหนด response ที่สม่ำเสมอ.", Suggestions: []string{"ขอตัวอย่าง Go", "Quiz me", "อธิบายแบบง่ายขึ้น"}})
	})
	mux.HandleFunc("/api/v1/skills/assessment", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			httpx.JSON(w, http.StatusOK, map[string]interface{}{"questions": []map[string]interface{}{{"id": "s1", "skill": "Backend", "text": "How comfortable are you designing a REST API?", "options": []string{"Beginner", "Intermediate", "Advanced"}}}})
			return
		}
		if r.Method == http.MethodPost {
			httpx.JSON(w, http.StatusOK, SkillResult{Overall: 72, Skills: map[string]int{"Backend": 80, "Database": 65, "Cloud": 48, "Testing": 55}, RecommendedCourseIDs: []string{"c012", "c008"}})
			return
		}
		methodNotAllowed(w)
	})
	mux.HandleFunc("/api/v1/skills/result", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, SkillResult{Overall: 72, Skills: map[string]int{"Backend": 80, "Database": 65, "Cloud": 48, "Testing": 55}, RecommendedCourseIDs: []string{"c012", "c008"}})
	})
	mux.HandleFunc("/api/v1/career-paths/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		id := strings.Trim(strings.TrimPrefix(r.URL.Path, "/api/v1/career-paths/"), "/")
		for _, path := range paths {
			if path.ID == id {
				httpx.JSON(w, http.StatusOK, path)
				return
			}
		}
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "career path not found"})
	})
	mux.HandleFunc("/api/v1/portfolio", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			httpx.JSON(w, http.StatusOK, portfolio)
			return
		}
		if r.Method == http.MethodPut {
			var update Portfolio
			if json.NewDecoder(r.Body).Decode(&update) != nil {
				badRequest(w, "invalid portfolio")
				return
			}
			update.UserID = "user-demo"
			portfolio = update
			httpx.JSON(w, http.StatusOK, portfolio)
			return
		}
		methodNotAllowed(w)
	})
	mux.HandleFunc("/api/v1/jobs", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, jobs)
	})
	mux.HandleFunc("/api/v1/jobs/", func(w http.ResponseWriter, r *http.Request) {
		suffix := strings.Trim(strings.TrimPrefix(r.URL.Path, "/api/v1/jobs/"), "/")
		parts := strings.Split(suffix, "/")
		for _, job := range jobs {
			if job.ID != parts[0] {
				continue
			}
			if len(parts) == 1 && r.Method == http.MethodGet {
				httpx.JSON(w, http.StatusOK, job)
				return
			}
			if len(parts) == 2 && parts[1] == "apply" && r.Method == http.MethodPost {
				httpx.JSON(w, http.StatusCreated, Application{JobID: job.ID, Status: "submitted"})
				return
			}
		}
		httpx.JSON(w, http.StatusNotFound, map[string]string{"error": "job not found"})
	})
	registerCorporateAndAdmin(mux)
}

func registerCorporateAndAdmin(mux *http.ServeMux) {
	mux.HandleFunc("/api/v1/corporate/dashboard", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, map[string]interface{}{"employees": 500, "activeLearners": 312, "completionRate": 74, "trainingHours": 1840, "trainingBudget": 450000})
	})
	mux.HandleFunc("/api/v1/corporate/employees", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, []map[string]interface{}{{"id": "e001", "name": "Anan", "department": "Engineering", "progress": 68, "status": "active"}, {"id": "e002", "name": "Siriporn", "department": "Product", "progress": 91, "status": "active"}})
	})
	mux.HandleFunc("/api/v1/corporate/learning-paths", func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodGet {
			httpx.JSON(w, http.StatusOK, []map[string]interface{}{{"id": "lp001", "name": "Backend Onboarding", "courses": 3, "assignedEmployees": 42}})
			return
		}
		if r.Method == http.MethodPost {
			httpx.JSON(w, http.StatusCreated, map[string]string{"id": "lp002", "status": "created"})
			return
		}
		methodNotAllowed(w)
	})
	mux.HandleFunc("/api/v1/admin/dashboard", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, map[string]interface{}{"users": 24580, "publishedCourses": 186, "pendingCourses": 4, "monthlyRevenue": 1284000})
	})
	mux.HandleFunc("/api/v1/admin/users", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, []map[string]string{{"id": "u001", "name": "Anan", "role": "LEARNER", "status": "active"}, {"id": "u002", "name": "Dr. Krit", "role": "INSTRUCTOR", "status": "active"}})
	})
	mux.HandleFunc("/api/v1/admin/courses/pending", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, []map[string]string{{"id": "c101", "title": "Advanced Go", "instructor": "Dr. Krit", "status": "pending_review"}})
	})
	mux.HandleFunc("/api/v1/admin/payments", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, []map[string]string{{"id": "ord001", "amount": "2990", "status": "paid"}})
	})
	mux.HandleFunc("/api/v1/admin/audit-logs", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			methodNotAllowed(w)
			return
		}
		httpx.JSON(w, http.StatusOK, []map[string]string{{"action": "course.approved", "actor": "admin@ablearning.com", "createdAt": "2026-09-07T10:00:00Z"}})
	})
}

func badRequest(w http.ResponseWriter, message string) {
	httpx.JSON(w, http.StatusBadRequest, map[string]string{"error": message})
}
func methodNotAllowed(w http.ResponseWriter) {
	httpx.JSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "method not allowed"})
}
