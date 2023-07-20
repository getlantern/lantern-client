#1 Disable implicit rules
.SUFFIXES:

.PHONY: codegen protos routes mocks test integration-test sourcedump build-framework build-framework-debug clean archive require-version set-version show-version reset-build-number install-gomobile assert-go-version

FRAMEWORK_DIR = /Users/jigarfumakiya/Documents/getlantern/mobile_app/android-lantern/ios/internalsdk

FRAMEWORK_NAME = Internalsdk.xcframework

codegen: protos routes

# You can install the dart protoc support by running 'dart pub global activate protoc_plugin'
protos: lib/messaging/protos_flutteronly/messaging.pb.dart lib/vpn/protos_shared/vpn.pb.dart

lib/messaging/protos_flutteronly/messaging.pb.dart: protos_flutteronly/messaging.proto
	@protoc --dart_out=./lib/messaging --plugin=protoc-gen-dart=$$HOME/.pub-cache/bin/protoc-gen-dart protos_flutteronly/messaging.proto

lib/vpn/protos_shared/vpn.pb.dart: protos_shared/vpn.proto
	@protoc --dart_out=./lib/vpn --plugin=protoc-gen-dart=$$HOME/.pub-cache/bin/protoc-gen-dart protos_shared/vpn.proto

# Compiles autorouter routes
routes: lib/core/router/router.gr.dart

lib/core/router/router.gr.dart: $(shell find lib -name \*.dart -print)
	@flutter packages pub run build_runner build --delete-conflicting-outputs

test:
	@flutter test

TEST ?= *_test

# integration-test:
# 	@flutter drive --driver test_driver/integration_driver.dart --debug --flavor prod --target `ls integration_test/$(TEST).dart`

GO_VERSION := 1.19

TAG ?= $$VERSION
TAG_HEAD := $(shell git rev-parse HEAD)
INSTALLER_NAME ?= lantern-installer
CHANGELOG_NAME ?= CHANGELOG.md
CHANGELOG_MIN_VERSION ?= 5.0.0

get-command = $(shell which="$$(which $(1) 2> /dev/null)" && if [[ ! -z "$$which" ]]; then printf %q "$$which"; fi)

GO        := $(call get-command,go)
NODE      := $(call get-command,node)
NPM       := $(call get-command,npm)
GULP      := $(call get-command,gulp)
AWSCLI    := $(call get-command,aws)
CHANGE    := $(call get-command,git-chglog)
PIP       := $(call get-command,pip)
WGET      := $(call get-command,wget)
APPDMG    := $(call get-command,appdmg)
MAGICK    := $(call get-command,magick)
BUNDLER   := $(call get-command,bundle)
ADB       := $(call get-command,adb)
OPENSSL   := $(call get-command,openssl)
GMSAAS    := $(call get-command,gmsaas)
SENTRY    := $(call get-command,sentry-cli)

GIT_REVISION_SHORTCODE := $(shell git rev-parse --short HEAD)
GIT_REVISION := $(shell git describe --abbrev=0 --tags --exact-match 2> /dev/null || git rev-parse --short HEAD)
GIT_REVISION_DATE := $(shell git show -s --format=%ci $(GIT_REVISION_SHORTCODE))

REVISION_DATE := $(shell date -u -j -f "%F %T %z" "$(GIT_REVISION_DATE)" +"%Y%m%d.%H%M%S" 2>/dev/null || date -u -d "$(GIT_REVISION_DATE)" +"%Y%m%d.%H%M%S")
BUILD_DATE := $(shell date -u +%Y%m%d.%H%M%S)
# We explicitly set a build-id for use in the liblantern ELF binary so that Sentry can successfully associate uploaded debug symbols with corresponding errors/crashes
BUILD_ID := 0x$(shell echo '$(REVISION_DATE)-$(BUILD_DATE)' | xxd -c 256 -ps)
export CI
CIBASE := $(shell printf "CI=$$CI" | base64)

STAGING = false
UPDATE_SERVER_URL ?=
VERSION ?= 9999.99.99
# Note - we don't bother stripping symbols or DWARF table as Android's packaging seems to take care of that for us
LDFLAGS := -X github.com/getlantern/android-lantern/internalsdk.RevisionDate=$(REVISION_DATE) -X github.com/getlantern/android-lantern/internalsdk.ApplicationVersion=$(VERSION) -X github.com/getlantern/flashlight/v7/common.StagingMode=$(STAGING)

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

S3_BUCKET ?= lantern
FORCE_PLAY_VERSION ?= false
DEBUG_VERSION ?= $(GIT_REVISION)

# By default, build APKs containing support for ARM only 32 bit. Since we're using multi-architecture
# app bundles for play store, we no longer need to include 64 bit in our APKs that we distribute.
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
  ANDROID_ARCH_JAVA := armeabi-v7a arm64-v8a x86_64
  ANDROID_ARCH_GOMOBILE := android/arm,android/arm64,android/amd64
  APK_QUALIFIER :=
else
  $(error unsupported ANDROID_ARCH "$(ANDROID_ARCH)")
endif

ANDROID_LIB_PKG := github.com/getlantern/android-lantern/internalsdk
ANDROID_LIB_BASE := liblantern

MOBILE_APPID := org.getlantern.lantern

ANDROID_LIB := $(ANDROID_LIB_BASE)-$(ANDROID_ARCH).aar

BASE_MOBILE_DIR ?= .
MOBILE_DIR ?= $(BASE_MOBILE_DIR)/android
GRADLE    := $(MOBILE_DIR)/gradlew
MOBILE_LIBS := $(MOBILE_DIR)/app/libs
MOBILE_ARCHS := x86 x86_64 armeabi-v7a arm64-v8a
MOBILE_ANDROID_LIB := $(MOBILE_LIBS)/$(ANDROID_LIB)
MOBILE_ANDROID_DEBUG := $(BASE_MOBILE_DIR)/build/app/outputs/apk/prod/debug/app-prod$(APK_QUALIFIER)-debug.apk
MOBILE_ANDROID_RELEASE := $(BASE_MOBILE_DIR)/build/app/outputs/apk/prod/sideload/app-prod$(APK_QUALIFIER)-sideload.apk
MOBILE_ANDROID_BUNDLE := $(BASE_MOBILE_DIR)/build/app/outputs/bundle/prodPlay/app-prod$(APK_QUALIFIER)-play.aab
MOBILE_RELEASE_APK := $(INSTALLER_NAME)-$(ANDROID_ARCH).apk
MOBILE_DEBUG_APK := $(INSTALLER_NAME)-$(ANDROID_ARCH)-debug.apk
MOBILE_BUNDLE := lantern-$(ANDROID_ARCH).aab
MOBILE_TEST_APK := $(BASE_MOBILE_DIR)/build/app/outputs/apk/androidTest/autoTest/debug/app-autoTest-debug-androidTest.apk
MOBILE_TESTS_APK := $(BASE_MOBILE_DIR)/build/app/outputs/apk/autoTest/debug/app-autoTest-debug.apk

BUILD_TAGS ?=
BUILD_TAGS += ' lantern'

GO_SOURCES := go.mod go.sum $(shell find internalsdk -type f -name "*.go")
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

define check-go-version
    if [ -z '${IGNORE_GO_VERSION}' ] && go version | grep -q -v $(GO_VERSION); then \
		echo "go $(GO_VERSION) is required." && exit 1; \
	fi
endef

guard-%:
	 @ if [ -z '${${*}}' ]; then echo 'Environment variable $* not set' && exit 1; fi

.PHONY: require-app
require-app: guard-APP

.PHONY: require-version
require-version: guard-VERSION

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

.PHONY: require-sentry
require-sentry:
	@if [[ -z "$(SENTRY)" ]]; then echo 'Missing "sentry-cli" command. See sentry.io for installation instructions.'; exit 1; fi

release-qa: require-version require-s3cmd
	@BASE_NAME="$(INSTALLER_NAME)-internal" && \
	VERSION_FILE_NAME="version-qa-android.txt" && \
	rm -f $$BASE_NAME* && \
	cp $(INSTALLER_NAME)-arm32.apk $$BASE_NAME.apk && \
	cp lantern-all.aab $$BASE_NAME.aab && \
	echo "Uploading installer packages and shasums" && \
	for NAME in $$(ls -1 $$BASE_NAME*.*); do \
		shasum -a 256 $$NAME | cut -d " " -f 1 > $$NAME.sha256 && \
		echo "Uploading SHA-256 `cat $$NAME.sha256`" && \
		s3cmd put -P $$NAME.sha256 s3://$(S3_BUCKET) && \
		echo "Uploading $$NAME to S3" && \
		s3cmd put -P $$NAME s3://$(S3_BUCKET) && \
		SUFFIX=$$(echo "$$NAME" | sed s/$$BASE_NAME//g) && \
		VERSIONED=$(INSTALLER_NAME)-$$VERSION$$SUFFIX && \
		echo "Copying $$VERSIONED" && \
		s3cmd cp s3://$(S3_BUCKET)/$$NAME s3://$(S3_BUCKET)/$$VERSIONED && \
		echo "Copied $$VERSIONED ... setting acl to public" && \
		s3cmd setacl s3://$(S3_BUCKET)/$$VERSIONED --acl-public; \
	done && \
	echo "Setting content types for installer packages" && \
	for NAME in $$BASE_NAME.apk $(INSTALLER_NAME)-$$VERSION.apk $$BASE_NAME.aab ; do \
		s3cmd modify --add-header='content-type':'application/vnd.android.package-archive' s3://$(S3_BUCKET)/$$NAME; \
	done && \
	for NAME in update_android_arm ; do \
		cp lantern_$$NAME.bz2 lantern_$$NAME-$$VERSION.bz2 && \
		echo "Copying versioned name lantern_$$NAME-$$VERSION.bz2..." && \
		s3cmd put -P lantern_$$NAME-$$VERSION.bz2 s3://$(S3_BUCKET); \
	done && \
	echo $$VERSION > $$VERSION_FILE_NAME && \
	s3cmd put -P $$VERSION_FILE_NAME s3://$(S3_BUCKET) && \
	echo "Wrote $$VERSION_FILE_NAME as $$(wget -qO - http://$(S3_BUCKET).s3.amazonaws.com/$$VERSION_FILE_NAME)" 

release-beta: require-s3cmd
	@BASE_NAME="$(INSTALLER_NAME)-internal" && \
	VERSION_FILE_NAME="version-beta-android.txt" && \
	cd $(BINARIES_PATH) && \
	git pull && \
	cd - && \
	for URL in s3://lantern/$$BASE_NAME.apk s3://lantern/$$BASE_NAME.aab; do \
		NAME=$$(basename $$URL) && \
		BETA=$$(echo $$NAME | sed s/"$$BASE_NAME"/$(BETA_BASE_NAME)/) && \
		s3cmd cp s3://$(S3_BUCKET)/$$NAME s3://$(S3_BUCKET)/$$BETA && \
		s3cmd setacl s3://$(S3_BUCKET)/$$BETA --acl-public && \
		s3cmd get --force s3://$(S3_BUCKET)/$$NAME $(BINARIES_PATH)/$$BETA; \
	done && \
	s3cmd cp s3://$(S3_BUCKET)/version-qa-android.txt s3://$(S3_BUCKET)/$$VERSION_FILE_NAME && \
	s3cmd setacl s3://$(S3_BUCKET)/$$VERSION_FILE_NAME --acl-public && \
	echo "$$VERSION_FILE_NAME is now set to $$(wget -qO - http://$(S3_BUCKET).s3.amazonaws.com/$$VERSION_FILE_NAME)" && \
	cd $(BINARIES_PATH) && \
	git add $(BETA_BASE_NAME)* && \
	(git commit -am "Latest lantern android beta binaries released from QA." && git push origin $(BINARIES_BRANCH)) || true

release-prod: require-version require-s3cmd require-wget require-lantern-binaries require-magick
	@TAG_COMMIT=$$(git rev-list --abbrev-commit -1 $(TAG)) && \
	if [[ -z "$$TAG_COMMIT" ]]; then \
		echo "Could not find given tag $(TAG)."; \
	fi && \
	PROD_BASE_NAME2="$(INSTALLER_NAME)-beta" && \
	VERSION_FILE_NAME="version-android.txt" && \
	for URL in s3://lantern/$(BETA_BASE_NAME).apk s3://lantern/$(BETA_BASE_NAME).aab; do \
		NAME=$$(basename $$URL) && \
		PROD=$$(echo $$NAME | sed s/"$(BETA_BASE_NAME)"/$(PROD_BASE_NAME)/) && \
		PROD2=$$(echo $$NAME | sed s/"$(BETA_BASE_NAME)"/$$PROD_BASE_NAME2/) && \
		s3cmd cp s3://$(S3_BUCKET)/$$NAME s3://$(S3_BUCKET)/$$PROD && \
		s3cmd setacl s3://$(S3_BUCKET)/$$PROD --acl-public && \
		s3cmd cp s3://$(S3_BUCKET)/$$NAME s3://$(S3_BUCKET)/$$PROD2 && \
		s3cmd setacl s3://$(S3_BUCKET)/$$PROD2 --acl-public && \
		echo "Downloading released binary to $(BINARIES_PATH)/$$PROD" && \
		s3cmd get --force s3://$(S3_BUCKET)/$$PROD $(BINARIES_PATH)/$$PROD && \
		cp $(BINARIES_PATH)/$$PROD $(BINARIES_PATH)/$$PROD2; \
	done && \
	s3cmd cp s3://$(S3_BUCKET)/version-beta.txt s3://$(S3_BUCKET)/$$VERSION_FILE_NAME && \
	s3cmd setacl s3://$(S3_BUCKET)/$$VERSION_FILE_NAME --acl-public && \
	echo "$$VERSION_FILE_NAME is now set to $$(wget -qO - http://$(S3_BUCKET).s3.amazonaws.com/$$VERSION_FILE_NAME)" && \
	echo "Uploading released binaries to $(BINARIES_PATH)"
	@cd $(BINARIES_PATH) && \
	git checkout $(BINARIES_BRANCH) && \
	git pull && \
	git add $(PROD_BASE_NAME)* && \
	echo -n $$VERSION | $(MAGICK) -font Helvetica -pointsize 30 -size 68x24  label:@- -transparent white version.png && \
	(COMMIT_MESSAGE="Latest binaries for Lantern $$VERSION ($$TAG_COMMIT)." && \
	git add . && \
	git commit -m "$$COMMIT_MESSAGE" && \
	git push origin $(BINARIES_BRANCH) \
	) || true
	
release-autoupdate: require-version
	@TAG_COMMIT=$$(git rev-list --abbrev-commit -1 $(TAG)) && \
	if [[ -z "$$TAG_COMMIT" ]]; then \
		echo "Could not find given tag $(TAG)."; \
	fi && \
	for URL in s3://lantern/lantern_update_android_arm-$$VERSION.bz2; do \
		NAME=$$(basename $$URL) && \
		STRIPPED_NAME=$$(echo "$$NAME" | cut -d - -f 1 | sed s/lantern_//).bz2 && \
		s3cmd get --force s3://$(S3_BUCKET)/$$NAME $$STRIPPED_NAME; \
	done && \
	$(RUBY) ./create_or_update_release.rb getlantern lantern $$VERSION update_android_arm.bz2

release: require-version require-s3cmd require-wget require-lantern-binaries require-release-track release-prod copy-beta-installers-to-mirrors invalidate-getlantern-dot-org upload-aab-to-play

$(ANDROID_LIB): $(GO_SOURCES)
	$(call check-go-version) && \
	go env -w 'GOPRIVATE=github.com/getlantern/*' && \
	go install golang.org/x/mobile/cmd/gomobile && \
	gomobile init && \
	gomobile bind \
	    -target=$(ANDROID_ARCH_GOMOBILE) \
		-tags='headless lantern' -o=$(ANDROID_LIB) \
		-androidapi=19 \
		-ldflags="$(LDFLAGS)" \
		$(GOMOBILE_EXTRA_BUILD_FLAGS) \
		$(ANDROID_LIB_PKG)

$(MOBILE_ANDROID_LIB): $(ANDROID_LIB)
	mkdir -p $(MOBILE_LIBS) && \
	cp $(ANDROID_LIB) $(MOBILE_ANDROID_LIB)

.PHONY: android-lib
android-lib: $(MOBILE_ANDROID_LIB)

# TODO: The below don't work when doing full builds, but we should indeed make debug builds unstripped and unoptimized.
# .PHONY: android-lib-debug
# android-lib-debug: export GOMOBILE_EXTRA_BUILD_FLAGS += $(DISABLE_OPTIMIZATION_FLAGS)
# android-lib-debug: $(MOBILE_ANDROID_LIB)

# .PHONY: android-lib-prod
# android-lib-prod: export LDFLAGS += $(LD_STRIP_FLAGS)
# android-lib-prod: $(MOBILE_ANDROID_LIB)

$(MOBILE_TEST_APK) $(MOBILE_TESTS_APK): $(MOBILE_SOURCES) $(MOBILE_ANDROID_LIB)
	@$(GRADLE) -PandroidArch=$(ANDROID_ARCH) \
		-PandroidArchJava="$(ANDROID_ARCH_JAVA)" \
		-b $(MOBILE_DIR)/app/build.gradle \
		:app:assembleAutoTestDebug :app:assembleAutoTestDebugAndroidTest

do-android-debug: $(MOBILE_SOURCES) $(MOBILE_ANDROID_LIB)
	@ln -fs $(MOBILE_DIR)/gradle.properties . && \
	COUNTRY="$$COUNTRY" && \
	PAYMENT_PROVIDER="$$PAYMENT_PROVIDER" && \
	STAGING="$$STAGING" && \
	STICKY_CONFIG="$$STICKY_CONFIG" && \
	CI="$$CI" && \
	echo "Base64 CI: $(CIBASE)" && \
	$(GRADLE) -PlanternVersion=$(DEBUG_VERSION) -PproServerUrl=$(PRO_SERVER_URL) -PpaymentProvider=$(PAYMENT_PROVIDER) -Pcountry=$(COUNTRY) -PplayVersion=$(FORCE_PLAY_VERSION) -PuseStaging=$(STAGING) -PstickyConfig=$(STICKY_CONFIG) -PlanternRevisionDate=$(REVISION_DATE) -PandroidArch=$(ANDROID_ARCH) -PandroidArchJava="$(ANDROID_ARCH_JAVA)" -Pdart-defines="$(CIBASE)" -PdevelopmentMode="true" -Pci=$(CI) -b $(MOBILE_DIR)/app/build.gradle \
	assembleProdDebug

pubget:
	@flutter pub get

$(MOBILE_DEBUG_APK): $(MOBILE_SOURCES) $(GO_SOURCES)
	@$(call check-go-version) && \
	make do-android-debug && \
	cp $(MOBILE_ANDROID_DEBUG) $(MOBILE_DEBUG_APK)

$(MOBILE_RELEASE_APK): $(MOBILE_SOURCES) $(GO_SOURCES) $(MOBILE_ANDROID_LIB) require-sentry
	echo $(MOBILE_ANDROID_LIB) && \
	mkdir -p ~/.gradle && \
	ln -fs $(MOBILE_DIR)/gradle.properties . && \
	COUNTRY="$$COUNTRY" && \
	STAGING="$$STAGING" && \
	STICKY_CONFIG="$$STICKY_CONFIG" && \
	PAYMENT_PROVIDER="$$PAYMENT_PROVIDER" && \
	VERSION_CODE="$$VERSION_CODE" && \
	DEVELOPMENT_MODE="$$DEVELOPMENT_MODE" && \
	$(GRADLE) -PlanternVersion=$$VERSION -PlanternRevisionDate=$(REVISION_DATE) -PandroidArch=$(ANDROID_ARCH) -PandroidArchJava="$(ANDROID_ARCH_JAVA)" -PproServerUrl=$(PRO_SERVER_URL) -PpaymentProvider=$(PAYMENT_PROVIDER) -Pcountry=$(COUNTRY) -PplayVersion=$(FORCE_PLAY_VERSION) -PuseStaging=$(STAGING) -PstickyConfig=$(STICKY_CONFIG) -PversionCode=$(VERSION_CODE) -PdevelopmentMode=$(DEVELOPMENT_MODE) -b $(MOBILE_DIR)/app/build.gradle \
		assembleProdSideload && \
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
	$(GRADLE) -PlanternVersion=$$VERSION -PlanternRevisionDate=$(REVISION_DATE) -PandroidArch=$(ANDROID_ARCH) -PandroidArchJava="$(ANDROID_ARCH_JAVA)" -PproServerUrl=$(PRO_SERVER_URL) -PpaymentProvider=$(PAYMENT_PROVIDER) -Pcountry=$(COUNTRY) -PplayVersion=true -PuseStaging=$(STAGING) -PstickyConfig=$(STICKY_CONFIG) -b $(MOBILE_DIR)/app/build.gradle \
		bundlePlay && \
	sentry-cli upload-dif --wait -o getlantern -p android build/app/intermediates/merged_native_libs/prodPlay/out/lib && \
	cp $(MOBILE_ANDROID_BUNDLE) $(MOBILE_BUNDLE)

android-debug: $(MOBILE_DEBUG_APK)

android-release: pubget $(MOBILE_RELEASE_APK)

android-bundle: $(MOBILE_BUNDLE)

android-debug-install: $(MOBILE_DEBUG_APK)
	$(ADB) uninstall $(MOBILE_APPID) ; $(ADB) install -r $(MOBILE_DEBUG_APK)

android-release-install: $(MOBILE_RELEASE_APK)
	$(ADB) install -r $(MOBILE_RELEASE_APK)

package-android: require-version clean
	@make pubget android-release && \
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
	rm -Rf /tmp/android-lantern ; \
	mkdir -p /tmp/android-lantern && \
	cp -R LICENSE LICENSING.md android internalsdk lib protos* go.mod go.sum /tmp/android-lantern && \
	cd /tmp/android-lantern && \
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
	@echo "Nuking $(FRAMEWORK_DIR)"
	rm -Rf $(FRAMEWORK_DIR)
	@echo "generating Ios.xcFramework"
	go env -w 'GOPRIVATE=github.com/getlantern/*' && \
	gomobile init && \
	gomobile bind -target=ios \
	-tags='headless lantern ios' \
	-ldflags="$(LDFLAGS)" \
    		$(GOMOBILE_EXTRA_BUILD_FLAGS) \
    		$(ANDROID_LIB_PKG)
	@echo "copying framework"
	mkdir -p $(FRAMEWORK_DIR)/$(FRAMEWORK_NAME)
	cp -R ./$(FRAMEWORK_NAME)/* $(FRAMEWORK_DIR)/$(FRAMEWORK_NAME)
	@echo "Nuking $(FRAMEWORK_NAME)"
	rm -Rf ./$(FRAMEWORK_NAME)


install-gomobile:
	@echo "installing gomobile" && \
	go install golang.org/x/mobile/cmd/gomobile@latest

assert-go-version:
	@if go version | grep -q -v $(GO_VERSION); then echo "go $(GO_VERSION) is required." && exit 1; fi

clean:
	rm -f liblantern*.aar && \
	rm -f $(MOBILE_LIBS)/liblantern-* && \
	rm -Rf android/app/build && \
	rm -Rf *.aab && \
	rm -Rf *.apk && \
	rm -f `which gomobile` && \
	rm -f `which gobind`
	rm -Rf "$(FLASHLIGHT_FRAMEWORK_PATH)" "$(INTERMEDIATE_FLASHLIGHT_FRAMEWORK_PATH)"




