
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
    total_fee_obj.value =  Number(Number(card_fee_obj.value) + Number(registration_fee_obj.value)).toFixed(2)

  });
});


$("#addressSelector").change(function(){
    $("#addressSelector").removeAttr("size");
});



$('input[type="radio"]').click(function(){
          $(this).toggleClass('yeller');
});



