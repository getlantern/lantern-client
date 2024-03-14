package internalsdk

type LanternService struct {
	sessionModel *SessionModel
}

func NewService(sessionModel *SessionModel) *LanternService {
	return &LanternService{
		sessionModel,
	}
}
