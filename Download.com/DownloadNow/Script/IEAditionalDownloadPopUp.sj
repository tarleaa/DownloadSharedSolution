//USEUNIT LoggingAttribute
function SaveCloseIEDecisionPopUp()
{
    
    var securityWarningBar = Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("SecurityWarningBar",1000)
    if (securityWarningBar.Exists && securityWarningBar.Visible)
        {
            securityWarningBar.ClickR();
            Aliases.BrowserProcess.Popup.MenuItem("Download File...").Click()
        }
    
    
    
    var dialogPopup = Sys.Browser("iexplore").WaitDialog("*Internet Explorer", 2000)
    if(dialogPopup.Exists)
    {
      var fileDetails = dialogPopup.FindChild("Caption", "What do you want to do with *", 3);
      if(fileDetails.Exists)
      {
        var saveButton = dialogPopup.FindChild("WndCaption", "&Save", 4);
        if(saveButton.Exists)
        {
          saveButton.Click();
        }
        else{Log.Error("No 'Save' button was found in the 'What do you want to do with...' pop-up");}
              
      }
      else{Log.Error("No 'What do you want to do with ...' pop-up was found");}
    }
          
    //wait 2 seconds for the 2nd 'What do you want to do with...' pop-up to appear
    delay(2000);
    //search for the pop-up
    dialogPopup = Sys.Browser("iexplore").WaitDialog("*Internet Explorer", 2000)
    if(dialogPopup.Exists)
    {
      //post error to log
      Log.Error("Two download instances have started. Please see issue #DWNQA-879");
      
      //close the 2nd download pop-up window
      dialogPopup.Close();
    }
    else{Log.Message("No other download instances were found");}
}