jQuery(function($){
	var theChartOptions = {chartRangeMin:1, chartRangeMax:5, width:"200px"}
	$("*:radio").click(function(evt){
		var theName = this.name;
		$.post("/answer",{question_id:this.name, value:this.value},
			function(data){
				$("#graph-"+theName).sparkline(data.values,theChartOptions);
			},"json");
	});
	
	$(".graph").sparkline('html',theChartOptions);
});
