// Package corporate implements screens 36-38: the corporate dashboard,
// employee management and learning paths, scoped to the caller's organization.
package corporate

import "time"

type KPI struct {
	Label string `json:"label"`
	Value string `json:"value"`
}

type DeptPerformance struct {
	Department  string  `json:"department"`
	Employees   int     `json:"employees"`
	AvgProgress float64 `json:"avg_progress"` // 0..100
}

type Dashboard struct {
	Organization string            `json:"organization"`
	KPIs         []KPI             `json:"kpis"`
	Departments  []DeptPerformance `json:"departments"`
}

type Employee struct {
	ID              int64   `json:"id"` // organization_users.id
	UserID          int64   `json:"user_id"`
	Name            string  `json:"name"`
	Email           string  `json:"email"`
	Department      string  `json:"department"`
	RoleInOrg       string  `json:"role_in_org"`
	Status          string  `json:"status"`
	CoursesEnrolled int     `json:"courses_enrolled"`
	AvgProgress     float64 `json:"avg_progress"`
}

type EmployeeFilter struct {
	Query, Department, Status string
	Limit, Offset             int
}

type AddEmployeeInput struct {
	Email      string `json:"email"`
	Department string `json:"department"`
	RoleInOrg  string `json:"role_in_org"`
}

type UpdateEmployeeInput struct {
	Department *string `json:"department"`
	Status     *string `json:"status"`
}

type PathCourse struct {
	ID    int64  `json:"id"`
	Title string `json:"title"`
}

type LearningPath struct {
	ID        int64        `json:"id"`
	Name      string       `json:"name"`
	Goal      string       `json:"goal"`
	Deadline  *string      `json:"deadline"`
	Courses   []PathCourse `json:"courses"`
	CreatedAt time.Time    `json:"created_at"`
}

type CreatePathInput struct {
	Name      string  `json:"name"`
	Goal      string  `json:"goal"`
	Deadline  *string `json:"deadline"` // YYYY-MM-DD
	CourseIDs []int64 `json:"course_ids"`
}
