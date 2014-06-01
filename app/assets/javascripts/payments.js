$('#copy_cards').change(function() {
    var one = this.val();
    alert(one);
    $('#copy_card_fee').val(one * 5);
});
