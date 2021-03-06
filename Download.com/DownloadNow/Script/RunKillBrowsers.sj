//USEUNIT LoggingAttribute

/// <summary>
/// Launches the specified browser instance.
/// </summary>
/// <param name="browserName">
/// Specify the browser which will be launched (from 'Test Items' project page)
/// </param>
function StartBrowser(browserName)
{
      //kill all browser instances: 
      CloseAllBrowserInstances();
       
      //for each browser
      switch ( browserName )
      {     
            case "iexplore":
			      {
              //set the max allowed IE version
              var maxIEVersion = 11;
			  
			        //get IE version and store it to persistent variable (in the Porject Variables)
              Project.Variables.VariableByName("IEVersion") =  Browsers.Item(Browsers.btIExplorer).Version.MajorPart; 
              
              Log.Message("IE version intalled on machine: " + Project.Variables.IEVersion);
			  
              //set the browser process to persistent variable
              Project.Variables.VariableByName("CurrentBrowser") = "iexplore"; 
			  
			        //if IE version is greater than maxIEVersion, stop the test and post message to log
              if((Project.Variables.IEVersion > maxIEVersion) || (Project.Variables.IEVersion < 8))
              {
                Log.Error("No support is added for IE version " + Project.Variables.IEVersion + ". Please use a different version.");
                Log.Error("Latest supported version is version " + maxIEVersion);
				        Log.Error("Oldest supported version is version 8");
               
			          //stop the current test only
                Runner.Stop(true);
              }
              
              //run the browser
              TestedApps.iexplore.Run();
			  
			        //post to log the current IE version what was launched
              Log.Message("Following IE version was launched: " + Project.Variables.IEVersion);

              //in case the "Your last browsing session closed unexpectedly" pop-up / notification appears, close it
              if(Project.Variables.IEVersion == 8)
              {
                //verify if the pop-up appears
                var ieRestoreDialog = Sys.Browser("iexplore").WaitDialog("*Internet Explorer", 100);
                if(ieRestoreDialog.Exists)
                {
                  Sys.Browser("iexplore").Dialog("*Internet Explorer").TitleBar(0).Button("Close").Click();
                }
                if(Aliases.BrowserProcess.WaitAliasChild("IEWarningMessage",50).Exists)
                    {
                        Aliases.BrowserProcess.IEWarningMessage.GoToHomePageLink.Click()
                    }
              }
              else
              {
                //for IE 9, 10 and 11
                //wait 2 seconds for the notification bat to appear
                var frameNotificationBar = Sys.Browser("iexplore").BrowserWindow(0).WaitWindow("Frame Notification Bar", "", 1, 2000);
                //if it appears
                if(frameNotificationBar.Exists)
                {
                  //verify it's visible. If it's visible, close it
                  if(frameNotificationBar.Visible)
                  {
                    //search for the close button:
                    var closeButton = frameNotificationBar.FindChild("ObjectIdentifier", "Close", 2, true);
                    if(closeButton.Exists)
                    {
                      //click the x to close the notification
                      closeButton.Click();
                    }
                    else
                    {
                      Log.Error("Notification bar is visible at browser launch but no Close button was found for it");
                    }
                  }
                }
              }
              
              //make sure the browser window is maximized
              MaximizeBrowserWindows();
              
              break;
			      }
			
            case "firefox":
			      {
              //set the maximum allowed FF version
              var maxFFVersion = 35;
              
              //get FF version:
              var ffVersion = Browsers.Item(Browsers.btFirefox).Version.MajorPart;
              
              Log.Message("FF version intalled on machine: " + ffVersion);
            
              //set the browser process to persistent variable
              Project.Variables.VariableByName("CurrentBrowser") = "firefox";
			  
			        //if FF version is greater than maxFFVersion or smaller than 27, stop the test and post message to log
              if((ffVersion > maxFFVersion) || (ffVersion < 27))
              {
                Log.Error("No support is added for FF version " + ffVersion + ". Please use a different version.");
                Log.Error("Latest supported version is: " + maxFFVersion);
				        Log.Error("Oldest supported FF version is version 27");
				
                //stop the current test only
                Runner.Stop(true);
              }
			  
			        //run the browser
              TestedApps.firefox.Run();
			        
             
              //make sure the browser window is maximized
              MaximizeBrowserWindows();
              
              //set browser zoom level to 100%
              Sys.Browser("firefox").UIPage("chrome://browser/content/browser.xul").toolbar("toolbar_menubar").toolbaritem("menubar_items").menubar("main_menubar").ClickItem("View|Zoom|Reset");
			  
			        //post to log the current FF version what was launched
              Log.Message("Following FF version was launched: " + ffVersion);

              break;
            }
			
            case "chrome":
			      {
              //set maximum Chrome version:
              var maxChromeVersion = 40;
              
			        //set the browser process to persistent variable
              Project.Variables.VariableByName("CurrentBrowser") = "chrome";
              
              //get current Chrome version
              var chromeVersion = Browsers.Item(Browsers.btChrome).Version.MajorPart;
              
              Log.Message("Chrome version intalled on machine: " + chromeVersion);

              //if Chrome version is greater than maxChromeVersion, post an error message to the log and stop test
              if((chromeVersion > maxChromeVersion) || (chromeVersion < 35))
              {
                Log.Error("No support is added for Chrome version " + chromeVersion + ". Please use a different version.");
                Log.Error("Latest supported version is version " + maxChromeVersion);
				        Log.Error("Oldest supported FF version is version 35");
				
                //stop the current test only
                Runner.Stop(true);
              }
              
              //launch Chrome
              Browsers.Item("chrome").Run()

			        //make sure the browser window is maximized
              MaximizeBrowserWindows();
			  
			        //post to log the current Chrome version what was launched
              Log.Message("Following Chrome version was launched: " + chromeVersion);
              
              //close the top notification bar ('You are using an unsupported command-line flag...' bar)
              var topNotifBar = Aliases.BrowserProcess.BrowserWindow.WaitAliasChild("ChromeTopWarningBar",500)
              if(topNotifBar.Exists)
              {
               // topNotifBar.Button("Close").Click();
               topNotifBar.CloseButton.Click();
              }
              else{Log.Message("Top notification bar was not found.");}

              break;
			      }
              
            default:
              Log.Error("Entered browser name is not supported");
              break;
      }    
}

/// <summary>
/// Closes all browser instances (for IE, FF and Chrome).
/// </summary>
function CloseAllBrowserInstances()
{
    var IEProcess, PropName, PropValues;

    //close all IE instances
    while(true)
    {
        //set variables in case multiple IE browsers are opened (IE opens a browser process for each browser window)
        PropName = Array("processname", "index");
        PropValues = Array("iexplore", 1);
        
        //find all IE processes
        IEProcess = Sys.FindChild(PropName, PropValues, 1, true);
    
        //if process does not exist, exit while loop
        if(IEProcess.Exists == false)
        {
            break;
        }
        else
        {                
            //termnate the process
            IEProcess.Terminate();
            //delay script execution for 4 second before verifying if the IE process 
            //exists (so that the terminat process has the change to kill IE)
            Delay(2000);
            //terminate the process if still not closed
            if(IEProcess.Exists)
            { 
                IEProcess.Terminate();
            }
        }
    }
    						
    //close all Chrome instances:
    Sys.Refresh()
    var chromeProcess = Sys.FindChild("processname", "chrome", 1, true);
    var c = 0;
    while(chromeProcess.Exists && c < 10)
    {   
        if(chromeProcess.Exists)
        {
          //chromeProcess.Terminate();
         chromeProcess.Close()
        }
        if(chromeProcess.Exists)
        {
          //click the 'Yes, exit Chrome' button (if it appears) for hanging downloads.
          var dwInProgress = Aliases.BrowserProcess.Page.WaitAliasChild("ConfirmWindow",100)
          if(dwInProgress.Exists)
          {
            var yesExitChromeButton = dwInProgress.WaitAliasChild("OKButton",100)
            if(yesExitChromeButton.Exists)
            {
              yesExitChromeButton.Click();
              delay(500);
              //end while loop
              c = 10;
            }
          }
        }
        
        chromeProcess = Sys.FindChild("processname", "chrome", 1, true);
        c++;
        if(c == 10)
        {
          Sys.WaitBrowser("chrome",10).Terminate();
          if(chromeProcess.Exists)
          {Log.Message("Chrome process was not closed after sending 10 Terminate commands");}
        }  
    }
  
    //close all FF instances:
    var firefoxProcess = Sys.FindChild("processname", "firefox", 1, true);
    var f = 0;
    while(firefoxProcess.Exists && f < 10)
    {
        Sys.WaitBrowser("firefox",500).Close();
         if (Aliases.BrowserProcess.WaitAliasChild("ConfirmCloseWindow", 500).Exists)
           {
               closeTab = Aliases.BrowserProcess.ConfirmCloseWindow.FindChild("ObjectIdentifier","Close tabs",5)
               closeTab.Click()
           }
        firefoxProcess = Sys.FindChild("processname", "firefox", 1, true);
        f++;
        if(f == 10)
        {
          Sys.WaitBrowser("firefox",500).Terminate();
          if(firefoxProcess.Exists)
          {Log.Message("Firefox process was not closed after sending 10 Terminate commands")}
          }
    }
}
/// <summary>
/// Maximize browser window (for IE, FF and Chrome).
/// </summary>
function MaximizeBrowserWindows()
{
    //find all objects that have the Object Type property and BrowserWindow value. Store then into array
    var browserWindow = Sys.Browser(Project.Variables.CurrentBrowser).FindAll("ObjectType", "BrowserWindow", 1, true).toArray();
    if (Project.Variables.CurrentBrowser == "iexplore")
    {
    if (Aliases.BrowserProcess.WaitAliasChild("SetUpDialog",1000).Exists)
        {
           Aliases.BrowserProcess.SetUpDialog.panelWelcomeToInternetExplorer8.AskMeLaterButton.Click()
        }
    }
    
    //for each found object, call the Maximize method in order to maximize the browser window
    for (var i = 0; i < browserWindow.length; i++)
    {
        browserWindow[i].Maximize();
    }
} 
