//USEUNIT DownloadWindow
//USEUNIT DRESection
//USEUNIT IEAditionalDownloadPopUp
//USEUNIT LoggingAttribute
//USEUNIT NavigateToURL
//USEUNIT RunKillBrowsers
//USEUNIT SearchAndWaitToExist


function Redirect3055 (variationType, browserName)
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
    
    //if page type for current row is Redirect 3055
    if(csvPageType == "Redirect 3055")
    {
      //if the page variation corresponds with the variationType (variationType is taken from the Project TestCases view)
      if(csvVariation == variationType)
      {
        
        //post the csv details to log: Page Type, Variation, Platform and URL used
        Log.Message("============== Start new iteration ========", "", pmNormal, IterationStyle());
        Log.Message("Page Type: " + csvPageType, "", pmNormal, IterationStyle());
        Log.Message("Variation: " + csvVariation, "", pmNormal, IterationStyle());
        Log.Message("Platform: " + csvPlatform, "", pmNormal, IterationStyle());
        Log.Message("URL: " + Project.Variables.ServerName + csvURL, "", pmNormal, IterationStyle());
        Log.Message("===========================================", "", pmNormal, IterationStyle());
        
        Log.Message("Open the 3055 page type", "", pmNormal, UseCaseStyle());        
        //navigate to URL taken from the csv file
        NavigateToURLs(browserName, csvURL);
            
        //get current page URL
        var browser = Sys.Browser(Project.Variables.CurrentBrowser);
        var page = browser.Page("*");
        page.Wait();
        var currentURL = page.URL;
      
        Log.Message("Use case: Verify page", "", pmNormal, UseCaseStyle());
        
        //verify the landing URL is on the same environment as the one navigated to (csvURL vs currentURL)
        var results = aqString.Find(currentURL, Project.Variables.ServerName);
        if(results != -1)
        {Log.Message("Page on correct Server was opened");}
        else{Log.Error("Page on correct Server was NOT opened. Expected server name: " + Project.Variables.ServerName + ". Actual: " + currentURL);}
      
        //verify the page is a 3055 page
        var results = aqString.Find(currentURL, "3055");
        if(results != -1)
        {Log.Message("Page URL contains 3055 ID");}
        else{Log.Error("Page URL does not contain the 3055 ID. Actual URL: " + currentURL);}
        
        //========================== Check Platform ===============================================
        //verify the landing tab is the same as the one from excel (csvPlatform vs current one): use className property
        switch(csvPlatform)
        {
          case "Windows":
          {
            if(csvVariation == "Offsite Popup (Download)")
            {
              var extension = ".zip";
            }
            else
            {
              //set extension for windows: 
              var extension = ".exe";
            }
            
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
        
        Log.Message("Use case: verify DRE Unit", "", pmNormal, UseCaseStyle());
        //verify the DRE
        DreSection();
        
        
        
       
      }
    }
    //get next link from the spreadsheet
    link.Next();
  }
  //close the connection to the spreadsheet
  link.Disconnect();
}