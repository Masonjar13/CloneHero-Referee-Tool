;@Ahk2Exe-ExeName CH Ref Tool
;@Ahk2Exe-SetName CloneHero Tournament Reffing Tool
;@Ahk2Exe-SetDescription Tool for creating CloneHero tournament referee reports.
;@Ahk2Exe-SetProductName CloneHero Tournament Reffing Tool
;@Ahk2Exe-SetMainIcon %A_AhkPath%\..\ICONMX_g2.ico
;@Ahk2Exe-SetVersion 1.0.0.0
#Requires AutoHotkey v2.0
#singleInstance off
#warn all, off
#noTrayIcon
persistent
setWorkingDir(a_scriptDir)
try
	fileInstall("setlists.ini", "setlists.ini")

; ask for song count
songCnt:=inputBox("Best of how many songs?","Match Song Count")
if (!songCnt || !isDigit(songCnt.value) || songCnt.result!="OK")
	exitApp()
songCnt:=songCnt.value

; load setlists
setlist:=object()
setlist.lists:=strSplit(iniRead("setlists.ini"),"`n")
setlist.sets:=map()
for i in setlist.lists {
	setlist.sets[i]:=strSplit(regExReplace(iniRead("setlists.ini",i),"(^|\n)\K\d+="),"`n")
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
g.c.lowSeedBanText:=g.add("text","xm section w250 right","bans") ; insert Low Seed Player name
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
g.c.outputButton.onEvent("click",output.bind(g))
g.c.highSeedEdit.onEvent("loseFocus",playerUpdate.bind(g,"high"))
g.c.lowSeedEdit.onEvent("loseFocus",playerUpdate.bind(g,"low"))
g.c.setlistDDL.onEvent("change",songsUpdate.bind(g,setlist))

; event functions
output(g,ctrl,_) {
	high:=g.c.highSeedEdit.value
	low:=g.c.lowSeedEdit.value
	highWins:=lowWins:=0
	group:=g.c.groupEdit.value
	
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
		. high " bans " g.c.highSeedBanDDL.text "`n"
		. low " bans " g.c.lowSeedBanDDL.text "`n`n"
		. out1 "`n"
		. (highWins > lowWins ? high : low) " wins!"
	a_clipboard:=out
	tool("Output saved to clipboard")
}

playerUpdate(g,seed,ctrl,_) {
	if (seed="high") {
		g.c.highSeedBanText.text:=ctrl.value " bans"
		g.c.games[1].text.text:=ctrl.value " picks "
	} else if seed="low" {
		g.c.lowSeedBanText.text:=ctrl.value " bans"
	}
	for i in g.c.games {
		i.DDL.delete()
		i.DDL.add([g.c.highSeedEdit.value,g.c.lowSeedEdit.value])
	}
}

songsUpdate(g,setlist,ctrl,_) {
	set:=setlist.sets[setlist.lists[g.c.setlistDDL.value]]
	g.c.highSeedBanDDL.delete()
	g.c.highSeedBanDDL.add(set)
	g.c.lowSeedBanDDL.delete()
	g.c.lowSeedBanDDL.add(set)
	
	for i in g.c.games {
		i.DDLS.delete()
		i.DDLS.add(set)
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

; std lib
tool(str:="",wait:=2500,x:=unset,y:=unset){
	if (!str) {
		tooltip()
	} else {
		tooltip(str,x?,y?)
		setTimer(tool,-wait)
	}
	return str
}

; show gui
g.show()
return

