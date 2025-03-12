;@Ahk2Exe-ExeName CH Ref Tool
;@Ahk2Exe-SetName CloneHero Tournament Reffing Tool
;@Ahk2Exe-SetDescription Tool for creating CloneHero tournament referee reports.
;@Ahk2Exe-SetProductName CloneHero Tournament Reffing Tool
;@Ahk2Exe-SetMainIcon %A_AhkPath%\..\ICONMX_g2.ico
;@Ahk2Exe-SetVersion 1.4.0.0
#Requires AutoHotkey v2.0
#singleInstance off
#warn all, off
/*@Ahk2Exe-Keep
#noTrayIcon
*/
persistent

#include <Gdip_All>
#include <std>
#include <CHRefTool>

setWorkingDir(a_scriptDir)

; file/folder setup
files:={data:a_scriptDir "\data"
		,ini:a_scriptDir "\data\setlists.ini"
		,log:a_scriptDir "\data\log.txt"
		,matches:a_scriptDir "\matches"}

; ask for song count
songCnt:=inputBox("Best of how many songs?","Match Song Count")
if (!songCnt || !isDigit(songCnt.value) || songCnt.result!="OK")
	exitApp()

CHTool:=CHRefTool(files,songCnt.value)
onExit(objBindMethod(CHTool,"quit"))
CHTool.g.show()
return
