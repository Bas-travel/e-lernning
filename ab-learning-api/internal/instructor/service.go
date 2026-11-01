package instructor

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
)

var (
	ErrValidation = errors.New("validation failed")
	ErrForbidden  = errors.New("you do not own this course")
	ErrLocked     = errors.New("course cannot be modified in its current status")
)

type Service struct{ repo *Repository }

func NewService(repo *Repository) *Service { return &Service{repo: repo} }

func invalid(msg string) error { return fmt.Errorf("%w: %s", ErrValidation, msg) }

func (s *Service) instructorID(userID int64) (int64, error) { return s.repo.InstructorID(userID) }

func editable(status string) bool { return status == "draft" || status == "rejected" }

// ownedEditable checks the course belongs to the instructor and is editable.
func (s *Service) ownedEditable(instrID int64, m CourseMeta, err error) error {
	if err != nil {
		return err
	}
	if m.InstructorID != instrID {
		return ErrForbidden
	}
	if !editable(m.Status) {
		return fmt.Errorf("%w (status: %s)", ErrLocked, m.Status)
	}
	return nil
}

func slugify(title string) string {
	var b strings.Builder
	dash := false
	for _, r := range strings.ToLower(title) {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') {
			b.WriteRune(r)
			dash = false
		} else if !dash && b.Len() > 0 {
			b.WriteByte('-')
			dash = true
		}
	}
	out := strings.Trim(b.String(), "-")
	if out == "" {
		out = "course"
	}
	if len(out) > 60 {
		out = strings.Trim(out[:60], "-")
	}
	buf := make([]byte, 3)
	_, _ = rand.Read(buf)
	return out + "-" + hex.EncodeToString(buf)
}

func validateCourse(in *CourseInput) error {
	in.Title = strings.TrimSpace(in.Title)
	in.Description = strings.TrimSpace(in.Description)
	if l := len([]rune(in.Title)); l < 3 || l > 200 {
		return invalid("title must be 3-200 characters")
	}
	if in.CategoryID <= 0 {
		return invalid("category_id is required")
	}
	if in.Level == "" {
		in.Level = "beginner"
	}
	if in.Level != "beginner" && in.Level != "intermediate" && in.Level != "advanced" {
		return invalid("level must be beginner, intermediate or advanced")
	}
	if in.Language == "" {
		in.Language = "th"
	}
	if in.Price < 0 || in.Price > 1_000_000 {
		return invalid("price must be between 0 and 1,000,000")
	}
	if in.DiscountPrice != nil && (*in.DiscountPrice < 0 || *in.DiscountPrice > in.Price) {
		return invalid("discount_price must be between 0 and price")
	}
	if err := validateMediaURL(in.ThumbnailURL); err != nil {
		return err
	}
	return nil
}

func validateMediaURL(u string) error {
	if u == "" || strings.HasPrefix(u, "/uploads/") || strings.HasPrefix(u, "https://") || strings.HasPrefix(u, "http://") {
		return nil
	}
	return invalid("media URL must be an uploaded file (/uploads/...) or an http(s) URL")
}

func (s *Service) Dashboard(userID int64) (Dashboard, error) {
	id, err := s.instructorID(userID)
	if err != nil {
		return Dashboard{}, err
	}
	return s.repo.Dashboard(id)
}

func (s *Service) Revenue(userID int64) (Revenue, error) {
	id, err := s.instructorID(userID)
	if err != nil {
		return Revenue{}, err
	}
	return s.repo.Revenue(id)
}

func (s *Service) ListCourses(userID int64, status string) ([]Course, error) {
	id, err := s.instructorID(userID)
	if err != nil {
		return nil, err
	}
	return s.repo.ListCourses(id, status)
}

func (s *Service) GetCourse(userID, courseID int64) (Course, error) {
	id, err := s.instructorID(userID)
	if err != nil {
		return Course{}, err
	}
	return s.repo.GetCourse(id, courseID)
}

func (s *Service) CreateCourse(userID int64, in CourseInput) (Course, error) {
	if err := validateCourse(&in); err != nil {
		return Course{}, err
	}
	id, err := s.instructorID(userID)
	if err != nil {
		return Course{}, err
	}
	cid, err := s.repo.CreateCourse(id, in, slugify(in.Title))
	if errors.Is(err, ErrBadRef) {
		return Course{}, invalid("category_id does not exist")
	}
	if err != nil {
		return Course{}, err
	}
	return s.repo.GetCourse(id, cid)
}

func (s *Service) UpdateCourse(userID, courseID int64, in CourseInput) (Course, error) {
	if err := validateCourse(&in); err != nil {
		return Course{}, err
	}
	id, err := s.instructorID(userID)
	if err != nil {
		return Course{}, err
	}
	m, err := s.repo.CourseMeta(courseID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return Course{}, err
	}
	if err := s.repo.UpdateCourse(courseID, in); err != nil {
		if errors.Is(err, ErrBadRef) {
			return Course{}, invalid("category_id does not exist")
		}
		return Course{}, err
	}
	return s.repo.GetCourse(id, courseID)
}

func (s *Service) DeleteCourse(userID, courseID int64) error {
	id, err := s.instructorID(userID)
	if err != nil {
		return err
	}
	m, err := s.repo.CourseMeta(courseID)
	if err != nil {
		return err
	}
	if m.InstructorID != id {
		return ErrForbidden
	}
	if m.Status != "draft" {
		return fmt.Errorf("%w: only draft courses can be deleted (status: %s)", ErrLocked, m.Status)
	}
	return s.repo.DeleteCourse(courseID)
}

// Submit moves a draft/rejected course to pending_review after readiness checks.
func (s *Service) Submit(userID, courseID int64) (Course, error) {
	id, err := s.instructorID(userID)
	if err != nil {
		return Course{}, err
	}
	m, err := s.repo.CourseMeta(courseID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return Course{}, err
	}
	c, err := s.repo.GetCourse(id, courseID)
	if err != nil {
		return Course{}, err
	}
	if strings.TrimSpace(c.Description) == "" {
		return Course{}, invalid("add a course description before submitting")
	}
	lessons, missing, err := s.repo.SubmitReadiness(courseID)
	if err != nil {
		return Course{}, err
	}
	if lessons == 0 {
		return Course{}, invalid("add at least one lesson before submitting")
	}
	if missing > 0 {
		return Course{}, invalid(fmt.Sprintf("%d video lesson(s) have no uploaded video", missing))
	}
	if err := s.repo.SetStatus(courseID, "pending_review"); err != nil {
		return Course{}, err
	}
	return s.repo.GetCourse(id, courseID)
}

func (s *Service) CreateSection(userID int64, in SectionInput) (Section, error) {
	in.Title = strings.TrimSpace(in.Title)
	if in.Title == "" || len([]rune(in.Title)) > 200 {
		return Section{}, invalid("title is required (max 200 characters)")
	}
	id, err := s.instructorID(userID)
	if err != nil {
		return Section{}, err
	}
	m, err := s.repo.CourseMeta(in.CourseID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return Section{}, err
	}
	return s.repo.CreateSection(in)
}

func (s *Service) UpdateSection(userID, sectionID int64, in SectionInput) error {
	in.Title = strings.TrimSpace(in.Title)
	if in.Title == "" || len([]rune(in.Title)) > 200 {
		return invalid("title is required (max 200 characters)")
	}
	id, err := s.instructorID(userID)
	if err != nil {
		return err
	}
	m, err := s.repo.CourseMetaBySection(sectionID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return err
	}
	return s.repo.UpdateSection(sectionID, in)
}

func (s *Service) DeleteSection(userID, sectionID int64) error {
	id, err := s.instructorID(userID)
	if err != nil {
		return err
	}
	m, err := s.repo.CourseMetaBySection(sectionID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return err
	}
	if err := s.repo.DeleteSection(sectionID); err != nil {
		return err
	}
	s.repo.RecomputeDuration(m.ID)
	return nil
}

func validateLesson(in *LessonInput) error {
	in.Title = strings.TrimSpace(in.Title)
	if in.Title == "" || len([]rune(in.Title)) > 200 {
		return invalid("title is required (max 200 characters)")
	}
	if in.Type == "" {
		in.Type = "video"
	}
	switch in.Type {
	case "video", "article", "quiz", "project":
	default:
		return invalid("type must be video, article, quiz or project")
	}
	if in.DurationSeconds < 0 || in.DurationSeconds > 24*3600 {
		return invalid("duration_seconds out of range")
	}
	return validateMediaURL(in.VideoURL)
}

func (s *Service) CreateLesson(userID int64, in LessonInput) (Lesson, error) {
	if err := validateLesson(&in); err != nil {
		return Lesson{}, err
	}
	id, err := s.instructorID(userID)
	if err != nil {
		return Lesson{}, err
	}
	m, err := s.repo.CourseMetaBySection(in.SectionID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return Lesson{}, err
	}
	l, err := s.repo.CreateLesson(in)
	if err == nil {
		s.repo.RecomputeDuration(m.ID)
	}
	return l, err
}

func (s *Service) UpdateLesson(userID, lessonID int64, in LessonInput) error {
	if err := validateLesson(&in); err != nil {
		return err
	}
	id, err := s.instructorID(userID)
	if err != nil {
		return err
	}
	m, err := s.repo.CourseMetaByLesson(lessonID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return err
	}
	if err := s.repo.UpdateLesson(lessonID, in); err != nil {
		return err
	}
	s.repo.RecomputeDuration(m.ID)
	return nil
}

func (s *Service) DeleteLesson(userID, lessonID int64) error {
	id, err := s.instructorID(userID)
	if err != nil {
		return err
	}
	m, err := s.repo.CourseMetaByLesson(lessonID)
	if err := s.ownedEditable(id, m, err); err != nil {
		return err
	}
	if err := s.repo.DeleteLesson(lessonID); err != nil {
		return err
	}
	s.repo.RecomputeDuration(m.ID)
	return nil
}
