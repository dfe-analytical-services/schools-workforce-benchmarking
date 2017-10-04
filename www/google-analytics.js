//Google Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();
  a=s.createElement(o), m=s.getElementsByTagName(o)[0];
  a.async=1;
  a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-107125936-3', 'auto');
  ga('send', 'pageview');

//Track school name  
  $(document).on('click', '#submit_t1_School_ID', function(e) {
    ga('send', 'event', 'widget', 'select school', $("#t1_School_ID").val());
  });

//Track measure inputted on similar schools tab  
  $(document).on('change', '#t1_measures', function(e) {
    ga('send', 'event', 'widget', 'select t1 measures', $(e.currentTarget).val());
  });

//Track measure inputted on similar schools tab  
  $(document).on('change', '.checkbox', function(e) {
    ga('send', 'event', 'widget', 'select t1 checkbox');
  });

//Track measure inputted on school to school tab  
  $(document).on('change', '#t2_measures', function(e) {
    ga('send', 'event', 'widget', 'select t2 measures', $(e.currentTarget).val());
  });
  
//Track similar schools report  
  $(document).on('click', '#t1_report', function() {
    ga('send', 'event', 'widget', 'generate similar schools report')
  });

//Track similar schools report  
//  $(document).on('click', '#t1_report', function() {
//    ga('send', 'event', 'widget', 'generate similar schools report', //$("#t1_report_measures").val());
//  });

//Checkbox attempts

//$('t1_characteristics').each(function(){
//  if($(this).is(':checked')){ 
//    ga('send', 'event', 'widget', 'a', $(this).val()); // 
//  }
//});

//$(document).ready(function(){
//$('t1_characteristics').each(function(){
//  if($('#t1_characteristics').is(':checked')){ 
//    ga('send', 'event', 'widget', 'a', $('#t1_characteristics').val());
//  }
//})
//});

//$("#t1_characteristics").click(function() {
//  if ($(this).is(":checked")) {
//    ga('send', 'event', 'widget', 'a', $('#t1_characteristics').val());
//  }
//});

