reverseArray(iArray) {
	rArray:=[]
	for i,a in iArray {
		rArray.insertAt(1,a)
	}
	return rArray
}