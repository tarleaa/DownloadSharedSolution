//USEUNIT DownloadWindow
//USEUNIT DRESection
//USEUNIT IEAditionalDownloadPopUp
//USEUNIT LoggingAttribute
//USEUNIT NavigateToURL
//USEUNIT RunKillBrowsers
//USEUNIT SearchAndWaitToExist

function PD3000_AllPages(variationType, browserName)
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
    if(csvPageType == "Product Detail 3000")
    {
      //if the page variation corresponds with the variationType (variationType is taken from the Project TestCases view)
      if(csvVariation == variationType)
      {
        //post the csv details to log: Page Type, Variation, Platform and URL used
        Log.Message("============== Start new iteration ========", "" , pmNormal, IterationStyle());
        Log.Message("Page Type: " + csvPageType, "", pmNormal, IterationStyle());
        Log.Message("Variation: " + csvVariation, "", pmNormal, IterationStyle());
        Log.Message("Platform: " + csvPlatform, "", pmNormal, IterationStyle());
        Log.Message("URL: " + Project.Variables.ServerName + csvURL, "", pmNormal, IterationStyle());
        Log.Message("===========================================", "", pmNormal, IterationStyle());
           
        Log.Message("Use case: open 3000 page", "", pmNormal, UseCaseStyle());   
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
            //search the windows button and confirm it's the active one
            var windowsTabButton = findChildMethod("className", "windows active");
            if(windowsTabButton != null)
            {Log.Message("Windows tab is the active tab");}
            else{Log.Error("Windows tab is not the active tab");}
            
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

        
        //========================== Check Download button text ===================================
        //for Standard Product
        if(csvVariation == "Standard" || csvVariation == "Archived Product")
        {
          
          //verify the Download button is present on page and has the correct value
          var downloadButton = findChildMethod("contentText", "Download Now")
          if(downloadButton != null)
          {Log.Message("Download button with correct value (Download Now) was found");}
          else{Log.Error("Incorrect download button value was found");}
          
          //verify the Download button has the correct additional value, specific for this variation 
          downloadButton = findChildMethod("contentText", "Secure Download");
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found");}	
        }
		    
        //for Publisher Hosted or Offsite Popup (Download) versions
        if(csvVariation == "Publisher Hosted" || csvVariation == "Offsite Popup (Download)")
        {
          //verify the Download button is present on page and has the correct value
          var downloadButton = findChildMethod("contentText", "Download Now")
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found. Expected: 'Download Now'");}
          
          //verify the Download button has the correct additional value, specific for this variation
          downloadButton = findChildMethod("contentText", "External Download Site");
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found. Expected: 'External Download Site'");}
        }
        
        //for DLM Product
        if(csvVariation == "DLM Product")
        {
          //verify the Download button is present on page and has the correct value
          var downloadButton = findChildMethod("contentText", "Download Now")
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found. Expected: 'Download Now'");}
          
          //verify the Download button has the correct additional value, specific for this variation
          downloadButton = findChildMethod("contentText", "Installer Enabled");
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found. Expected: 'Installer Enabled'");}
        }
        
        //for Offsite Popup (Web Page, pop up), Offsite Popup (Web Page, main window), iOS Product and Android Product
        if(csvVariation == "Offsite Popup (Web Page, pop up)" || csvVariation == "Offsite Popup (Web Page, main window)"
            || csvVariation == "iOS Product" || csvVariation == "Android Product")
        {
          //verify the Download button is present on page and has the correct value
          var downloadButton = findChildMethod("contentText", "Visit Site")
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found. Expected: 'Visit Site'");}
          
          //verify the Download button has the correct additional value, specific for this variation
          downloadButton = findChildMethod("contentText", "External Download Site");
          if(downloadButton != null)
          {Log.Message("Download button with correct value was found");}
          else{Log.Error("Incorrect download button value was found. Expected: 'External Download Site'");}
        }
		    //========================== End of Check Download button text ============================

        //click on Download button
        if(downloadButton != null)
        {
          Log.Message("Use case: click the 'Download' / 'Visit site' button", "", pmNormal, UseCaseStyle());   
          //hover cursor to the button
          downloadButton.HoverMouse();
          //click on the button:
          downloadButton.Click();
        }
        else
        {
          Log.Error("Download button was not found on page. Stopping current test only...");
          Runner.Stop(true)
        }
        

        // for Publisher Hosted, Offsite Popup (Download) or Offsite Popup (Web Page, pop up), iOS Product and Android Product
        if(csvVariation == "Publisher Hosted" || csvVariation == "Offsite Popup (Download)" || csvVariation == "Offsite Popup (Web Page, pop up)"
            || csvVariation == "iOS Product" || csvVariation == "Android Product")
        {
          //find the 'Continue to Download' button on the page
          var continueToExternalSiteButton = SearchWaitToExist("contentText", "Continue to Download");
          if(continueToExternalSiteButton != null && continueToExternalSiteButton.Exists)
          {
            continueToExternalSiteButton.Click();
          }
          else{Log.Error("'This download is served from an external site' modal did not appear on screen.");}
          
          page.Wait();
        }
        
        //check that a pop-up was opened that requires the user to Open, Save or Save As the file (for Offsite Popup (Download) with IE browsers only)
        //click on the Save button
        if(csvVariation == "Offsite Popup (Download)" && browserName == "iexplore")
        {
          SaveCloseIEDecisionPopUp();
        }

        //========================== Check download via Download button ===========================
        //for IE version 10 and lower, verify the notificaiton download appears without waiting for the new page to load
		    if(Project.Variables.CurrentBrowser == "iexplore" && Project.Variables.IEVersion <= 10)
        {
          Log.Message("Use case: verify download", "", pmNormal, UseCaseStyle());   
          //verify download pop-up / bar is triggered and correct file is being downloaded, without waiting for the new page to load
          //VerifyDownloadWindow method is called from the 'DownloadWindow' script file
          VerifyDownloadWindow(extension, csvVariation);
          //wait for the page to load
          page.Wait();
        }
        else
        {
          //wait for page to load
          page.Wait();
              
          Log.Message("Use case: verify download", "", pmNormal, UseCaseStyle());  
          //verify download pop-up / bar is triggered and correct file is being downloaded
          //VerifyDownloadWindow method is called from the 'DownloadWindow' script file
          VerifyDownloadWindow(extension, csvVariation);
        }
        
        //for "Offsite Popup (Web Page, pop up)", "OffSitePopUp (Web Page, main window)", iOS Android or Android Product
        //skip the 'restart the download' scenario (it is not applicable)
        if((csvVariation != "Offsite Popup (Web Page, pop up)") && (csvVariation != "Offsite Popup (Web Page, main window)")
            && (csvVariation != "iOS Product") && (csvVariation != "Android Product") && (csvVariation != "Publisher Hosted"))
        {
          Log.Message("Use case: 'restart the download' scenario from the 3001 page", "", pmNormal, UseCaseStyle());  
          //wait (up to 30 seconds) for the 'restart the download' object to appear on page
          SearchWaitToExist("contentText", "restart the download.");

          //get current URL
          var currentURL = page.URL;

          //verify the end page URL contains 3001 
          results = aqString.Find(currentURL, "3001"); 
          if(results != -1)
          {Log.Message("User was redirected to correct page: contains 3001");}
          else{Log.Error("User was NOT redirected to correct page as the page does not contain 3001. URL of the page: " + currentURL);}
          
          //for all pages except Archived Product pages
          if(csvVariation != "Archived Product")
          {    
            //verify the productSetID is passed on:
            results = aqString.Find(currentURL, productSetID);
            if(results != -1)
            {Log.Message("ProductSetID was passed on in the 3001 URL");}
            else{Log.Error("ProductSetID was NOT passed on in the 3001 URL");}
          }
        
          //========================== End of Check download via Download button ====================
        
          //========================== Check download via restart the download link =================
          //search the 'restart the download.' link
          var restartDownload = findChildMethod("contentText", "restart the download.");
          if(restartDownload != null)
          {
            //click on the 'restart the download.' link
            restartDownload.Click();
          
            //check that a pop-up was opened that requires the user to Open, Save or Save As the file.
            //click on the Save button
            if(csvVariation == "Offsite Popup (Download)" && browserName == "iexplore")
            {
              SaveCloseIEDecisionPopUp();
            }

            //verify download pop-up / bar is triggered and correct file is being downloaded, without waiting for the new page to load
            VerifyDownloadWindow(extension, csvVariation);
          }
          else{Log.Error("No 'restart the download.' link was found on page.");}
          //========================== End of Check download via restart the download link ==========
        }
        
        //========================== Check download via float CTA =================================
        
        Log.Message("Use case: floating CTA", "", pmNormal, UseCaseStyle());  
        //go back to the previous URL
        Sys.Browser(browserName).ToUrl(Project.Variables.ServerName + csvURL);
        page.Wait();
        
        //wait 5 seconds after page was loaded to make sure that all the elements from the page have actually loaded
        delay(5000);
        
        //get current URL
        currentURL = page.URL;
        
        //verify the same 3000 page opened
        if(aqString.Find(currentURL, csvURL) != -1)
        {Log.Message("Correct URL was opened");}
        else{Log.Error("Incorrect URL was found after navigating to the previous page");}
        
        //create a loop for scrolling down the page.
        //after every scroll of the page, check if the float CTA appeared on screen
        for(i = 0; i < 6; i++)
        {
           //scroll down the page to trigger the float CTA
           page.MouseWheel(-5);
           //wait 2 seconds before starting to search for the float CTA. Float CTA may not appear immediately after finish scrolling the page
           delay(2000);
           
           //verify the existence of the float CTA bar:
          //find the float CTA bar and wait up to 2 seconds to become visible
          var floatBar = page.FindChild("ObjectIdentifier", "floating_button_dln_bar", 50, true);
          floatBar.WaitProperty("Visible", true, 2000);
          //if float bar exists and is visible on screen
          if(floatBar.Exists && floatBar.Visible)
          {
            Log.Message("Float CTA was found.");
            //find the Download Now / Visit Site button within the float CTA
            var ctaLeftContent = floatBar.FindChild("ObjectIdentifier", "floating_button_dln_bar_left_content", 10, true);
            if(ctaLeftContent.Exists && ctaLeftContent.Visible)
            {
              if (csvVariation != "Offsite Popup (Web Page, pop up)" && csvVariation != "Offsite Popup (Web Page, main window)"
                    && (csvVariation != "iOS Product") && (csvVariation != "Android Product") && (csvVariation != "Publisher Hosted"))
              {   
                var floatCTAButtonText = "Download Now";           
              }
              else
              {
                var floatCTAButtonText = "Visit Site";
              }
              //verify the contentText for object is 'Download Now'
              if(ctaLeftContent.contentText == floatCTAButtonText)
              {
                Log.Message("Float CTA '" + floatCTAButtonText + "' button was found");
              
                //Chrome browser automatically scrolls to the top of the page when trying to click the Download Now button from the float CTA
                //so, if the current browser is Chrome, click on the Download Now from the CTA using page coordinates
                //for all other browsers, use the simple Click method
                if(Project.Variables.CurrentBrowser == "chrome")
                {
                  // Calculating the coordinates of the center of the Download Now button from the float CTA
                  var x = page.ScreenLeft + ctaLeftContent.Left + ctaLeftContent.Width/2;
                  var y = ctaLeftContent.Top + ctaLeftContent.Height/2;
                  //hover over the content before clicking on it
                  page.HoverMouse(x, y);
                  //wait for the mouse to be moved to the location
                  delay(500);
                  //click on the Download Now button
                  page.Click(x, y);
                  //wait 3 seconds for the page to start loading
                  delay(3000);
                }
                else
                {
                  //click on the Download Now button
				          ctaLeftContent.HoverMouse();
                  ctaLeftContent.Click();
                  //wait 2 seconds for the pop-up to appear, then search for it
                  delay(2000);
                }
              }
              else{Log.Error("Found object does not contain '" + floatCTAButtonText + "' text");}
            }
            else{Log.Error("'" + floatCTAButtonText + "' button was not found in the float CTA");}
        
            // for Publisher Hosted pages
            if(csvVariation == "Publisher Hosted"  || csvVariation == "Offsite Popup (Download)" || csvVariation == "Offsite Popup (Web Page, pop up)"
                || (csvVariation == "iOS Product") || (csvVariation == "Android Product"))
            {
              //search for the whole modal
              var modalPopUp = page.FindChild("className", "modalPopup open", 2);
              if(modalPopUp.Exists)
              {
                //search for the 'Continue to Donwload' button within the modal
                var continueToDownloadButton = modalPopUp.FindChild("contentText", "Continue to Download", 5);
                if(continueToDownloadButton.Exists)
                {
                   //click the 'Continue to Download' button in the opened modal
                   continueToDownloadButton.Click();
                   //wait 3 seconds for the page to start loading
                   delay(3000);
                   page.Wait();
                }
                else{Log.Error("For Publisher Hosted pages, 'Continue to Download' button was not found.");}
              }
              else{Log.Error("'This download is served from an external site' modal did not appear on screen.");}
            }
            
            //check that a pop-up was opened that requires the user to Open, Save or Save As the file.
            //click on the Save button
            if(csvVariation == "Offsite Popup (Download)" && browserName == "iexplore")
            {
              SaveCloseIEDecisionPopUp();
            }
          
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
              Log.Message("Page starts to load after the Download Now link was clicked from the float CTA");
              //wait for page to load
              page.Wait();

              //verify download pop-up / bar is triggered and correct file is being downloaded
              VerifyDownloadWindow(extension, csvVariation);
            }
            break;
          }
          else
          {   
            //if after 3 iterations float CTA was not found, post a warning message to the log and reload the page
            if(i == 3)
            {
              Log.Warning("No float CTA after 3 scrolls down. Refreshing the page...");
              page.Keys("[F5]");
              page.Wait();
            }
                     
            //if last iteration, post error to log
            if(i == 5)
            {
              Log.Error("Float CTA bar was not found after scrolling down the page.");
            }
          }
        }     
        //========================== End of Check download via float CTA ==========================
        
        
        //========================== Check download via Direct Download Link (for DLM Product variation only) ========================================
        
        if(csvVariation == "DLM Product")
        {
          Log.Message("Use case: 'Direct Download Link'", "", pmNormal, UseCaseStyle());  
          //navigate to the test URL:
          Sys.Browser(browserName).ToUrl(Project.Variables.ServerName + csvURL);
          page.Wait();
          
          //find the "Direct Download Link" link with specific contentText and className
          
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
              Log.Message("Page starts to load after the Download Now link was clicked from the float CTA");
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
              
              //for all pages except Archived Product
              if(csvVariation != "Archived Product")
              {
                //verify the productSetID is passed on:
                results = aqString.Find(currentURL, productSetID);
                if(results != -1)
                {Log.Message("ProductSetID was passed on in the 3001 URL");}
                else{Log.Error("ProductSetID was NOT passed on in the 3001 URL");}
              }
            }
          }
          else
          {
            Log.Error("More than 1 object with following property name / value were found. Please use extra / different property name");
            Log.Error("Property name / value: " + PropArray[0] + " / " + ValuesArray[0]);
            Log.Error("Property name / value: " + PropArray[1] + " / " + ValuesArray[1]);
          }       
        }
        //========================== End of Check download via Direct Download Link (for DLM Products only) =================================
        
        //if the page is a 3001 / 3055 page, verify the DRE section
        //get current URL
        currentURL = page.URL;
        if((aqString.Find(currentURL, "3001") != -1) || (aqString.Find(currentURL, "3055") != -1))
        {
          Log.Message("Use case: DRE section for the 3001 / 3055 page", "", pmNormal, UseCaseStyle());  
          //check the DRE section
          DreSection();
        }
        
        //========================== Verify the DRE section on the 3000 page ================================================================
        
        Log.Message("Use case: DRE section for the 3000 page", "", pmNormal, UseCaseStyle());  
        //navigate to URL taken from the csv file
        NavigateToURLs(browserName, csvURL);
        page.Wait();
        
        DreSection();
        //========================== End of verification of the DRE section on the 3000 page ================================================
        
      }
    }
    //get next link from the spreadsheet
    link.Next();
  }
  //close the connection to the spreadsheet
  link.Disconnect();
}


