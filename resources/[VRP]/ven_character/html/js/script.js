$(document).ready(function(){
  // Listen for NUI Events
  window.addEventListener('message', function(event){
    var item = event.data;
    if(item.openBlackscreen == true) {
      openBlackscreen();
    }
    else if(item.openBlackscreen == false) {
      closeBlackscreen();
    }
    else if(item.openForm == true) {
      openForm();
    }
    else if(item.closeForm == true) {
      closeForm();
    }
    else if(item.showIcon == true) {
      showIcon();
    }
    else if(item.hideIcon == true) {
      hideIcon();
    }
  });
  
  //Register clicks
  $("#submitform").click(function(){
	  submitData();
  });
  
  $("#firstname").click(function(){
	  document.getElementById("firstname").focus();
  });
  
  $("#lastname").click(function(){
	  document.getElementById("lastname").focus();
  });
  
  $("#age").click(function(){
    document.getElementById("age").focus();
  });

  $("#gender").click(function(){
    document.getElementById("gender").focus();
  });
  
  //GUI Functions
  function closeAll() {
    $(".body").css("display", "none");
  }
  
  function openBlackscreen() {
    $(".div_merda").css("display", "inline-block");
  }

  function closeBlackscreen() {
    $(".div_merda").css("display", "none");
  }
  
  function openForm() {
    $("#menuzinho").fadeIn(1000);
  }

  function showIcon() {
    $(".body").css("display", "flex");
    $("#iconezinho").fadeIn(1000);
  }

  function hideIcon() {
    $("#iconezinho").fadeOut(1000);
  }
  
  function closeForm() {
    $(".body").css("display", "none");
  }
  
  function submitData() {
    $.post('http://vrp_firstid/submit', JSON.stringify({
  		first: document.getElementById("firstname").value,
  		last: document.getElementById("lastname").value,
		//gender: document.getElementById("gender").value,
  		age: document.getElementById("age").value
  	}));
  }
});
