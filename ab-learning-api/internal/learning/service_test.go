package learning

import "testing"

func TestEnrollCreatesProgressRecord(t *testing.T) {
	service := NewService(NewRepository())

	enrollment, err := service.Enroll("c001")
	if err != nil {
		t.Fatal(err)
	}

	if enrollment.CourseID != "c001" {
		t.Fatal("expected linked course id")
	}

	if enrollment.Progress != 0 {
		t.Fatal("new enrollment should start at zero progress")
	}
}

func TestUpdateProgressRejectsOutOfRangeValue(t *testing.T) {
	service := NewService(NewRepository())

	_, err := service.UpdateProgress("c001", 150)
	if err == nil {
		t.Fatal("expected validation error")
	}
}

func TestGetMyCoursesIncludesEnrollmentData(t *testing.T) {
	service := NewService(NewRepository())
	_, _ = service.Enroll("c002")

	courses := service.GetMyCourses()
	if len(courses) == 0 {
		t.Fatal("expected enrolled courses")
	}
}
