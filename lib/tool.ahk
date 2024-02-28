tool(str:="",wait:=2500,x:=unset,y:=unset) {
	if (!str) {
		tooltip()
	} else {
		tooltip(str,x?,y?)
		setTimer(tool,-wait)
	}
	return str
}