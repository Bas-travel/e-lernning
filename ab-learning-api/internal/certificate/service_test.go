package certificate

import "testing"

func TestIssueCertificateCreatesRecord(t *testing.T) {
	service := NewService(NewRepository())

	cert, err := service.Issue("c001", "Go Backend Professional")
	if err != nil {
		t.Fatal(err)
	}
	if cert.CourseName == "" {
		t.Fatal("expected certificate course name")
	}
}

func TestGetMissingCertificateFails(t *testing.T) {
	service := NewService(NewRepository())

	_, err := service.Get("missing")
	if err == nil {
		t.Fatal("expected missing certificate error")
	}
}
