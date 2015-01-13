//USEUNIT DownloadWindow
//USEUNIT DRESection
//USEUNIT LoggingAttribute
//USEUNIT NavigateToURL
//USEUNIT RunKillBrowsers
//USEUNIT SearchAndWaitToExist

function OptimizedSEM3014(variationType, browserName)
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
    if(csvPageType == "Optimized SEM Avast 3014")
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
           
        Log.Message("Use case: Open Optimized SEM Avast 3014 page", "", pmNormal, UseCaseStyle());    
        //navigate to URL taken from the csv file
        NavigateToURLs(browserName, csvURL);
            
        //get current page URL
        var browser = Sys.Browser(Project.Variables.CurrentBrowser);
        var page = browser.Page("*");
        page.Wait();
        var currentURL = page.URL;
      
        //get the productSetID
        //get the number of the last "/"
        var start = aqString.FindLast(currentURL, "/");
        //get the number of the next "." starting from last "/"
        var last = aqString.Find(currentURL, ".", start);
        //get the productSetID
        var productSetID = aqString.SubString(currentURL, start+6, last - start-6);
        
        //verify the landing URL is on the same environment as the one navigated to (csvURL vs currentURL)
        var results = aqString.Find(currentURL, Project.Variables.ServerName);
        if(results != -1)
        {Log.Message("Page on correct Server was opened");}
        else{Log.Error("Page on correct Server was NOT opened. Expected server name: " + Project.Variables.ServerName + ". Actual: " + currentURL);}

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
             
        Log.Message("Use case: verify Avast add is present", "", pmNormal, UseCaseStyle());
        var avastAd = page.FindAllChildren("ObjectIdentifier", "avast_3014_promotion_jpg", 50).toArray();
        if(avastAd.length == 1)
        {Log.Message("Avast ad was found on page");}
        else
        {
          if(avastAd.length == 0)
          {Log.Error("No Avast ad was found on page");}
          else{Log.Error("More that 1 Avast ad was found on page");}
        }
          
        
        Log.Message("Use case: Download button", "", pmNormal, UseCaseStyle());  
        //search for the 'Download Now' button
        Log.Message("Search and click on the 'Download Now' button");
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
            
        Log.Message("Use case: verify download", "", pmNormal, UseCaseStyle());    
        //verify download pop-up / bar is triggered and correct file is being downloaded
        VerifyDownloadWindow(extension, csvVariation);
      
        //wait (up to 30 seconds) for the 'restart the download' object to appear on page
        SearchWaitToExist("contentText", "restart the download.");

        Log.Message("Use case: 'restart the download' link", "", pmNormal, UseCaseStyle());  
        
        //get current URL
        var currentURL = page.URL;

        //verify the end page URL contains 3016 
        results = aqString.Find(currentURL, "3016"); 
        if(results != -1)
        {Log.Message("User was redirected to correct page: contains 3016");}
        else{Log.Error("User was NOT redirected to correct page as the page does not contain 3016. URL of the page: " + currentURL);}
              
        //verify the productSetID is passed on:
        results = aqString.Find(currentURL, productSetID);
        if(results != -1)
        {Log.Message("ProductSetID was passed on in the 3012 URL");}
        else{Log.Error("ProductSetID was NOT passed on in the 3012 URL");}
        
        //search for the 'restart the download' link
        Log.Message("Find and click on the 'restart the download' link");
        //find all links with following properties / values:
        
        // Specify the sought-for property names 
        PropArray = new Array ("contentText", "idStr");
        // Specify the sought-for property values
        ValuesArray = new Array ("restart the download.", "pdl-manual");
        
        var restartDownloadList = Sys.Browser(browserName).Page(currentURL).FindAllChildren(PropArray, ValuesArray, 20).toArray();
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
        
        Log.Message("Use case: DRE section (3016 page)", "", pmNormal, UseCaseStyle()); 
        //verify the DRE
        DreSection();
        
      }
    }
    
    //get next link from the spreadsheet
    link.Next();
  }
  
}