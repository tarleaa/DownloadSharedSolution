
//USEUNIT DownloadWindow
//USEUNIT DRESection
//USEUNIT IEAditionalDownloadPopUp
//USEUNIT LoggingAttribute
//USEUNIT NavigateToURL
//USEUNIT RunKillBrowsers
//USEUNIT SearchAndWaitToExist

function AvastOnlyHL (variationType, browserName)
{
  //======================== Read CSV file =====================================
  //get the csv file from the Variables tab of the current project
  var link = Project.Variables.DLNowDataSource;
  //position the iterator on the first row of the csv file
  link.Reset();

  //go through the file getting each row   
  while (link.IsEOF() == false)
  {
    //get the value from each row, by table header
    var csvPageType = link.Value("Pagetype");
    var csvVariation = link.Value("Variation");
    var csvPlatform = link.Value("Platform");
    var csvURL = link.Value("URL");
    //======================== End of Read CSV file ============================
    
    //if page type for current row is Product Detail 3000
    if(csvPageType == "Avast-only HL 3000BP" || csvPageType == "Avast-only HL 3001BP")
    {
      //if the page variation corresponds with the variationType (variationType is taken from the Project TestCases view)
      if(csvVariation == variationType)
      {
        //post the csv details to log: Page Type, Variation, Platform and URL used
        Log.Message("============== Start new iteration ========");
        Log.Message("Page Type: " + csvPageType);
        Log.Message("Variation: " + csvVariation);
        Log.Message("Platform: " + csvPlatform);
        Log.Message("URL: " + Project.Variables.ServerName + csvURL);
        Log.Message("===========================================");
        
        Log.Message("Open the 3000 page type", "", pmNormal, UseCaseStyle());        
        //navigate to URL taken from the csv file
        NavigateToURLs(browserName, csvURL);
            
        //get current page URL
        var browser = Sys.Browser(Project.Variables.CurrentBrowser);
        var page = browser.Page("*");
        page.Wait();
        var currentURL = page.URL;
      
        //verify the landing URL is on the same environment as the one navigated to (csvURL vs currentURL)
        var results = aqString.Find(currentURL, Project.Variables.ServerName);
        if(results != -1)
        {Log.Message("Page on correct Server was opened");}
        else{Log.Error("Page on correct Server was NOT opened. Expected server name: " + Project.Variables.ServerName + ". Actual: " + currentURL);}
      
        //verify the landing URL contains "part=dl-"
        var results = aqString.Find(currentURL, "part=dl-");
        if(results != -1)
        {Log.Message("Page contains 'part=dl-'");}
        else{Log.Error("Page does NOT contain 'part=dl-'");}
      
        //========================== Check Platform ===============================================
        //verify the landing tab is the same as the one from excel (csvPlatform vs current one): use className property
        switch(csvPlatform)
        {
          case "Windows":
          {            
            //set extension for windows: 
            var extension = ".exe";
            
            break;
          }
        
          case "Mac":
          {             
            //set extension for mac: 
            var extension = ".dmg";
            break;
          }
        
          case "iOS":
          case "Android":
          {
            break;
          }
          
          default:
          {
    				Log.Error("No such platform available");
    				break;
          }
        }
        //========================== End of Check Platform ========================================
       
        //for Avast-only HL 3000BP trigger the download by clicking on the Download Now button
        if(csvPageType == "Avast-only HL 3000BP")
        {
          Log.Message("Click Download button", "", pmNormal, UseCaseStyle());
          if (Aliases.BrowserProcess.Page.WaitAliasChild("DownloadNowButton",5000)) 
          {
              Aliases.BrowserProcess.Page.DownloadNowButton.Click();
          }
        }
      
        Log.Message("Verify download", "", pmNormal, UseCaseStyle());  
        //verify download pop-up / bar is triggered and correct file is being downloaded
        VerifyDownloadWindow(extension, csvVariation);
      
        //for Avast-only HL 3001BP variation, check the "restart the download" link works
        if(csvPageType == "Avast-only HL 3001BP")
        {
          Log.Message("Verify 'restart the download' scenario (from the 3001 page)", "", pmNormal, UseCaseStyle());  

          var restartDownload = Aliases.BrowserProcess.Page.WaitAliasChild("RestartDownloadLink",60000)
          if (restartDownload.Exists)
          {
              restartDownload.Click()
              VerifyDownloadWindow(extension, csvVariation);
          }
          
          Log.Message("DRE section on the Avast-only HL 3001BP page", "", pmNormal, UseCaseStyle());  
          //check the DRE section
          DreSection();
        }
        if(csvPageType == "Avast-only HL 3000BP")
        {
          //verify the user is left of on the same URL:
          currentURL = page.URL;
          var results = aqString.Compare(currentURL, Project.Variables.ServerName + csvURL, true);
          //if strings are equal
          if(results == 0)
          {Log.Message("Same page is displayed after downloading the file");}
          else{Log.Error("Different page URL is displayed after downloading the file");}
        } 
        //kill all browsers
        CloseAllBrowserInstances();      
      }
    }
    
    //get next link from the spreadsheet
    link.Next();
  }
  
  //close the connection to the spreadsheet
  link.Disconnect();
}