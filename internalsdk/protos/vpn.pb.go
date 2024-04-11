// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.26.0
// 	protoc        v4.24.3
// source: protos_shared/vpn.proto

package protos

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type ServerInfo struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	City        string `protobuf:"bytes,1,opt,name=city,proto3" json:"city,omitempty"`
	Country     string `protobuf:"bytes,2,opt,name=country,proto3" json:"country,omitempty"`
	CountryCode string `protobuf:"bytes,3,opt,name=countryCode,proto3" json:"countryCode,omitempty"`
}

func (x *ServerInfo) Reset() {
	*x = ServerInfo{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *ServerInfo) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ServerInfo) ProtoMessage() {}

func (x *ServerInfo) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ServerInfo.ProtoReflect.Descriptor instead.
func (*ServerInfo) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{0}
}

func (x *ServerInfo) GetCity() string {
	if x != nil {
		return x.City
	}
	return ""
}

func (x *ServerInfo) GetCountry() string {
	if x != nil {
		return x.Country
	}
	return ""
}

func (x *ServerInfo) GetCountryCode() string {
	if x != nil {
		return x.CountryCode
	}
	return ""
}

type Bandwidth struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Percent    int64 `protobuf:"varint,1,opt,name=percent,proto3" json:"percent,omitempty"`       // [0, 100]
	Remaining  int64 `protobuf:"varint,2,opt,name=remaining,proto3" json:"remaining,omitempty"`   // in MB
	Allowed    int64 `protobuf:"varint,3,opt,name=allowed,proto3" json:"allowed,omitempty"`       // in MB
	TtlSeconds int64 `protobuf:"varint,4,opt,name=ttlSeconds,proto3" json:"ttlSeconds,omitempty"` // number of seconds left before data reset
}

func (x *Bandwidth) Reset() {
	*x = Bandwidth{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Bandwidth) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Bandwidth) ProtoMessage() {}

func (x *Bandwidth) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Bandwidth.ProtoReflect.Descriptor instead.
func (*Bandwidth) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{1}
}

func (x *Bandwidth) GetPercent() int64 {
	if x != nil {
		return x.Percent
	}
	return 0
}

func (x *Bandwidth) GetRemaining() int64 {
	if x != nil {
		return x.Remaining
	}
	return 0
}

func (x *Bandwidth) GetAllowed() int64 {
	if x != nil {
		return x.Allowed
	}
	return 0
}

func (x *Bandwidth) GetTtlSeconds() int64 {
	if x != nil {
		return x.TtlSeconds
	}
	return 0
}

type AppData struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	PackageName   string `protobuf:"bytes,1,opt,name=packageName,proto3" json:"packageName,omitempty"`
	Name          string `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	Icon          []byte `protobuf:"bytes,3,opt,name=icon,proto3" json:"icon,omitempty"`
	AllowedAccess bool   `protobuf:"varint,4,opt,name=allowedAccess,proto3" json:"allowedAccess,omitempty"`
}

func (x *AppData) Reset() {
	*x = AppData{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[2]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *AppData) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*AppData) ProtoMessage() {}

func (x *AppData) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[2]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use AppData.ProtoReflect.Descriptor instead.
func (*AppData) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{2}
}

func (x *AppData) GetPackageName() string {
	if x != nil {
		return x.PackageName
	}
	return ""
}

func (x *AppData) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *AppData) GetIcon() []byte {
	if x != nil {
		return x.Icon
	}
	return nil
}

func (x *AppData) GetAllowedAccess() bool {
	if x != nil {
		return x.AllowedAccess
	}
	return false
}

type Device struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Id      string `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	Name    string `protobuf:"bytes,2,opt,name=name,proto3" json:"name,omitempty"`
	Created int64  `protobuf:"varint,3,opt,name=created,proto3" json:"created,omitempty"`
}

func (x *Device) Reset() {
	*x = Device{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[3]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Device) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Device) ProtoMessage() {}

func (x *Device) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[3]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Device.ProtoReflect.Descriptor instead.
func (*Device) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{3}
}

func (x *Device) GetId() string {
	if x != nil {
		return x.Id
	}
	return ""
}

func (x *Device) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *Device) GetCreated() int64 {
	if x != nil {
		return x.Created
	}
	return 0
}

type Devices struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Devices []*Device `protobuf:"bytes,1,rep,name=devices,proto3" json:"devices,omitempty"`
}

func (x *Devices) Reset() {
	*x = Devices{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[4]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Devices) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Devices) ProtoMessage() {}

func (x *Devices) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[4]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Devices.ProtoReflect.Descriptor instead.
func (*Devices) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{4}
}

func (x *Devices) GetDevices() []*Device {
	if x != nil {
		return x.Devices
	}
	return nil
}

type Plan struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Id                     string           `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	Description            string           `protobuf:"bytes,2,opt,name=description,proto3" json:"description,omitempty"`
	BestValue              bool             `protobuf:"varint,3,opt,name=bestValue,proto3" json:"bestValue,omitempty"`
	UsdPrice               int64            `protobuf:"varint,4,opt,name=usdPrice,proto3" json:"usdPrice,omitempty"`
	Price                  map[string]int64 `protobuf:"bytes,5,rep,name=price,proto3" json:"price,omitempty" protobuf_key:"bytes,1,opt,name=key,proto3" protobuf_val:"varint,2,opt,name=value,proto3"`
	TotalCostBilledOneTime string           `protobuf:"bytes,6,opt,name=totalCostBilledOneTime,proto3" json:"totalCostBilledOneTime,omitempty"`
	OneMonthCost           string           `protobuf:"bytes,7,opt,name=oneMonthCost,proto3" json:"oneMonthCost,omitempty"`
	TotalCost              string           `protobuf:"bytes,8,opt,name=totalCost,proto3" json:"totalCost,omitempty"`
	FormattedBonus         string           `protobuf:"bytes,9,opt,name=formattedBonus,proto3" json:"formattedBonus,omitempty"`
	RenewalText            string           `protobuf:"bytes,10,opt,name=renewalText,proto3" json:"renewalText,omitempty"`
}

func (x *Plan) Reset() {
	*x = Plan{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[5]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Plan) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Plan) ProtoMessage() {}

func (x *Plan) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[5]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Plan.ProtoReflect.Descriptor instead.
func (*Plan) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{5}
}

func (x *Plan) GetId() string {
	if x != nil {
		return x.Id
	}
	return ""
}

func (x *Plan) GetDescription() string {
	if x != nil {
		return x.Description
	}
	return ""
}

func (x *Plan) GetBestValue() bool {
	if x != nil {
		return x.BestValue
	}
	return false
}

func (x *Plan) GetUsdPrice() int64 {
	if x != nil {
		return x.UsdPrice
	}
	return 0
}

func (x *Plan) GetPrice() map[string]int64 {
	if x != nil {
		return x.Price
	}
	return nil
}

func (x *Plan) GetTotalCostBilledOneTime() string {
	if x != nil {
		return x.TotalCostBilledOneTime
	}
	return ""
}

func (x *Plan) GetOneMonthCost() string {
	if x != nil {
		return x.OneMonthCost
	}
	return ""
}

func (x *Plan) GetTotalCost() string {
	if x != nil {
		return x.TotalCost
	}
	return ""
}

func (x *Plan) GetFormattedBonus() string {
	if x != nil {
		return x.FormattedBonus
	}
	return ""
}

func (x *Plan) GetRenewalText() string {
	if x != nil {
		return x.RenewalText
	}
	return ""
}

type PaymentProviders struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Name     string   `protobuf:"bytes,1,opt,name=name,proto3" json:"name,omitempty"`
	LogoUrls []string `protobuf:"bytes,2,rep,name=logoUrls,proto3" json:"logoUrls,omitempty"`
}

func (x *PaymentProviders) Reset() {
	*x = PaymentProviders{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[6]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *PaymentProviders) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*PaymentProviders) ProtoMessage() {}

func (x *PaymentProviders) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[6]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use PaymentProviders.ProtoReflect.Descriptor instead.
func (*PaymentProviders) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{6}
}

func (x *PaymentProviders) GetName() string {
	if x != nil {
		return x.Name
	}
	return ""
}

func (x *PaymentProviders) GetLogoUrls() []string {
	if x != nil {
		return x.LogoUrls
	}
	return nil
}

type PaymentMethod struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Method    string              `protobuf:"bytes,1,opt,name=method,proto3" json:"method,omitempty"`
	Providers []*PaymentProviders `protobuf:"bytes,2,rep,name=providers,proto3" json:"providers,omitempty"`
}

func (x *PaymentMethod) Reset() {
	*x = PaymentMethod{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[7]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *PaymentMethod) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*PaymentMethod) ProtoMessage() {}

func (x *PaymentMethod) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[7]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use PaymentMethod.ProtoReflect.Descriptor instead.
func (*PaymentMethod) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{7}
}

func (x *PaymentMethod) GetMethod() string {
	if x != nil {
		return x.Method
	}
	return ""
}

func (x *PaymentMethod) GetProviders() []*PaymentProviders {
	if x != nil {
		return x.Providers
	}
	return nil
}

type User struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	UserId       int64     `protobuf:"varint,1,opt,name=userId,proto3" json:"userId,omitempty"`
	Email        string    `protobuf:"bytes,2,opt,name=email,proto3" json:"email,omitempty"`
	Telephone    string    `protobuf:"bytes,3,opt,name=telephone,proto3" json:"telephone,omitempty"`
	UserStatus   string    `protobuf:"bytes,4,opt,name=userStatus,proto3" json:"userStatus,omitempty"`
	Locale       string    `protobuf:"bytes,5,opt,name=locale,proto3" json:"locale,omitempty"`
	Expiration   int64     `protobuf:"varint,6,opt,name=expiration,proto3" json:"expiration,omitempty"`
	Devices      []*Device `protobuf:"bytes,7,rep,name=devices,proto3" json:"devices,omitempty"`
	Code         string    `protobuf:"bytes,8,opt,name=code,proto3" json:"code,omitempty"`
	ExpireAt     int64     `protobuf:"varint,9,opt,name=expireAt,proto3" json:"expireAt,omitempty"`
	Referral     string    `protobuf:"bytes,10,opt,name=referral,proto3" json:"referral,omitempty"`
	Token        string    `protobuf:"bytes,11,opt,name=token,proto3" json:"token,omitempty"`
	YinbiEnabled bool      `protobuf:"varint,12,opt,name=yinbiEnabled,proto3" json:"yinbiEnabled,omitempty"`
}

func (x *User) Reset() {
	*x = User{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[8]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *User) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*User) ProtoMessage() {}

func (x *User) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[8]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use User.ProtoReflect.Descriptor instead.
func (*User) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{8}
}

func (x *User) GetUserId() int64 {
	if x != nil {
		return x.UserId
	}
	return 0
}

func (x *User) GetEmail() string {
	if x != nil {
		return x.Email
	}
	return ""
}

func (x *User) GetTelephone() string {
	if x != nil {
		return x.Telephone
	}
	return ""
}

func (x *User) GetUserStatus() string {
	if x != nil {
		return x.UserStatus
	}
	return ""
}

func (x *User) GetLocale() string {
	if x != nil {
		return x.Locale
	}
	return ""
}

func (x *User) GetExpiration() int64 {
	if x != nil {
		return x.Expiration
	}
	return 0
}

func (x *User) GetDevices() []*Device {
	if x != nil {
		return x.Devices
	}
	return nil
}

func (x *User) GetCode() string {
	if x != nil {
		return x.Code
	}
	return ""
}

func (x *User) GetExpireAt() int64 {
	if x != nil {
		return x.ExpireAt
	}
	return 0
}

func (x *User) GetReferral() string {
	if x != nil {
		return x.Referral
	}
	return ""
}

func (x *User) GetToken() string {
	if x != nil {
		return x.Token
	}
	return ""
}

func (x *User) GetYinbiEnabled() bool {
	if x != nil {
		return x.YinbiEnabled
	}
	return false
}

// API
type APIResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Status  string `protobuf:"bytes,1,opt,name=status,proto3" json:"status,omitempty"`
	Error   string `protobuf:"bytes,2,opt,name=error,proto3" json:"error,omitempty"`
	ErrorId string `protobuf:"bytes,3,opt,name=errorId,proto3" json:"errorId,omitempty"`
}

func (x *APIResponse) Reset() {
	*x = APIResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[9]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *APIResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*APIResponse) ProtoMessage() {}

func (x *APIResponse) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[9]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use APIResponse.ProtoReflect.Descriptor instead.
func (*APIResponse) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{9}
}

func (x *APIResponse) GetStatus() string {
	if x != nil {
		return x.Status
	}
	return ""
}

func (x *APIResponse) GetError() string {
	if x != nil {
		return x.Error
	}
	return ""
}

func (x *APIResponse) GetErrorId() string {
	if x != nil {
		return x.ErrorId
	}
	return ""
}

type LinkResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	UserID  int64  `protobuf:"varint,1,opt,name=userID,proto3" json:"userID,omitempty"`
	Token   string `protobuf:"bytes,2,opt,name=token,proto3" json:"token,omitempty"`
	Status  string `protobuf:"bytes,3,opt,name=status,proto3" json:"status,omitempty"`
	Error   string `protobuf:"bytes,4,opt,name=error,proto3" json:"error,omitempty"`
	ErrorId string `protobuf:"bytes,5,opt,name=errorId,proto3" json:"errorId,omitempty"`
}

func (x *LinkResponse) Reset() {
	*x = LinkResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protos_shared_vpn_proto_msgTypes[10]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *LinkResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*LinkResponse) ProtoMessage() {}

func (x *LinkResponse) ProtoReflect() protoreflect.Message {
	mi := &file_protos_shared_vpn_proto_msgTypes[10]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use LinkResponse.ProtoReflect.Descriptor instead.
func (*LinkResponse) Descriptor() ([]byte, []int) {
	return file_protos_shared_vpn_proto_rawDescGZIP(), []int{10}
}

func (x *LinkResponse) GetUserID() int64 {
	if x != nil {
		return x.UserID
	}
	return 0
}

func (x *LinkResponse) GetToken() string {
	if x != nil {
		return x.Token
	}
	return ""
}

func (x *LinkResponse) GetStatus() string {
	if x != nil {
		return x.Status
	}
	return ""
}

func (x *LinkResponse) GetError() string {
	if x != nil {
		return x.Error
	}
	return ""
}

func (x *LinkResponse) GetErrorId() string {
	if x != nil {
		return x.ErrorId
	}
	return ""
}

var File_protos_shared_vpn_proto protoreflect.FileDescriptor

var file_protos_shared_vpn_proto_rawDesc = []byte{
	0x0a, 0x17, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x73, 0x5f, 0x73, 0x68, 0x61, 0x72, 0x65, 0x64, 0x2f,
	0x76, 0x70, 0x6e, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x22, 0x5c, 0x0a, 0x0a, 0x53, 0x65, 0x72,
	0x76, 0x65, 0x72, 0x49, 0x6e, 0x66, 0x6f, 0x12, 0x12, 0x0a, 0x04, 0x63, 0x69, 0x74, 0x79, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x63, 0x69, 0x74, 0x79, 0x12, 0x18, 0x0a, 0x07, 0x63,
	0x6f, 0x75, 0x6e, 0x74, 0x72, 0x79, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x63, 0x6f,
	0x75, 0x6e, 0x74, 0x72, 0x79, 0x12, 0x20, 0x0a, 0x0b, 0x63, 0x6f, 0x75, 0x6e, 0x74, 0x72, 0x79,
	0x43, 0x6f, 0x64, 0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0b, 0x63, 0x6f, 0x75, 0x6e,
	0x74, 0x72, 0x79, 0x43, 0x6f, 0x64, 0x65, 0x22, 0x7d, 0x0a, 0x09, 0x42, 0x61, 0x6e, 0x64, 0x77,
	0x69, 0x64, 0x74, 0x68, 0x12, 0x18, 0x0a, 0x07, 0x70, 0x65, 0x72, 0x63, 0x65, 0x6e, 0x74, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x03, 0x52, 0x07, 0x70, 0x65, 0x72, 0x63, 0x65, 0x6e, 0x74, 0x12, 0x1c,
	0x0a, 0x09, 0x72, 0x65, 0x6d, 0x61, 0x69, 0x6e, 0x69, 0x6e, 0x67, 0x18, 0x02, 0x20, 0x01, 0x28,
	0x03, 0x52, 0x09, 0x72, 0x65, 0x6d, 0x61, 0x69, 0x6e, 0x69, 0x6e, 0x67, 0x12, 0x18, 0x0a, 0x07,
	0x61, 0x6c, 0x6c, 0x6f, 0x77, 0x65, 0x64, 0x18, 0x03, 0x20, 0x01, 0x28, 0x03, 0x52, 0x07, 0x61,
	0x6c, 0x6c, 0x6f, 0x77, 0x65, 0x64, 0x12, 0x1e, 0x0a, 0x0a, 0x74, 0x74, 0x6c, 0x53, 0x65, 0x63,
	0x6f, 0x6e, 0x64, 0x73, 0x18, 0x04, 0x20, 0x01, 0x28, 0x03, 0x52, 0x0a, 0x74, 0x74, 0x6c, 0x53,
	0x65, 0x63, 0x6f, 0x6e, 0x64, 0x73, 0x22, 0x79, 0x0a, 0x07, 0x41, 0x70, 0x70, 0x44, 0x61, 0x74,
	0x61, 0x12, 0x20, 0x0a, 0x0b, 0x70, 0x61, 0x63, 0x6b, 0x61, 0x67, 0x65, 0x4e, 0x61, 0x6d, 0x65,
	0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0b, 0x70, 0x61, 0x63, 0x6b, 0x61, 0x67, 0x65, 0x4e,
	0x61, 0x6d, 0x65, 0x12, 0x12, 0x0a, 0x04, 0x6e, 0x61, 0x6d, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28,
	0x09, 0x52, 0x04, 0x6e, 0x61, 0x6d, 0x65, 0x12, 0x12, 0x0a, 0x04, 0x69, 0x63, 0x6f, 0x6e, 0x18,
	0x03, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x04, 0x69, 0x63, 0x6f, 0x6e, 0x12, 0x24, 0x0a, 0x0d, 0x61,
	0x6c, 0x6c, 0x6f, 0x77, 0x65, 0x64, 0x41, 0x63, 0x63, 0x65, 0x73, 0x73, 0x18, 0x04, 0x20, 0x01,
	0x28, 0x08, 0x52, 0x0d, 0x61, 0x6c, 0x6c, 0x6f, 0x77, 0x65, 0x64, 0x41, 0x63, 0x63, 0x65, 0x73,
	0x73, 0x22, 0x46, 0x0a, 0x06, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65, 0x12, 0x0e, 0x0a, 0x02, 0x69,
	0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x02, 0x69, 0x64, 0x12, 0x12, 0x0a, 0x04, 0x6e,
	0x61, 0x6d, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6e, 0x61, 0x6d, 0x65, 0x12,
	0x18, 0x0a, 0x07, 0x63, 0x72, 0x65, 0x61, 0x74, 0x65, 0x64, 0x18, 0x03, 0x20, 0x01, 0x28, 0x03,
	0x52, 0x07, 0x63, 0x72, 0x65, 0x61, 0x74, 0x65, 0x64, 0x22, 0x2c, 0x0a, 0x07, 0x44, 0x65, 0x76,
	0x69, 0x63, 0x65, 0x73, 0x12, 0x21, 0x0a, 0x07, 0x64, 0x65, 0x76, 0x69, 0x63, 0x65, 0x73, 0x18,
	0x01, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x07, 0x2e, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65, 0x52, 0x07,
	0x64, 0x65, 0x76, 0x69, 0x63, 0x65, 0x73, 0x22, 0x98, 0x03, 0x0a, 0x04, 0x50, 0x6c, 0x61, 0x6e,
	0x12, 0x0e, 0x0a, 0x02, 0x69, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x02, 0x69, 0x64,
	0x12, 0x20, 0x0a, 0x0b, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69, 0x6f, 0x6e, 0x18,
	0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0b, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x69,
	0x6f, 0x6e, 0x12, 0x1c, 0x0a, 0x09, 0x62, 0x65, 0x73, 0x74, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x18,
	0x03, 0x20, 0x01, 0x28, 0x08, 0x52, 0x09, 0x62, 0x65, 0x73, 0x74, 0x56, 0x61, 0x6c, 0x75, 0x65,
	0x12, 0x1a, 0x0a, 0x08, 0x75, 0x73, 0x64, 0x50, 0x72, 0x69, 0x63, 0x65, 0x18, 0x04, 0x20, 0x01,
	0x28, 0x03, 0x52, 0x08, 0x75, 0x73, 0x64, 0x50, 0x72, 0x69, 0x63, 0x65, 0x12, 0x26, 0x0a, 0x05,
	0x70, 0x72, 0x69, 0x63, 0x65, 0x18, 0x05, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x10, 0x2e, 0x50, 0x6c,
	0x61, 0x6e, 0x2e, 0x50, 0x72, 0x69, 0x63, 0x65, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x52, 0x05, 0x70,
	0x72, 0x69, 0x63, 0x65, 0x12, 0x36, 0x0a, 0x16, 0x74, 0x6f, 0x74, 0x61, 0x6c, 0x43, 0x6f, 0x73,
	0x74, 0x42, 0x69, 0x6c, 0x6c, 0x65, 0x64, 0x4f, 0x6e, 0x65, 0x54, 0x69, 0x6d, 0x65, 0x18, 0x06,
	0x20, 0x01, 0x28, 0x09, 0x52, 0x16, 0x74, 0x6f, 0x74, 0x61, 0x6c, 0x43, 0x6f, 0x73, 0x74, 0x42,
	0x69, 0x6c, 0x6c, 0x65, 0x64, 0x4f, 0x6e, 0x65, 0x54, 0x69, 0x6d, 0x65, 0x12, 0x22, 0x0a, 0x0c,
	0x6f, 0x6e, 0x65, 0x4d, 0x6f, 0x6e, 0x74, 0x68, 0x43, 0x6f, 0x73, 0x74, 0x18, 0x07, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x0c, 0x6f, 0x6e, 0x65, 0x4d, 0x6f, 0x6e, 0x74, 0x68, 0x43, 0x6f, 0x73, 0x74,
	0x12, 0x1c, 0x0a, 0x09, 0x74, 0x6f, 0x74, 0x61, 0x6c, 0x43, 0x6f, 0x73, 0x74, 0x18, 0x08, 0x20,
	0x01, 0x28, 0x09, 0x52, 0x09, 0x74, 0x6f, 0x74, 0x61, 0x6c, 0x43, 0x6f, 0x73, 0x74, 0x12, 0x26,
	0x0a, 0x0e, 0x66, 0x6f, 0x72, 0x6d, 0x61, 0x74, 0x74, 0x65, 0x64, 0x42, 0x6f, 0x6e, 0x75, 0x73,
	0x18, 0x09, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0e, 0x66, 0x6f, 0x72, 0x6d, 0x61, 0x74, 0x74, 0x65,
	0x64, 0x42, 0x6f, 0x6e, 0x75, 0x73, 0x12, 0x20, 0x0a, 0x0b, 0x72, 0x65, 0x6e, 0x65, 0x77, 0x61,
	0x6c, 0x54, 0x65, 0x78, 0x74, 0x18, 0x0a, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0b, 0x72, 0x65, 0x6e,
	0x65, 0x77, 0x61, 0x6c, 0x54, 0x65, 0x78, 0x74, 0x1a, 0x38, 0x0a, 0x0a, 0x50, 0x72, 0x69, 0x63,
	0x65, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x12, 0x10, 0x0a, 0x03, 0x6b, 0x65, 0x79, 0x18, 0x01, 0x20,
	0x01, 0x28, 0x09, 0x52, 0x03, 0x6b, 0x65, 0x79, 0x12, 0x14, 0x0a, 0x05, 0x76, 0x61, 0x6c, 0x75,
	0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x03, 0x52, 0x05, 0x76, 0x61, 0x6c, 0x75, 0x65, 0x3a, 0x02,
	0x38, 0x01, 0x22, 0x42, 0x0a, 0x10, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x50, 0x72, 0x6f,
	0x76, 0x69, 0x64, 0x65, 0x72, 0x73, 0x12, 0x12, 0x0a, 0x04, 0x6e, 0x61, 0x6d, 0x65, 0x18, 0x01,
	0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6e, 0x61, 0x6d, 0x65, 0x12, 0x1a, 0x0a, 0x08, 0x6c, 0x6f,
	0x67, 0x6f, 0x55, 0x72, 0x6c, 0x73, 0x18, 0x02, 0x20, 0x03, 0x28, 0x09, 0x52, 0x08, 0x6c, 0x6f,
	0x67, 0x6f, 0x55, 0x72, 0x6c, 0x73, 0x22, 0x58, 0x0a, 0x0d, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e,
	0x74, 0x4d, 0x65, 0x74, 0x68, 0x6f, 0x64, 0x12, 0x16, 0x0a, 0x06, 0x6d, 0x65, 0x74, 0x68, 0x6f,
	0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x06, 0x6d, 0x65, 0x74, 0x68, 0x6f, 0x64, 0x12,
	0x2f, 0x0a, 0x09, 0x70, 0x72, 0x6f, 0x76, 0x69, 0x64, 0x65, 0x72, 0x73, 0x18, 0x02, 0x20, 0x03,
	0x28, 0x0b, 0x32, 0x11, 0x2e, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x50, 0x72, 0x6f, 0x76,
	0x69, 0x64, 0x65, 0x72, 0x73, 0x52, 0x09, 0x70, 0x72, 0x6f, 0x76, 0x69, 0x64, 0x65, 0x72, 0x73,
	0x22, 0xd3, 0x02, 0x0a, 0x04, 0x55, 0x73, 0x65, 0x72, 0x12, 0x16, 0x0a, 0x06, 0x75, 0x73, 0x65,
	0x72, 0x49, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x03, 0x52, 0x06, 0x75, 0x73, 0x65, 0x72, 0x49,
	0x64, 0x12, 0x14, 0x0a, 0x05, 0x65, 0x6d, 0x61, 0x69, 0x6c, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09,
	0x52, 0x05, 0x65, 0x6d, 0x61, 0x69, 0x6c, 0x12, 0x1c, 0x0a, 0x09, 0x74, 0x65, 0x6c, 0x65, 0x70,
	0x68, 0x6f, 0x6e, 0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x09, 0x52, 0x09, 0x74, 0x65, 0x6c, 0x65,
	0x70, 0x68, 0x6f, 0x6e, 0x65, 0x12, 0x1e, 0x0a, 0x0a, 0x75, 0x73, 0x65, 0x72, 0x53, 0x74, 0x61,
	0x74, 0x75, 0x73, 0x18, 0x04, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0a, 0x75, 0x73, 0x65, 0x72, 0x53,
	0x74, 0x61, 0x74, 0x75, 0x73, 0x12, 0x16, 0x0a, 0x06, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x65, 0x18,
	0x05, 0x20, 0x01, 0x28, 0x09, 0x52, 0x06, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x65, 0x12, 0x1e, 0x0a,
	0x0a, 0x65, 0x78, 0x70, 0x69, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x18, 0x06, 0x20, 0x01, 0x28,
	0x03, 0x52, 0x0a, 0x65, 0x78, 0x70, 0x69, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x12, 0x21, 0x0a,
	0x07, 0x64, 0x65, 0x76, 0x69, 0x63, 0x65, 0x73, 0x18, 0x07, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x07,
	0x2e, 0x44, 0x65, 0x76, 0x69, 0x63, 0x65, 0x52, 0x07, 0x64, 0x65, 0x76, 0x69, 0x63, 0x65, 0x73,
	0x12, 0x12, 0x0a, 0x04, 0x63, 0x6f, 0x64, 0x65, 0x18, 0x08, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04,
	0x63, 0x6f, 0x64, 0x65, 0x12, 0x1a, 0x0a, 0x08, 0x65, 0x78, 0x70, 0x69, 0x72, 0x65, 0x41, 0x74,
	0x18, 0x09, 0x20, 0x01, 0x28, 0x03, 0x52, 0x08, 0x65, 0x78, 0x70, 0x69, 0x72, 0x65, 0x41, 0x74,
	0x12, 0x1a, 0x0a, 0x08, 0x72, 0x65, 0x66, 0x65, 0x72, 0x72, 0x61, 0x6c, 0x18, 0x0a, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x08, 0x72, 0x65, 0x66, 0x65, 0x72, 0x72, 0x61, 0x6c, 0x12, 0x14, 0x0a, 0x05,
	0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x18, 0x0b, 0x20, 0x01, 0x28, 0x09, 0x52, 0x05, 0x74, 0x6f, 0x6b,
	0x65, 0x6e, 0x12, 0x22, 0x0a, 0x0c, 0x79, 0x69, 0x6e, 0x62, 0x69, 0x45, 0x6e, 0x61, 0x62, 0x6c,
	0x65, 0x64, 0x18, 0x0c, 0x20, 0x01, 0x28, 0x08, 0x52, 0x0c, 0x79, 0x69, 0x6e, 0x62, 0x69, 0x45,
	0x6e, 0x61, 0x62, 0x6c, 0x65, 0x64, 0x22, 0x55, 0x0a, 0x0b, 0x41, 0x50, 0x49, 0x52, 0x65, 0x73,
	0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x16, 0x0a, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x12, 0x14, 0x0a,
	0x05, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x05, 0x65, 0x72,
	0x72, 0x6f, 0x72, 0x12, 0x18, 0x0a, 0x07, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x49, 0x64, 0x18, 0x03,
	0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x49, 0x64, 0x22, 0x84, 0x01,
	0x0a, 0x0c, 0x4c, 0x69, 0x6e, 0x6b, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x16,
	0x0a, 0x06, 0x75, 0x73, 0x65, 0x72, 0x49, 0x44, 0x18, 0x01, 0x20, 0x01, 0x28, 0x03, 0x52, 0x06,
	0x75, 0x73, 0x65, 0x72, 0x49, 0x44, 0x12, 0x14, 0x0a, 0x05, 0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x18,
	0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x05, 0x74, 0x6f, 0x6b, 0x65, 0x6e, 0x12, 0x16, 0x0a, 0x06,
	0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x18, 0x03, 0x20, 0x01, 0x28, 0x09, 0x52, 0x06, 0x73, 0x74,
	0x61, 0x74, 0x75, 0x73, 0x12, 0x14, 0x0a, 0x05, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x18, 0x04, 0x20,
	0x01, 0x28, 0x09, 0x52, 0x05, 0x65, 0x72, 0x72, 0x6f, 0x72, 0x12, 0x18, 0x0a, 0x07, 0x65, 0x72,
	0x72, 0x6f, 0x72, 0x49, 0x64, 0x18, 0x05, 0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x65, 0x72, 0x72,
	0x6f, 0x72, 0x49, 0x64, 0x42, 0x1b, 0x0a, 0x10, 0x69, 0x6f, 0x2e, 0x6c, 0x61, 0x6e, 0x74, 0x65,
	0x72, 0x6e, 0x2e, 0x6d, 0x6f, 0x64, 0x65, 0x6c, 0x5a, 0x07, 0x2f, 0x70, 0x72, 0x6f, 0x74, 0x6f,
	0x73, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_protos_shared_vpn_proto_rawDescOnce sync.Once
	file_protos_shared_vpn_proto_rawDescData = file_protos_shared_vpn_proto_rawDesc
)

func file_protos_shared_vpn_proto_rawDescGZIP() []byte {
	file_protos_shared_vpn_proto_rawDescOnce.Do(func() {
		file_protos_shared_vpn_proto_rawDescData = protoimpl.X.CompressGZIP(file_protos_shared_vpn_proto_rawDescData)
	})
	return file_protos_shared_vpn_proto_rawDescData
}

var file_protos_shared_vpn_proto_msgTypes = make([]protoimpl.MessageInfo, 12)
var file_protos_shared_vpn_proto_goTypes = []interface{}{
	(*ServerInfo)(nil),       // 0: ServerInfo
	(*Bandwidth)(nil),        // 1: Bandwidth
	(*AppData)(nil),          // 2: AppData
	(*Device)(nil),           // 3: Device
	(*Devices)(nil),          // 4: Devices
	(*Plan)(nil),             // 5: Plan
	(*PaymentProviders)(nil), // 6: PaymentProviders
	(*PaymentMethod)(nil),    // 7: PaymentMethod
	(*User)(nil),             // 8: User
	(*APIResponse)(nil),      // 9: APIResponse
	(*LinkResponse)(nil),     // 10: LinkResponse
	nil,                      // 11: Plan.PriceEntry
}
var file_protos_shared_vpn_proto_depIdxs = []int32{
	3,  // 0: Devices.devices:type_name -> Device
	11, // 1: Plan.price:type_name -> Plan.PriceEntry
	6,  // 2: PaymentMethod.providers:type_name -> PaymentProviders
	3,  // 3: User.devices:type_name -> Device
	4,  // [4:4] is the sub-list for method output_type
	4,  // [4:4] is the sub-list for method input_type
	4,  // [4:4] is the sub-list for extension type_name
	4,  // [4:4] is the sub-list for extension extendee
	0,  // [0:4] is the sub-list for field type_name
}

func init() { file_protos_shared_vpn_proto_init() }
func file_protos_shared_vpn_proto_init() {
	if File_protos_shared_vpn_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_protos_shared_vpn_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*ServerInfo); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Bandwidth); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[2].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*AppData); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[3].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Device); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[4].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Devices); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[5].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Plan); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[6].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*PaymentProviders); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[7].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*PaymentMethod); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[8].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*User); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[9].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*APIResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_protos_shared_vpn_proto_msgTypes[10].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*LinkResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_protos_shared_vpn_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   12,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_protos_shared_vpn_proto_goTypes,
		DependencyIndexes: file_protos_shared_vpn_proto_depIdxs,
		MessageInfos:      file_protos_shared_vpn_proto_msgTypes,
	}.Build()
	File_protos_shared_vpn_proto = out.File
	file_protos_shared_vpn_proto_rawDesc = nil
	file_protos_shared_vpn_proto_goTypes = nil
	file_protos_shared_vpn_proto_depIdxs = nil
}
