(function(){
	$('html').removeClass("nojs").addClass("js");
	var r = this;

	var page = 1;

	var addressLookup = {};

	var addressTextLookup = {};

	var advancedSearch = false;

	var useManualAddress;

	var orgTypeLookup = {
			"individual":"individual",
			"organisationOfIndividuals":"organisation of individuals",
			"limitedCompany":"limited company or limited liability partnership",
			"publicBody":"public body"
		};

	function findAddress(){
		var value = $("#registration_postcodeSearch").val();
		if(value == "")value = "MK5 7TQ";

		var $addresses = $("#addresses");
		$addresses.html("");
		for(var i=0; i<6; i++){
			var addr;
			var addrValue;
			if(i==0){
				addr = "Please select an address..";
				addrValue = "";
			}else{
				addr = (i+5)+" Some street, Some town, "+value;
				addrValue = "addr"+i;
			}

			var option = new Option(addr,addrValue);
			$(option).html(addr);
			$addresses.append(option);

			addressTextLookup[addrValue] = addr;
			//addressLookup[addrValue] = "<div>"+(i+5)+" Some street,</div><div>Some town,</div><div>"+value+"</div>";
			addressLookup[addrValue] = {houseNumber:i+5, streetLine1:"Some street",streetLine2:"",townCity:"Some town",postcode:value};
		}

		//$("#addressSearch").css("display","none");
		$("#addressSearchResults").css("display","");
	}

	function updateAddress(){
		var address = $("#addresses").val();
		if(address==="")return;

		//$("#addressDisplay").html(addressLookup[address]);
		
		var addressObject = addressLookup[address];
		$("#registration_houseNumber").val(addressObject.houseNumber);
		$("#registration_streetLine1").val(addressObject.streetLine1);
		$("#registration_streetLine2").val(addressObject.streetLine2);
		$("#registration_townCity").val(addressObject.townCity);
		$("#registration_postcode").val(addressObject.postcode);


		//$("#addressSearchResults").css("display","none");
		//$("#selectedAddress").css("display","");
		setHidden("uprn",address);
		setHidden("address",addressTextLookup[address]);

	}

	function manualAddress(){
		$("#addressSearchResults").css("display","none");
		$("#selectedAddress").css("display","none");
		$("input[name=findAddress]").css("display","none");
		$("#addressManual").css("display","");
		$("#addressSearch").css("display","");
		setHidden("uprn","");
		setHidden("address","");
		useManualAddress = true;
	}


	function submitAddress(){
		if(!useManualAddress){
			return;
		}
		var address = $("#registration_houseNumber").val() + " " + $("#registration_streetLine1").val();
		var address2 = $("#registration_streetLine2").val();
		if(address2!=""){
			address += ", "+address2;
		}
		var city = $("#registration_townCity").val();
		if(city!=""){
			address += ", "+city;
		}
		address += ", "+$("#registration_postcode").val();
		setHidden("address",address);
	}

	function changeAddress(){
		$("#selectedAddress").css("display","none");
		$("#addressSearch").css("display","");
		setHidden("uprn","");
		setHidden("address","");
	}

	function updateSummary(){
		var address = $("#addresses").val();
		address = addressLookup[address];

		var data = {
			organisationType: $("#registration_businessType").val(),
			organisationName: $("#registration_companyName").val(),
			title : $("#registration_title").val(),
			otherTitle : $("#registration_otherTitle").val(),
			firstName : $("#registration_firstName").val(),
			lastName : $("#registration_lastName").val(),
			emailAddress : $("#registration_emailAddress").val(),
			phoneNumber: $("#registration_phoneNumber").val(),
			individualsType: $("#registration_individualsType").val(),
			publicBodyType:$("#registration_publicBodyType").val(),
			address: address
		}

		updateSummaryWithData(data,$("#summary").get(0));
	}


	function searchResultSummaries(){
		$("#reg-search-result .detail .data").each(function(index,elem){
			var $elem = $(elem);
			var detailElem = elem.parentNode;
			var address = $elem.attr("data-address");

			var data = {
				organisationType: $elem.attr("data-organisationType"),
				organisationName: $elem.attr("data-organisationName"),
				title : $elem.attr("data-title"),
				otherTitle : $elem.attr("data-otherTitle"),
				firstName : $elem.attr("data-firstName"),
				lastName : $elem.attr("data-lastName"),
				emailAddress : $elem.attr("data-emailAddress"),
				phoneNumber: $elem.attr("data-phoneNumber"),
				individualsType: $elem.attr("data-individualsType"),
				publicBodyType:$elem.attr("data-publicBodyType"),
				mdStatus:$elem.attr("data-status"),
				address: address
			}


			updateSummaryWithData(data,elem);
			
			var div = document.createElement("div");
			var $div = $(div);
			$div.addClass("view");
			detailElem.parentNode.parentNode.parentNode.insertBefore(div,detailElem.parentNode.parentNode.parentNode.firstChild);

			var a = document.createElement("a");
			var $a = $(a);
			$a.attr("href","#");
			$div.append(a);
			
			if (data.mdStatus == "REVOKED") {
				var pStatus = document.createElement("div");
				var $pStatus = $(pStatus);
				$pStatus.addClass("revokedtext");
				$pStatus.html("Status: Revoked");
				$div.append(pStatus);
			}
			
			$a.click(authorViewDetail(detailElem,a));
			$a.click(resetAll() );
			
			new Tooltip(detailElem.parentNode,$elem.html(),function(){
				return $(detailElem).css("display") === "none";
			});
			
			$elem.parent().parent().parent().parent()
			  .mouseenter(function() {
			    // Hide all details boxes
			    resetAll();
			    
			    // Show this specific details box
			    $(detailElem).css("display","block");
			    $(detailElem).parent().parent().css("display","block");
			    
			    $(detailElem).parent().parent().parent().css("background-color", "#FFCC99");//orange
			    
			    // Reset link to a Hide link
			    $(a).html("Hide details");
			  });
			
		});
	}
	
	function resetAll(){
		$("#reg-search-result .detail .data").each(function(index,elem){
			// hide all details boxes
			var $elem = $(elem);
			var detailElem = elem.parentNode;
			$(detailElem).css("display","none");
			$(detailElem).parent().parent().css("display","none");
			$(detailElem).parent().parent().parent().css("background-color","rgb(222, 224, 226)");//grey
		});
		
		$("#reg-search-result .box .view a").each(function(index,elem){
			// revert all text links to default
			$(elem).html("View details");
		});
	}

	function authorViewDetail(elem,a){
		
		
		
		var shown = true;
		return function(e){
			// reset all details to hidden
			resetAll();
			e.preventDefault();
			if(!shown){
				$(elem).css("display","block");
				$(a).html("Hide details");
				// display/hide new details
				$(elem).parent().parent().css("display","block");
				
			}else{
				$(elem).css("display","none");
				$(a).html("View details");
				// display/hide new details
				$(elem).parent().parent().css("display","none");
			}
			shown = !shown;
		};
	}

	function updateSummaryWithData(data,elem){
		var registerAs = data.registerAs;
		var orgType = data.organisationType;
		var orgName = data.organisationName;

		var title = data.title;
		var firstName = data.firstName;
		var lastName = data.lastName;
		var email = data.emailAddress;
		var phone = data.phoneNumber;

		var address = data.address;


		var orgInfo = "";
		if (orgType==="organisationOfIndividuals") {orgInfo=data.individualsType;}
		else if (orgType==="limitedCompany") {orgInfo=data.companyRegistrationNumber;}
		else if (orgType==="publicBody") {orgInfo=data.publicBodyType;}

		if(orgInfo!==""){
			orgInfo = " ("+orgInfo+")";
		}

		var html = "<div>Registering for</div>";
		html += "<div>"+orgName+orgInfo+"</div>";
		html += "<p>At the following address</p>";
		html += address;
		html += "<p>Contact</p>";
		var tmpTitle = title;
		if (title==="Other") {
			tmpTitle = data.otherTitle;
		}
		html += "<div>"+tmpTitle+" "+firstName+" "+lastName+" ("+email+")</div>";
		html += "<div>Telephone number: "+phone+"</div>";


		$(elem).html(html);
	}

	function refreshQuestions(){
		var value = $("#registration_businessType").val();
		var publicBody = $("#registration_publicBodyType").val();

		$("#indType-wrapper").css("display",value === "organisationOfIndividuals"?"":"none");
		$("#regNumber-wrapper").css("display",value === "limitedCompany"?"":"none");
		$("#publicBodyType-wrapper").css("display",value === "publicBody"?"":"none");
		$("#publicBodyOther-wrapper").css("display",(value === "publicBody" && publicBody === "other")?"":"none");

		if(value !== ""){
			$("#orgTypeQuestions").removeClass("js-hidden");
		}else{
			$("#orgTypeQuestions").addClass("js-hidden");
		}
	}

	function setHidden(key,value){
		$("#registration_"+key).val(value);
	}

	function regSearch(){
		var businessName = $("#companyName").val().toLowerCase();
		var searchOrgType = $("#businessType").val().toLowerCase();
		var searchPostcode = $("#postcode").val().toLowerCase();

		var count = 0;
		$("#reg-search-result .box").each(function(index,elem){
			var $dataElem = $(".data",elem);
			var name = $dataElem.attr("data-organisationName").toLowerCase();
			var orgType = $dataElem.attr("data-organisationType").toLowerCase();
			var postcode = $dataElem.attr("data-postcode").toLowerCase();

			var pass = name.indexOf(businessName)!=-1;
			if(advancedSearch){
				pass = pass && (searchOrgType==="" || orgType.indexOf(searchOrgType)!=-1) && (searchPostcode==="" || postcode.indexOf(searchPostcode)!=-1)
			}

			if(pass){
				count++;
				$(elem).css("display","block");
			}else{
				$(elem).css("display","none");
			}
		});
		if(count>0){
			$("#reg-search-result > h2").html("Found "+count+" registrations");
			$("#reg-search-result > p").html("Showing 1-"+count+" of "+count+" records");
		}else{
			$("#reg-search-result > h2").html("No matching registrations found");
			$("#reg-search-result > p").html("");
		}
		$("#reg-search-result").css("display","block");
	}

	function advancedToggle(){
		advancedSearch = !advancedSearch;

		if(advancedSearch){
			$("a#toggle-search").html("Basic search");
			$("#advanced-options").css("display","block");
		}else{

			$("a#toggle-search").html("Advanced search");
			$("#advanced-options").css("display","none");
		}
	}
	
	function updateTitleOther(){
		var show = $('#registration_title').val() == "Other";
		if(show){
			$('#titleOtherWrapper').removeClass("js-hidden");
		}else{
			$('#titleOtherWrapper').addClass("js-hidden");
		}
	}
	
	function smarterAnswersQuestion1(){
		var tmpVal = $('#discover_businessType').val();
		// Show Question2: Only if business type is a sole trader, partnership or limited company
		var showQ2 = tmpVal == "soleTrader" || tmpVal == "partnership" || tmpVal == "limitedCompany";
		if (showQ2) {
			$('#discover_otherBusinesses').removeClass("js-hidden");
		} else {
			// Question 1 has changed, Reset Other answers
            $('#new_discover input[type="radio"]').prop('checked', false);      // Find all radios and uncheck
            smarterAnswersQuestion2();   // Run logic on subsequent questions
            smarterAnswersQuestion3();
            
			$('#new_discover input[type="checkbox"]').prop('checked', false);   // Find all checkboxes and uncheck
			smarterAnswersQuestion4();
			
			$('#discover_otherBusinesses').addClass("js-hidden");
		}
		
		// Show Contact EA Text if Other selected
		var showContact = tmpVal == "other";
		if (showContact) {
			$('#new_discover #contactText').removeClass("js-hidden");
		} else {
			$('#new_discover #contactText').addClass("js-hidden");
		}
		
		// Show LowerTier Text: Only if business type is a charity, or a waste authority
		var showLower = tmpVal == "charity" || tmpVal == "collectionAuthority" || tmpVal == "disposalAuthority" || tmpVal == "regulationAuthority";
		if (showLower) {
			$('#new_discover #lowerText').removeClass("js-hidden");
		} else {
			$('#new_discover #lowerText').addClass("js-hidden");
		}
	}
	
	function isIE8(){
		if ($.browser.msie && ($.browser.version == "8.0"))
		{
			return true;
		}
		return false;
	}
	
	function smarterAnswersQuestion2(){
		// Show UpperTier Text Only if otherBusinesses is yes
		
		var tmpVal;
		var showUpper;
		// Special case handling for IE8/agency users
		var ie8 = isIE8();
		if(!ie8)
		{
			tmpVal = $('#discover_otherBusinesses_yes:checked').val();
			var tmpVal3 = $('input:radio[name="discover_otherBusinesses_yes"]:checked').val();
			var tmpVal4 = $('input:radio[name="discover_otherBusinesses"]:checked').val();
			var tmpVal5 = $('input:radio[name="discover[otherBusinesses]_no"]').is(':checked');
			var tmpVal6 = $('#discover_otherBusinesses_yes').is(':checked');
			
			if (window.console) console.log('my1 tmpVal: ' + tmpVal + ' other: ' + tmpVal3 + tmpVal4 + tmpVal5 + tmpVal6);
			showUpper = tmpVal == "yes";
		}
		else
		{
			var tmpVal2 = $('input[name="discover_otherBusinesses_yes"]:checked').val();
			var tmpVal3 = $('input:radio[name="discover_otherBusinesses_yes"]:checked').val();
			var tmpVal4 = $('input:radio[name="discover_otherBusinesses"]:checked').val();
			var tmpVal5 = $('input:radio[name="discover_otherBusinesses_yes"]').is(':checked');
			tmpVal = $('#discover_otherBusinesses_yes').is(':checked');
			
			if (window.console) console.log('my2 tmpVal: ' + tmpVal + ' other: ' + tmpVal2 + tmpVal3 + tmpVal4 + tmpVal5 );
			showUpper = tmpVal;
		}
		
		//var tmpVal = $('#discover_otherBusinesses_yes:checked').val();
		//var tmpVal = $('input[name="discover_otherBusinesses_yes"]:checked').val();
		
		
		if (showUpper) {
			// Uncheck question 3
			$('#new_discover #discover_constructionWaste input[type="radio"]').prop('checked', false);
			smarterAnswersQuestion3();   // Run logic on subsequent questions
			
			$('#new_discover #upperText').removeClass("js-hidden");
		} else {
			$('#new_discover #upperText').addClass("js-hidden");
		}
		
		//tmpVal = $('#discover_otherBusinesses_no:checked').val();
		//tmpVal = $('input[name="discover_otherBusinesses_no"]:checked').val();
		if(!ie8)
		{
			tmpVal = $('#discover_otherBusinesses_no:checked').val();
		}
		else
		{
			tmpVal = $('input[name="discover_otherBusinesses_no"]:checked').val();
		}
		
		// Show Question3: Only if otherBusinesses is no
		var showQ3 = tmpVal == "no";
		if (showQ3) {
			$('#discover_constructionWaste').removeClass("js-hidden");
		} else {
			$('#discover_constructionWaste').addClass("js-hidden");
		}
	}
	
	function smarterAnswersQuestion3(){
		var tmpVal; // = $('#discover_constructionWaste_no:checked').val();
		if(!isIE8())
		{
			tmpVal = $('#discover_constructionWaste_no:checked').val();
		}
		else
		{
			tmpVal = $('input[name="discover_constructionWaste_no"]:checked').val();
		}
		
		// Show Question4: Only if constructionWaste is no
		var showQ4 = tmpVal == "no";
		if (showQ4) {
			$('#discover_wasteType').removeClass("js-hidden");
		} else {
			// Uncheck all checkboxes
			$('#new_discover input[type="checkbox"]').prop('checked', false);   // Find all checkboxes and uncheck
			smarterAnswersQuestion4();
			
			$('#discover_wasteType').addClass("js-hidden");
		}
		
		// Show UpperTier Text Only if constructionWaste is yes
		//tmpVal = $('#discover_constructionWaste_yes:checked').val();
		if(!isIE8())
		{
			tmpVal = $('#discover_constructionWaste_yes:checked').val();
		}
		else
		{
			tmpVal = $('input[name="discover_constructionWaste_yes"]:checked').val();
		}
		
		var showUpper = tmpVal == "yes";
		if (showUpper) {
			$('#new_discover #upperText').removeClass("js-hidden");
		} else {
			$('#new_discover #upperText').addClass("js-hidden");
		}
	}
	
	function smarterAnswersQuestion4(){
		var tmpAnimalVal; // = $('#discover_wasteType_animal:checked').val();
		if(!isIE8())
		{
			tmpAnimalVal = $('#discover_wasteType_animal:checked').val();
		}
		else
		{
			tmpAnimalVal = $('input[name="discover_wasteType_animal"]:checked').val();
		}
		
		var tmpMineVal = $('#discover_wasteType_mine:checked').val();
		var tmpFarmVal = $('#discover_wasteType_farm:checked').val();
		var tmpOtherVal = $('#discover_wasteType_other:checked').val();
		
		var isAnimal = tmpAnimalVal == "1";
		var isMine = tmpMineVal == "1";
		var isFarm = tmpFarmVal == "1";
		var isOther = tmpOtherVal == "1";
		
		// Show Upper tier if 2 or more are selected
		if ( (isAnimal && isMine) || (isAnimal && isFarm) || (isAnimal && isOther) || (isMine && isFarm) || (isMine && isOther) || (isFarm && isOther) ) 
		{
			// Show Upper tier Text (hide lower)
			$('#new_discover #lowerText').addClass("js-hidden");
			$('#new_discover #upperText').removeClass("js-hidden");
		}
		// Show Lower tier if only 1 selected
		else if ( (isAnimal) || (isMine) || (isFarm) || (isOther)) {
			// Show Lower tier text (hide upper)
			$('#new_discover #upperText').addClass("js-hidden");
			$('#new_discover #lowerText').removeClass("js-hidden");
		}
		else {
			// Hide both upper and lower
			$('#new_discover #lowerText').addClass("js-hidden");
			$('#new_discover #upperText').addClass("js-hidden");
		}
		
	}
	
	/*
	* Useful Notes:
	// Individual radio reset
	//$('#discover_otherBusinesses_yes').prop('checked', false);
	*
	// Log message to console
	//if (window.console) console.log('my message: ' + valuetotest);
	*/
	
	function toggleSignInUp(){
		var signin = $('#registration_sign_up_mode').val() == "sign_in";
		var signup = $('#registration_sign_up_mode').val() == "sign_up";
		if(signup||signin) {
			$('#registration_accountEmail').parent().removeClass("js-hidden");
			$('#registration_password').parent().removeClass("js-hidden");
			if(signup) {
				$('#registration_password_confirmation').parent().removeClass("js-hidden");
			} else {
				$('#registration_password_confirmation').parent().addClass("js-hidden");
			}
		} else {
			$('#registration_accountEmail').parent().addClass("js-hidden");
			$('#registration_password').parent().addClass("js-hidden");
			$('#registration_password_confirmation').parent().addClass("js-hidden");
		}
	}
	
	var Tooltip = function(elem,html,mayShow){
		var tip = document.createElement("div");
		var $tip = $(tip);
		$tip.addClass("tooltip");
		$tip.css("display","none");
		$tip.css("position","absolute");
		$tip.css("z-index","1");
		this.visible = false;
		this.$tip = $tip;
		this.mayShow = mayShow;
		document.body.appendChild(tip);
		if(html){
			$tip.html(html);
		}
		
		var t = this;
		$(elem).mouseenter(function(e){t.show(e.pageX,e.pageY);});
		$(elem).mouseleave(function(e){t.hide();});
		$(document.body).mousemove(function(e){t.position(e.pageX,e.pageY);});
	};
	
	Tooltip.prototype.show = function(x,y){
		if(this.mayShow && !this.mayShow()){
			return;
		}
		
		this.$tip.css("display","block");
		this.visible = true;
		this.position(x,y);
	};
	
	Tooltip.prototype.position = function(x,y){
		if(this.mayShow && !this.mayShow()){
			if(this.visible){
				this.hide();
			}
			return;
		}
		
		this.$tip.css("top",y+"px");
		this.$tip.css("left",(x+20)+"px");
	};
	
	Tooltip.prototype.hide = function(){
		this.$tip.css("display","none");
		this.visible = false;
	};

	$(document).ready(function(){
		//$('#registration_businessType').change(refreshQuestions);
		//$("#registration_publicBodyType").change(refreshQuestions);
		$("input[name=findAddress]").click(function(e){e.preventDefault();findAddress();});
		$("#addresses").change(updateAddress);
		$("input[name=changeAddress]").click(function(e){e.preventDefault();changeAddress();});
		//refreshQuestions();
		
		$("#registration_title").change(function(e){e.preventDefault();updateTitleOther();});
		updateTitleOther();
		
		$("#registration_sign_up_mode").change(function(e){e.preventDefault();toggleSignInUp();});
		toggleSignInUp();
		
		// Smarter Answers Initialisation
		$("#discover_businessType").change(function(e){e.preventDefault();smarterAnswersQuestion1();});
		smarterAnswersQuestion1();
		$("#discover_otherBusinesses").change(function(e){e.preventDefault();smarterAnswersQuestion2();});
		smarterAnswersQuestion2();
		$("#discover_constructionWaste").change(function(e){e.preventDefault();smarterAnswersQuestion3();});
		smarterAnswersQuestion3();
		$("#discover_wasteType").change(function(e){e.preventDefault();smarterAnswersQuestion4();});
		smarterAnswersQuestion4();

		var uprn = $("#registration_uprn").val();
		if(uprn && uprn !== ""){
			findAddress();
			$("#addresses").val(uprn);
			updateAddress();
		}else{
			var address1 = $("#registration_streetLine1").val();
			var address2 = $("#registration_streetLine2").val();
			var city = $("#registration_townCity").val();
			if(address1!=="" || address2!=="" || city!==""){
				manualAddress();
			}
		}
		
		searchResultSummaries();
/*
		$("#reg-search").click(function(e){
			e.preventDefault();
			regSearch();
		});
		*/
		$("a#toggle-search").click(function(e){
			e.preventDefault();
			advancedToggle();
		});
		$("#manualAddressLink").click(function(e){
			e.preventDefault();
			manualAddress();
		});
		$("form").submit(function(e){
			submitAddress();
		});
	});
}());
