$(function() {
    var copyCardNodeSelector = '#registration_copy_cards';
    $(document).on('change', copyCardNodeSelector, updateCostsWhenCopyCardQuantityChanged);
    if ($(copyCardNodeSelector).length) {
        updateCostsWhenCopyCardQuantityChanged();
    }
});

function updateCostsWhenCopyCardQuantityChanged() {
    var no_of_cards_obj = document.getElementById('registration_copy_cards');
    var no_of_cards = no_of_cards_obj.value;

    if (no_of_cards < 0) {
        no_of_cards = 0;
    }

    var total_fee = 0;
    var outstanding_balance_obj = document.getElementById('registration_outstanding_balance');
    var card_fee_obj = document.getElementById('registration_copy_card_fee');
    var total_fee_obj = document.getElementById('registration_total_fee');
    var registration_fee_obj = document.getElementById('total_excluding_copy_cards');

    card_fee_obj.value = Number(no_of_cards * 5).toFixed(2); // FIXME this monetary value duplicates amother Rails variable

    // Add extra handling to cope with orders that do not have registration fee's
    if (registration_fee_obj !== null) {
        total_fee = Number(card_fee_obj.value) + Number(registration_fee_obj.value)
    }
    else {
        total_fee = Number(card_fee_obj.value)
    }

    if (outstanding_balance_obj !== null) {
      total_fee += Number(outstanding_balance_obj.value)
    }

    total_fee_obj.value = Number(total_fee).toFixed(2);
}


$("#addressSelector").change(function(){
    $("#addressSelector").removeAttr("size");
});


$('input[type="radio"]').click(function(){
    $(this).toggleClass('yeller');
});
