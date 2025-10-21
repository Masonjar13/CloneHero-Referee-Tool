class CHRefTool {
	__new(files,songCnt) {
		this.files:=files,this.songCnt:=songCnt
		this.highSeed:=this.lowSeed:=this.highSeedNum:=this.lowSeedNum:=""
		this.deferV:=0
		this.uuid:=0
		this.aID:=a_tickCount
		this.loadData()
		this.makeGui()
	}

	loadData() {
		files:=this.files

		; check directories
		if !inStr(fileExist(files.data),"D") {
			dirCreate(files.data)
		}

		if !inStr(fileExist(files.matches),"D") {
			dirCreate(files.matches)
		}

		; check/download ini
		if !fileExist(files.ini) {
			download("https://raw.githubusercontent.com/Masonjar13/CloneHero-Referee-Tool/refs/heads/main/data/setlists.ini",files.ini)
		}

		; load setlists
		setlist:=object()
		setlist.lists:=reverseArray(strSplit(iniRead(files.ini),"`n"))
		setlist.sets:=map(),setlist.setsTB:=map(),setlist.altConfig:=map()

		for i in setlist.lists {
			set:=[],setTB:=[],j:=1
			while j:=regExMatch(iniRead(files.ini,i),"\d+=\K([^``]+)``(\S+)",&songMatch:=unset,j) {
				sType:=strReplace(songMatch[2],"TB",,1,&rCnt:=unset)
				if (rCnt) {
					setTB.push(sType " - " songMatch[1])
				} else if (sType ~= "N\/?A") {
					set.push(songMatch[1])
				} else {
					sType:=strReplace(songMatch[2],"Boss",,1,&rCnt:=unset)
					if (rCnt) {
						if (this.songCnt=9) {
							set.push(sType " - " songMatch[1])
						}
					} else {
						set.push(sType " - " songMatch[1])
					}
				}
			}

			; check altConfig
			setlist.altConfig[i]:=iniRead(files.ini,i,'altConfig',0)
			setlist.sets[i]:=set
			setlist.setsTB[i]:=setTB
		}
		this.setlist:=setlist
	}

	makeGui() {
		songCnt:=this.songCnt
		
		; create gui
		g:=gui(,"CloneHero Tournament Reffing",this)
		g.setFont("s15","Helvetica")

		; controls
		g.c:=object()

		; basic info
		g.c.setlistText:=g.add("text","section","Setlist: ")
		g.c.setlistDDL:=g.add("dropDownList","r10 ys",this.setlist.lists) ; setlist
		g.setFont("s12","Helvetica")
		g.c.setlistUpdate:=g.add("button","ys","Update")
		g.c.coinFlip:=g.add("button","ys","Coin Flip")
		g.setFont("s15","Helvetica")
		g.c.outputButton:=g.add("button","ys xs+550","Save to Clipboard")
		g.c.groupText:=g.add("text","xm section","Group: ")
		g.c.groupEdit:=g.add("edit","ys limit1 r1 w40 uppercase")
		g.c.defer:=g.add("checkbox","ys","Defer ban?")
		g.c.coinFlipResult:=g.add("text","ys x+155 w80")
		g.c.highSeedText:=g.add("text","xm section r1","High Seed Player: ")
		g.c.highSeedEdit:=g.add("edit","ys")
		g.c.lowSeedText:=g.add("text","ys r1","Low Seed Player: ")
		g.c.lowSeedEdit:=g.add("edit","ys")

		; song hover
		g.setFont("c505050 underline s12 w900")
		g.c.songHover:=g.add("text","xm+200 w500","Demo Song Text")
		g.setFont("norm cblack s15 w400")

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
			g.c.games[a_index].text:=g.add("text","xm section w250 right",(a_index = songCnt ? "TIEBREAKER - " : "picks"))
			g.setFont("s12")
			g.c.games[a_index].DDLS:=g.add("dropDownList","ys w250") ; songs
			g.setFont("s15")
			g.c.games[a_index].win:=g.add("text","ys","Winner: ")
			g.setFont("s12")
			g.c.games[a_index].DDL:=g.add("dropDownList","ys w250") ; players
			g.setFont("s15")
			g.c.games[a_index].DDL.onEvent("change","nextPick")
			g.c.games[a_index].DDLS.onEvent("change","nextPick")
		}

		; gui events
		g.onEvent("close",a=>exitApp())
		g.c.outputButton.onEvent("click","output")
		g.c.highSeedEdit.onEvent("loseFocus",objBindMethod(this,"playerUpdate","high"))
		g.c.lowSeedEdit.onEvent("loseFocus",objBindMethod(this,"playerUpdate","low"))
		g.c.setlistDDL.onEvent("change","songsUpdate")
		g.c.screenshotButton.onEvent("click","getScreenshot")
		g.c.setlistUpdate.onEvent("click","updateIni")
		g.c.defer.onEvent("click","defer")
		g.c.coinFlip.onEvent("click","coinFlip")
		setTimer(objBindMethod(this,"onHover"),10)

		this.g:=g
	}

	; event methods
	outputMake() { ; format output
		g:=this.g

		high:=trim(strReplace(g.c.highSeedEdit.value,this.highSeedNum))
		low:=trim(strReplace(g.c.lowSeedEdit.value,this.lowSeedNum))
		if !(high || low) {
			return -1
		}
		highWins:=lowWins:=0
		group:=g.c.groupEdit.value

		out:=""

		; get picks and count wins
		highPicks:=[],lowPicks:=[],cnt:=0,p:="",tb:=""
		for i in g.c.games {
			w:=""
			cnt++
			p:=regExReplace(i.DDLS.text,"(Solo - )|(Strum - )|(Hybrid - )")
			if (i.DDL.text=high) {
				highWins++
				w:=high
			} else if (i.DDL.text=low) {
				lowWins++
				w:=low
			}

			if p {
				if (high && inStr(i.text.text,high)) { ; high pick
					;highWins++
					;p:=regExReplace(i.DDLS.text,"(Solo - )|(Strum - )|(Hybrid - )")
					highPicks.push({song:p,index:cnt,winner:w})
				} else if (low && inStr(i.text.text,low)) { ; low pick
					;lowWins++
					;p:=regExReplace(i.DDLS.text,"(Solo - )|(Strum - )|(Hybrid - )")
					lowPicks.push({song:p,index:cnt,winner:w})
				} else if !inStr(i.text.text,"picks"){ ; must be tb?
					tb:={song:p,winner:w}
				}
				out.="G" a_index ": " i.text.text p (i.DDL.text ? " - " i.DDL.text " wins!" : "") "`n"
			}
		}

		out:=(group?"Group " group "`n`n":"")
			. (this.highSeedNum?this.highSeedNum " ":"") high " " highWins "-" lowWins " " low (this.lowSeedNum?" " this.lowSeedNum:"") "`n`n"
			. (this.g.c.coinFlipResult.value?this.highSeed " calls _____, coin flip lands on " this.g.c.coinFlipResult.value "`n`n":"")
			. (this.deferV?high " deferred ban/pick`n`n":"")
			. this.highSeed " bans " (highBan:=regExReplace(g.c.highSeedBanDDL.text,"(Solo - )|(Strum - )|(Hybrid - )")) "`n"
			. this.lowSeed " bans " (lowBan:=regExReplace(g.c.lowSeedBanDDL.text,"(Solo - )|(Strum - )|(Hybrid - )")) "`n`n"
			. out "`n"
			. (highWins > this.songCnt//2 ? high " wins!": (lowWins > this.songCnt//2 ? low " wins!": (highWins = this.songCnt//2 && highWins=lowWins ? "Drawn Match" : "")))
		
		; format json
		winner:=highWins > lowWins ? "highSeed" : highWins == lowWins ? "draw" : "lowSeed"
;		coinFlip:=this.g.c.coinFlipResult.value?this.highSeed
		jOut:={group:group,setlist:g.c.setlistDDL.text,defer:this.deferV,winner:winner,songCount:this.songCnt,
			highSeed:{
				seed:this.highSeedNum?trim(this.highSeedNum,"()"):0,
				name:high,
				wins:highWins,
				ban:highBan,
				picks:highPicks
			},
			lowSeed:{
				seed:this.lowSeedNum?trim(this.lowSeedNum,"()"):0,
				name:low,
				wins:lowWins,
				ban:lowBan,
				picks:lowPicks
			}
		}
		if tb {
			jOut.tb:=tb
		}
		this.sOut:=out
		this.jOut:=JSON.Dump(jOut)
	}

	output(ctrl,_) { ; on-exit or clipboard button
		err:=this.outputMake()
		if err {
			tool("Add player names first!")
			return
		}
		; check for live instance
;		aLog(jOut,this.files.alog this.uuid)
;		aLog(jOut,this.files.alog this.aID)

		; called from quit or button?
		if (_="exit") {
			mLog(this.sOut,this.files.log)
			mLog(this.jOut,this.files.jlog)
			try {
				fileDelete(this.files.alog this.aID)
			}
		} else {
			a_clipboard:=this.sOut
			tool("Output saved to clipboard")
		}
	}

	outputLive(_*) { ; live json update
		err:=this.outputMake()
		if err {
			return
		}
		;aLog(jOut,this.files.alog this.uuid)
		aLog(this.jOut,this.files.alog this.aID)
		if this.uuid {
			this.jsonPost(this.jOut)
		}
	}

	jsonPost(jsonP) {
		; post-call with json to server
		return
	}

	getScreenshot(ctrl,_) {
		g:=this.g
		
		static ts:=regExReplace(timeStamp().timedates,"\/|:",".")
		if !(g.c.highSeedEdit.value || g.c.highSeedEdit.value) {
			msgbox("Please enter both player names before taking a screenshot.","Screenshot")
		} else {
			dirCreate(scPath:=files.matches "\" g.c.highSeedEdit.value " vs " g.c.lowSeedEdit.value " - " ts)
			fPath:=screenshot(scPath)
			winActivate("ahk_id" g.hwnd)

			; validate and notify user
			if (fileExist(fPath)) {
				tool("Screenshot taken")
			} else {
				tool("Unspecified error, Screenshot not taken",5000)
			}
		}
	}

	playerUpdate(seed,ctrl,_) {
		g:=this.g
		pName:=ctrl.value
		
		; swap players if ban deferred
		if (this.deferV) {
			seed:=(seed="high"?"low":"high")
		}
		
		; check for seed number
		regExMatch(pName,"\(\d+\)",&seedNum:=unset)
		
		if (seed="high") {
			if this.highSeed = pName { ; didn't change
				return
			}
			if (isObject(seedNum)) {
				this.highSeedNum:=seedNum[]
				pName:=trim(strReplace(pName,seedNum[]))
			} else {
				this.highSeedNum:=""
			}
			g.c.highSeedBanText.text:=pName " bans"
			g.c.games[1].text.text:=pName " picks"
			this.highSeed:=pName
		} else if (seed="low") {
			if this.lowSeed = pName { ; didn't change
				return
			}
			if (isObject(seedNum)) {
				this.lowSeedNum:=seedNum[]
				pName:=trim(strReplace(pName,seedNum[]))
			} else {
				this.lowSeedNum:=""
			}
			g.c.lowSeedBanText.text:=pName " bans"
			this.lowSeed:=pName
		}

		for i in g.c.games {
			i.DDL.delete()
			a:=[""]
			if (this.highSeed) {
				a.push(this.highSeed)
			}
			if (this.lowSeed) {
				a.push(this.lowSeed)
			}
			i.DDL.add(a)
			
			; blank out names for picks
			if (a_index<this.songCnt-1) {
				g.c.games[a_index+1].text.text:=" picks "
			}
		}

		; altConfig switch
		switch this.altConfig {
			case "BWS":
				this.altBWS()
		}
		this.outputLive()
	}

	songsUpdate(ctrl,_) {
		g:=this.g,setlist:=this.setlist
		
		set:=[""],set.push(setlist.sets[setlist.lists[g.c.setlistDDL.value]]*)
		setTB:=[""],setTB.push(setlist.setsTB[setlist.lists[g.c.setlistDDL.value]])
		this.altConfig:=setlist.altConfig[setlist.lists[g.c.setlistDDL.value]]

		g.c.highSeedBanDDL.delete()
		g.c.highSeedBanDDL.add(set)
		g.c.lowSeedBanDDL.delete()
		g.c.lowSeedBanDDL.add(set)
		
		for i in g.c.games {
			i.DDLS.delete()
			if (a_index=g.c.games.length) {
				if !setTB.length { ; no TBs
					if g.c.games[g.c.games.length].text.text != "picks" {
						g.c.games[g.c.games.length].text.text := "picks"
					}
					i.DDLs.add(set)
				} else {
					if g.c.games[g.c.games.length].text.text != "TIEBREAKER - " {
						g.c.games[g.c.games.length].text.text := "TIEBREAKER - "
					}
					i.DDLS.add(setTB)
				}
			} else {
				if (i.text.text != "picks") {
					i.text.text := "picks"
				}
				i.DDLS.add(set)
			}
		}
		; altConfig switch
		switch this.altConfig {
			case "BWS":
				this.altBWS()
		}
		this.outputLive()
	}

	nextPick(ctrl,_) {
		g:=this.g,songCnt:=this.songCnt
		
		high:=this.highSeed
		low:=this.lowSeed
		
		; altConfig switch
		switch this.altConfig {
			case "BWS":
				this.outputLive()
				return
		}

		for i in g.c.games {
			if (a_index = songCnt-1 && this.setlist.setsTB[this.setlist.lists[this.g.c.setlistDDL.value]].length)
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
		this.outputLive()
	}

	defer(ctrl,_) {
		this.deferV:=ctrl.value,g:=this.g
		p1:=trim(strReplace(g.c.highSeedEdit.value,this.highSeedNum))
		p2:=trim(strReplace(g.c.lowSeedEdit.value,this.lowSeedNum))
		
		if (this.deferV) { ; swap players
			this.highSeed:=p2
			this.lowSeed:=p1
		} else { ; swap back to normal
			this.highSeed:=p1
			this.lowSeed:=p2
		}

		; swap bans & first pick
		g.c.highSeedBanText.text:=this.highSeed " bans"
		g.c.lowSeedBanText.text:=this.lowSeed " bans"
		g.c.games[1].text.text:=this.highSeed " picks "

		; altConfig switch
		switch this.altConfig {
			case "BWS":
				this.altBWS()
		}
		this.outputLive()
	}

	onHover() {
		if winActive("ahk_id" this.g.hwnd) {
			mouseGetPos(,,&win:=0,&wCtrl:=0)
			if (win = this.g.hwnd && inStr(wCtrl,"ComboBox")) {
				bNum:=subStr(wCtrl,9)
				
				if (bNum = 1) { ; Setlist DDL
					return
				} else if (bNum > 3 && mod(bNum,2)) { ; Winner DDL
					return
				} else {
					cText:=controlGetText(wCtrl,"ahk_id" this.g.hwnd)
					if (cText!=this.g.c.songHover.text) {
						this.g.c.songHover.text:=cText
					}
				}
			} else if (this.g.c.songHover.text) {
				this.g.c.songHover.text:=""
			}
		}
	}

	updateIni(ctrl,_) {
		r:=msgbox("Updating the ini file will delete your current ini file. Are you sure you want to update?","Ini Update Confirmation",4)
		if (r="Yes") {
			fileDelete(files.ini)
			this.loadData()
			this.g.c.setlistDDL.delete()
			this.g.c.setlistDDL.add(this.setlist.lists)
		}
	}
	
	coinFlip(ctrl,_) {
		this.g.c.coinFlipResult.value:=(random(0,1)?"Heads":"Tails")
		ctrl.enabled:=0
	}
	
	quit(reason,code) {
		this.output(0,"exit")
	}

	; altConfigs
	altBWS(){

		; pre-set all picks
		for i in this.g.c.games {
			if (a_index=this.g.c.games.length) {
				if i.text.text != "DECIDER - " {
					i.text.text := "DECIDER - "
				}
			} else {
				cPick := mod(this.deferV?a_index+1:a_index,2)?this.highSeed:this.lowSeed
				i.text.text := cPick " picks"
			}
		}
	}
}
