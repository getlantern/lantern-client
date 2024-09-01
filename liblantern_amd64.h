/* Code generated by cmd/cgo; DO NOT EDIT. */

/* package command-line-arguments */


#line 1 "cgo-builtin-export-prolog"

#include <stddef.h>

#ifndef GO_CGO_EXPORT_PROLOGUE_H
#define GO_CGO_EXPORT_PROLOGUE_H

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef struct { const char *p; ptrdiff_t n; } _GoString_;
#endif

#endif

/* Start of preamble from import "C" comments.  */





/* End of preamble from import "C" comments.  */


/* Start of boilerplate cgo prologue.  */
#line 1 "cgo-gcc-export-header-prolog"

#ifndef GO_CGO_PROLOGUE_H
#define GO_CGO_PROLOGUE_H

typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt64 GoInt;
typedef GoUint64 GoUint;
typedef size_t GoUintptr;
typedef float GoFloat32;
typedef double GoFloat64;
#ifdef _MSC_VER
#include <complex.h>
typedef _Fcomplex GoComplex64;
typedef _Dcomplex GoComplex128;
#else
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;
#endif

/*
  static assertion to make sure the file is being used on architecture
  at least with matching size of GoInt.
*/
typedef char _check_for_64_bit_pointer_matching_GoInt[sizeof(void*)==64/8 ? 1:-1];

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef _GoString_ GoString;
#endif
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

#endif

/* End of boilerplate cgo prologue.  */

#ifdef __cplusplus
extern "C" {
#endif

extern char* isUserFirstTime();
extern void setFirstTimeVisit();
extern char* isUserLoggedIn();
extern char* signup(char* email, char* password);
extern char* login(char* email, char* password);
extern char* logout();

// Send recovery code to user email
//
extern char* startRecoveryByEmail(char* email);

// Complete recovery by email
//
extern char* completeRecoveryByEmail(char* email, char* code, char* password);

// // This will validate code send by server
//
extern char* validateRecoveryByEmail(char* email, char* code);

// This will delete user accoutn and creates new user
//
extern char* deleteAccount(char* password);
extern char* start();
extern char* onSuccess();
extern char* hasProxyFected();
extern char* hasConfigFected();
extern void sysProxyOn();
extern void sysProxyOff();
extern char* websocketAddr();
extern char* paymentMethodsV3();
extern char* paymentMethodsV4();
extern char* proxyAll();
extern void setProxyAll(char* value);

// this method is reposible for checking if the user has updated plan or bought plans
//
extern char* hasPlanUpdatedOrBuy();
extern char* devices();
extern char* approveDevice(char* code);
extern char* removeDevice(char* deviceId);
extern char* userLinkValidate(char* code);
extern char* expiryDate();
extern char* userData();
extern char* emailAddress();
extern char* emailExists(char* email);
extern char* testProviderRequest(char* email, char* paymentProvider, char* plan);

// The function returns two C strings: the first represents success, and the second represents an error.
// If the redemption is successful, the first string contains "true", and the second string is nil.
// If an error occurs during redemption, the first string is nil, and the second string contains the error message.
//
extern char* redeemResellerCode(char* email, char* currency, char* deviceName, char* resellerCode);
extern char* referral();
extern char* myDeviceId();
extern char* lang();
extern void setSelectLang(char* lang);
extern char* country();
extern char* sdkVersion();
extern char* hasSucceedingProxy();
extern char* onBoardingStatus();
extern char* acceptedTermsVersion();
extern char* proUser();
extern char* deviceLinkingCode();
extern char* paymentRedirect(char* planID, char* currency, char* provider, char* email, char* deviceName);
extern void exitApp();
extern char* reportIssue(char* email, char* issueType, char* description);
extern char* checkUpdates();

#ifdef __cplusplus
}
#endif
