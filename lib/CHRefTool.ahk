﻿class CHRefTool {
	__new(files,songCnt) {
		this.files:=files,this.songCnt:=songCnt
		this.highSeed:=this.lowSeed:=this.highSeedNum:=this.lowSeedNum:=""
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

		; check/write ini
		if !fileExist(files.ini) {
			fileAppend(b64dText("DQpbQ1NDIE9wZW4gNF0NCjAxPVRpbHRgU29sbw0KMDI9VGhlIFNlY29uZCBMb3VkZXN0IEd1aXRhciBJbiBUaGUgV29ybGRgU29sbw0KMDM9TWlkbmlnaHRgU29sbw0KMDQ9TGlmZSBDb250cm9sbGVyYFN0cnVtDQowNT1TYXR1cm5pbmVgU3RydW0NCjA2PU5pdHJ1c2BTdHJ1bQ0KMDc9VHJ1c3RgSHlicmlkDQowOD1EZWF0aCBQZXJjZXB0aW9uYEh5YnJpZA0KMDk9TCdFbnRpdGVgSHlicmlkDQoxMD1Hcm91bmRob2cgKEJlYXQgSnVnZ2xlKWBIeWJyaWQNCjExPUZvcmdvdHRlbiBUcmFpbGBTb2xvVEINCjEyPUNoYXJnaW5nIFRoZSBWb2lkYFN0cnVtVEINCjEzPVNlZSBUaGUgTGlnaHQgb2YgRnJlZWRvbWBIeWJyaWRUQg0KW0NTQyA0IEFtYXRldXJdDQowMT1XaWdnbGVjb3JlYFNvbG8NCjAyPUUuQi5FYFNvbG8NCjAzPUZlbGlzICgxMTAlKWBTb2xvDQowND0oQm9zcykgQm9keSBBbmQgU291bGBTb2xvQm9zcw0KMDU9U29saWxvcXV5YFN0cnVtDQowNj1IYXZhIE5hZ2lsYWBTdHJ1bQ0KMDc9WmhvcnlrYFN0cnVtDQowOD0oQm9zcykgQW5kIFRoZSBNb29uIFR1cm5lZCBCbGFjayAoMTEwJSlgU3RydW1Cb3NzDQowOT1Qb2lzb24gV2FzIFRoZSBDdXJlIFtDU0M6Q1MgRWRpdF1gSHlicmlkDQoxMD1BbmRyb21lZGEgKDExNSUpYEh5YnJpZA0KMTE9TmV2ZXJtb3JlYEh5YnJpZA0KMTI9VGltZSBUcmF2ZWxlciAoMTE1JSlgSHlicmlkDQoxMz0oQm9zcykgVGhlIFVuc2VlbiBPbmVzYEh5YnJpZEJvc3MNCjE0PU1vb25saWdodCBTb25hdGEsIDNyZCBNb3ZlbWVudGBTb2xvVEINCjE1PURlc3Ryb3llcmBTdHJ1bVRCDQoxNj1HbG9yeSBUbyBUaGUgV29ybGRgSHlicmlkVEINCltDU0MgNCBQbGF5b2Zmc10NCjAxPUZpbmdlcm9pZCAoMTEwJSlgU29sbw0KMDI9VHJhY2sgb24gRmlyZWBTb2xvDQowMz1DaGVhdGluZyB0aGUgTkFTQSBTcGFjZSBQaHlzaWNhbCAoMTEwJSlgU29sbw0KMDQ9KEJvc3MpIFByZXZhaWwgKEphcnZpczk5OTkgQ292ZXIpYFNvbG9Cb3NzDQowNT0yNSBNZXRhbCBSaWZmcyBQbGF5ZWQgYXQgMjMwIEJQTWBTdHJ1bQ0KMDY9WWUgRW50cmFuY2VtcGVyaXVtYFN0cnVtDQowNz1UaGUgQ3J5cHRvZ3JhcGhlcmBTdHJ1bQ0KMDg9KEJvc3MpIFNjb3VyZ2Ugb2YgdGhlIE9mZnNwcmluZyAoMTI1JSlgU3RydW1Cb3NzDQowOT1MZWdlbmQgKDEyNSUpYEh5YnJpZA0KMTA9VHVya2V5IFR1cmtleWBIeWJyaWQNCjExPUVuZGFya2VubWVudCAoQW5hYWwgTmF0aHJha2ggQ292ZXIpYEh5YnJpZA0KMTI9T3JiIFtDU0MgRWRpdF0gKDEyNSUpYEh5YnJpZA0KMTM9KEJvc3MpIEZsYXNoYmFja2xvZ2BIeWJyaWRCb3NzDQoxND1VbmZsZXNoIFNvbG8gTWVkbHlgU29sb1RCDQoxNT1TYWxpZ2lhYFN0cnVtVEINCjE2PVBhcmFsbGVsIFVuaXZlcnNlIFNoaWZ0ZXJgSHlicmlkVEINCg==")
				,files.ini)
		}

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
			setlist.sets[i]:=set
			setlist.setsTB[i]:=setTB
		}
		this.setlist:=setlist
	}

	makeGui() {
		songCnt:=this.songCnt
		
		; create gui
		g:=gui("+E0x2080000","CloneHero Tournament Reffing",this)
		g.setFont("s15","Helvetica")

		; controls
		g.c:=object()

		; basic info
		g.c.setlistText:=g.add("text","section","Setlist: ")
		g.c.setlistDDL:=g.add("dropDownList","ys",this.setlist.lists) ; setlist
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
			g.c.games[a_index].DDL.onEvent("change","nextPick")
		}

		; gui events
		g.onEvent("close",a=>exitApp())
		g.c.outputButton.onEvent("click","output")
		g.c.highSeedEdit.onEvent("loseFocus",objBindMethod(this,"playerUpdate","high"))
		g.c.lowSeedEdit.onEvent("loseFocus",objBindMethod(this,"playerUpdate","low"))
		g.c.setlistDDL.onEvent("change","songsUpdate")
		g.c.screenshotButton.onEvent("click","getScreenshot")

		this.g:=g
	}

	; event methods
	output(ctrl,_) {
		g:=this.g
		
		high:=this.highSeed
		low:=this.lowSeed
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
			. (this.highSeedNum?this.highSeedNum " ":"") high " " highWins "-" lowWins " " low (this.lowSeedNum?" " this.lowSeedNum:"") "`n`n"
			. high " bans " regExReplace(g.c.highSeedBanDDL.text,"(Solo - )|(Strum - )|(Hybrid - )") "`n"
			. low " bans " regExReplace(g.c.lowSeedBanDDL.text,"(Solo - )|(Strum - )|(Hybrid - )") "`n`n"
			. regExReplace(out1,"(Solo - )|(Strum - )|(Hybrid - )") "`n"
			. (highWins > lowWins ? high : low) " wins!"
		
		; called from quit or button?
		if (_="exit") {
			mLog(out,this.files.log)
		} else {
			a_clipboard:=out
			tool("Output saved to clipboard")
		}
	}

	getScreenshot(ctrl,_) {
		g:=this.g
		
		static ts:=regExReplace(timeStamp().timedates,"\/|:",".")
		if !(g.c.highSeedEdit.value || g.c.highSeedEdit.value) {
			msgbox("Please enter both player names before taking a screenshot.","Screenshot")
		} else {
			dirCreate(scPath:=files.matches "\" g.c.highSeedEdit.value " vs " g.c.lowSeedEdit.value " - " ts)
			screenshot(scPath)
			winActivate("ahk_id" g.hwnd)
		}
	}

	playerUpdate(seed,ctrl,_) {
		g:=this.g
		pName:=ctrl.value
		
		; check for seed number
		regExMatch(pName,"\(\d+\)",&seedNum:=unset)
		
		if (seed="high") {
			if (isObject(seedNum)) {
				this.highSeedNum:=seedNum[]
				pName:=trim(strReplace(pName,seedNum[]))
			} else {
				this.highSeedNum:=""
			}
			g.c.highSeedBanText.text:=pName " bans"
			g.c.games[1].text.text:=pName " picks "
			this.highSeed:=pName
		} else if (seed="low") {
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
			a:=[]
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
	}

	songsUpdate(ctrl,_) {
		g:=this.g,setlist:=this.setlist
		
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

	nextPick(ctrl,_) {
		g:=this.g,songCnt:=this.songCnt
		
		high:=this.highSeed
		low:=this.lowSeed
		
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

	quit(reason,code) {
		this.output(0,"exit")
	}
}
