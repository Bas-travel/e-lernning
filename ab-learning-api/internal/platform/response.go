package platform

import (
	"encoding/json"
	"log"
	"net/http"
)

// AppError mirrors the `Error` schema in `05-openapi.yaml`:
//
//	Error:
//	  properties:
//	    code: { type: string }
//	    message: { type: string }
//
// Every handler should return *AppError (via WriteError) rather than a raw
// error, so the client only ever sees this one JSON shape.
type AppError struct {
	Status  int    `json:"-"`
	Code    string `json:"code"`
	Message string `json:"message"`
}

func (e *AppError) Error() string { return e.Message }

func NewAppError(status int, code, message string) *AppError {
	return &AppError{Status: status, Code: code, Message: message}
}

// Common, reusable errors — keeps handlers from re-typing status/code pairs.
var (
	ErrValidation   = func(msg string) *AppError { return NewAppError(http.StatusBadRequest, "VALIDATION_ERROR", msg) }
	ErrUnauthorized = NewAppError(http.StatusUnauthorized, "UNAUTHORIZED", "Your session has expired. Please log in again.")
	ErrInvalidCreds = NewAppError(http.StatusUnauthorized, "INVALID_CREDENTIALS", "Email/phone or password is incorrect.")
	ErrNotFound     = func(msg string) *AppError { return NewAppError(http.StatusNotFound, "NOT_FOUND", msg) }
	ErrConflict     = func(msg string) *AppError { return NewAppError(http.StatusConflict, "CONFLICT", msg) }
	ErrInternal     = NewAppError(http.StatusInternalServerError, "INTERNAL_ERROR", "Something went wrong. Please try again.")
)

// WriteJSON writes any payload as JSON with the given status code.
func WriteJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	if payload == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Printf("write json: %v", err)
	}
}

// WriteError writes an *AppError (or wraps any other error as a generic
// 500) as JSON, and logs unexpected (500-class) errors server-side.
func WriteError(w http.ResponseWriter, err error) {
	if appErr, ok := err.(*AppError); ok {
		WriteJSON(w, appErr.Status, appErr)
		return
	}
	log.Printf("unhandled error: %v", err)
	WriteJSON(w, ErrInternal.Status, ErrInternal)
}

// DecodeJSON decodes the request body into dst, returning a VALIDATION_ERROR
// AppError on malformed JSON so handlers don't each repeat this check.
func DecodeJSON(r *http.Request, dst any) error {
	defer r.Body.Close()
	dec := json.NewDecoder(r.Body)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		return ErrValidation("Request body is malformed: " + err.Error())
	}
	return nil
}
