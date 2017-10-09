//Google Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();
  a=s.createElement(o), m=s.getElementsByTagName(o)[0];
  a.async=1;
  a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-107125936-3', 'auto');
  ga('send', 'pageview');


//Front page

//Track school name  
//Works
  $(document).on('click', '#submit_t1_School_ID', function(e) {
    ga('send', 'event', 'widget', 'select school', $("#t1_School_ID").val());
  });


//Main tool - Similar Schools Tab

//Track measure inputted on similar schools tab 
//Works
  $(document).on('change', '#t1_measures', function(e) {
    ga('send', 'event', 'widget', 'select t1 measures', $(e.currentTarget).val());
    
  
  });

//Track plot type
//Works!
$(document).on('change', '#plot_type :radio', function(e) {
  if(this.checked && this.value == 'density'){
      ga('send', 'event', 'widget', 'select plot type', $(e.currentTarget).val());
    } 
  else if(this.checked && this.value == 'histogram'){
      ga('send', 'event', 'widget', 'select plot type', $(e.currentTarget).val());
    }
  });




//Track characteristics check on similar schools tab  
//Works
  $(document).on('change', '#t1_characteristics :checkbox', function(e) {
      if(this.checked) {
        ga('send', 'event', 'widget', 'select t1 checkbox', $(e.currentTarget).val());
    }
  });

  
//Track similar schools report
//work but measures don't come up
  $(document).on('click', '#t1_report', function() {
    ga('send', 'event', 'widget', 'generate similar schools report');
  });


//School to School tab

//Track measure inputted on school to school tab
//Works
  $(document).on('change', '#t2_measures', function(e) {
    ga('send', 'event', 'widget', 'select t2 measures', $(e.currentTarget).val());
  });

//Track schools inputted on school to school tab  
//Works but measures won't come up
  $(document).on('change', '#t2_Schools', function() {
    ga('send', 'event', 'widget', 'select t2 schools', $('#t2_Schools').val());
  });
  
//Track school to school report 
//works but measures don't come up
  $(document).on('click', '#t2_report', function() {
    ga('send', 'event', 'widget', 'generate school to school report',$("#t2_report_measures").val());
  });