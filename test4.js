const unixTimestamp = 1698720885;

var date = new Date(unixTimestamp * 1000);
var formattedDate = date.toLocaleString(); // 형식화된 날짜 및 시간
console.log(formattedDate);