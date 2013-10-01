(function(){
	$('html').removeClass("nojs").addClass("js");

	var page = 1;

	var addressLookup = {};

	var addressTextLookup = {};

	var orgTypeLookup = {
			"individual":"individual",
			"organisationOfIndividuals":"organisation of individuals",
			"limitedCompany":"limited company or limited liability partnership",
			"publicBody":"public body"
		};

	function movePage(num){
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
		if(page<=1)return;
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
		var registerAs = $("#registration_registerAs").val();
		var orgType = $("#registration_organisationType").val();
		var orgName = $("#registration_organisationName").val();

		var title = $("#registration_title").val();
		var firstName = $("#registration_firstName").val();
		var lastName = $("#registration_lastName").val();
		var email = $("#registration_emailAddress").val();
		var phone = $("#registration_phoneNumber").val();


		var address = $("#addresses").val();
		address = addressLookup[address];

		var orgInfo = "";
		if(orgType==="organisationOfIndividuals"){orgInfo=$("#registration_individualsType").val()}
		else if(orgType==="limitedCompany"){orgInfo=$("#registration_companyRegistrationNumber").val()}
		else if(orgType==="publicBody"){orgInfo=$("#registration_publicBodyType").val()}

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


		$("#summary").html(html);
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
	});
}());
