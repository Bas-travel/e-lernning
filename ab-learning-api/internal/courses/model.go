package courses

type Lesson struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	Duration string `json:"duration"`
}

type Course struct {
	ID               string  `json:"id"`
	Title            string  `json:"title"`
	Category         string  `json:"category"`
	Level            string  `json:"level"`
	Instructor       string  `json:"instructor"`
	Duration         string  `json:"duration"`
	Price            float64 `json:"price"`
	Rating           float64 `json:"rating"`
	ShortDescription string  `json:"shortDescription"`
	Description      string  `json:"description"`
	Lessons          []Lesson `json:"lessons,omitempty"`
}
