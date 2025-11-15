class timeStamp {
	__new(stamp:="") {
		if(!stamp)
			this.stamp:=stamp:=a_now
		else
			this.stamp:=stamp
		this.year:=subStr(stamp,1,4)
		this.month:=subStr(stamp,5,2)
		this.day:=subStr(stamp,7,2)
		this.hour:=subStr(stamp,9,2)
		this.hourap:=this.hour>12?this.hour-12:this.hour+0
		this.ap:=this.hour>12?"pm":"am"
		this.minute:=subStr(stamp,11,2)
		this.second:=subStr(stamp,13,2)
		
		; pre-formatted
		this.date:=(td:=this.month "/" this.day) "/" this.year ; imperial
		;this.date:=(td:=ts.day "/" ts.month) "/" ts.year ; metric
		this.date2:=td "/" subStr(this.year,3)
		this.time:=this.hour ":" this.minute
		this.timeap:=this.hourap ":" this.minute " " this.ap
		this.timedate:=this.date " " this.time
		this.timedates:=this.date "_" this.time ":" this.second
		this.timedateap:=this.date " " this.timeap
		this.timedate2:=this.date2 " " this.time
		this.timedateap2:=this.date2 " " this.timeap
	}
}

tool(str:="",wait:=2500,x:=unset,y:=unset) {
	if (!str) {
		tooltip()
	} else {
		tooltip(str,x?,y?)
		setTimer(tool,-wait)
	}
	return str
}

mLog(text,logFile) {
	fileOpen(logFile,2,"UTF-8").write(a_nowUTC " | " timeStamp(a_nowUTC).timedate  " | " timeStamp().timedate "`n" text "`n`n")
}

aLog(text,logFile) {
	fileOpen(logFile,1,"UTF-8").write(text)
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
	return filePath "\" cnt
}

b64e(bin,binSize) {
	dllCall("Crypt32.dll\CryptBinaryToString","Ptr",bin,"UInt",binSize,"UInt",0x1,"Ptr",0,"UInt*",&oL:=0)
	bOut:=buffer(oL << 1,0)
	dllCall("Crypt32.dll\CryptBinaryToString","Ptr",bin,"UInt",binSize,"UInt",0x1,"Ptr",bOut,"UInt*",&oL)
	return strReplace(strGet(bOut),"`r`n")
}

reverseArray(iArray) {
	rArray:=[]
	for i,a in iArray {
		rArray.insertAt(1,a)
	}
	return rArray
}

urlDownloadToVar(url,raw:=0,headers:="",userAgent:=""){
	if (!regExMatch(url,"i)https?://"))
		url:="https://" url
	try {
		hObject:=comObject("WinHttp.WinHttpRequest.5.1")
		hObject.open("GET",url)
		if (userAgent)
			hObject.setRequestHeader("User-Agent",userAgent)
		if (isObject(headers)) {
			for i,a in headers {
				hObject.setRequestHeader(i,a)
			}
		}
		hObject.send()
		return raw?hObject.responseBody:hObject.responseText
	} catch any as e
		return e.message
}

httpPost(url,body,headers:="",userAgent:="") {
	if (!regExMatch(url,"i)https?://"))
		url:="https://" url
	try {
		hObject:=comObject("WinHttp.WinHttpRequest.5.1")
		hObject.open("POST",url)
		if (userAgent)
			hObject.setRequestHeader("User-Agent",userAgent)
		if (isObject(headers)) {
			for i,a in headers {
				hObject.setRequestHeader(i,a)
			}
		}
		hObject.send(body)
		return hObject.responseText
	} catch any as e
		return e.message
}