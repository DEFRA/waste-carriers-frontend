
$.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}


$(function() {
  $(document).on('change', '#registration_copy_cards', function() {

   var no_of_cards_obj = document.getElementById('registration_copy_cards');
   var no_of_cards = no_of_cards_obj.value;

   if (no_of_cards < 0) {
       no_of_cards = 0;
   }

   var card_fee_obj = document.getElementById('registration_copy_card_fee');
   var total_fee_obj = document.getElementById('registration_total_fee');
   var registration_fee_obj = document.getElementById('registration_registration_fee');

    card_fee_obj.value = Number(no_of_cards * 5).toFixed(2); // FIXME this monetary value duplicates amother Rails variable
    
    // Add extra handling to cope with orders that do not have registration fee's
    if (registration_fee_obj !== null) {
        total_fee_obj.value =  Number(Number(card_fee_obj.value) + Number(registration_fee_obj.value)).toFixed(2)
    }
    else {
        total_fee_obj.value =  Number(Number(card_fee_obj.value)).toFixed(2)
    }


    // make sure users can't order 0 copy cards when ordering only copy cards
    if (($(this).val() == 0) && ($.urlParam('from') == 'add_copy_cards')){       
      $("#worldpay_button").prop('disabled', true);
      $("#offline_pay_button").prop('disabled', true);
    } else {
       $("#worldpay_button").prop('disabled', false);
       $("#offline_pay_button").prop('disabled', false);
    }

  });
});


$("#addressSelector").change(function(){
    $("#addressSelector").removeAttr("size");
});


$('input[type="radio"]').click(function(){
          $(this).toggleClass('yeller');
});



