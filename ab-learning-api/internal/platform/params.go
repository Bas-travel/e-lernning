package platform

import (
	"strconv"
	"strings"
)

// ParseID turns a path parameter into a positive int64. Every domain needs
// this, and every domain needs it to fail the same way — a 400 naming the
// resource, rather than a raw parse error or a 404 that hides a malformed
// request.
func ParseID(raw, resource string) (int64, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return 0, ErrValidation(resource + " id is required")
	}
	id, err := strconv.ParseInt(trimmed, 10, 64)
	if err != nil || id <= 0 {
		return 0, ErrValidation(resource + " id must be a positive number")
	}
	return id, nil
}
