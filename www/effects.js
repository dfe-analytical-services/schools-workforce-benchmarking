//Function to hide the navbar on load and disable submit button when app loads

$(document).ready(function() {
  $("#navbar").hide();
  $("#change_t1_School_ID").hide();
  $("#submit_t1_School_ID").prop('disabled', true);
});