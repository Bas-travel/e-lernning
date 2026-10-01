package certificate

import (
	"bytes"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/ablearning/api/internal/platform"
	"github.com/go-pdf/fpdf"
)

type HTTPHandler struct {
	repository *SQLRepository
}

func NewHTTPHandler(repository *SQLRepository) *HTTPHandler {
	return &HTTPHandler{repository: repository}
}

func (h *HTTPHandler) RegisterRoutes(mux *http.ServeMux, protected func(http.Handler) http.Handler) {
	mux.Handle("GET /api/v1/certificates", protected(http.HandlerFunc(h.list)))
	mux.Handle("GET /api/v1/certificates/{id}/download", protected(http.HandlerFunc(h.download)))
}

func (h *HTTPHandler) list(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	records, err := h.repository.ListForUser(r.Context(), userID)
	if err != nil {
		platform.WriteError(w, err)
		return
	}
	platform.WriteJSON(w, http.StatusOK, records)
}

func (h *HTTPHandler) download(w http.ResponseWriter, r *http.Request) {
	userID, ok := platform.UserIDFromContext(r.Context())
	if !ok {
		platform.WriteError(w, platform.ErrUnauthorized)
		return
	}
	certificateID, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil || certificateID <= 0 {
		platform.WriteError(w, platform.ErrValidation("Certificate ID must be a positive integer."))
		return
	}
	record, err := h.repository.GetForUser(r.Context(), userID, certificateID)
	if errors.Is(err, sql.ErrNoRows) {
		platform.WriteError(w, platform.ErrNotFound("Certificate could not be found."))
		return
	}
	if err != nil {
		platform.WriteError(w, err)
		return
	}

	document := fpdf.New("L", "mm", "A4", "")
	document.SetTitle("AB LEARNING Certificate", false)
	document.AddPage()
	document.SetDrawColor(22, 101, 52)
	document.SetLineWidth(1.5)
	document.Rect(12, 12, 273, 186, "D")
	document.SetTextColor(22, 101, 52)
	document.SetFont("Arial", "B", 24)
	document.CellFormat(0, 20, "CERTIFICATE OF COMPLETION", "", 1, "C", false, 0, "")
	document.Ln(18)
	document.SetTextColor(45, 55, 72)
	document.SetFont("Arial", "", 14)
	document.CellFormat(0, 12, "This certifies successful completion of", "", 1, "C", false, 0, "")
	document.Ln(4)
	document.SetFont("Arial", "B", 22)
	document.MultiCell(0, 12, printableASCII(record.CourseName), "", "C", false)
	document.Ln(10)
	document.SetFont("Arial", "", 12)
	document.CellFormat(0, 10, "Certificate code: "+record.CertificateCode, "", 1, "C", false, 0, "")
	document.CellFormat(0, 10, "Issued: "+record.IssuedAt, "", 1, "C", false, 0, "")
	document.Ln(8)
	document.SetFont("Arial", "B", 12)
	document.CellFormat(0, 10, "AB LEARNING", "", 1, "C", false, 0, "")

	var pdf bytes.Buffer
	if err := document.Output(&pdf); err != nil {
		platform.WriteError(w, fmt.Errorf("render certificate PDF: %w", err))
		return
	}
	w.Header().Set("Content-Type", "application/pdf")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=certificate-%d.pdf", record.ID))
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(pdf.Bytes())
}

func printableASCII(value string) string {
	result := make([]rune, 0, len(value))
	for _, char := range value {
		if char >= 32 && char <= 126 {
			result = append(result, char)
		} else {
			result = append(result, '?')
		}
	}
	return string(result)
}
