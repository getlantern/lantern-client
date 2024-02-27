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

extern void start();
extern void sysProxyOn();
extern void sysProxyOff();
extern char* selectedTab();
extern char* websocketAddr();
extern void setSelectTab(char* ttab);
extern char* plans();
extern char* paymentMethods();
extern char* userData();
extern char* serverInfo();
extern char* emailAddress();
extern char* referral();
extern char* chatEnabled();
extern char* playVersion();
extern char* storeVersion();
extern char* lang();
extern void setSelectLang(char* lang);
extern char* country();
extern char* sdkVersion();
extern char* vpnStatus();
extern char* hasSucceedingProxy();
extern char* onBoardingStatus();
extern char* acceptedTermsVersion();
extern char* proUser();
extern char* deviceLinkingCode();
extern char* paymentRedirect(char* planID, char* provider, char* email, char* deviceName);
extern char* developmentMode();
extern char* splitTunneling();
extern char* chatMe();
extern char* replicaAddr();
extern char* reportIssue(char* email, char* issueType, char* description);
extern char* checkUpdates();
extern char* purchase(GoString planID, GoString email, GoString cardNumber, GoString expDate, GoString cvc);

#ifdef __cplusplus
}
#endif
