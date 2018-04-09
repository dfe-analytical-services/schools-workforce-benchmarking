//Google Analytics

//code to add general tracking to the tool
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();
  a=s.createElement(o), m=s.getElementsByTagName(o)[0];
  a.async=1;
  a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-108704572-1', 'auto');
  ga('send', 'pageview');

//Tracking activity in the tool

//Front page

//Track school name  and URN
  $(document).on('click', '#submit_t1_School_ID', function(e) {
    ga('send', 'event', 'widget', 'select school', $("#t1_School_ID").val());
  });


//Main tool - Similar Schools Tab

//Track measure inputted on similar schools tab 
  $(document).on('change', '#t1_measures', function(e) {
    ga('send', 'event', 'widget', 'select t1 measures', $(e.currentTarget).val());
  });

//Track plot type
$(document).on('change', '#plot_type :radio', function(e) {
  if(this.checked && this.value == 'density'){
      ga('send', 'event', 'widget', 'select plot type', $(e.currentTarget).val());
    } 
  else if(this.checked && this.value == 'histogram'){
      ga('send', 'event', 'widget', 'select plot type', $(e.currentTarget).val());
    }
  });



//Track characteristics chosen on similar schools tab  
  $(document).on('change', '#t1_characteristics :checkbox', function(e) {
      if(this.checked) {
        ga('send', 'event', 'widget', 'select t1 checkbox', $(e.currentTarget).val());
    }
  });

  
//Track similar schools report
  $(document).on('click', '#t1_report', function() {
    ga('send', 'event', 'widget', 'generate similar schools report');
  });

//Track report plot type
$(document).on('change', '#report_plot_type :radio', function(e) {
  if(this.checked && this.value == 'density'){
      ga('send', 'event', 'widget', 'select plot type', $(e.currentTarget).val());
    } 
  else if(this.checked && this.value == 'histogram'){
      ga('send', 'event', 'widget', 'select plot type', $(e.currentTarget).val());
    }
  });


//School to School tab

//Track measure inputted on school to school tab
  $(document).on('change', '#t2_measures', function(e) {
    ga('send', 'event', 'widget', 'select t2 measures', $(e.currentTarget).val());
  });

  
//Track school to school report 
  $(document).on('click', '#t2_report', function() {
    ga('send', 'event', 'widget', 'generate school to school report');
  });