package internalsdk

import (
	"strconv"

	"github.com/getlantern/flashlight/v7/issue"
	"github.com/getlantern/lantern-client/internalsdk/common"
)

var issueMap = map[string]string{
	"Cannot access blocked sites": "3",
	"Cannot complete purchase":    "0",
	"Cannot sign in":              "1",
	"Spinner loads endlessly":     "2",
	"Slow":                        "4",
	"Chat not working":            "7",
	"Discover not working":        "8",
	"Cannot link device":          "5",
	"Application crashes":         "6",
	"Other":                       "9",
}

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
	return issue.SendReport(
		NewUserConfig(&panickingSessionImpl{session}),
		issueTypeInt,
		description,
		subscriptionLevel,
		userEmail,
		common.ApplicationVersion,
		device,
		model,
		osVersion,
		nil,
	)
}
