Unicode true
Name "Lantern"

# Installs Lantern and launches it
# See http://nsis.sourceforge.net/Run_an_application_shortcut_after_an_install

AutoCloseWindow true

!addplugindir nsis_plugins
!include "nsis_includes/nsProcess.nsh"

# Use the modern ui
!include MUI.nsh
!include LogicLib.nsh
!include FileFunc.nsh

!define MUI_ICON lantern.ico

;Pages
!insertmacro MUI_PAGE_INSTFILES

  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "RunLantern"
!insertmacro MUI_PAGE_FINISH

;Languages
!insertmacro MUI_LANGUAGE "Farsi"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Czech"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "Slovak"

# define name of installer
OutFile ${OUT_FILE}

# define installation directory
InstallDir $APPDATA\Lantern

# Request user permissions so that auto-updates will work with no prompt
RequestExecutionLevel user

# start default section
Section
    # Uninstall the previous version. This will also kill the process.
    Call UninstallPrevious
    ClearErrors
    IfErrors 0 +2
        Abort "Error stopping previous Lantern version. Please stop it from the system tray and install again."

    # set the installation directory as the destination for the following actions
    SetOutPath $INSTDIR
    SetOverwrite on

    File ${APP_NAME}
    File lantern.ico
    File .packaged-lantern.yaml
    File lantern.yaml
    File /r data
    File *.dll

    # Store installation folder
    WriteRegStr HKCU "Software\Lantern" "" $INSTDIR

    WriteUninstaller "$INSTDIR\uninstall.exe"

    # Support uninstalling via Add/Remove programs
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
                     "DisplayName" "Lantern"

    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
                     "DisplayIcon" "$INSTDIR\lantern.ico"

    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
                     "Publisher" "Brave New Software Project, Inc."

    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
                     "URLInfoAbout" "http://lantern.io"

    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
                     "DisplayVersion" "${VERSION}"

    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
                     "UninstallString" "$\"$INSTDIR\uninstall.exe$\""

    CreateDirectory "$SMPROGRAMS\Lantern"
    CreateShortCut "$SMPROGRAMS\Lantern\Lantern.lnk" "$INSTDIR\${APP_NAME}" "" "$INSTDIR\lantern.ico" 0
    CreateShortCut "$SMPROGRAMS\Lantern\Uninstall Lantern.lnk" "$INSTDIR\uninstall.exe"
    CreateShortCut "$DESKTOP\Lantern.lnk" "$INSTDIR\${APP_NAME}" "" "$INSTDIR\lantern.ico" 0

    # This is a bad registry entry created by old Lantern versions.
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "value"

    # Add a registry key to set -clear-proxy-settings. See https://github.com/getlantern/lantern/issues/2776
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" \
                     "Lantern" "$\"$INSTDIR\${APP_NAME}$\" -clear-proxy-settings"

SectionEnd
# end default section

Function RunLantern
    # Launch Lantern and initialize
    ShellExecAsUser::ShellExecAsUser "" "$INSTDIR\${APP_NAME}"
FunctionEnd

# Uninstall previous versions before installing the new one
Function UninstallPrevious
    DetailPrint "Uninstalling previous version"
    ReadRegStr $R0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern" \
						"UninstallString"
    StrCmp $R0 "" noprevious

    DetailPrint "Uninstalling $R0"
    ClearErrors
    ExecWait '$R0 /S -from-installer=true _?=$INSTDIR' ;Do not copy the uninstaller to a temp file

    IfErrors erroruninstalling done
noprevious:
	DetailPrint "No previous version to uninstall"
        Goto end
erroruninstalling:
	DetailPrint "Error uninstalling previous at $R0"
    	Goto end
done:
	DetailPrint "Successfully uninstalled $R0"
end:
FunctionEnd

# start uninstaller section
Section "uninstall"
	${GetParameters} $R0
	${GetOptions} $R0 "-from-installer=" $R1
	${If} $R1 == "true"
		DetailPrint "Not showing survey in call from installer"
	${Else}
		DetailPrint "Showing uninstall survey -- not called from installer"
		DetailPrint "Looking for uninstall survey in $INSTDIR\uninstall_url.txt"
		${If} ${FileExists} "$INSTDIR\uninstall_url.txt"
			FileOpen $4 "$INSTDIR\uninstall_url.txt" r
			FileRead $4 $5
			FileClose $4

			${If} $5 == ""
				DetailPrint "No uninstall survey URL?"
			${Else}
				DetailPrint "Found uninstall survey URL $5"
				ExecShell "open" $5
			${EndIf}
		${Else}
			DetailPrint "No uninstall survey URL file - opening default"
			ExecShell "open" "https://www.surveymonkey.com/r/chinese-unopened-uninstall"
		${EndIf}

	${EndIf}

	# We need to kill the existing process because otherwise it will own the files we try to write to.
	DetailPrint "Closing existing Lantern"
    	${nsProcess::CloseProcess} "${APP_NAME}" $R0
    	# Sleep for 1 second to process a chance to die and file to become writable
    	Sleep 1000

	DetailPrint "Killed existing Lantern tasks"

    	RMDir /r "$SMPROGRAMS\Lantern"

    	Delete "$DESKTOP\Lantern.lnk"

    	Delete "$INSTDIR\${APP_NAME}"
    	Delete "$INSTDIR\uninstall.exe"
    	Delete "$INSTDIR\lantern.ico"
    	Delete "$INSTDIR\.packaged-lantern.yaml"
    	Delete "$INSTDIR\lantern.yaml"

	# Remove uninstaller from Add/Remove programs
    	DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lantern"

    	# Don't run Lantern on startup.
    	DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "Lantern"
        ${nsProcess::Unload}
SectionEnd
# end uninstaller section
