package instructor

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

// Uploader stores instructor media on local disk under UploadDir and serves
// it from /uploads/. This is the Phase 3 stand-in: Phase 4 replaces it with
// Mux / Cloudflare Stream (transcoding + adaptive streaming + signed URLs).
type Uploader struct {
	Dir      string
	MaxVideo int64 // bytes
	MaxImage int64 // bytes
}

type mediaKind struct {
	folder  string
	max     int64
	allowed map[string]string // sniffed content-type -> extension
}

func (u Uploader) kind(name string) mediaKind {
	if name == "video" {
		return mediaKind{"videos", u.MaxVideo, map[string]string{"video/mp4": ".mp4", "video/webm": ".webm"}}
	}
	return mediaKind{"images", u.MaxImage, map[string]string{"image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp"}}
}

var errBadType = errors.New("unsupported file type")

func (u Uploader) Save(w http.ResponseWriter, r *http.Request, which string) (UploadResult, int, error) {
	k := u.kind(which)
	r.Body = http.MaxBytesReader(w, r.Body, k.max+(1<<20))
	mr, err := r.MultipartReader()
	if err != nil {
		return UploadResult{}, http.StatusBadRequest, errors.New("expected multipart/form-data with a 'file' field")
	}
	for {
		part, err := mr.NextPart()
		if errors.Is(err, io.EOF) {
			return UploadResult{}, http.StatusBadRequest, errors.New("missing 'file' field")
		}
		if err != nil {
			return UploadResult{}, http.StatusRequestEntityTooLarge, fmt.Errorf("file too large (max %d MB) or malformed body", k.max>>20)
		}
		if part.FormName() != "file" {
			continue
		}
		head := make([]byte, 512)
		n, _ := io.ReadFull(part, head)
		head = head[:n]
		ctype := http.DetectContentType(head)
		if i := strings.Index(ctype, ";"); i >= 0 {
			ctype = ctype[:i]
		}
		ext, ok := k.allowed[ctype]
		if !ok {
			return UploadResult{}, http.StatusUnsupportedMediaType, fmt.Errorf("%w (%s)", errBadType, ctype)
		}
		dir := filepath.Join(u.Dir, k.folder)
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return UploadResult{}, http.StatusInternalServerError, errors.New("storage unavailable")
		}
		rnd := make([]byte, 12)
		_, _ = rand.Read(rnd)
		name := hex.EncodeToString(rnd) + ext
		path := filepath.Join(dir, name)
		f, err := os.Create(path)
		if err != nil {
			return UploadResult{}, http.StatusInternalServerError, errors.New("storage unavailable")
		}
		size, copyErr := io.Copy(f, io.MultiReader(bytes.NewReader(head), io.LimitReader(part, k.max-int64(len(head))+1)))
		_ = f.Close()
		if copyErr != nil || size > k.max {
			_ = os.Remove(path)
			return UploadResult{}, http.StatusRequestEntityTooLarge, fmt.Errorf("file too large (max %d MB)", k.max>>20)
		}
		return UploadResult{
			URL: "/uploads/" + k.folder + "/" + name, SizeBytes: size, ContentType: ctype,
			OriginalName: filepath.Base(part.FileName()),
		}, http.StatusCreated, nil
	}
}

// NoListFS serves files but refuses directory listings.
type NoListFS struct{ FS http.FileSystem }

func (n NoListFS) Open(name string) (http.File, error) {
	f, err := n.FS.Open(name)
	if err != nil {
		return nil, err
	}
	st, err := f.Stat()
	if err != nil || st.IsDir() {
		_ = f.Close()
		return nil, os.ErrNotExist
	}
	return f, nil
}
