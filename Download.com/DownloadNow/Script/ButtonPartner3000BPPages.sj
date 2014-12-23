//USEUNIT DownloadWindow
//USEUNIT DRESection
//USEUNIT LoggingAttribute
//USEUNIT NavigateToURL
//USEUNIT RunKillBrowsers
//USEUNIT SearchAndWaitToExist

function ButtonPartner3000BP(variationType, browserName)
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
    if(csvPageType == "Button Partner 3000BP")
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
           
        Log.Message("Opening Button Partner 3000BP page", "", pmNormal, UseCaseStyle());    
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
      
        //verify the landing URL contains "part=dl-x"
        var results = aqString.Find(currentURL, "part=dl-x");
        if(results != -1)
        {Log.Message("Page contains 'part=dl-x'");}
        else{Log.Error("Page does NOT contain 'part=dl-x'");}
      
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
      
        
        Log.Message("Use case: verify center section and ads", "", pmNormal, UseCaseStyle());  
        //search that the page contains the center section
        //use property = 'className' / value = 'product-landing-table bp-table'
        Log.Message("Search if the center section exists");
        var centerSection = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren("className", "product-landing-table bp-table", 20).toArray();        
        
        //if only 1 center section was found using the proprety / value used
        if(centerSection.length == 1)
        {Log.Message("'Center section' from page was found");}
        else
        {
          //if no 'center section' was found 
          if(centerSection.length == 0)
          {Log.Error("'Center section' was not found on page");}
          
          //if more than 1 'center section' was found using the property / value
          if(centerSection.length > 1)
          {
            Log.Error("More than one 'center section' was found using following property / value");
            Log.Error("Property name / value: 'className' / 'product-landing-table bp-table'");
          }
        }
        
        //verify the correct special offer ad is displayed
        //for Standard page, a generic MPU should be displayed
        if(csvVariation == "Standard")
        {
          var adsOnPageArray = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren("idStr", "button-partner-offer", 20).toArray();
          if(adsOnPageArray.length == 1)
          {
            var image = adsOnPageArray[0].FindChild("ObjectIdentifier", "DL_SpecialOfferNew_png", 3);
            if(image.Exists && image.Visible)
            {
              Log.Message("MPU for Standard Product was found.");
            }
            else
            {
              Log.Error("No MPU was found for Standard Product");
            }
          }
        }
        
        //for VIP page, a specific ad is displayed
        if(csvVariation == "VIP Product")
        {
          var adsOnPageArray = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren("idStr", "button-partner-offer", 20).toArray();
          if(adsOnPageArray.length == 1)
          {
            var image = adsOnPageArray[0].FindChild("ObjectIdentifier", "*PromoLogo_png", 3);
            if(image.Exists && image.Visible)
            {
              Log.Message("MPU for VIP Product was found.");
            }
            else
            {
              Log.Error("No MPU was found for VIP Product");
            }
          }
        }
        
        //for DLM page, a larger MPU is displayed in the right of the center section
        if(csvVariation == "DLM Product")
        {
          var adsOnPageArray = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren("idStr", "mpu_button_partner", 20).toArray();
          if(adsOnPageArray.length == 1)
          {
           Log.Message("MPU for VIP Product was found.");
          }
          else
          {
            Log.Error("No MPU was found for VIP Product");
          }
        }
        
        Log.Message("Use case: download button", "", pmNormal, UseCaseStyle());  
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

        //get current URL
        var currentURL = page.URL;

        //verify the end page URL contains 3001 
        results = aqString.Find(currentURL, "3001"); 
        if(results != -1)
        {Log.Message("User was redirected to correct page: contains 3001");}
        else{Log.Error("User was NOT redirected to correct page as the page does not contain 3001. URL of the page: " + currentURL);}
              
        //verify the productSetID is passed on:
        results = aqString.Find(currentURL, productSetID);
        if(results != -1)
        {Log.Message("ProductSetID was passed on in the 3001 URL");}
        else{Log.Error("ProductSetID was NOT passed on in the 3001 URL");}
        
        Log.Message("Use case: 'restart the download' case", "", pmNormal, UseCaseStyle());  
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
        
        Log.Message("Use case: DRE section (3001 page)", "", pmNormal, UseCaseStyle());  
        //verify the DRE section on the 3001 page:
        DreSection();
        
        
        //for DLM Product
        if(csvVariation == "DLM Product")
        {
          Log.Message("Use case: 'Direct Download Link'", "", pmNormal, UseCaseStyle());  
          //go back to the test URL
          Sys.Browser(browserName).ToUrl(Project.Variables.ServerName + csvURL);
          page.Wait();
          
          // verify the page contains a 'Direct Download Link'
          
          // Specify the sought-for property names 
          PropArray = new Array ("contentText", "className");
          // Specify the sought-for property values
          ValuesArray = new Array ("Direct Download Link", "dln-cta");
          
          var directDownloadLinkList = Sys.Browser(browserName).Page(Project.Variables.ServerName + csvURL).FindAllChildren(PropArray, ValuesArray, 20).toArray();
          //if only one element was found
          if(directDownloadLinkList.length == 1)
          {
            //click on the element
            directDownloadLinkList[0].Click(); 
            
            //check download notification (pop-up, bar ...)
            //for IE browser, version 10 and lower, verify the notificaiton download appears without waiting for the new page to load
    		    if(Project.Variables.CurrentBrowser == "iexplore" && Project.Variables.IEVersion <= 10)
            {
              //for IE 10, wait an extra 2 seconds to make sure that the download pop-up appeared on screen
              delay(2000);
              //verify download pop-up / bar is triggered and correct file is being downloaded, without waiting for the new page to load
              VerifyDownloadWindow(extension, csvVariation);
            }
            else
            {
              //wait 3 seconds for the page to start loading
              delay(3000);
              Log.Message("Page starts to load after the 'Direct Download Link' was clicked");
              //wait for page to load
              page.Wait();

              //verify download pop-up / bar is triggered and correct file is being downloaded
              VerifyDownloadWindow(extension, csvVariation);
              
              //verify the landing page contains 3001 URL
              
              //get current URL
              var currentURL = page.URL;

              //verify the end page URL contains 3001 
              results = aqString.Find(currentURL, "3001"); 
              if(results != -1)
              {Log.Message("User was redirected to correct page: contains 3001");}
              else{Log.Error("User was NOT redirected to correct page as the page does not contain 3001. URL of the page: " + currentURL);}
              
              //verify the productSetID is passed on:
              results = aqString.Find(currentURL, productSetID);
              if(results != -1)
              {Log.Message("ProductSetID was passed on in the 3001 URL");}
              else{Log.Error("ProductSetID was NOT passed on in the 3001 URL");}
            }
          }
          else
          {
            Log.Error("More than 1 object with following property name / value were found. Please use extra / different property name");
            Log.Error("Property name / value: " + PropArray[0] + " / " + ValuesArray[0]);
            Log.Error("Property name / value: " + PropArray[1] + " / " + ValuesArray[1]);
          }
        }
        Log.Message("Use case: DRE section (3000 page)", "", pmNormal, UseCaseStyle());  
      }
    }
    
    //get next link from the spreadsheet
    link.Next();
  }
  
}