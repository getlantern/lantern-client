#1 Disable implicit rules
.SUFFIXES:

.PHONY: codegen protos routes mocks test integration-test sourcedump build-framework build-framework-debug clean archive require-version set-version show-version reset-build-number install-gomobile assert-go-version

INTERNALSDK_FRAMEWORK_DIR = ios/internalsdk
INTERNALSDK_FRAMEWORK_NAME = Internalsdk.xcframework

%.pb.go: %.proto
	go build -o build/protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go

codegen: protos routes

# You can install the dart protoc support by running 'dart pub global activate protoc_plugin'
protos: lib/vpn/protos_shared/vpn.pb.dart internalsdk/protos/vpn.pb.go

lib/messaging/protos_flutteronly/messaging.pb.dart: protos_flutteronly/messaging.proto
	@protoc --dart_out=./lib/messaging --plugin=protoc-gen-dart=$$HOME/.pub-cache/bin/protoc-gen-dart protos_flutteronly/messaging.proto

lib/vpn/protos_shared/vpn.pb.dart: protos_shared/vpn.proto
	@protoc --dart_out=./lib/vpn --plugin=protoc-gen-dart=$$HOME/.pub-cache/bin/protoc-gen-dart protos_shared/vpn.proto

internalsdk/protos/%.pb.go: protos_shared/%.proto
	@echo "Generating Go protobuf for $<"
	@protoc --plugin=protoc-gen-go=build/protoc-gen-go \
             --go_out=internalsdk \
             $<

internalsdk/protos/vpn.pb.go: protos_shared/vpn.proto
	@protoc --go_out=internalsdk protos_shared/vpn.proto

# Compiles autorouter routes
routes: lib/core/router/router.gr.dart

lib/core/router/router.gr.dart: $(shell find lib -name \*.dart -print)
	@dart run build_runner build --delete-conflicting-outputs

test:
	@flutter test

TEST ?= *_test

# integration-test:
# 	@flutter drive --driver test_driver/integration_driver.dart --debug --flavor prod --target `ls integration_test/$(TEST).dart`

TAG ?= $$VERSION
TAG_HEAD := $(shell git rev-parse HEAD)
INSTALLER_NAME ?= lantern-installer
CHANGELOG_NAME ?= CHANGELOG.md
CHANGELOG_MIN_VERSION ?= 5.0.0

PACKAGE_MAINTAINER := Lantern Team <team@getlantern.org>
PACKAGE_VENDOR := Brave New Software Project, Inc
PACKAGE_URL := https://lantern.io

APP_DESCRIPTION := Censorship circumvention tool
APP_EXTENDED_DESCRIPTION := Lantern allows you to access sites blocked by internet censorship.\nWhen you run it, Lantern reroutes traffic to selected domains through servers located where such domains are uncensored.

get-command = $(shell which="$$(which $(1) 2> /dev/null)" && if [[ ! -z "$$which" ]]; then printf %q "$$which"; fi)

GO        := $(call get-command,go)
NODE      := $(call get-command,node)
NPM       := $(call get-command,npm)
GULP      := $(call get-command,gulp)
AWSCLI    := $(call get-command,aws)
CHANGE    := $(call get-command,git-chglog)
PIP       := $(call get-command,pip)
WGET      := $(call get-command,wget)
RUBY      := $(call get-command,ruby)
APPDMG    := $(call get-command,appdmg)
RETRY     := $(call get-command,retry)
MAGICK    := $(call get-command,magick)
MINGW     := $(call get-command,i686-w64-mingw32-gcc)
BUNDLER   := $(call get-command,bundle)
ADB       := $(call get-command,adb)
OPENSSL   := $(call get-command,openssl)
GMSAAS    := $(call get-command,gmsaas)
SENTRY    := $(call get-command,sentry-cli)
BASE64    := $(call get-command,base64)

GIT_REVISION_SHORTCODE := $(shell git rev-parse --short HEAD)
GIT_REVISION := $(shell git describe --abbrev=0 --tags --exact-match 2> /dev/null || git rev-parse --short HEAD)
GIT_REVISION_DATE := $(shell git show -s --format=%ci $(GIT_REVISION_SHORTCODE))

REVISION_DATE := $(shell date -u -j -f "%F %T %z" "$(GIT_REVISION_DATE)" +"%Y%m%d.%H%M%S" 2>/dev/null || date -u -d "$(GIT_REVISION_DATE)" +"%Y%m%d.%H%M%S")
BUILD_DATE := $(shell date -u +%Y%m%d.%H%M%S)
# We explicitly set a build-id for use in the liblantern ELF binary so that Sentry can successfully associate uploaded debug symbols with corresponding errors/crashes
BUILD_ID := 0x$(shell echo '$(REVISION_DATE)-$(BUILD_DATE)' | xxd -c 256 -ps)
export CI
CIBASE := $(shell printf "CI=$${CI:-false}" | base64)


STAGING = false
UPDATE_SERVER_URL ?=
VERSION ?= 9999.99.99
# Note - we don't bother stripping symbols or DWARF table as Android's packaging seems to take care of that for us
LDFLAGS := -X github.com/getlantern/lantern-client/internalsdk/common.RevisionDate=$(REVISION_DATE) \
-X github.com/getlantern/lantern-client/internalsdk/common.ApplicationVersion=$(VERSION) \
-X github.com/getlantern/lantern-client/internalsdk/common.BuildDate=$(BUILD_DATE)

# Ref https://pkg.go.dev/cmd/link
# -w omits the DWARF table
# -s omits the symbol table and debug info
# LD_STRIP_FLAGS := -s -w
# DISABLE_OPTIMIZATION_FLAGS := -gcflags="all=-N -l"
GOMOBILE_EXTRA_BUILD_FLAGS :=

BINARIES_PATH ?= ../lantern-binaries
BINARIES_BRANCH ?= main

BETA_BASE_NAME ?= $(INSTALLER_NAME)-preview
PROD_BASE_NAME ?= $(INSTALLER_NAME)

## secrets Keys
INTERSTITIAL_AD_UNIT=ca-app-pub-2685698271254859/9922829329
## vault secrets
VAULT_ADS_SECRETS_PATH ?= secret/googleAds

## vault keys
INTERSTITIAL_AD_UNIT_ID= INTERSTITIAL_AD_UNIT_ID

S3_BUCKET ?= lantern
FORCE_PLAY_VERSION ?= false
DEBUG_VERSION ?= $(GIT_REVISION)

# Sentry properties
SENTRY_AUTH_TOKEN=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
SENTRY_ORG=getlantern
SENTRY_PROJECT_IOS=lantern-ios

DWARF_DSYM_FOLDER_PATH=$(shell pwd)/build/ios/Release-prod-iphoneos/Runner.app.dSYM
INFO_PLIST := ios/Runner/Info.plist

APP ?= lantern
CAPITALIZED_APP := Lantern
DESKTOP_LIB_NAME ?= liblantern
DARWIN_LIB_NAME ?= $(DESKTOP_LIB_NAME).dylib
DARWIN_LIB_AMD64 ?= $(DESKTOP_LIB_NAME)_amd64.dylib
DARWIN_LIB_ARM64 ?= $(DESKTOP_LIB_NAME)_arm64.dylib
DARWIN_APP_NAME ?= $(CAPITALIZED_APP).app
INSTALLER_RESOURCES ?= installer-resources-$(APP)
INSTALLER_NAME ?= $(APP)-installer
WINDOWS_LIB_NAME ?= $(DESKTOP_LIB_NAME).dll
WINDOWS_APP_NAME ?= $(APP).exe
WINDOWS64_LIB_NAME ?= $(DESKTOP_LIB_NAME).dll
WINDOWS64_APP_NAME ?= $(APP)_x64.exe
LINUX_LIB_NAME_64 ?= $(DESKTOP_LIB_NAME).so
LINUX_LIB_NAME_32 ?= $(APP)_linux_386

APP_YAML := lantern.yaml
APP_YAML_PATH := installer-resources-lantern/$(APP_YAML)
PACKAGED_YAML := .packaged-$(APP_YAML)

ANDROID_ARCH ?= arm32

ifeq ($(ANDROID_ARCH), x86)
  ANDROID_ARCH_JAVA := x86
  ANDROID_ARCH_GOMOBILE := android/386
  APK_QUALIFIER := -x86
else ifeq ($(ANDROID_ARCH), amd64)
  ANDROID_ARCH_JAVA := x86_64
  ANDROID_ARCH_GOMOBILE := android/amd64
  APK_QUALIFIER := -x86_64
else ifeq ($(ANDROID_ARCH), arm32)
  ANDROID_ARCH_JAVA := armeabi-v7a
  ANDROID_ARCH_GOMOBILE := android/arm
  APK_QUALIFIER := -armeabi-v7a
else ifeq ($(ANDROID_ARCH), arm64)
  ANDROID_ARCH_JAVA := arm64-v8a
  ANDROID_ARCH_GOMOBILE := android/arm64
  APK_QUALIFIER := -arm64-v8a
else ifeq ($(ANDROID_ARCH), arm)
  ANDROID_ARCH_JAVA := armeabi-v7a arm64-v8a
  ANDROID_ARCH_GOMOBILE := android/arm,android/arm64
  APK_QUALIFIER :=
else ifeq ($(ANDROID_ARCH), all)
# Note - we exclude x86 because flutter does not support x86. By excluding x86
# native libs, 32 bit Intel devices will just emulate ARM.
# DO NOT ADD x86 TO THIS LIST!!
  ANDROID_ARCH_JAVA := arm64-v8a x86_64
  ANDROID_ARCH_GOMOBILE := android
  APK_QUALIFIER :=
else
  $(error unsupported ANDROID_ARCH "$(ANDROID_ARCH)")
endif

ANDROID_LIB_BASE := liblantern

MOBILE_APPID := org.getlantern.lantern

ANDROID_LIB := $(ANDROID_LIB_BASE)-$(ANDROID_ARCH).aar

BASE_MOBILE_DIR ?= .
MOBILE_DIR ?= $(BASE_MOBILE_DIR)/android
GRADLE    := $(MOBILE_DIR)/gradlew
LANTERN_CLOUD := $$GOPATH/src/github.com/getlantern/lantern-cloud
MOBILE_LIBS := $(MOBILE_DIR)/app/libs
MOBILE_ARCHS := x86 x86_64 armeabi-v7a arm64-v8a
MOBILE_ANDROID_LIB := $(MOBILE_LIBS)/$(ANDROID_LIB)
MOBILE_ANDROID_DEBUG := $(BASE_MOBILE_DIR)/build/app/outputs/apk/prod/debug/app-prod$(APK_QUALIFIER)-debug.apk
MOBILE_ANDROID_RELEASE := $(BASE_MOBILE_DIR)/build/app/outputs/apk/prod/sideload/app-prod$(APK_QUALIFIER)-sideload.apk
MOBILE_ANDROID_BUNDLE := $(BASE_MOBILE_DIR)/build/app/outputs/bundle/prodPlay/app-prod$(APK_QUALIFIER)-play.aab
MOBILE_RELEASE_APK := $(INSTALLER_NAME).apk
MOBILE_DEBUG_APK := $(INSTALLER_NAME)-$(ANDROID_ARCH)-debug.apk
MOBILE_BUNDLE := $(INSTALLER_NAME).aab
MOBILE_TEST_APK := $(BASE_MOBILE_DIR)/build/app/outputs/apk/androidTest/autoTest/debug/app-autoTest-debug-androidTest.apk
MOBILE_TESTS_APK := $(BASE_MOBILE_DIR)/build/app/outputs/apk/autoTest/debug/app-autoTest-debug.apk
CI_APK_PATH := $(BASE_MOBILE_DIR)/build/app/outputs/flutter-apk/app-prod-debug.apk
BUILD_TAGS ?=
BUILD_TAGS += ' lantern'
PROTO_SOURCES = $(shell find . -name '*.proto' -not -path './vendor/*')
GENERATED_PROTO_SOURCES = $(shell echo "$(PROTO_SOURCES)" | sed 's/\.proto/\.pb\.go/g')
GO_SOURCES := $(GENERATED_PROTO_SOURCES) go.mod go.sum $(shell find internalsdk -type f -name "*.go")
MOBILE_SOURCES := $(shell find Makefile android assets go.mod go.sum lib protos* -type f -not -path "*/libs/$(ANDROID_LIB_BASE)*" -not -iname "router.gr.dart")


.PHONY: dumpvars packages vendor android-debug do-android-release android-release do-android-bundle android-bundle android-debug-install android-release-install android-test android-cloud-test package-android

# dumpvars prints out all variables defined in the Makefile, useful for debugging environment
dumpvars:
	$(foreach v,                                        \
		$(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), \
		$(info $(v) = $($(v))))

.PHONY: tag
tag: require-version
	@(git diff-index --quiet HEAD -- || (echo "Attempted to tag dirty working tree" && exit 1)) && \
	git pull && \
	echo "Tagging..." && \
	git tag -a "$(TAG)" "$(TAG_HEAD)" -f --annotate -m"Tagged $(TAG)" && \
	git push --force-with-lease origin $(TAG) && \
	echo "Updating $(CHANGELOG_NAME)" && \
	$(CHANGE) --output $(CHANGELOG_NAME) $(CHANGELOG_MIN_VERSION)..$(TAG) && \
	git add $(CHANGELOG_NAME) && \
	git commit -m "Updated changelog for $$VERSION" && \
	git push

define fpm-debian-build =
	echo "Running fpm-debian-build" && \
	PKG_ARCH=$1 && \
	WORKDIR=$$(mktemp -dt "$$(basename $$0).XXXXXXXXXX") && \
	INSTALLER_RESOURCES=./$(INSTALLER_RESOURCES)/linux && \
	\
	mkdir -p $$WORKDIR/usr/bin && \
	mkdir -p $$WORKDIR/usr/lib/$(APP) && \
	mkdir -p $$WORKDIR/usr/share/applications && \
	mkdir -p $$WORKDIR/usr/share/icons/hicolor/128x128/apps && \
	mkdir -p $$WORKDIR/usr/share/doc/$(APP) && \
	chmod -R 755 $$WORKDIR && \
	\
	cp $$INSTALLER_RESOURCES/deb-copyright $$WORKDIR/usr/share/doc/$(APP)/copyright && \
	cp $$INSTALLER_RESOURCES/$(APP).desktop $$WORKDIR/usr/share/applications && \
	cp $$INSTALLER_RESOURCES/icon128x128on.png $$WORKDIR/usr/share/icons/hicolor/128x128/apps/$(APP).png && \
	\
	cp build/linux/$$PKG_ARCH/release/bundle/$(APP) $$WORKDIR/usr/lib/$(APP)/$(APP)-binary && \
	cp $$INSTALLER_RESOURCES/$(APP).sh $$WORKDIR/usr/lib/$(APP) && \
	\
	chmod -x $$WORKDIR/usr/lib/$(APP)/$(APP)-binary && \
	chmod +x $$WORKDIR/usr/lib/$(APP)/$(APP).sh && \
	\
	ln -s /usr/lib/$(APP)/$(APP).sh $$WORKDIR/usr/bin/$(APP) && \
	rm -f $$WORKDIR/usr/lib/$(APP)/$(PACKAGED_YAML) && \
	rm -f $$WORKDIR/usr/lib/$(APP)/$(APP_YAML) && \
	cp $(INSTALLER_RESOURCES)/$(PACKAGED_YAML) $$WORKDIR/usr/lib/$(APP)/$(PACKAGED_YAML) && \
	cp $(APP_YAML_PATH) $$WORKDIR/usr/lib/$(APP)/$(APP_YAML) && \
	\
	cat $$WORKDIR/usr/lib/$(APP)/$(APP)-binary | bzip2 > $(APP)_update_linux_$$PKG_ARCH.bz2 && \
	bundle install && \
	fpm -a $$PKG_ARCH -s dir -t deb -n $(APP) -v $$VERSION -m "$(PACKAGE_MAINTAINER)" --description "$(APP_DESCRIPTION)\n$(APP_EXTENDED_DESCRIPTION)" --category net --license "Apache-2.0" --vendor "$(PACKAGE_VENDOR)" --url $(PACKAGE_URL) --deb-compression gz -f -C $$WORKDIR usr;
endef

define osxcodesign
	codesign --options runtime --strict --timestamp --force --deep -s "Developer ID Application: Innovate Labs LLC (4FYC28AXA2)" -v $(1)
endef

guard-%:
	 @ if [ -z '${${*}}' ]; then echo 'Environment variable $* not set' && exit 1; fi

.PHONY: require-app
require-app: guard-APP

.PHONY: require-version
require-version: guard-VERSION

.PHONY: require-sentry-auth-token
require-secrets-dir: guard-SENTRY_AUTH_TOKEN

.PHONY: require-secrets-dir
require-secrets-dir: guard-SECRETS_DIR

.PHONY: require-release-track
require-release-track: guard-APK_RELEASE_TRACK

.PHONY: require-lantern-binaries
require-lantern-binaries:
	@if [[ ! -d "$(BINARIES_PATH)" ]]; then \
		echo "Missing binaries repository directory at $(BINARIES_PATH) (such as /Users/home/go/getlantern/lantern-binaries). Set it with BINARIES_PATH=\"/path/to/repository\" make ..." && \
		exit 1; \
	fi

$(GO):
	@echo 'Missing "$(GO)" command.'; exit 1;

.PHONY: require-awscli
require-awscli:
	@if [[ -z "$(AWSCLI)" ]]; then echo 'Missing "aws" command. Use "brew install awscli" or see https://aws.amazon.com/cli/'; exit 1; fi && \
	if [[ -z "$$($(AWSCLI) configure list | grep _key)" ]]; then echo 'Run "aws configure" first'; exit 1; fi

.PHONY: require-s3cmd
require-s3cmd:
	@if [[ -z "s3cmd" ]]; then echo 'Missing "s3cmd" command. Use "brew install s3cmd" or see https://github.com/s3tools/s3cmd/blob/master/INSTALL'; exit 1; fi

.PHONY: require-changelog
require-changelog:
	@if [[ -z "$(CHANGE)" ]]; then echo 'Missing "git-chglog" command. See https://github.com/git-chglog/git-chglog'; exit 1; fi

.PHONY: require-pip
require-pip:
	@if [[ -z "$(PIP)" ]]; then echo 'Missing "pip" command. Use "brew install pip"'; exit 1; fi

.PHONY: require-wget
require-wget:
	@if [[ -z "$(WGET)" ]]; then echo 'Missing "wget" command.'; exit 1; fi

.PHONY: require-magick
require-magick:
	@if [[ -z "$(MAGICK)" ]]; then echo 'Missing "magick" command. Try brew install imagemagick.'; exit 1; fi

.PHONY: require-mingw
require-mingw:
	@if [[ -z "$(MINGW)" ]]; then echo 'Missing "mingw" command. Try "brew install mingw-w64."'; exit 1; fi

.PHONY: require-sentry
require-sentry:
	@if [[ -z "$(SENTRY)" ]]; then echo 'Missing "sentry-cli" command. See sentry.io for installation instructions.'; exit 1; fi

.PHONY: require-appdmg
require-appdmg:
	@if [[ -z "$(APPDMG)" ]]; then echo 'Missing "appdmg" command. Try sudo npm install -g appdmg.'; exit 1; fi

.PHONY: require-retry
require-retry:
	@if [[ -z "$(RETRY)" ]]; then echo 'Missing retry command. Try go install github.com/joshdk/retry'; exit 1; fi

release-autoupdate: require-version
	@curl https://s3.amazonaws.com/lantern/lantern-installer.apk | bzip2 > update_android_arm.bz2 && \
	$(RUBY) ./create_or_update_release.rb getlantern lantern $$VERSION update_android_arm.bz2

release: require-version require-s3cmd require-wget require-lantern-binaries require-release-track release-prod copy-beta-installers-to-mirrors invalidate-getlantern-dot-org upload-aab-to-play

$(ANDROID_LIB): $(GO_SOURCES)
	go env -w 'GOPRIVATE=github.com/getlantern/*' && \
	go install golang.org/x/mobile/cmd/gomobile && \
	gomobile init && \
	gomobile bind \
	    -target=$(ANDROID_ARCH_GOMOBILE) \
		-tags='headless lantern' -o=$(ANDROID_LIB) \
		-androidapi=23 \
		-ldflags="-s -w $(LDFLAGS)" \
		$(GOMOBILE_EXTRA_BUILD_FLAGS) \
		github.com/getlantern/lantern-client/internalsdk github.com/getlantern/pathdb/testsupport github.com/getlantern/pathdb/minisql

$(MOBILE_ANDROID_LIB): $(ANDROID_LIB)
	mkdir -p $(MOBILE_LIBS) && cp $(ANDROID_LIB) $(MOBILE_ANDROID_LIB)

.PHONY: android-lib appium-test-build
android-lib: $(MOBILE_ANDROID_LIB)

appium-test-build:
	flutter build apk --flavor=appiumTest --dart-define=app.flavor=appiumTest --debug

appium-ios-ipa:
	flutter build ipa --flavor=appiumTest --dart-define=app.flavor=appiumTest --profile

appium-ios-build:
	flutter build ios --flavor=appiumTest --dart-define=app.flavor=appiumTest --profile

$(MOBILE_TEST_APK) $(MOBILE_TESTS_APK): $(MOBILE_SOURCES) $(MOBILE_ANDROID_LIB)
	@$(GRADLE) -PandroidArch=$(ANDROID_ARCH) \
		-PandroidArchJava="$(ANDROID_ARCH_JAVA)" \
		-b $(MOBILE_DIR)/app/build.gradle \
		:app:assembleAutoTestDebug :app:assembleAutoTestDebugAndroidTest

dart-defines-debug:
	@DART_DEFINES="$(CIBASE)"; \
	printf "$$DART_DEFINES"

do-android-debug: $(MOBILE_SOURCES) $(MOBILE_ANDROID_LIB) ffigen
	@ln -fs $(MOBILE_DIR)/gradle.properties . && \
	DART_DEFINES=`make dart-defines-debug` && \
	echo "Value of DART_DEFINES is: $$DART_DEFINES" && \
	CI="$$CI" && \
	echo "Value of CI is: $$CI" && \
    $(GRADLE) -Pdart-defines="$$DART_DEFINES" -PlanternVersion=$(DEBUG_VERSION) \
	-PproServerUrl=$(PRO_SERVER_URL) -PpaymentProvider=$(PAYMENT_PROVIDER) -Pcountry=$(COUNTRY) \
	-PplayVersion=$(FORCE_PLAY_VERSION) -PuseStaging=$(STAGING) -PstickyConfig=$(STICKY_CONFIG) \
	-PlanternRevisionDate=$(REVISION_DATE) -PandroidArch=$(ANDROID_ARCH) \
	-PandroidArchJava="$(ANDROID_ARCH_JAVA)" -PdevelopmentMode="true" \
	-Pci=$(CI) -b $(MOBILE_DIR)/app/build.gradle assembleProdDebug

pubget:
	@flutter pub get

$(MOBILE_DEBUG_APK): $(MOBILE_SOURCES) $(GO_SOURCES)
	make do-android-debug && \
	cp $(MOBILE_ANDROID_DEBUG) $(MOBILE_DEBUG_APK)

$(MOBILE_RELEASE_APK): $(MOBILE_SOURCES) $(GO_SOURCES) $(MOBILE_ANDROID_LIB) require-sentry require-sentry-auth-token
	echo $(MOBILE_ANDROID_LIB) && \
	mkdir -p ~/.gradle && \
	ln -fs $(MOBILE_DIR)/gradle.properties . && \
	COUNTRY="$$COUNTRY" && \
	STAGING="$$STAGING" && \
	STICKY_CONFIG="$$STICKY_CONFIG" && \
	PAYMENT_PROVIDER="$$PAYMENT_PROVIDER" && \
	VERSION_CODE="$$VERSION_CODE" && \
	DEVELOPMENT_MODE="$$DEVELOPMENT_MODE" && \
	$(GRADLE) -PlanternVersion=$$VERSION -PlanternRevisionDate=$(REVISION_DATE) -PandroidArch=$(ANDROID_ARCH) \
	-PandroidArchJava="$(ANDROID_ARCH_JAVA)" -PproServerUrl=$(PRO_SERVER_URL) -PpaymentProvider=$(PAYMENT_PROVIDER) \
	-Pcountry=$(COUNTRY) -PplayVersion=$(FORCE_PLAY_VERSION) -PuseStaging=$(STAGING) -PstickyConfig=$(STICKY_CONFIG) \
	-PversionCode=$(VERSION_CODE) -PdevelopmentMode=$(DEVELOPMENT_MODE) -b $(MOBILE_DIR)/app/build.gradle assembleProdSideload && \
	sentry-cli upload-dif --wait -o getlantern -p android build/app/intermediates/merged_native_libs/prodSideload/out/lib && \
	cp $(MOBILE_ANDROID_RELEASE) $(MOBILE_RELEASE_APK) && \
	cat $(MOBILE_RELEASE_APK) | bzip2 > lantern_update_android_arm.bz2


$(MOBILE_BUNDLE): $(MOBILE_SOURCES) $(GO_SOURCES) $(MOBILE_ANDROID_LIB) require-sentry
	@mkdir -p ~/.gradle && \
	ln -fs $(MOBILE_DIR)/gradle.properties . && \
	COUNTRY="$$COUNTRY" && \
	STAGING="$$STAGING" && \
	STICKY_CONFIG="$$STICKY_CONFIG" && \
	PAYMENT_PROVIDER="$$PAYMENT_PROVIDER" && \
	$(GRADLE) -PlanternVersion=$$VERSION -PlanternRevisionDate=$(REVISION_DATE) -PandroidArch=$(ANDROID_ARCH) -PandroidArchJava="$(ANDROID_ARCH_JAVA)" \
	-PproServerUrl=$(PRO_SERVER_URL) -PpaymentProvider=$(PAYMENT_PROVIDER) \
	-Pcountry=$(COUNTRY) -PplayVersion=true -PuseStaging=$(STAGING) -PstickyConfig=$(STICKY_CONFIG) -b $(MOBILE_DIR)/app/build.gradle bundlePlay && \
	sentry-cli upload-dif --wait -o getlantern -p android build/app/intermediates/merged_native_libs/prodPlay/out/lib && \
	cp $(MOBILE_ANDROID_BUNDLE) $(MOBILE_BUNDLE)

android-debug: $(MOBILE_DEBUG_APK)

android-release: pubget $(MOBILE_RELEASE_APK)

set-version:
	@echo "Setting the CFBundleShortVersionString to $(VERSION)"
	@cd ios && agvtool new-marketing-version $(VERSION)
	@echo "Incrementing the build number..."
	@CURRENT_BUILD=$$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" $(INFO_PLIST)); \
	NEXT_BUILD=$$(($$CURRENT_BUILD + 1)); \
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $$NEXT_BUILD" $(INFO_PLIST)


ios-release:set-version build-framework
	@echo "Creating the Flutter iOS build..."
	flutter build ipa --flavor prod --release
	@echo "Uploading debug symbols to Sentry..."
	export SENTRY_LOG_LEVEL=info
	sentry-cli --auth-token $(SENTRY_AUTH_TOKEN) upload-dif --include-sources --org $(SENTRY_ORG) --project $(SENTRY_PROJECT_IOS) $(DWARF_DSYM_FOLDER_PATH)
	@IPA_PATH=$(shell pwd)/build/ios/ipa; \
	echo "iOS IPA generated under: $$IPA_PATH"; \
	open "$$IPA_PATH"

.PHONY: echo-build-tags
echo-build-tags: ## Prints build tags and extra ldflags. Run this with `REPLICA=1 make echo-build-tags` for example to see how it changes
	@if [[ -z "$$VERSION" ]]; then \
		echo "** VERSION was not set, using default version. This is OK while in development."; \
	fi
	@echo "Build tags: $(BUILD_TAGS)"
	@echo "Extra ldflags: $(EXTRA_LDFLAGS)"
	@echo "Library name: $(LIB_NAME)"
	@if [[ "$$GOOS" ]]; then echo "GOOS: $(GOOS)"; fi
	@if [[ "$$GOARCH" ]]; then echo "GOARCH: $(GOARCH)"; fi
	@if [[ "$$CC" ]]; then echo "CC: $(CC)"; fi
	@if [[ "$$CXX" ]]; then echo "CXX: $(CXX)"; fi

.PHONY: desktop-lib ffigen

desktop-lib: export GOPRIVATE = github.com/getlantern
desktop-lib: export CGO_ENABLED = 1
desktop-lib: echo-build-tags
	go build -trimpath $(GO_BUILD_FLAGS) -o "$(LIB_NAME)" -tags="$(BUILD_TAGS)" -ldflags="$(LDFLAGS) $(EXTRA_LDFLAGS)" desktop/lib.go

ffigen:
	dart run ffigen --config ffigen.yaml

.PHONY: linux-amd64
linux-amd64: $(LINUX_LIB_NAME_64) ## Build lantern for linux-amd64

.PHONY: package-linux-x64
package-linux-x64: require-version
	@$(call fpm-debian-build,"x64")
	@echo "-> $(APP)_$(VERSION)_x64.deb"

.PHONY: package-linux-arm64
package-linux-amd64: require-version
	@$(call fpm-debian-build,"arm64")
	@echo "-> $(APP)_$(VERSION)_arm64.deb"

$(LINUX_LIB_NAME_64): export GOOS = linux
$(LINUX_LIB_NAME_64): export GOARCH = amd64
$(LINUX_LIB_NAME_64): export LIB_NAME = $(LINUX_LIB_NAME_64)
$(LINUX_LIB_NAME_64): export EXTRA_LDFLAGS += -linkmode external -s -w
$(LINUX_LIB_NAME_64): export GO_BUILD_FLAGS += -a -buildmode=c-shared
$(LINUX_LIB_NAME_64): export Environment = production
$(LINUX_LIB_NAME_64): desktop-lib

.PHONY: windows
windows: require-mingw $(WINDOWS_LIB_NAME) ## Build lantern for windows

$(WINDOWS_LIB_NAME): export CXX = i686-w64-mingw32-g++
$(WINDOWS_LIB_NAME): export CC = i686-w64-mingw32-gcc
$(WINDOWS_LIB_NAME): export CGO_LDFLAGS = -static
$(WINDOWS_LIB_NAME): export GOOS = windows
$(WINDOWS_LIB_NAME): export GOARCH = 386
$(WINDOWS_LIB_NAME): export LIB_NAME = $(WINDOWS_LIB_NAME)
$(WINDOWS_LIB_NAME): export BUILD_TAGS += walk_use_cgo
$(WINDOWS_LIB_NAME): export EXTRA_LDFLAGS +=
$(WINDOWS_LIB_NAME): export GO_BUILD_FLAGS += -a -buildmode=c-shared
$(WINDOWS_LIB_NAME): export BUILD_RACE =
$(WINDOWS_LIB_NAME): export Environment = production
$(WINDOWS_LIB_NAME): desktop-lib

.PHONY: windows64
windows64: require-mingw $(WINDOWS64_LIB_NAME) ## Build lantern for windows

$(WINDOWS64_LIB_NAME): export CXX = x86_64-w64-mingw32-g++
$(WINDOWS64_LIB_NAME): export CC = x86_64-w64-mingw32-gcc
$(WINDOWS64_LIB_NAME): export CGO_LDFLAGS = -static
$(WINDOWS64_LIB_NAME): export GOOS = windows
$(WINDOWS64_LIB_NAME): export GOARCH = amd64
$(WINDOWS64_LIB_NAME): export LIB_NAME = $(WINDOWS64_LIB_NAME)
$(WINDOWS64_LIB_NAME): export BUILD_TAGS += walk_use_cgo
$(WINDOWS64_LIB_NAME): export EXTRA_LDFLAGS +=
$(WINDOWS64_LIB_NAME): export GO_BUILD_FLAGS += -a -buildmode=c-shared
$(WINDOWS64_LIB_NAME): export BUILD_RACE =
$(WINDOWS64_LIB_NAME): desktop-lib

## Darwin
.PHONY: darwin-amd64
darwin-amd64: $(DARWIN_LIB_AMD64)
$(DARWIN_LIB_AMD64): export LIB_NAME = $(DARWIN_LIB_AMD64)
$(DARWIN_LIB_AMD64): export GOOS = darwin
$(DARWIN_LIB_AMD64): export GOARCH = amd64
$(DARWIN_LIB_AMD64): export GO_BUILD_FLAGS += -a -buildmode=c-shared
$(DARWIN_LIB_AMD64): export EXTRA_LDFLAGS += -s
$(DARWIN_LIB_AMD64): desktop-lib

.PHONY: darwin-arm64
darwin-arm64: $(DARWIN_LIB_ARM64)
$(DARWIN_LIB_ARM64): export LIB_NAME = $(DARWIN_LIB_ARM64)
$(DARWIN_LIB_ARM64): export GOOS = darwin
$(DARWIN_LIB_ARM64): export GOARCH = arm64
$(DARWIN_LIB_ARM64): export GO_BUILD_FLAGS += -a -buildmode=c-shared
$(DARWIN_LIB_ARM64): export EXTRA_LDFLAGS += -s
$(DARWIN_LIB_ARM64): desktop-lib

.PHONY: darwin
darwin: darwin-arm64
	make darwin-amd64
	lipo \
		-create \
		${DESKTOP_LIB_NAME}_arm64.dylib \
		${DESKTOP_LIB_NAME}_amd64.dylib \
		-output ${DARWIN_LIB_NAME}
	install_name_tool -id "@rpath/${DARWIN_LIB_NAME}" ${DARWIN_LIB_NAME}
	rm ${DESKTOP_LIB_NAME}_arm64.h && mv ${DESKTOP_LIB_NAME}_amd64.h ${DESKTOP_LIB_NAME}.h

$(INSTALLER_NAME).dmg: require-version require-appdmg require-retry require-magick
	@echo "Generating distribution package for darwin/amd64..." && \
	if [[ "$$(uname -s)" == "Darwin" ]]; then \
		INSTALLER_RESOURCES="$(INSTALLER_RESOURCES)/darwin" && \
		DARWIN_APP_NAME="build/macos/Build/Products/Release/Lantern.app" && \
		ls $$DARWIN_APP_NAME && \
		cp $(DARWIN_LIB_NAME) $$DARWIN_APP_NAME/Contents/Frameworks && \
		$(call osxcodesign,$$DARWIN_APP_NAME/Contents/Frameworks/liblantern.dylib) && \
		$(call osxcodesign,$$DARWIN_APP_NAME/Contents/MacOS/Lantern) && \
		$(call osxcodesign,$$DARWIN_APP_NAME) && \
		rm -rf $(INSTALLER_NAME).dmg && \
		sed "s/__VERSION__/$$VERSION/g" $$INSTALLER_RESOURCES/dmgbackground.svg > $$INSTALLER_RESOURCES/dmgbackground_versioned.svg && \
		$(MAGICK) -size 600x400 $$INSTALLER_RESOURCES/dmgbackground_versioned.svg $$INSTALLER_RESOURCES/dmgbackground.png && \
		sed "s/__VERSION__/$$VERSION/g" $$INSTALLER_RESOURCES/$(APP).dmg.json > $$INSTALLER_RESOURCES/$(APP)_versioned.dmg.json && \
		retry -attempts 5 $(APPDMG) --quiet $$INSTALLER_RESOURCES/$(APP)_versioned.dmg.json $(INSTALLER_NAME).dmg && \
		mv $(INSTALLER_NAME).dmg $(CAPITALIZED_APP).dmg.zlib && \
		hdiutil convert -quiet -format UDBZ -o $(INSTALLER_NAME).dmg $(CAPITALIZED_APP).dmg.zlib && \
		$(call osxcodesign,$(INSTALLER_NAME).dmg) && \
		rm $(CAPITALIZED_APP).dmg.zlib; \
	else \
		echo "-> Skipped: Can not generate a package on a non-OSX host."; \
	fi;

.PHONY: darwin-installer
darwin-installer: $(INSTALLER_NAME).dmg

.PHONY: notarize-darwin
notarize-darwin: require-ac-username require-ac-password
	@echo "Notarizing distribution package for darwin/amd64..." && \
	if [[ "$$(uname -s)" == "Darwin" ]]; then \
		./$(INSTALLER_RESOURCES)/tools/notarize-darwin.py \
		  -u $$AC_USERNAME \
		  -p $$AC_PASSWORD \
		  -a 4FYC28AXA2 \
		  $(INSTALLER_NAME).dmg; \
	else \
		echo "-> Skipped: Can not notarize a package on a non-OSX host."; \
	fi;

.PHONY: require-ac-username
require-ac-username: guard-AC_USERNAME ## App Store Connect username - needed for notarizing macOS apps.

.PHONY: require-ac-password
require-ac-password: guard-AC_PASSWORD ## App Store Connect password - needed for notarizing macOS apps. It is recommended that this be stored in the keychain and provided like `security find-generic-password -s <password-name> -w`. This must be an "app-specific password". See https://support.apple.com/en-us/HT204397.

.PHONY: require-bundler
require-bundler:
	@if [ "$(BUNDLER)" = "" ]; then \
		echo "Missing 'bundle' command. See https://rubygems.org/gems/bundler/versions/1.16.1 or just gem install bundler -v '1.16.1'" && exit 1; \
	fi

.PHONY: package-darwin
package-darwin: darwin-installer notarize-darwin

android-bundle: $(MOBILE_BUNDLE)

android-debug-install: $(MOBILE_DEBUG_APK)
	$(ADB) uninstall $(MOBILE_APPID) ; $(ADB) install -r $(MOBILE_DEBUG_APK)

android-release-install: $(MOBILE_RELEASE_APK)
	$(ADB) install -r $(MOBILE_RELEASE_APK)

package-android: pubget require-version
	@ANDROID_ARCH=all make android-release && \
	ANDROID_ARCH=all make android-bundle && \
	echo "-> $(MOBILE_RELEASE_APK)"

upload-aab-to-play: require-release-track require-pip
	@echo "Uploading APK to Play store on $$APK_RELEASE_TRACK release track.." && \
	s3cmd get --force s3://$(S3_BUCKET)/$(PROD_BASE_NAME).aab $(PROD_BASE_NAME).aab && \
	pip install --upgrade google-api-python-client && \
	python upload_apk.py "$$APK_RELEASE_TRACK" $(PROD_BASE_NAME).aab

changelog: require-version require-changelog require-app
	@TAG_COMMIT=$$(git rev-list --abbrev-commit -1 $(TAG)) && \
	if [[ -z "$$TAG_COMMIT" ]]; then \
		echo "Could not find given tag $(TAG)."; \
	fi && \
	cd  && \
	$(call changelog,flashlight)

# Creates a dump of the source code lantern-android-sources-<version>.tar.gz
sourcedump: require-version
	here=`pwd` && \
	rm -Rf /tmp/lantern-client ; \
	mkdir -p /tmp/lantern-client && \
	cp -R LICENSE LICENSING.md android internalsdk lib protos* go.mod go.sum /tmp/lantern-client && \
	cd /tmp/lantern-client && \
	find . -name "*_test.go" -exec rm {} \; && \
	find . -name "*.jks" -exec rm {} \; && \
	rm -Rf android/.idea android/sentry.properties android/.settings android/local.properties android/app/.classpath android/app/.project android/app/.settings android/app/src/androidTest android/app/src/test android/app/src/main/res android/app/libs android/.gradle android/alipaySdk-15.6.5-20190718211148/ android/app/bin android/app/.cxx android/app/google-services.json && \
	go mod tidy && \
	go mod vendor && \
	find . -name "CHANGELOG*" -exec rm {} \; && \
	rm -Rf vendor/github.com/getlantern/flashlight/v7/embeddedconfig vendor/github.com/getlantern/flashlight/v7/genconfig && \
	find vendor/github.com/getlantern -name "*.go" -exec perl -pi -e 's/"https?\:\/\/[^"]+/"URL_HIDDEN/g' {} \; && \
	find vendor/github.com/getlantern -name LICENSE -exec rm {} \; && \
	tar -czf $$here/lantern-android-sources-$$VERSION.tar.gz .

build-framework: assert-go-version install-gomobile
	@echo "Nuking $(INTERNALSDK_FRAMEWORK_DIR) and $(MINISQL_FRAMEWORK_DIR)"
	rm -Rf $(INTERNALSDK_FRAMEWORK_DIR) $(MINISQL_FRAMEWORK_DIR)
	@echo "generating Ios.xcFramework"
	go env -w 'GOPRIVATE=github.com/getlantern/*' && \
	gomobile init && \
	gomobile bind -target=ios,iossimulator \
	-tags='headless lantern ios netgo' \
	-ldflags="$(LDFLAGS)"  \
    		$(GOMOBILE_EXTRA_BUILD_FLAGS) \
    		github.com/getlantern/lantern-client/internalsdk github.com/getlantern/pathdb/testsupport github.com/getlantern/pathdb/minisql github.com/getlantern/lantern-client/internalsdk/ios
	@echo "moving framework"
	mkdir -p $(INTERNALSDK_FRAMEWORK_DIR)
	mv ./$(INTERNALSDK_FRAMEWORK_NAME) $(INTERNALSDK_FRAMEWORK_DIR)/$(INTERNALSDK_FRAMEWORK_NAME)


install-gomobile:
	@echo "installing gomobile" && \
	go install golang.org/x/mobile/cmd/gomobile@latest

assert-go-version:
	@if go version | grep -q -v $(GO_VERSION); then echo "go $(GO_VERSION) is required." && exit 1; fi

.PHONY: swift-format
swift-format:
	swift-format --in-place --recursive DBModule ios/Runner ios/Tunnel ios/LanternTests

clean:
	rm -f liblantern*.aar && \
	rm -f $(MOBILE_LIBS)/liblantern-* && \
	rm -Rf android/app/build && \
	rm -Rf *.aab && \
	rm -Rf *.apk && \
	rm -f `which gomobile` && \
	rm -f `which gobind`
	rm -Rf "$(FLASHLIGHT_FRAMEWORK_PATH)" "$(INTERMEDIATE_FLASHLIGHT_FRAMEWORK_PATH)"
