
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
            //search the windows button and confirm it's the active one
            var windowsTabButton = findChildMethod("className", "windows active");
            if(windowsTabButton != null)
            {Log.Message("Windows tab is the active tab");}
            else{Log.Error("Windows tab is not the active tab");}
            
            //set extension for windows: 
            var extension = ".exe";
            
            break;
          }
        
          case "Mac":
          { 
            //search the mac button and confirm it's the active one
            var macTabButton = findChildMethod("className", "mac active");
            if(macTabButton != null)
            {Log.Message("Mac tab is the active tab");}
            else{Log.Error("Mac tab is not the active tab");}
            
            //set extension for mac: 
            var extension = ".dmg";
            break;
          }
        
          case "iOS":
          {  
            //search the mac button and confirm it's the active one
            var iOSTabButton = findChildMethod("className", "ios active");
            if(iOSTabButton != null)
            {Log.Message("iOS tab is the active tab");}
            else{Log.Error("iOS tab is not the active tab");}
            break;
          }
        
          case "Android":
          {
            //search the mac button and confirm it's the active one
            var androidTabButton = findChildMethod("className", "android last active");
            if(androidTabButton != null)
            {Log.Message("Android tab is the active tab");}
            else{Log.Error("Android tab is not the active tab");}
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
          // Specify the sought-for property names 
          PropArray = new Array ("contentText", "className");
          // Specify the sought-for property values
          ValuesArray = new Array ("Download Now", "dln-cta");
          
          var downloadNowList = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren(PropArray, ValuesArray, 20).toArray();
          //if only one element was found
          if(downloadNowList.length == 1)
          {
            Log.Message("'Download Now' button was found on page");
            //click on the element
            downloadNowList[0].Click(); 
            page.Wait();
          }
          else
          {
            Log.Error("More than 1 object with following property name / value were found. Please use extra / different property name");
            Log.Error("Property name / value: " + PropArray[0] + " / " + ValuesArray[0]);
            Log.Error("Property name / value: " + PropArray[1] + " / " + ValuesArray[1]);
          }        
        }
      
        Log.Message("Verify download", "", pmNormal, UseCaseStyle());  
        //verify download pop-up / bar is triggered and correct file is being downloaded
        VerifyDownloadWindow(extension, csvVariation);
      
        //for Avast-only HL 3001BP variation, check the "restart the download" link works
        if(csvPageType == "Avast-only HL 3001BP")
        {
          Log.Message("Verify 'restart the download' scenario (from the 3001 page)", "", pmNormal, UseCaseStyle());  
          //find all links with following properties / values:
        
          // Specify the sought-for property names 
          PropArray = new Array ("contentText", "idStr");
          // Specify the sought-for property values
          ValuesArray = new Array ("restart the download.", "pdl-manual");
        
          var restartDownloadList = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren(PropArray, ValuesArray, 20).toArray();
          if(restartDownloadList.length == 1)
          {
            Log.Message("Clicking on the 'restart the download' link");
            //click on the 'restart the download.' link
            restartDownloadList[0].Click();

            //verify download pop-up / bar is triggered and correct file is being downloaded, without waiting for the new page to load
            VerifyDownloadWindow(extension, csvVariation);
          }
          else
          {
            Log.Error("More than 1 object with following property name / value were found. Please use extra / different property name");
            Log.Error("Property name / value: " + PropArray[0] + " / " + ValuesArray[0]);
            Log.Error("Property name / value: " + PropArray[1] + " / " + ValuesArray[1]);
          }
          
          Log.Message("DRE section on the Avast-only HL 3001BP page", "", pmNormal, UseCaseStyle());  
          //check the DRE section
          DreSection();
        }

        //verify the user is left of on the same URL:
        currentURL = page.URL;
        var results = aqString.Compare(currentURL, Project.Variables.ServerName + csvURL, true);
        //if strings are equal
        if(results == 0)
        {Log.Message("Same page is displayed after downloading the file");}
        else{Log.Error("Different page URL is displayed after downloading the file");}       
      }
    }
    
    //get next link from the spreadsheet
    link.Next();
  }
  
  //close the connection to the spreadsheet
  link.Disconnect();
}