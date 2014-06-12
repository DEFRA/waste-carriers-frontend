
$(function() {
  $(document).on('change', '#registration_copy_cards', function() {

   var no_of_cards_obj = document.getElementById('registration_copy_cards');
   var no_of_cards = no_of_cards_obj.value;
   var card_fee_obj = document.getElementById('registration_copy_card_fee');
   var total_fee_obj = document.getElementById('registration_total_fee');
   var registration_fee_obj = document.getElementById('registration_registration_fee');

    card_fee_obj.value = no_of_cards * 5
    total_fee_obj.value =  Number(card_fee_obj.value) + Number(registration_fee_obj.value)

  });
});


$("#addressSelector").change(function(){
    $("#addressSelector").removeAttr("size");
    $("#selected_business_address").val( $( "#addressSelector option:selected" ).text() );
});

