// Get cookie consent if the UTC time zone is within the EU+ and user has not consented previously (no cookie exists)
// Wait for page to fully load before checking
$(window).on('load', function(){
  // Use local copy of JavaScript Cookie v2.2.1
  $.getScript('/js/js.cookie.js', function() {
    // If the cookie expired or does not exist
    if ( typeof(Cookies) == 'undefined' || Cookies.get('site_cookie') == null ){
      // if within EU time zone show consent dialog
      if (testEUtimezone()){
        toggleconsent();
      } else {
        // otherwise show notice
        $(".cookienotice").show();
      }
    } else {
      console.log("You have already consented to cookie usage");
    }
  });
});
// Use UTC to determine if the time zone resides in or around the EU (within UTC 0 to +4 - https://www.timeanddate.com/time/zones/eu)
function testEUtimezone(){
  var offset = new Date().getTimezoneOffset();
  if ((offset >= -240) && (offset <= 0)){ // European time zone in minutes
    console.log("UTC time zone within the EU");
    return true;
  }
  console.log("UTC time zone is not within the EU");
  return false; // Not EU time zone
}
// Consent to cookie usage (both 'Accept' in consent dialog, or 'OK' in cookie notice). Sets expiration to 1 year.
function acceptcookie(){
  $("#cookieModal").modal('hide');
  $(".cookienotice").hide();
  // set cookie that expires in 12 mns
  Cookies.set('site_cookie', 'accepted', { expires: 365 });
  console.log("I consent to the use of cookies on knative.dev");
}
// Hide cookie notice and confirm user knows how to opt-out
function optout(){
  $("#cookieModal").modal('hide');
  $(".cookienotice").hide();
  // set cookie that expires in 12 mns
  Cookies.set('site_cookie', 'opt_out', { expires: 365 });
  console.log("I read knative.dev/about-analytics-cookies and understand how to opt-out of Google Analytics cookies");
}
// Show info about how to opt-out
function learnaboutcookies(){
  $(".opt-out").toggle();
}
// Close cookie notice (cookie use accepted only for session)
function closenotice(){
  // Consent to cookies for only this session
  Cookies.set('site_cookie', 'accepted');
  togglenotice();
  console.log("I consent to the use of cookies on knative.dev for this session");
}

// Helpful commands (ie testing)

// Manually remove existing cookie
function removecookie(){
  Cookies.remove('site_cookie');
}
// Toggle cookie consent modal
function toggleconsent(){
  $("#cookieModal").modal('toggle');
}
// Toggle cookie notice
function togglenotice(){
  $(".cookienotice").toggle();
}
// Manually check if the 'site_cookie' exists
function getcookie(){
  return Cookies.get('site_cookie');
}
