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