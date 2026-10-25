package courses

import "testing"

func TestListReturnsCatalogItems(t *testing.T) {
	service := NewService(NewRepository())

	items := service.List()
	if len(items) == 0 {
		t.Fatal("expected catalog items")
	}

	if items[0].ID == "" || items[0].Title == "" {
		t.Fatal("expected valid course item")
	}
}

func TestGetByIDRequiresValidCourseID(t *testing.T) {
	service := NewService(NewRepository())

	_, err := service.GetByID("")
	if err == nil {
		t.Fatal("expected missing id error")
	}
}
