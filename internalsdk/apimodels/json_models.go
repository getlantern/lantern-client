package apimodels

import "math/big"

type UserResponse struct {
	UserID       float64  `json:"userId"`
	Code         string   `json:"code"`
	Token        string   `json:"token"`
	Referral     string   `json:"referral"`
	Locale       string   `json:"locale"`
	Servers      []string `json:"servers"`
	Inviters     []string `json:"inviters"`
	Invitees     []string `json:"invitees"`
	Devices      []string `json:"devices"`
	YinbiEnabled bool     `json:"yinbiEnabled"`
}

type UserDetailResponse struct {
	UserID       int64        `json:"userId"`
	Code         string       `json:"code"`
	Token        string       `json:"token"`
	Referral     string       `json:"referral"`
	Email        string       `json:"email"`
	UserStatus   string       `json:"userStatus"`
	UserLevel    string       `json:"userLevel"`
	Locale       string       `json:"locale"`
	Expiration   int64        `json:"expiration"`
	Servers      []string     `json:"servers"`
	Purchases    []Purchase   `json:"purchases"`
	BonusDays    string       `json:"bonusDays"`
	BonusMonths  string       `json:"bonusMonths"`
	Inviters     []string     `json:"inviters"`
	Invitees     []string     `json:"invitees"`
	Devices      []UserDevice `json:"devices"`
	YinbiEnabled bool         `json:"yinbiEnabled"`
}

type Purchase struct {
	Plan string `json:"plan"`
}

type UserDevice struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Created int64  `json:"created"`
}

type Salt struct {
	Salt []int64 `json:"salt"`
}

type SrpB struct {
	SrpB big.Int `json:"srpB"`
}
