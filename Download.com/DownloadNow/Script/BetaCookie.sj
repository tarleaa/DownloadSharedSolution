//USEUNIT FindObjectsMethod
//USEUNIT LoggingAttribute

//sets the cookie for Beta site
function SetBetaCookie()
{
  //get current OS and store it into global variable:
  Project.Variables.VariableByName("CurentOS") = Sys.OSInfo.Name;  
  
  //get current browser and navigate to 'Cookie Page'
  var browser = Sys.Browser(Project.Variables.CurrentBrowser);
  delay(2000);
  browser.ToUrl("http://download.cnet.com/html/akamai/dlak.html");
  var page = browser.Page("http://download.cnet.com/html/akamai/dlak.html");
  
  //find the textbox in which the cookie will be entered
  var dlakTextbox = findChildMethod("idStr", "dlak");
  //enter 'l3tm31n' to textbox
  dlakTextbox.SetText("l3tm31n");
  
  //find and click on the 'Set' button:
  var setButton = findChildMethod("value", "Set");
  setButton.Click();
  delay(500);
  
  //verify the access granted pop-up appeared:
  var confirmationMessage = Sys.Browser(Project.Variables.CurrentBrowser).FindChild("WndCaption", "Cookie set with a 30 day expiration.");
  if(confirmationMessage != null)
  {Log.Message("Cookie was set. You now have access to Beta env");}
  else{Log.Error("Cookie was not set. Access to Beta env is not granted.");}
  
  //wait for the alert pop-up to appear
  var waitPopUp = page.WaitAlert(500);
  if(waitPopUp.Exists)
  {
    //if appeared, click the OK button
    page.Alert.Button("OK").Click();
  }
  else
  { 
    //if alert did not appear (like in the case of Win8/IE10)
    Log.Message("'Confirmation that cookie was set' message Sis not displayed. Continuing test assuming cookie was set...");
  }
}