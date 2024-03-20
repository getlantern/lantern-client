package pro

import (
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

type PaymentMethodsResponse struct {
	*protos.BaseResponse `json:",inline"`
	Providers            []protos.PaymentProviders `json:"providers"`
}

type PaymentRedirectResponse struct {
	*protos.BaseResponse `json:",inline"`
	Redirect             string `json:"redirect"`
}

type PlansResponse struct {
	*protos.BaseResponse `json:",inline"`
	Plans                []protos.Plan `json:"plans"`
}

type UserDataResponse struct {
	*protos.BaseResponse `json:",inline"`
	User                 *protos.User `json:"user"`
}

type LinkCodeResponse struct {
	*protos.BaseResponse `json:",inline"`
	Code                 string
	ExpireAt             int64
}
