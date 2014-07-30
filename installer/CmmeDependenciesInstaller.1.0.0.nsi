; The name of the project
Name "CMME Accessibility Overlay Dependencies 1.0.0" 

;Name of the installer
OutFile "CmmeDependenciesInstaller.1.0.0.exe"

!define ORGANIZATION_NAME "CMME"
!define BATSTARTUP "StartSapiServer.bat"

; The default installation directory
InstallDir $PROGRAMFILES32\${ORGANIZATION_NAME}

RequestExecutionLevel admin

;--------------------------------

; The stuff to install
Section "" 

SetShellVarContext all

SetOutPath "$INSTDIR\dependencies\"
File /r         "Dependencies\*"
SetOutPath "$INSTDIR\"
File /a         ${BATSTARTUP}

SectionEnd ; end the section

;Installers for .NET runtime and language dependencies
Section -Dependencies
	
	SetOutPath $INSTDIR\Dependencies
	MessageBox MB_YESNO "Install required 4.5 .NET runtime?" /SD IDYES IDNO endDotNETDependency
		;Microsoft Runtime (Version 4.5)
		;http://www.microsoft.com/en-us/download/details.aspx?id=30653
		File "Dependencies\dotNetFx45_Full_setup.exe"
		ExecWait "$INSTDIR\Dependencies\dotNetFx45_Full_setup.exe"
		Goto endDotNETDependency
	endDotNETDependency:
	MessageBox MB_YESNO "Install required .NET speech runtime?" /SD IDYES IDNO endDotNETSpeechDependency
		;Microsoft Speech Platform - Runtime (Version 11)
		;Download from here: http://www.microsoft.com/en-us/download/details.aspx?id=27225
		File "Dependencies\SpeechPlatformRuntime.msi"
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\SpeechPlatformRuntime.msi"'
		Goto endDotNETSpeechDependency
	endDotNETSpeechDependency:
	MessageBox MB_YESNO "Install required language dependencies?" /SD IDYES IDNO endLanguageDependencies
		;Microsoft Speech Platform - Runtime Languages (Version 11)
		;Download from here: http://www.microsoft.com/en-us/download/details.aspx?id=27224
		
		File "Dependencies\MSSpeech_TTS_de-DE_Hedda.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_de-DE_Hedda.msi"'
		File "Dependencies\MSSpeech_TTS_en-US_Helen.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_en-US_Helen.msi"'
		File "Dependencies\MSSpeech_TTS_es-ES_Helena.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_es-ES_Helena.msi"'
		File "Dependencies\MSSpeech_TTS_fr-FR_Hortense.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_fr-FR_Hortense.msi"'
		File "Dependencies\MSSpeech_TTS_it-IT_Lucia.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_it-IT_Lucia.msi"'
		File "Dependencies\MSSpeech_TTS_nl-NL_Hanna.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_nl-NL_Hanna.msi"'
		File "Dependencies\MSSpeech_TTS_pt-BR_Heloisa.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_pt-BR_Heloisa.msi"'
		File "Dependencies\MSSpeech_TTS_ru-RU_Elena.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_ru-RU_Elena.msi"'
		File "Dependencies\MSSpeech_TTS_zh-CN_HuiHui.msi";
		ExecWait '"msiexec" /i "$INSTDIR\Dependencies\MSSpeech_TTS_zh-CN_HuiHui.msi"'

		Goto endLanguageDependencies
	endLanguageDependencies:

SectionEnd

; The stuff to install
Section "" ;Sapi Server

SetShellVarContext all

SetOutPath "$INSTDIR\sapi-server\"
File /r         "SAPI-Server\*"

SectionEnd ; end the section

Section "" ;Update shortcuts

SetShellVarContext all

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\${ORGANIZATION_NAME}\${BATSTARTUP}.lnk"  
  Delete "$DESKTOP\${BATSTARTUP}.lnk"
  Delete "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\${BATSTARTUP}.lnk"
  
  SetOutPath "$INSTDIR\"
  
  CreateShortCut "$SMPROGRAMS\${ORGANIZATION_NAME}\${BATSTARTUP}.lnk" "$INSTDIR\${BATSTARTUP}"
  CreateShortCut "$DESKTOP\${BATSTARTUP}.lnk" "$INSTDIR\${BATSTARTUP}"
  CreateShortCut "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\${BATSTARTUP}.lnk" "$INSTDIR\${BATSTARTUP}"

SectionEnd ;end shortcuts