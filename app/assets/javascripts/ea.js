(function(){
	$('html').removeClass("nojs").addClass("js");
	var r = this;

	var page = 1;

	var advancedSearch = false;

	function searchResultSummaries(){
		$("#reg-search-result .detail .data").each(function(index,elem){
			var $elem = $(elem);
			var detailElem = elem.parentNode;
			var address = $elem.attr("data-address");

			var data = {
				organisationType: $elem.attr("data-organisationType"),
				organisationName: $elem.attr("data-organisationName"),
				firstName : $elem.attr("data-firstName"),
				lastName : $elem.attr("data-lastName"),
				emailAddress : $elem.attr("data-emailAddress"),
				phoneNumber: $elem.attr("data-phoneNumber"),
				individualsType: $elem.attr("data-individualsType"),
				publicBodyType:$elem.attr("data-publicBodyType"),
				mdStatus:$elem.attr("data-status"),
				regIdentifier:$elem.attr("data-regIdentifier"),
				accessCode:$elem.attr("data-accessCode"),
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
			if (data.mdStatus == "PENDING") {
				var pStatus = document.createElement("div");
				var $pStatus = $(pStatus);
				$pStatus.addClass("pendingtext");
				$pStatus.html("Status: Pending");
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

		var firstName = data.firstName;
		var lastName = data.lastName;
		var email = data.emailAddress;
		var phone = data.phoneNumber;

		var address = data.address;
		var regIden = data.regIdentifier;
		var accessCode = data.accessCode;

		var orgInfo = "";

		var html = "";
		html += "<div>"+orgName+orgInfo+"</div>";
		html += "<div>Registration number: "+regIden+"</div>";
		if (accessCode!=="") {
		    html += "<div>Access code: "+accessCode+"</div>";
		}
		html += address;
		if (email !== "")
		{
			email = " (" + email + ")";
		}
		html += "<div>"+firstName+" "+lastName+email+"</div>";
		html += "<div>Telephone number: "+phone+"</div>";

		$(elem).html(html);
	}

	function advancedToggle(){
		advancedSearch = !advancedSearch;

		if (advancedSearch) {
			var myFullLabel = $("#full-search-label").html();
			$("a#toggle-search").html(myFullLabel);
			$("#advanced-options").css("display","block");
		} else {
			var myRefineLabel = $("#refine-search-label").html();
			$("a#toggle-search").html(myRefineLabel);
			$("#advanced-options").css("display","none");
		}
	}

	/**
	* Helper function to determine browser version
	*/
	function isIE8(){
		if ($.browser.msie && ($.browser.version == "8.0"))
		{
			return true;
		}
		return false;
	}

	function showHideRevoke(){
		// Show revoked reason is revoked question is yes
		var showReason = $('#revoke_question_yes').is(':checked');
		if (showReason) {
			$('#registration_metaData_revokedReason').parent().removeClass("js-hidden");
			$('input[name="revoke"]').removeClass("js-hidden");
			$('input[name="continue"]').addClass("js-hidden");
		} else {
			$('#registration_metaData_revokedReason').val('');
			$('#registration_metaData_revokedReason').parent().addClass("js-hidden");
			$('input[name="revoke"]').addClass("js-hidden");
			$('input[name="continue"]').removeClass("js-hidden");
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

	/**
	* This function ensure than when internal links are activated a smooth transistion occurs between
	* scroll of the page from the click to the target location
	*/
	function smoothInternalLinks(){
		$('a[href^="#"]').on('click',function (e) {
		    e.preventDefault();

		    var target = this.hash,
		    $target = $(target);

		    $('html, body').stop().animate({
		        'scrollTop': $target.offset().top - 75
		    }, 900, 'swing', function () {
		        window.location.hash = target;
		    });

		    $target.focus();

		});
	}

	$(document).ready(function(){
		// Setup Revoke questions on NCCC edit
		$("#revoke_question").change(function(e){showHideRevoke();});
		showHideRevoke();
		searchResultSummaries();

		$("a#toggle-search").click(function(e){
			e.preventDefault();
			advancedToggle();
		});
		
		$("#manualAddressLink").click(function(e){
			e.preventDefault();
			manualAddress();
		});

		smoothInternalLinks();

    	$("#sSelect").change(function(){
    		$("#sSelect").removeAttr("size");
    	});

    	GOVUK.performance.stageprompt.setupForGoogleAnalytics();
	});
}());


$('input[type="radio"]').click(function(){
          $(this).toggleClass('red');
});
