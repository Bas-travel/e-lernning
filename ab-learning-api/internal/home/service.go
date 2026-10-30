package home

import "context"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

// GetFeed implements GET /api/v1/home (screen 08). Runs four independent
// reads — kept sequential for clarity in this scaffold; worth
// parallelizing with errgroup once the query count grows.
func (s *Service) GetFeed(ctx context.Context, userID int64) (Feed, error) {
	greeting, err := s.repo.GreetingName(ctx, userID)
	if err != nil {
		return Feed{}, err
	}

	continueLearning, err := s.repo.ContinueLearning(ctx, userID, 5)
	if err != nil {
		return Feed{}, err
	}

	recommended, err := s.repo.Recommended(ctx, userID, 6)
	if err != nil {
		return Feed{}, err
	}

	live, err := s.repo.UpcomingLive(ctx, 3)
	if err != nil {
		return Feed{}, err
	}

	careerProgress, err := s.repo.CareerPathProgress(ctx, userID)
	if err != nil {
		return Feed{}, err
	}

	// Ensure the JSON arrays are `[]`, not `null`, when empty — matches
	// what the Flutter client's List.map(...) expects without needing a
	// null check on its side.
	if continueLearning == nil {
		continueLearning = []CourseSummary{}
	}
	if recommended == nil {
		recommended = []CourseSummary{}
	}
	if live == nil {
		live = []LiveSummary{}
	}

	return Feed{
		GreetingName:          greeting,
		ContinueLearning:      continueLearning,
		Recommended:           recommended,
		Live:                  live,
		CareerPathProgressPct: careerProgress,
	}, nil
}
