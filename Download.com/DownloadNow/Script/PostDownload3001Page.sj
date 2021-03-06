//USEUNIT DownloadWindow
//USEUNIT DRESection
//USEUNIT IEAditionalDownloadPopUp
//USEUNIT LoggingAttribute
//USEUNIT NavigateToURL
//USEUNIT RunKillBrowsers
//USEUNIT SearchAndWaitToExist

function PostDw3001 (variationType, browserName)
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
    if(csvPageType == "Post-download 3001")
    {
      //post the csv details to log: Page Type, Variation, Platform and URL used
      Log.Message("============== Start new iteration ========");
      Log.Message("Page Type: " + csvPageType);
      Log.Message("Variation: " + csvVariation);
      Log.Message("Platform: " + csvPlatform);
      Log.Message("URL: " + Project.Variables.ServerName + csvURL);
      Log.Message("===========================================");
         
      Log.Message("Use case: open page (3001 page)", "", pmNormal, UseCaseStyle());      
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
      
      //verify the landing URL contains the 3001 string
      var results = aqString.Find(currentURL, "3001");
      if(results != -1)
      {Log.Message("Page contains 3001 in URL");}
      else{Log.Error("Page does not contain 3001 in the URL");}
      
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
      
      Log.Message("Use case: verify download", "", pmNormal, UseCaseStyle()); 
      //verify download pop-up / bar is triggered and correct file is being downloaded
      //VerifyDownloadWindow method is called from the 'DownloadWindow' script file
      VerifyDownloadWindow(extension, csvVariation);
      
      Log.Message("Use case: 'restart the download' link", "", pmNormal, UseCaseStyle()); 
      //search the 'restart the download.' link
      var restartDownload = Aliases.BrowserProcess.Page.WaitAliasChild("RestartDownloadLink",5000)
      if(restartDownload != null)
      {
        //click on the 'restart the download.' link
        restartDownload.Click();

        //verify download pop-up / bar is triggered and correct file is being downloaded, without waiting for the new page to load
        VerifyDownloadWindow(extension, csvVariation);
      }
      
      Log.Message("Use case: DRE section (3001 page)", "", pmNormal, UseCaseStyle()); 
      //verify the DRE section:
      DreSection(); 
      
    }

    //get next link from the spreadsheet
    link.Next();
  }
  
  //close the connection to the spreadsheet
  link.Disconnect();
}