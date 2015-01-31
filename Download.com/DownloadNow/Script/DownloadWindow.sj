//USEUNIT LoggingAttribute
//USEUNIT PageStatus
//USEUNIT SearchAndWaitToExist

/// <summary>
/// Verify the download pop-up / bar appears on browser.
/// </summary>
/// <param name="fileType">
/// Specify for which file type to check (available: .exe / .apk / .ipa / .dmg / .zip / cbsidlm)
/// </param>
function VerifyDownloadWindow(fileType, csvVariation)
{
  Project.Variables.FileNameExtension = "*" + fileType
  switch(Project.Variables.CurrentBrowser)
  {
    case "iexplore":
    {
      //verify the downloadable file has the correct type (unwrapped / rapped ...)
      //csvVariation taken from the csv file
      switch(csvVariation)
      {
        case "DLM Product":
        case "Offsite Popup (Download)":
        case "Archived Product":
        case "DRE Unit":
        case "Avast 3000 BP":
        case "Avast 3001 BP":
        case "VIP Product":
        case "Standard":
        {
          //for IE 8
          if(Project.Variables.IEVersion == 8)
          {
            //verify if the upper bar is displayed ("To help protect your security, IE blocked this site from downloading files to your computer...")
            Log.Message("Searching for the top security bar.");
            var topSecurityBar = Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("SecurityWarningBar", Project.Variables.IESecurityBarWaitTime*1000)   
            if(topSecurityBar.Exists && topSecurityBar.Visible)
            {
              //right click the top bar
              Log.Message("Clicking on the top security bar and selecting 'Download File...'");
              topSecurityBar.Click();
              delay(500);
              if( Aliases.BrowserProcess.WaitAliasChild("Popup",100).Exists && Aliases.BrowserProcess.WaitAliasChild("Popup",100).Visible)
              {
                 Aliases.BrowserProcess.Popup.MenuItem("Download File...").Click()
              }
              else
              {
                // Specify the sought-for property names 
                PropArray = new Array ("ObjectIdentifier", "ObjectType");
                // Specify the sought-for property values
                ValuesArray = new Array ("Download File...", "MenuItem");
              
                //click the 'Download File...' menu option
                var downloadFileMenuItem = Sys.FindAllChildren(PropArray, ValuesArray, 50).toArray();
                //expect to find 2 objects: use the first one
                if(downloadFileMenuItem.length == 1 || downloadFileMenuItem.length == 2)
                {
                  //click the 'Download File...' menu item
                  downloadFileMenuItem[0].Click();
                }
                else
                {Log.Error("More than 2 object matching the searched proprName / proprValue was found. Please add / use more specific proprName / proprValue");}
              }
            }
            
            //find the IE File Download pop-up
            var downloadPopUp = Aliases.BrowserProcess.WaitAliasChild("SecurityWarningDialog", Project.Variables.DownloadWaitTime * 1000)
            //if pop-up exists
            if(downloadPopUp != null && downloadPopUp.Exists)
            {
              downloadPopUp.Activate()
              //verify if there is more than one download pop-up
              var downloadPopupInstances = Aliases.BrowserProcess.FindAllChildren("WndCaption", "File Download").toArray();
              //if there is more than 1 download pop-up, close the 2nd download pop-up and post error
              if(downloadPopupInstances.length > 1)
              { 
                Log.Error("A 2nd download instance was started. Logged issue #DWNQA-879");
                downloadPopupInstances[1].Close();
              }
              //get the file name from the pop-up
              Aliases.RefreshMappingInfo()
              var fileToBeDownloaded = Aliases.BrowserProcess.SecurityWarningDialog.WaitAliasChild("FileNameText",5000)
              if(fileToBeDownloaded.Exists)
              {Log.Message("Correct extension was found: " + fileType);}
              else{Log.Error("Different than expected file extension was found");}
              
              /*
              //for DLM product verify that file starts with 'cbsidlm-cbs'
              if(csvVariation == "DLM Product")
              {           
                fileToBeDownloaded = Sys.Browser("iexplore").FindChild("wText", "cbsidlm-cbs*", 4);
                if(fileToBeDownloaded.Exists)
                {Log.Message("File correctly contains 'cbsidlm-cbs' within it's name");}
                else{Log.Error("File does NOT contain 'cbsidlm-cbs' within it's name. Please investigate");}
              }
              */
              
              //get the download pop-up again (in case of 2 download pop-ups, one was close. This makes sure you are using the existing one).
              //find the 'Save' button on the first pop-up (the one with Run / Save / Cancel buttons:
              var saveButton = Aliases.BrowserProcess.SecurityWarningDialog.WaitAliasChild("SaveButton", 5000)
              if(saveButton.Exists)
              {
                //click Save
                saveButton.Click();
                if(Aliases.BrowserProcess.SecurityWarningDialog.WaitAliasChild("SaveButton", 50).Exists)
                 {
                    saveButton.Click();
                 }
                //verify the 'Save As' dialog window opened (wait up to 1 second for it to appear)
                var saveAsDialog = Aliases.BrowserProcess.WaitAliasChild("SaveAsWindow",5000)
                if(saveAsDialog.Exists)
                {
                  //click on the 'Save' button (from the dialog with Save / Cancel + choose save location:
                  saveButton = saveAsDialog.WaitAliasChild("SaveButton",5000)
                  if(saveButton.Exists)
                  {
                    saveButton.Click();
                    //delay the script execution for 1 second and only then verify if any other notification are displayed  
                    delay(1000);
                    
                    //check to see if File already exists dialog appears: 
                    alreadyExistsPopUp = Aliases.BrowserProcess.WaitAliasChild("ConfirmSaveAsWindow",1000)
                    if(alreadyExistsPopUp.Exists)
                    {
                      //find the Yes to replace the file
                      var yesButton = Aliases.BrowserProcess.ConfirmSaveAsWindow.YesButton
                      if(yesButton.Exists)
                      {
                        //click on Yes to replace the file
                        yesButton.Click();
                      }
                    }
                    
                    //search for the downloading pop-up
                    var downloaded = Aliases.BrowserProcess.WaitAliasChild("DownloadCompleteWindow", 100);
                    if(downloaded.Exists)
                    {
                      Log.Message("Download has finished");
                      //close the Download Complete pop-up
                      downloaded.WaitAliasChild("CloseButton", 500).Click();
                    }
                    else
                    {
                      //search for the download in progress pop-up:
                      var downloadInProgressPopUp = Aliases.BrowserProcess.WaitAliasChild("DownloadInProgressWindow",500)
                      if(downloadInProgressPopUp.Exists)
                      {
                        //search for the Estimated time left text:
                        var estimatedTimeLeft = downloadInProgressPopUp.WaitAliasChild("EstimatedTimeLeftCaption",5000)
                        if(estimatedTimeLeft.Exists)
                        {
                          //get the estimated time left value
                          var timeLeftInitial = estimatedTimeLeft.WndCaption;
                          Log.Picture(Sys.Desktop.Picture(), "Instance #1: estimated time left for download to complete");
                          Log.Message(timeLeftInitial)
                          //delay the script execution for 2 seconds and then get the remaining download time / text
                          delay(2000);
                          var timeLeftCurrrent = estimatedTimeLeft.WndCaption;
                          Log.Picture(Sys.Desktop.Picture(), "Instance #2: estimated time left for download to complete");
                          Log.Message(timeLeftCurrrent)
                          //compare the 2 values to confirm that the download is working:
                          var result = aqString.Compare(timeLeftInitial, timeLeftCurrrent, true);
                          //if values match
                          if(result == 0)
                          {Log.Error("No download progress was made after 2 seconds. Download not started. Please investigate");}
                          else{Log.Message("Values are different. File is being downloaded");}
                          
                          //click to cancel the download:
                          var cancelButton = downloadInProgressPopUp.WaitAliasChild("CancelButton",500);
                          if(cancelButton.Exists)
                          {
                            cancelButton.Click();
                          }
                          else
                          {
                            //in case the download finished meanwhile, click the 'Close' button from the 'Download complete' dialog:
                            downloadCompleted = Aliases.BrowserProcess.WaitAliasChild("DownloadCompleteWindow",100)
                            if(downloadCompleted.Exists)
                            {
                              var closeButton =  downloadCompleted.WaitAliasChild("CloseButton", 500);
                              if(closeButton.Exists)
                              {
                                closeButton.Click();
                              }
                            }
                          }
                        }
                        else
                        {
                          //check if the download is finished
                          downloaded = Aliases.BrowserProcess.WaitAliasChild("DownloadCompleteWindow", 100);
                          if(downloaded.Exists)
                          {
                            Log.Message("Download has finished");
                            //close the Download Complete pop-up
                            downloaded.WaitAliasChild("CloseButton", 500).Click();
                          }
                          else
                          {
                            Log.Error("No 'Estimate time left' object was found in the downloading pop-up although download is still in progress");
                          }
                        }
                      }
                      else
                      {
                          //check if the download is finished
                          downloaded = Aliases.BrowserProcess.WaitAliasChild("DownloadCompleteWindow", 100);
                          if(downloaded.Exists)
                          {
                            Log.Message("Download has finished");
                            //close the Download Complete pop-up
                            downloaded.WaitAliasChild("CloseButton", 500).Click();
                          }
                          else
                          {
                            Log.Error("No download in progress pop-up was found");
                          }
                      }
                    }
                  }
                  else{Log.Error("No 'Save' button was found in the 'Save As' dialog window");}
                }
                else{Log.Error("No 'Save As' dialog was found (dialog where the user can select where on disk to save the file)");}
              }
              else{Log.Error("Could not find 'Save' button on the 'File Download *' popup");}
            }
            else{Log.Error("Download pop-up was not found.");}
          }
          //for IE9 and above
          else
          {
            //wait up to 10 seconds for the notification bar to exist
            var ieNotificationBar = Sys.Browser("iexplore").BrowserWindow(0).WaitWindow("Frame Notification Bar", "", 1, Project.Variables.DownloadWaitTime * 1000);
            if(ieNotificationBar.Exists)
            {
              //wait up to 10 seconds for the notification bar to become visible
              var notificationBarIsVisible = ieNotificationBar.WaitProperty("Visible", true, 30000);
              //if not visible after 10 seconds, post log. Else, continue with test
              if(notificationBarIsVisible == false)
              {
                Log.Error("IE bottom notification bar did not show up after 60 seconds");
              }
              else
              {
                //search for the notification bar contents
                var iePopUp = ieNotificationBar.FindChild("WndClass", "DirectUIHWND");
                if(iePopUp.Exists && iePopUp.Visible)
                {Log.Message("IE notification bar contents was found");}
                else{Log.Error("No IE notification bar contents was found");}
                    
                //get the text from the notification bar and search that it contains the fileType
                //in some cases there are 2 Notification bar Text objects. In this case, the 2nd one is the correct one.
                //So, search if the 2nd object exists.
                var notifBarText = iePopUp.WaitText("Notification bar Text", 2, 1000);
                //if objects exists
                if(notifBarText.Exists)
                {
                  //get it's value
                  notifBarText = iePopUp.Text("Notification bar Text", 2).Value;
                }
                else
                {
                  //get the value of the 1st object
                  notifBarText = iePopUp.Text("Notification bar Text").Value;
                }
                result = aqString.Find(notifBarText, fileType, 0, false);
                if(result != -1)
                {Log.Message("Downloading correct file type");}
                else
                {
                  Log.Error("File extension for currently downloaded file is incorrect.");
                  Log.Error("Current variation: " + csvVariation);
                  Log.Error("Expected filetype: " + fileType + ". Actual filetype: please see current screenshot");
                }
                
                /*
                //for DLM product verify that file starts with 'cbsidlm-cbs'
                if(csvVariation == "DLM Product")
                {           
                  fileToBeDownloaded = aqString.Find(notifBarText, "cbsidlm-cbs");
                  if(fileToBeDownloaded != -1)
                  {Log.Message("File correctly contains 'cbsidlm-cbs' within it's name");}
                  else{Log.Error("File does NOT contain 'cbsidlm-cbs' within it's name. Please investigate");}
                }    
                */
                
                //for all variations except Offsite Popup (Download), click the save button 
                if(csvVariation != "Offsite Popup (Download)")
                {
                  //click 'Save' from the download notification:
                  var saveButton = SearchWaitToExist("ObjectIdentifier", "Save");
                  if(saveButton != null && saveButton.Exists)
                  {
                    saveButton.Click();
                  }
                  else{Log.Error("'Save' button does not exist");}
                }
                else
                {
                  //do nothing as the start of the download was already triggered in the 'What do you want to do with...' pop-up window
                }

                //delay the check to give the dowload a chance to start
                delay(1000);
      
                //get the text from the notification bar
                notifBarText = iePopUp.Text("Notification bar Text").Value;
                Log.Picture(Sys.Desktop.Picture(), "Instance #1: estimated time left for download to complete");
                Log.Message("Initial value for notif bar is: " + notifBarText);
      
                //check the notification bar text
                var results = aqString.Find(notifBarText, "completed");
                if(results != -1)
                {Log.Message("File already finished downloading");}
                else
                {
                  Log.Message("Checking to see if file is downloading");

                  //delay the script execution for 1 second and only then get the downloading text (to verify download has progressed)
                  delay(1000);
                  var secondInstanceNotifBar = iePopUp.Text("Notification bar Text").Value;
                  Log.Picture(Sys.Desktop.Picture(), "Instance #2: estimated time left for download to complete");
                
                  Log.Message("Second value for notif bar is: " + secondInstanceNotifBar);
                  
                  //compare the strings: if they are the same, download did not start
                  // if they differ, download has started
                  if(aqString.Compare(notifBarText, secondInstanceNotifBar, true) == 0 && aqString.Find(notifBarText, "completed") != -1)
                  {
                    Log.Error("Download did not start after 2 seconds, as instances have the same notification text");
                    Log.Error("First  instance text: " + notifBarText);
                    Log.Error("Second instance text: " + secondInstanceNotifBar);
                  }
                  else{"Download has started"}
              
                  //cancel the download:
                  var cancelButton = iePopUp.FindChild("ObjectIdentifier","Cancel", 2, true);
                  if(cancelButton.Exists)
                  {
                    cancelButton.Click();
                    
                    //verify the download was cancelled
                    cancelButton = iePopUp.FindChild("ObjectIdentifier","Cancel", 2, true);
                    if(cancelButton.Exists && cancelButton.VisibleOnScreen)
                    {
                      cancelButton.Click();
                    }
                  }
                }   

                //click the 'x' button in order to close the notification tab
                iePopUp.Button("Close").Click();
                  
                //verify the bottom notification bar is closed. If not, close it
                iePopUp = ieNotificationBar.FindChild("WndClass", "DirectUIHWND");
                if(iePopUp.Exists && iePopUp.VisibleOnScreen)
                {
                  //click the 'x' button in order to close the notification tab
                  iePopUp.Button("Close").Click();
                }
              }
            }
            else{Log.Error("Bottom notification bar does not exist after 10 seconds");} 
          }
          break;
        }
        
        case "Publisher Hosted":
        case "Offsite Popup (Web Page, pop up)":
        case "Offsite Popup (Web Page, main window)":
        case "iOS Product":
        case "Android Product":
        {
          //accept any page
          var page = Sys.Browser("iexplore").Page("*");
          
          //search all level 1 pages from the IE process that contain "http://" string in the URL property and store them into array
          var pagesList = Sys.Browser("iexplore").FindAllChildren("URL", "http*://*", 1).toArray();
          
          if(pagesList.length > 2)
          {Log.Error("Clicking the Download button opened 2 similar external tabs");}
          
          //loop through the array
          for(var i = 0; i < pagesList.length; i++)
          {
            //for pages that don't contain in their URL the server being tested
            if(aqString.Find(pagesList[i].URL, Project.Variables.ServerName) == -1)
            {
              //wait for the page to load
              pagesList[i].Wait();
              
              //verify page status is 200 / 302
              VerifyWebObject(pagesList[i].URL)
              
              //only if a 3rd party site was opened in a new tab.
              if(pagesList.length > 1)
              {  
        				//for IE8, click Yes on the Security Warning message that might appear
        				if(Project.Variables.CurrentBrowser == "iexplore" && Project.Variables.IEVersion == 8)
                {
                  //check if the security warning appears:
                  var waitSecurityWarning = pagesList[i].WaitConfirm(1000);
                  if(waitSecurityWarning.Exists)
                  {
                    //click on 'Yes' when the Security Warning' message appear: 
                    pagesList[i].Confirm.Button("Cancel").Click();
                    delay(500);
                  }
                }
                //close the dialog that asks permission to open the program on your computer
                var waitIEdialog = Sys.Browser("iexplore").WaitDialog("Internet Explorer", 500);
                if(waitIEdialog.Exists)
                {
                  //click on Cancel on the dialog window
                  Sys.Browser("iexplore").Dialog("Internet Explorer").Button("Cancel").Click();
                }
                
                //close the tab
                pagesList[i].Close();
              }
            }
            else
            {
              //wait for the page to load
              pagesList[i].Wait();
              
              //if page contains the server being tested
              //get current URL
              var currentURL = page.URL;

              //verify the end page URL contains 3055 
              results = aqString.Find(currentURL, "3055"); 
              if(results != -1)
              {Log.Message("User was redirected to correct page: contains 3055");}
              else{Log.Error("User was NOT redirected to correct page as the page does not contain 3055. URL of the page: " + currentURL);}
              
            }
          }
          break;
        }
        
        default:
        {
          Log.Error("No such variation available");
          break;
        }
      }           
      break;
    }
        
    case "chrome":
    { 
    var curTime = aqDateTime.Now()           
      
      Project.Variables.FileNameExtension = "*"+ fileType + "*"
      //verify the file being downloaded has the correct type (unwrapped / rapped ...)
      switch(csvVariation)
      {
        case "Publisher Hosted":
        case "DLM Product":
        case "Offsite Popup (Download)":
        case "Archived Product":
        case "DRE Unit":
        case "Avast 3000 BP":
        case "Avast 3001 BP":
        case "VIP Product":
        case "Standard":
        {
          //verify if the chrome browser opened a pop-up (wait up to 5 seconds):
          var chromePopUp = Sys.Browser("chrome").WaitDialog("Save As",10);
          if(chromePopUp.Exists)
          {
            //click save
            Sys.Browser("chrome").Dialog("Save As").Button("Save").Click();
            
            //wait for 1 second for the already exists dialog to be displayed.
            if(Sys.Browser("chrome").WaitDialog("Confirm Save As", 1000).Exists)
            {
              //click the 'Yes' button to replace the file
              var yesButton = Sys.Browser("chrome").Dialog("Confirm Save As").FindChild("WndCaption", "&Yes", 3);
              if(yesButton.Exists)
              {
                yesButton.Click();
              }
              else{Log.Error("No 'Yes' button was found in the 'Confirm Save As' dialog");}
            }
          }
          else{Log.Message("No Dialog exists for downloading file. Searching for the bottom download bar...");}
          Aliases.RefreshMappingInfo()
          //verify download has started
          //search in the notification bar for object that contains the fileType variable
          
          var downloadBottomBar = Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("ChromeDownloadBar", Project.Variables.DownloadWaitTime *1000)

          if(downloadBottomBar.Exists && downloadBottomBar.WaitProperty("VisibleOnScreen","True", Project.Variables.DownloadWaitTime *1000))
          {
            //if the 'This type of file can harm your computer. Do you want to keep anyway?' message appears, click on 'Keep' button
            var keepButton = Aliases.BrowserProcess.BrowserWindow.ChromeDownloadWarning.WaitAliasChild("KeepButton",1000)
            if(keepButton.WaitProperty("Exists","True",2000) && keepButton.WaitProperty("VisibleOnScreen","True",2000))
            {
                keepButton.Click();
                if(keepButton.WaitProperty("Exists","True",2000) && keepButton.WaitProperty("VisibleOnScreen","True",2000))
                {
                    keepButton.Click();
                }
            }
            
            var extensionSearch = Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("ChromeDownloadWarning",2000)
            if(extensionSearch.Exists)
            {
              Log.Message("File with correct extension was found");
              //get the Caption of the button from the bottom bar 
              var buttonTextFirstInstance = extensionSearch.Caption;
              Log.Picture(Sys.Desktop.Picture(), "Instance #1: estimated time left for download to complete");
              Log.Message(buttonTextFirstInstance);
        
              //delay the script execution for 1.5 second and only then grab the button text (to verify download progress)
              delay(1500);
        
              //get another instance of the button from the bottom bar
              var buttonTextSecondInstance = extensionSearch.Caption;
              Log.Message(buttonTextSecondInstance);
              Log.Picture(Sys.Desktop.Picture(), "Instance #2: estimated time left for download to complete");
              
              //compare the 2 instances: if the same, download did not start
              if(buttonTextFirstInstance == buttonTextSecondInstance && aqString.Find(buttonTextFirstInstance, "secs left") != -1)
              {Log.Error("No download progress after 1.5 seconds");}
              else
              {
                //if download started
                Log.Message("Download started");

                //right click the button
                if (extensionSearch.WaitProperty("Enabled", "True", 10000))
                    {
                       extensionSearch.ClickR();   
                    }
                else
                    {
                       Log.Error("Download Icon in Download Bar is not enabled.")
                       Log.Picture(Sys.Desktop.Picture(), "Posting screenshot to log ...");
                       Aliases.BrowserProcess.BrowserWindow.BottomBarCloseButton.Click()
                    }
                        
              
                if(Sys.Browser("chrome").Window("Chrome_WidgetWin_2", "", 1).MenuBar(0).Client(1).Popup(0).MenuItem("Cancel").Enabled)
                {
                  //cancel the download
                  Sys.Browser("chrome").Window("Chrome_WidgetWin_2", "", 1).MenuBar(0).Client(1).Popup(0).MenuItem("Cancel").Click();
                }
                else
                {
                  Log.Message("'Cancel' button is greyed out. Please see following screenshot");
                  Log.Picture(Sys.Desktop.Picture(), "Posting screenshot to log ...");
                  Aliases.BrowserProcess.BrowserWindow.BottomBarCloseButton.Click()
                }
              
                //wait to see if any other downloads start
                delay(1000);
              }
            }
            else
            {
              //If the file name extenion is wrong, discards the donwload
              Project.Variables.FileNameExtension = "*.*?"
              Aliases.RefreshMappingInfo()
              var discardButton =  Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("ChromeDownloadWarning", 100).WaitAliasChild("DiscardButton", 100)
              if(discardButton.Exists)
              {discardButton.Click();}
              Log.Error("File extension for currently downloaded file is incorrect. Discarding the download.");
              Log.Error("Current variation: " + csvVariation);
              Log.Error("Expected filetype: " + fileType + ". Actual filetype: please see current screenshot");
            }
            
            /*
            //for DLM product, verify that file starts with 'cbsidlm-cbs'
            if(csvVariation == "DLM Product")
            {
              var fileContains = Sys.Browser("chrome").FindChild("ObjectIdentifier", "*cbsidlm-cbs*", 10);
              if(fileContains.Exists)
              {Log.Message("File correctly contains 'cbsidlm-cbs' within it's name");}
              else{Log.Error("File does NOT contain 'cbsidlm-cbs' within it's name. Please investigate");}
            }
            */
            
            //cancel any other triggered downloads and close the bottom bar
            //get the 'show all downloads'
            var bottomBar = Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("ChromeDownloadBar",5000)
            if(bottomBar.Exists && bottomBar.VisibleOnScreen)
            {
              //go through the bottom bar objects and find all Button objects
              var allButtonTypeObjects = bottomBar.Parent.FindAllChildren("ObjectType", "Button").toArray();
              
              //if more than 2 child items were found, it means that a 2nd download was already triggered
              if(allButtonTypeObjects.length > 2)
              {
                Log.Error("A 2nd download instance was started. Logged issue #DWNQA-879");
                
                //for each Button object, get the Caption
                for (i = 0; i < allButtonTypeObjects.length; i++)
                {
                  //if Caption does not contain Cancelled or Close, means the object contains a download in progress.
                  //for this object, right click it and Cancel it
                  if((aqString.Find(allButtonTypeObjects[i].Caption, "Cancelled") == -1) && (aqString.Find(allButtonTypeObjects[i].Caption, "Close") == -1) && (aqString.Find(allButtonTypeObjects[i].Caption, "MB") != -1))
                  {
                    allButtonTypeObjects[i].ClickR();
                  
                    Sys.Browser("chrome").Window("Chrome_WidgetWin_2", "", 1).MenuBar(0).Client(1).Popup(0).MenuItem("Cancel").Click();
                  }
                }
              }

              //click the close button:
              bottomBar.Parent.Button("Close").Click();
            }
          }
          else{
          var endTime = aqDateTime.Now()
          
          Log.Message(aqConvert.DateTimeToStr(aqDateTime.TimeInterval(curTime,endTime)))
          Log.Error("No bottom download bar exists / appeared in Chrome browser");}
          break;
        }
        
        case "Offsite Popup (Web Page, pop up)":
        case "Offsite Popup (Web Page, main window)":
        case "iOS Product":
        case "Android Product":
        {
          //accept any page
          var page = Sys.Browser("chrome").Page("*");
          
          //search all level 1 pages from the Chrome process that contain "http://" string in the URL property and store them into array
          var pagesList = Sys.Browser("chrome").FindAllChildren("URL", "http*://*", 1).toArray();
          
          //loop through the array
          for(var i = 0; i < pagesList.length; i++)
          {
            //for pages that don't contain in their URL the server being tested
            if(aqString.Find(pagesList[i].URL, Project.Variables.ServerName) == -1)
            {
              //wait for the page to load
              pagesList[i].Wait();
              
              //verify page status is 200 / 302
              VerifyWebObject(pagesList[i].URL)
              
              //only if a 3rd party site was opened in a new tab.
              if(pagesList.length > 1)
              {            
                //close the tab
                pagesList[i].Close();
              }
            }
            else
            {
              //if page URL contains the server being tested
              //verify the page contains 3055 within it's URL
              
              //get current URL
              var currentURL = page.URL;

              //verify the end page URL contains 3055 
              results = aqString.Find(currentURL, "3055"); 
              if(results != -1)
              {Log.Message("User was redirected to correct page: contains 3055");}
              else{Log.Error("User was NOT redirected to correct page as the page does not contain 3055. URL of the page: " + currentURL);}
            }
          }
          break;
        }
        
        default:
        {
          Log.Error("No such variation");
          break;
        }
      }
      break;
    }
    
    case "firefox": 
    {
            
      //verify the downloadable file has the correct type (unwrapped / rapped ...)
      switch(csvVariation)
      {
        case "Publisher Hosted":
        case "DLM Product":
        case "Offsite Popup (Download)":
        case "Archived Product":
        case "DRE Unit":
        case "Avast 3000 BP":
        case "Avast 3001 BP":
        case "VIP Product":
        case "Standard": 
        {    
        
          //wait up to 30 seconds for the download Dialog to appear.
          var downloadDialog = Aliases.BrowserProcess.WaitAliasChild("FFDownloadDialog", Project.Variables.DownloadWaitTime*1000)
          if(downloadDialog.Exists && downloadDialog.VisibleOnScreen)
          {
          
          Log.Message("FF download pop-up (of type Dialog or Window) was found");
          
          //click on the dialog to trigger the focus of pop-up
          downloadDialog.Click();
          
          //verify the file being download is the correcty type":                    
          var downloadedFileType = Sys.Browser("firefox").UIPage("chrome://mozapps/content/downloads/unknownContentType.xul").dialog("unknownContentType").vbox(0).vbox("container").hbox(0).vbox(0).description("location").tooltipText;
          
          var results = aqString.Find(downloadedFileType, fileType, 0, false)
          if(results != -1)
          {	
            Log.Message("Downloading correct file type: " + fileType);
          }
          else
          {
            Log.Error("Downloading incorrecct filetype: " + downloadedFileType);
          }
                    
          //click on the 'Save File' button:
          var saveFileButton = Aliases.BrowserProcess.FFDownloadPage.WaitAliasChild("SaveFileButton",5000)
         
          if(saveFileButton.Exists)
          {
             saveFileButton.HoverMouse()
             
             //wait for the button to become enabled (up to 2 seconds) then click it
             if (saveFileButton.WaitProperty("Enabled", true, 10000))
             {
                saveFileButton.Click();
             }  
          }
          else{Log.Error("'Save File' button was not found / enabled");}
          
          //if the pop-up still exists on page, and an OK button is available, click it
          var saveAsPopUp = Aliases.BrowserProcess.WaitAliasChild("FFSaveDialog",2000)
          if(saveAsPopUp.Exists)
          {
            if (Aliases.BrowserProcess.FFSaveDialog.WaitAliasChild("SaveButton",1000).Exists)
            {
              Aliases.BrowserProcess.FFSaveDialog.SaveButton.Click()
            }  
            else{Log.Error("'Save' button is greyed out.");}
          }
          
          //wait 1 second for the Dialog to close
          delay(1000);
          alreadyExistsPopUp = Aliases.BrowserProcess.WaitAliasChild("ConfirmSaveAsWindow",500)
          if(alreadyExistsPopUp.Exists)
          {
            //find the Yes to replace the file
            var yesButton = Aliases.BrowserProcess.ConfirmSaveAsWindow.YesButton
            if(yesButton.Exists)
            {
              //click on Yes to replace the file
              yesButton.Click();
            }
          }

          //check if the Dialog is still on page. If it is, close it
          var saveAsPopUp = Aliases.BrowserProcess.WaitAliasChild("FFSaveDialog",200)
          if(saveAsPopUp.Exists && saveAsPopUp.VisibleOnScreen)
          {
            Log.Error("Two download instances have started. Please see issue #DWNQA-879");
            saveAsPopUp.Close();
            //wait 1 second for it to close
            delay(500);
          }
          
          //open the download library:
          Sys.Browser("firefox").UIPage("chrome://browser/content/browser.xul").toolbar("toolbar_menubar").toolbaritem("menubar_items").menubar("main_menubar").ClickItem("Tools|Downloads");
          delay(500);
          
          //verify the download library exists:
          if(Sys.Browser("firefox").FindChild("WndCaption", "Library").Exists)
          {
            //get the Caption of the upper downloaded file
            var formDownloadPanel = Sys.Browser("firefox").WaitForm("Library", 100);
            if(formDownloadPanel.Exists)
            {
              //verify the List(0) child exists
              var waitListItem = Sys.Browser("firefox").Form("Library").Application("Library").WaitList(0, 500);
              if(waitListItem.Exists)
              {
                try{
                downloadPanel = Sys.Browser("firefox").Form("Library").Application("Library").List(0).Child(0);
                }catch (e)
                {
                    Log.Error("Error during the download.")
                    downloadPanel = null
                    
                }
              }
              else
              {
                //if List(0) does not exists, list all children of Form("Library") object and all of their 1st level children
                //this will help identify which is the correct path to be used
                var libraryChildCount = Sys.Browser("firefox").Form("Library").ChildCount;
                for(i = 0; i < libraryChildCount; i++)
                {
                  Log.Message(Sys.Browser("firefox").Form("Library").Child(i).FullName);
                  if(Sys.Browser("firefox").Form("Library").Child(i).ChildCount != 0)
                  {
                    //list all children for the children of Form("Library") object
                    var grandchildCount = Sys.Browser("firefox").Form("Library").Child(i).ChildCount;
                    for(j = 0; j < grandchildCount; j++)
                    {
                      Log.Message(Sys.Browser("firefox").Form("Library").Child(i).Child(j).FullName);
                    }
                  }
                  else
                  {
                    Log.Warning(Sys.Browser("firefox").Form("Library").Child(i).FullName + " has no children. Moving to next child");
                  }
                  Log.Message("==================================================");
                }
              }
            }
            else
            {
              var windowDownloadPanel = Sys.Browser("firefox").WaitWindow("MozillaWindowClass", "Library", 1, 100);
              if(windowDownloadPanel.Exists)
              {
                Log.Error("'Library' window has incorrect object path. Normal path: Form(Library). Incorrect: Window(MozillaWindowClass, Library, 1)");
              }
            }
            if (downloadPanel != null)
            {
            //get 2 status instances of the download progress
            var getStatusInitial = downloadPanel.Caption;
            Log.Picture(Sys.Desktop.Picture(), "Instance #1: estimated time left for download to complete");
            //delay the script execution for 3 seconds and only then grab the status (to verify download progress)
            delay(1500);
            var getStatusFinal = downloadPanel.Caption;
            Log.Picture(Sys.Desktop.Picture(), "Instance #1: estimated time left for download to complete");
            //seconds remaining
            //check first download status
            //if progress="100" is found, download is complete
            //if progress="0" is found, download has not started
            //if different than progress="0" or progress="100", download has started -> compare with 2nd status insance
            if(aqString.Find(getStatusInitial, "Open Containing Folder") != -1)
            {Log.Message("Download completed");}
            else
            {
              //as status is not completed and has started, verify it's progressing
              //if statuses are identical, log an error
              if(aqString.Compare(getStatusInitial, getStatusFinal, true) == 0)
              {Log.Error("Download is not progressing as status instances are the same. Please investigagte");}
              else{Log.Message("Download has started.");}
            }
            
            //click the 'Cancel' button for each existing ongoing download
            //get list with all listed ongoing downloads
            var cancelButtons = Sys.Browser("firefox").Form("Library").List(0).FindAllChildren("Caption", "Cancel", 2, true).toArray();

            //iterate thorough each array item and click the cancel button
            for(i = 0; i < cancelButtons.length; i++)
            {
              //cancel file download
              cancelButtons[i].Click();
            }

            //click on the 'Clear Downloads' button to close already downloaded files: 
            Sys.Browser("firefox").Form("Library").ToolBar(0).Button("Clear Downloads").Click();
            }
            //close the Download Library:
            Sys.Browser("firefox").Form("Library").Close();
            //verify if the Library window still exists.
            var libraryWindow = Sys.Browser("firefox").WaitForm("Library", 2000);
            //if Library window still exists, close it
            if(libraryWindow.Exists)
            {
              Log.Message("Library window was not closed on first try. Closing it now...");
              Sys.Browser("firefox").Form("Library").Close();
            }
          }
          else{Log.Error("Download library pop-up window was not found");}
          }
          else{Log.Error("FF download pop-up (of any type) was NOT found");}
      
          break;
        }	
        
        case "Offsite Popup (Web Page, pop up)":
        case "Offsite Popup (Web Page, main window)":
        case "iOS Product":
        case "Android Product":
        {
          //accept any page
          var page = Sys.Browser(Project.Variables.CurrentBrowser).Page("*");
          
          //search all level 1 pages from the Chrome process that contain "http://" string in the URL property and store them into array
          var pagesList = Sys.Browser(Project.Variables.CurrentBrowser).FindAllChildren("URL", "http*://*", 1).toArray();
          
          //loop through the array
          for(var i = 0; i < pagesList.length; i++)
          {
            
            //wait for the page to load
            pagesList[i].Wait();
              
            //for pages that don't contain in their URL the server being tested
            if(aqString.Find(pagesList[i].URL, Project.Variables.ServerName) == -1)
            {

              //verify page status is 200 / 302
              VerifyWebObject(pagesList[i].URL)
              
              //only if a 3rd party site was opened in a new tab.
              if(pagesList.length > 1)
              {            
                //close the tab
                pagesList[i].Close();
              }
            }
            else
            {
              //if page URL contains the server being tested
              //verify the page contains 3055 within it's URL
              
              //get current URL
              var currentURL = page.URL;

              //verify the end page URL contains 3055 
              results = aqString.Find(currentURL, "3055"); 
              if(results != -1)
              {Log.Message("User was redirected to correct page: contains 3055");}
              else{Log.Error("User was NOT redirected to correct page as the page does not contain 3055. URL of the page: " + currentURL);}
            }
          }
          break;
        }
        
        
        default:
        {
          Log.Error("No such variation");
          break;
        }
      }
      break;
    }
    
    default:
    {
      Log.Error("No support exists for this browser / incorrect browser name");
      break;
    }
  }  
}
