;UPDATE NAME ATTRIBUTE TO MATCH THE NAME OF THE FD PROJECT
!define NAME "CMME"  ;Assign project name w/out spaces

;--------------SETUP-------------------
;Include Modern UI
!include "MUI2.nsh"

; Installer attributes
AllowRootDirInstall true ; required to 'install' to root dir
ShowInstDetails show ; automatically show install details

; The name of the installer
Name "${NAME}"

; The file to write
OutFile "${NAME}_Installer.exe"

; The default installation directory
InstallDir $PROGRAMFILES32\Ideum

; Registry key to check for directory (so if you install again, it will overwrite the old one automatically)
InstallDirRegKey HKLM "Software\${NAME}" "Install_Dir"

; Request application privileges for Windows Vista+
RequestExecutionLevel admin

;--------------MACROS------------------

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start ${NAME}"
!define MUI_FINISHPAGE_RUN_FUNCTION "StartApp"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Language
!insertmacro MUI_LANGUAGE "English"

;--------------------------------

; Application and dependencies
Section "Install ${NAME}"

  ; Set output path to the installation directory.
  SetOutPath "$INSTDIR\${NAME}"

  ; Put files there
  File /r "..\bin\*"

  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\${NAME} "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayName" "${NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "UninstallString" "$INSTDIR\${NAME}\${NAME}_Uninstaller.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "NoRepair" 1
  WriteUninstaller "$INSTDIR\${NAME}\${NAME}_Uninstaller.exe"

SectionEnd

;Installers for .NET runtime and language dependencies
Section -Dependencies
	
	MessageBox MB_YESNO "Install required 4.5 .NET runtime?" /SD IDYES IDNO endDotNETDependency
		;Microsoft Runtime (Version 4.5)
		;http://www.microsoft.com/en-us/download/details.aspx?id=30653
		ExecWait "Dependencies\dotNetFx45_Full_setup.exe"
		Goto endDotNETDependency
	endDotNETDependency:	
	MessageBox MB_YESNO "Install required .NET speech runtime?" /SD IDYES IDNO endDotNETSpeechDependency
		;Microsoft Speech Platform - Runtime (Version 11)
		;Download from here: http://www.microsoft.com/en-us/download/details.aspx?id=27225
		ExecWait '"msiexec" /i "Dependencies\SpeechPlatformRuntime.msi"'
		Goto endDotNETSpeechDependency
	endDotNETSpeechDependency:	
	MessageBox MB_YESNO "Install required language dependencies?" /SD IDYES IDNO endLanguageDependencies
		;Microsoft Speech Platform - Runtime Languages (Version 11)
		;Download from here: http://www.microsoft.com/en-us/download/details.aspx?id=27224
		
		ExecWait '"msiexec" /i "Dependencies\MSSpeech_TTS_en-US_Helen.msi"'

		Goto endLanguageDependencies
	endLanguageDependencies:
		MessageBox MB_OK $APPDATA

SectionEnd

; Optional section (can be disabled by the user)
SectionGroup "Desktop Shortcuts"
	Section "!Core"
		CreateShortcut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${NAME}\${NAME}.exe"		
		CreateShortcut "$DESKTOP\SAPI_Server.lnk" "$INSTDIR\${NAME}\sapi-server\sapi_websocket.exe"		
	SectionEnd
SectionGroupEnd

; Optional section (can be disabled by the user)
SectionGroup "Start Menu Shortcuts"
	Section "!Core"
		CreateShortCut "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\${NAME}.lnk" "$INSTDIR\${NAME}\${NAME}.exe"
		CreateShortCut "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SAPI_Server.lnk" "$INSTDIR\${NAME}\sapi-server\sapi_websocket.exe"		
	SectionEnd	
SectionGroupEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove shortcuts and uninstaller
  Delete "$DESKTOP\${NAME}.lnk"
  Delete "$DESKTOP\SAPI_Server.lnk"
  Delete "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\${NAME}.lnk"  
  Delete "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SAPI_Server.lnk"  
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
  DeleteRegKey HKLM SOFTWARE\${NAME}  

  ; Remove installation directory
  RMDir /r "$INSTDIR"

SectionEnd

Function StartApp
  ExecShell "" "$INSTDIR\${NAME}\${NAME}.exe"
FunctionEnd