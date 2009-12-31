jQuery(function($){
	$("*:radio").click(function(evt){
		var theName = this.name;
		$.post("/answer",{question_id:this.name, value:this.value},
			function(data){
				$("#graph-"+theName).sparkline(data.values,{chartRangeMin:1, chartRangeMax:5});
			},"json");
	});
});