//USEUNIT LoggingAttribute
// Checks whether the specified URL is valid

function VerifyWebObject(link)
{
  //get the HTTP object
  var httpObj = Sys.OleObject("MSXML2.XMLHTTP");
  httpObj.open("GET", link, true);
  httpObj.send();
  
  //wait for the page request to be completed
  while(httpObj.readyState != 4)
  {delay(100);}

  //for HTTP return status: 200 & 302
  switch (httpObj.status)
  {
    case 200:
    case 302:
    {
      //if the response text is blank
      if (httpObj.responseText != "")
      {
         Log.Message("The " + link + " link is valid");
        return false;
      }
      break;
    }
    default:
    {
      Log.Message("The " + link + " link was not found, the returned status: " + httpObj.status, httpObj.responseText);
      return false;
    }
  }
  return true;
}