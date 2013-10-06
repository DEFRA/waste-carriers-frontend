(function(){
	$('html').removeClass("nojs").addClass("js");
	var r = this;

	var page = 1;

	var addressLookup = {};

	var addressTextLookup = {};

	var advancedSearch = false;

	var orgTypeLookup = {
			"individual":"individual",
			"organisationOfIndividuals":"organisation of individuals",
			"limitedCompany":"limited company or limited liability partnership",
			"publicBody":"public body"
		};

	function movePage(num){
		if(num==0){
			if(window.location.href.indexOf("/edit")!=-1){
				window.location.href = "/registrations";
			}else{
				window.location.href = r.startUrl;
			}
		}
		if(num===3){
			updateSummary();
			$("input[name=register]").removeClass("js-hidden").css("display","");
			$("input[name=next]").css("display","none");
		}else{
			$("input[name=register]").css("display","none");
			$("input[name=next]").css("display","");
		}

		$("#page"+page).css("display","none");
		$("#page"+num).css("display","");
		page = num;

		setProgress(num * 100 / 4);
		window.scrollTo(0);
	}

	function moveNext(){
		if(page>=3)return;
		movePage(page+1);
	}

	function moveBack(){
		if(page<=0)return;
		movePage(page-1);
	}

	function findAddress(){
		var value = $("#registration_postcode").val();
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
			addressLookup[addrValue] = "<div>"+(i+5)+" Some street,</div><div>Some town,</div><div>"+value+"</div>";
		}

		$("#addressSearch").css("display","none");
		$("#addressSearchResults").css("display","");
	}

	function updateAddress(){
		var address = $("#addresses").val();
		if(address==="")return;

		$("#addressDisplay").html(addressLookup[address]);


		$("#addressSearchResults").css("display","none");
		$("#selectedAddress").css("display","");
		setHidden("uprn",address);
		setHidden("address",addressTextLookup[address]);

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
			registerAs : $("#registration_registerAs").val(),
			organisationType: $("#registration_organisationType").val(),
			organisationName: $("#registration_organisationName").val(),
			title : $("#registration_title").val(),
			firstName : $("#registration_firstName").val(),
			lastName : $("#registration_lastName").val(),
			emailAddress : $("#registration_emailAddress").val(),
			phoneNumber: $("#registration_phoneNumber").val(),
			individualsType: $("#registration_individualsType").val(),
			companyRegistrationNumber:$("#registration_companyRegistrationNumber").val(),
			publicBodyType:$("#registration_publicBodyType").val(),
			address: address
		}

		updateSummaryWithData(data,$("#summary").get(0));
	}

	function searchResultSummaries(){
		$(".detail .data").each(function(index,elem){
			var $elem = $(elem);
			var detailElem = elem.parentNode;
			var address = $elem.attr("data-address");

			var data = {
				registerAs : $elem.attr("data-registerAs"),
				organisationType: $elem.attr("data-organisationType"),
				organisationName: $elem.attr("data-organisationName"),
				title : $elem.attr("data-title"),
				firstName : $elem.attr("data-firstName"),
				lastName : $elem.attr("data-lastName"),
				emailAddress : $elem.attr("data-emailAddress"),
				phoneNumber: $elem.attr("data-phoneNumber"),
				individualsType: $elem.attr("individualsType"),
				companyRegistrationNumber:$elem.attr("data-companyRegistrationNumber"),
				publicBodyType:$elem.attr("data-publicBodyType"),
				address: address
			}


			updateSummaryWithData(data,elem);

			var a = document.createElement("a");
			var $a = $(a);
			$a.attr("href","#");
			$a.addClass("view");
			$a.html("View registration");
			detailElem.parentNode.insertBefore(a,detailElem.parentNode.firstChild);
			$a.click(authorViewDetail(detailElem,a));
			
		});
	}

	function authorViewDetail(elem,a){
		var shown = false;
		return function(e){
			e.preventDefault();
			if(!shown){
				$(elem).css("display","block");
				$(a).html("Hide registration");
				
			}else{
				$(elem).css("display","none");
				$(a).html("View registration");
			}
			shown = !shown;
		}
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
		if(orgType==="organisationOfIndividuals"){orgInfo=data.individualsType}
		else if(orgType==="limitedCompany"){orgInfo=data.companyRegistrationNumber}
		else if(orgType==="publicBody"){orgInfo=data.publicBodyType}

		if(orgInfo!=""){
			orgInfo = " ("+orgInfo+")";
		}

		var html = "<div>Registering "+orgTypeLookup[orgType]+" for</div>";
		html += "<div>"+orgName+orgInfo+"</div>";
		html += "<p>At the following address</p>";
		html += address;
		html += "<p>Contact</p>";
		html += "<div>"+title+" "+firstName+" "+lastName+" ("+email+")</div>";
		html += "<div>Telephone number: "+phone+"</div>";


		$(elem).html(html);
	}

	function refreshQuestions(){
		var value = $("#registration_organisationType").val();

		$("#indType-wrapper").css("display",value === "organisationOfIndividuals"?"":"none");
		$("#regNumber-wrapper").css("display",value === "limitedCompany"?"":"none");
		$("#publicBodyType-wrapper").css("display",value === "publicBody"?"":"none");

		if(value !== ""){
			$("#orgTypeQuestions").removeClass("js-hidden");
		}else{
			$("#orgTypeQuestions").addClass("js-hidden");
		}
	}

	function setHidden(key,value){
		$("#registration_"+key).val(value);
	}

	function setProgress(percent){
		var $progress = $("#progress");
		$progress.html("<div class=\"offscreen\">"+percent+"%</div><div class=\"bar\"></div>");
		$("#progress .bar").css("width",percent+"%");
	}

	function regSearch(){
		var businessName = $("#businessName").val().toLowerCase();
		var searchOrgType = $("#organisationType").val().toLowerCase();
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


	$(document).ready(function(){
		$('#registration_organisationType').change(refreshQuestions);
		$("input[name=next]").click(function(e){e.preventDefault();moveNext()});
		$("input[name=back]").click(function(e){e.preventDefault();moveBack()});
		$("input[name=findAddress]").click(function(e){e.preventDefault();findAddress()});
		$("#addresses").change(updateAddress);
		$("input[name=changeAddress]").click(function(e){e.preventDefault();changeAddress()});
		refreshQuestions();

		var uprn = $("#registration_uprn").val();
		if(uprn && uprn !== ""){
			findAddress();
			$("#addresses").val(uprn);
			updateAddress();
		}
		setProgress(100 / 4);
		searchResultSummaries();

		$("#reg-search").click(function(e){
			e.preventDefault();
			regSearch();
		});
		$("a#toggle-search").click(function(e){
			e.preventDefault();
			advancedToggle();
		});
	});
}());
