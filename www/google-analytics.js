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
  $(document).on('change', '#t1_School_ID', function(e) {
    ga('send', 'event', 'widget', 'select school', $(e.currentTarget).val());
  });

//Track measure inputted on similar schools tab  
  $(document).on('change', '#t1_measures', function(e) {
    ga('send', 'event', 'widget', 'select t1 measures', $(e.currentTarget).val());
  });

//Track measure inputted on school to school tab  
  $(document).on('change', '#t2_measures', function(e) {
    ga('send', 'event', 'widget', 'select t2 measures', $(e.currentTarget).val());
  });
  

