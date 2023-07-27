package internalsdk

import (
	"context"
	"strconv"

	"github.com/getlantern/flashlight/v7/issue"
)

func SendIssueReport(
	session Session,
	issueType string,
	description string,
	subscriptionLevel string,
	userEmail string,
	device string,
	model string,
	osVersion string,
) error {
	issueTypeInt, err := strconv.Atoi(issueType)
	if err != nil {
		return err
	}
	ctx := context.Background()
	return issue.SendReport(
		ctx,
		newUserConfig(&panickingSessionImpl{session}),
		issueTypeInt,
		description,
		subscriptionLevel,
		userEmail,
		ApplicationVersion,
		device,
		model,
		osVersion,
		nil,
	)
}
