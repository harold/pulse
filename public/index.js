jQuery(function($){
	var theChartOptions = {chartRangeMin:1, chartRangeMax:5, width:"250px"}
	$("*:radio").click(function(evt){
		var theName = this.name;
		$.post("/answer",{question_id:this.name, value:this.value},
			function(data){
				$("#graph-"+theName).sparkline(data.values,theChartOptions);
			},"json");
	});
	
	$(".graph").sparkline('html',theChartOptions).click(function(){
		location = '/detail/'+$(this).parents('.question').attr('id');
	});
	
	$("a.hide").click(function(evt){
		var theQuestionWrapper = $(this.parents('.question'));
		$.post(this.href,function(){ theQuestionWrapper.remove(); });
		return false;
	});
	
	var theUpdateButtonForQuestion = function(question){
		question.find('.showhide').html( question.hasClass('hidden') ? 'show' : 'hide' );
	};
	
	$('#manage').click(function(){
		window.managingQuestions = !window.managingQuestions;
		$(this).html( window.managingQuestions ? 'Done Managing' : 'Manage Questions' );
		$('.manage-questions').toggle(window.managingQuestions);
		$('.answer-radios').toggle(!window.managingQuestions);
		$('.graph').toggle(!window.managingQuestions);
		$('.hidden').toggle(window.managingQuestions);
		
		if (window.managingQuestions){
			$('.showhide').each(function(){
				var theQuestion = $(this).parents('.question').eq(0);
				theUpdateButtonForQuestion(theQuestion);
			});
		}else{
			$.sparkline_display_visible();
		}
	});
	
	$('.showhide').click(function(){
		var theQuestion = $(this).parents('.question').eq(0);
		theQuestion.toggleClass('hidden');	
		var theNowHiddenFlag = theQuestion.hasClass('hidden');
		var theAction = theNowHiddenFlag ? 'hide' : 'show';
		$.post('/'+theAction+'/'+theQuestion.attr('id'),function(){theUpdateButtonForQuestion(theQuestion);});
	});
	
	$('#add-question').submit(function(){
		var theQuestion = this.elements.text;
		theQuestion.value = theQuestion.value.replace(/^\s+|\s+$/g,'');
		if ( !theQuestion.value ){
			alert( "I think you forgot to type the text of the question." );
			return false;
		}
	});
});
