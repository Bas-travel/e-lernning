package home

// These shapes intentionally match `HomeFeed.fromJson` in the Flutter app
// (lib/features/home/models/home_feed.dart) field-for-field, since that's
// the contract already implemented and tested on the client. This is a
// case where the real backend and a hand-written mock converged on the
// same shape by construction — flip the Flutter app's apiClientProvider
// to DioApiClient and this endpoint is a drop-in replacement for
// MockApiClient.getHome() with zero client-side changes.
//
// (05-openapi.yaml's placeholder `/home` schema predates this and is
// coarser — regenerate it from this struct set when the API stabilizes.)

type CourseSummary struct {
	ID                int64    `json:"id"`
	Title             string   `json:"title"`
	InstructorName    string   `json:"instructor_name"`
	Price             *float64 `json:"price,omitempty"`
	DiscountPrice     *float64 `json:"discount_price,omitempty"`
	RatingAvg         *float64 `json:"rating_avg,omitempty"`
	ProgressPct       *float64 `json:"progress_pct,omitempty"`
	ThumbnailGradient string   `json:"thumbnail_gradient"` // "primary" | "accent" | "secondary"
}

type LiveSummary struct {
	ID             int64  `json:"id"`
	Title          string `json:"title"`
	InstructorName string `json:"instructor_name"`
	ScheduledAt    string `json:"scheduled_at"` // RFC3339
	Status         string `json:"status"`       // upcoming | live | ended | cancelled
}

type Feed struct {
	GreetingName          string          `json:"greeting_name"`
	ContinueLearning      []CourseSummary `json:"continue_learning"`
	Recommended           []CourseSummary `json:"recommended"`
	Live                  []LiveSummary   `json:"live"`
	CareerPathProgressPct float64         `json:"career_path_progress_pct"`
}
