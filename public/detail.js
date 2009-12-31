jQuery(function($){
	var theQuestionId = $("#flot-graph").attr("question_id");
	$.post("/detaildata", {question_id:theQuestionId}, function(data){
		$.plot($("#flot-graph"), [data.values], { xaxis: { mode: "time" },
		                                          yaxis: { min: 1, max: 5} }
		);
	},"json");
});
