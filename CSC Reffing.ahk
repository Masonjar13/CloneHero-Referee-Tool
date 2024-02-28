;@Ahk2Exe-ExeName CH Ref Tool
;@Ahk2Exe-SetName CloneHero Tournament Reffing Tool
;@Ahk2Exe-SetDescription Tool for creating CloneHero tournament referee reports.
;@Ahk2Exe-SetProductName CloneHero Tournament Reffing Tool
;@Ahk2Exe-SetMainIcon %A_AhkPath%\..\ICONMX_g2.ico
;@Ahk2Exe-SetVersion 1.0.1.0
#Requires AutoHotkey v2.0
#singleInstance off
#warn all, off
/*@Ahk2Exe-Keep
#noTrayIcon
*/
#include <Gdip_All>
#include <timestamp>
#include <tool>

persistent

; file/folder setup
files:={data:a_scriptDir "\data"
		,ini:a_scriptDir "\data\setlists.ini"
		,log:a_scriptDir "\data\log.txt"
		,matches:a_scriptDir "\matches"}
setWorkingDir(files.data)
if !inStr(fileExist(files.data),"D") {
	dirCreate(files.data)
}
if !inStr(fileExist(files.matches),"D") {
	dirCreate(files.matches)
}
try
	fileInstall("data\setlists.ini",files.ini)

; ask for song count
songCnt:=inputBox("Best of how many songs?","Match Song Count")
if (!songCnt || !isDigit(songCnt.value) || songCnt.result!="OK")
	exitApp()
songCnt:=songCnt.value

; load setlists
setlist:=object()
setlist.lists:=strSplit(iniRead(files.ini),"`n")
setlist.sets:=map(),setlist.setsTB:=map()

for i in setlist.lists {
	set:=[],setTB:=[],j:=1
	while j:=regExMatch(iniRead(files.ini,i),"\d+=\K([^``]+)``(\S+)",&songMatch:=unset,j) {
		sType:=strReplace(songMatch[2],"TB",,1,&rCnt:=unset)
		if (rCnt) {
			setTB.push(sType " - " songMatch[1])
		} else {
			set.push(sType " - " songMatch[1])
		}
		;msgbox(songMatch[1] "`n" songMatch[2])
	}
	setlist.sets[i]:=set
	setlist.setsTB[i]:=setTB
}

; create gui
g:=gui("+E0x2080000")
g.title:="CloneHero Tournament Reffing"
g.c:=object()
g.setFont("s15","Helvetica")

; gui controls
; basic info
g.c.setlistText:=g.add("text","section","Setlist: ")
g.c.setlistDDL:=g.add("dropDownList","ys",setlist.lists) ; setlist
g.c.outputButton:=g.add("button","ys xs+550","Save to Clipboard")
g.c.groupText:=g.add("text","xm section","Group: ")
g.c.groupEdit:=g.add("edit","ys limit1 r1 w40 uppercase")
g.c.highSeedText:=g.add("text","xm section r1","High Seed Player: ")
g.c.highSeedEdit:=g.add("edit","ys")
g.c.lowSeedText:=g.add("text","ys r1","Low Seed Player: ")
g.c.lowSeedEdit:=g.add("edit","ys")

; bans
g.c.highSeedBanText:=g.add("text","xm ys+80 section w250 right","bans") ; insert High Seed Player name
g.setFont("s12")
g.c.highSeedBanDDL:=g.add("dropDownList","ys w250") ; song list
g.setFont("s15")
; screenshot
g.c.screenshotButton:=g.add("button","ys w200 h50","Screenshot")

g.c.lowSeedBanText:=g.add("text","xm ys+38 section w250 right","bans") ; insert Low Seed Player name
g.setFont("s12")
g.c.lowSeedBanDDL:=g.add("dropDownList","ys w250") ; song list
g.setFont("s15")

; games
g.c.games:=array()
loop songCnt {
	g.c.games.push(object())
	g.c.games[a_index].text:=g.add("text","xm section w250 right",(a_index = songCnt ? "TIEBREAKER - " : "picks "))
	g.setFont("s12")
	g.c.games[a_index].DDLS:=g.add("dropDownList","ys w250") ; songs
	g.setFont("s15")
	g.c.games[a_index].win:=g.add("text","ys","Winner: ")
	g.setFont("s12")
	g.c.games[a_index].DDL:=g.add("dropDownList","ys w250") ; players
	g.setFont("s15")
	g.c.games[a_index].DDL.onEvent("change",nextPick.bind(g,songCnt))
}

; gui events
g.onEvent("close",a=>exitApp())
g.c.outputButton.onEvent("click",output.bind(g,files))
g.c.highSeedEdit.onEvent("loseFocus",playerUpdate.bind(g,"high"))
g.c.lowSeedEdit.onEvent("loseFocus",playerUpdate.bind(g,"low"))
g.c.setlistDDL.onEvent("change",songsUpdate.bind(g,setlist))
g.c.screenshotButton.onEvent("click",getScreenshot.bind(g,files))

; event functions
output(g,files,ctrl,_) {
	high:=g.c.highSeedEdit.value
	low:=g.c.lowSeedEdit.value
	highWins:=lowWins:=0
	group:=g.c.groupEdit.value
	
	if !(high || low) {
		return
	}
	
	out1:=""
	
	; get picks and count wins
	for i in g.c.games {
		if (i.DDL.text=high) {
			highWins++
		} else if (i.DDL.text=low) {
			lowWins++
		} else {
			continue
		}
		
		out1.="G" a_index ": " i.text.text i.DDLS.text " - " i.DDL.text " wins!`n"
	}
	out:="Group " group "`n`n"
		. high " " highWins "-" lowWins " " low "`n`n"
		. high " bans " regExReplace(g.c.highSeedBanDDL.text,"(Solo - )|(Strum - )|(Hybrid - )") "`n"
		. low " bans " regExReplace(g.c.lowSeedBanDDL.text,"(Solo - )|(Strum - )|(Hybrid - )") "`n`n"
		. regExReplace(out1,"(Solo - )|(Strum - )|(Hybrid - )") "`n"
		. (highWins > lowWins ? high : low) " wins!"
	
	; called from quit or button?
	if (_="exit") {
		mLog(out,files.log)
	} else {
		a_clipboard:=out
		tool("Output saved to clipboard")
	}
}

getScreenshot(g,files,ctrl,_) {
	static ts:=regExReplace(timeStamp().timedates,"\/|:",".")
	if !(g.c.highSeedEdit.value || g.c.highSeedEdit.value) {
		msgbox("Please enter both player names before taking a screenshot.","Screenshot")
	} else {
		dirCreate(scPath:=files.matches "\" g.c.highSeedEdit.value " vs " g.c.lowSeedEdit.value " - " ts)
		screenshot(scPath)
		winActivate("ahk_id" g.hwnd)
	}
}

playerUpdate(g,seed,ctrl,_) {
	if (seed="high") {
		g.c.highSeedBanText.text:=ctrl.value " bans"
		g.c.games[1].text.text:=ctrl.value " picks "
	} else if (seed="low") {
		g.c.lowSeedBanText.text:=ctrl.value " bans"
	}
	for i in g.c.games {
		i.DDL.delete()
		i.DDL.add([g.c.highSeedEdit.value,g.c.lowSeedEdit.value])
	}
}

songsUpdate(g,setlist,ctrl,_) {
	set:=setlist.sets[setlist.lists[g.c.setlistDDL.value]]
	setTB:=setlist.setsTB[setlist.lists[g.c.setlistDDL.value]]
	g.c.highSeedBanDDL.delete()
	g.c.highSeedBanDDL.add(set)
	g.c.lowSeedBanDDL.delete()
	g.c.lowSeedBanDDL.add(set)
	
	for i in g.c.games {
		i.DDLS.delete()
		if (a_index=g.c.games.length) {
			i.DDLS.add(setTB)
		} else {
			i.DDLS.add(set)
		}
	}
}

nextPick(g,songCnt,ctrl,_) {
	high:=g.c.highSeedEdit.value
	low:=g.c.lowSeedEdit.value
	
	for i in g.c.games {
		if (a_index = songCnt-1)
			break
		if (i.DDL.text=high) {
			try
				g.c.games[a_index+1].text.text:=low " picks "
		} else if (i.DDL.text=low) {
			try
				g.c.games[a_index+1].text.text:=high " picks "
		} else {
			try
				g.c.games[a_index+1].text.text:=" picks "
		}
	}
}

; other functions
mLog(text,logFile) {
	fileAppend(a_nowUTC " | " timeStamp(a_nowUTC).timedate  " | " timeStamp().timedate "`n" text "`n`n",logFile)
}

screenshot(filePath) {
	static pt:=gdip_startup()
	static ch:="Clone Hero ahk_class UnityWndClass ahk_exe Clone Hero.exe"
	static cnt:=0

	if !winExist(ch) {
		msgbox("CloneHero window was not found!","CloneHero Not Running")
		return
	}
	winActivate(ch)
	winGetClientPos(&x:=unset,&y:=unset,&w:=unset,&h:=unset,ch)
	sc:=gdip_bitmapFromScreen(x "|" y "|" w "|" h)
	gdip_saveBitmapToFile(sc,filePath "\" (++cnt) ".png")
	gdip_disposeImage(sc)
}

; exit routine
quit(g,files,reason,code) {
	output(g,files,0,"exit")
}

; log on exit
onExit(quit.bind(g,files))

; show gui
g.show()
return
