package apimodels

import "math/big"

// / Migrate Json structs to use Model from Lantenr cloud
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

// Plans Json struct

type PlansResponse struct {
	Plans     []Plan    `json:"plans"`
	Providers Providers `json:"providers"`
}

type Plan struct {
	ID                     string           `json:"id"`
	Description            string           `json:"description"`
	Duration               Duration         `json:"duration"`
	Price                  map[string]int64 `json:"price"`
	ExpectedMonthlyPrice   map[string]int64 `json:"expectedMonthlyPrice"`
	UsdPrice               int64            `json:"usdPrice"`
	UsdPrice1Y             int64            `json:"usdPrice1Y"`
	UsdPrice2Y             int64            `json:"usdPrice2Y"`
	RedeemFor              RedeemFor        `json:"redeemFor"`
	RenewalBonus           RedeemFor        `json:"renewalBonus"`
	RenewalBonusExpired    RedeemFor        `json:"renewalBonusExpired"`
	RenewalBonusExpected   RedeemFor        `json:"renewalBonusExpected"`
	Discount               float64          `json:"discount"`
	BestValue              bool             `json:"bestValue"`
	Level                  string           `json:"level"`
	TotalCostBilledOneTime string
	FormattedDiscount      string
	FormattedBonus         string
	OneMonthCost           string
	TotalCost              string
}

type Price struct {
	Usd int64 `json:"usd"`
}

type Duration struct {
	Days   int64 `json:"days"`
	Months int64 `json:"months"`
	Years  int64 `json:"years"`
}

type RedeemFor struct {
	Days   int64 `json:"days"`
	Months int64 `json:"months"`
}

type Providers struct {
	Android []Android `json:"android"`
	Desktop []Android `json:"desktop"`
}

type Android struct {
	Method    string     `json:"method"`
	Providers []Provider `json:"providers"`
}

type Provider struct {
	Name string `json:"name"`
	Data *Data  `json:"data,omitempty"`
}

type Data struct {
	PubKey string `json:"pubKey"`
}

//Purchase Request

type PurchaseResponse struct {
	PaymentStatus string `json:"paymentStatus"`
	Plan          Plan   `json:"plan"`
	Status        string `json:"status"`
}

type SrpB struct {
	SrpB big.Int `json:"srpB"`
}

// Device Linking
type LinkRequestResult struct {
	Code     string `json:"code,omitempty"`
	ExpireAt int64  `json:"expireAt,omitempty"`
}
type UserRecovery struct {
	Status string `json:"status"`
	UserID int64  `json:"userID"`
	Token  string `json:"token"`
}

type ApiResponse struct {
	Error   string `json:"error"`
	ErrorId string `json:"errorId"`
	Status  string `json:"status"`
}
