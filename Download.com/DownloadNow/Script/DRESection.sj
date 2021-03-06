//USEUNIT LoggingAttribute
//USEUNIT PageStatus

function DreSection()
{
    //get the browser and current page
    var browser = Sys.Browser(Project.Variables.CurrentBrowser);
    var page = browser.Page("*");
    page.Wait();
    //delay(2000);
    var currentURL = page.URL;
    
    //find the DRE section object that includes the 'More Products to Consider' object
    var panelDlmRedirect = Aliases.BrowserProcess.Page.RbSkinObject.FindChild("idStr", "content-body*", 3)
    var dreSection = panelDlmRedirect.FindAllChildren("className", "dre", 3).toArray();
    //if only one DRE section was found
    if(dreSection.length == 1)
    {    
      //verify the 'More Products to Consider' object is within the DRE section
      var moreProductsText = dreSection[0].FindChild("contentText", "More Products to Consider",2);
      if(moreProductsText.Exists)
      {Log.Message("'More Products to Consider' header was found in the DRE section");}
      else{Log.Error("The 'More Products to Consider' header was NOT found in the DRE section");}  
      
      //scroll to bring the DRE section into view
      dreSection[0].scrollIntoView(true);
    }
    else
    { 
      //if no or more than one DRE section was found on page
      if(dreSection.length == 0)
      {Log.Error("No DRE section was found on the current page. Stopping current iteration...");
       Runner.Stop(true);}
      else
      {Log.Error(dreSection.length + "DRE sections were found on page. Only 1 section should be present. Please investigate");}
    }
    
    //get list of visible products from DRE section (using xPath)
    var panelAdSection = panelDlmRedirect.FindChild("idStr", "omDreImpression", 3).FindChild("className","viewport",3)
    if (panelAdSection.Exists)
        {
            var productsListXPathFind = panelAdSection.EvaluateXPath("//li[contains(@class, 'column slide selected')]/.//div[@class='thumb-description']");
   
           //Log.Message(panelAdSection.FullName)
           //if element(s) were found
           if(productsListXPathFind != null)
           {
                //convert the array that contains the DRE section products to JScript
                var dreProductList = new VBArray(productsListXPathFind).toArray();
           } 
           else
           {
                //post error to log and stop current iteration
                Log.Error("No products were found in the DRE section. Stopping current iteration...");
                Runner.Stop(true);
           }
        }
        
    //verify the grid has the correct number of columns
    //for 3000, 3001 and 3055 pages: 2 x 2 + sponsored product
    //for 3012 and 3016 pages: 2 x 3 (without the sponsored product)
    
    //get the sponsored product from the DRE section (using xPath)
    var sponsoredProductXPath = panelAdSection.EvaluateXPath("//li[contains(@class, 'column slide selected')]/.//div[contains(@class, 'slot pos_1')]");
    
    //for sponsored product not found, create an empty array
    //for found sponsored product: convert to Jscript array
    // var sponsoredProduct =panelAdSection.FindAllChildren("className","slot pos_*",4).toArray();
    if(sponsoredProductXPath == null)
    //if(sponsoredProduct.length == 0)
    {
    var sponsoredProduct = new Array();
    }
    else{
    var sponsoredProduct = new VBArray(sponsoredProductXPath).toArray();
    Log.Message(sponsoredProduct[0].innerText)
    }
    
    //for 3000 page:
    if(aqString.Find(currentURL, "3000") != -1)
    {
      //check the sponsored product is displayed
      if(sponsoredProduct.length == 1)
      {Log.Message("Sponsored product is displayed in the DRE section");}
      else{Log.Error(sponsoredProduct.length + " numbers of Sponsored products sections were found. Expected for 3000 page type: 1");}
        
      //check the number of products displayed
      if(dreProductList.length == 4)
      {Log.Message("For 3000 page type, 4 products are displayed in DRE section");}
      else{Log.Error("For 3000 page, " + dreProductList.length + " products are displayed in DRE section instead of 4");}
    }
      
    //for 3001 page:
    if(aqString.Find(currentURL, "3001") != -1)
    {
      //check the sponsored product is displayed
      if(sponsoredProduct.length == 1)
      {Log.Message("Sponsored product is displayed in the DRE section");}
      else{Log.Error(sponsoredProduct.length + " numbers of sponsored products sections were found. Expected for 3001 page type: 1");}
        
      //check the number of products displayed
      if(dreProductList.length == 4)
      {Log.Message("For 3001 page type, 4 products are displayed in DRE section");}
      else{Log.Error("For 3001 page, " + dreProductList.length + " products are displayed in DRE section instead of 4");}
    }
      
    //for 3055 page:
    if(aqString.Find(currentURL, "3055") != -1)
    {
      //check the sponsored product is displayed
      if(sponsoredProduct.length == 1)
      {Log.Message("Sponsored product is displayed in the DRE section");}
      else{Log.Error(sponsoredProduct.length + " numbers of ponsored products sections were found. Expected for 3055 page type: 1");}
        
      //check the number of products displayed
      if(dreProductList.length == 4)
      {Log.Message("For 3055 page type, 4 products are displayed in DRE section");}
      else{Log.Error("For 3055 page, " + dreProductList.length + " products are displayed in DRE section instead of 4");}
    }
      
    //for 3012 page:
    if(aqString.Find(currentURL, "3012") != -1)
    {
      //check the sponsored product is NOT displayed
      if(sponsoredProduct.length == 1)
      {Log.Error("Sponsored product is displayed in the DRE section");}
      else{Log.Message(sponsoredProduct.length + " numbers of ponsored products sections were found. Expected for 3012 page type: 0");}
        
      //check the number of products displayed
      if(dreProductList.length == 6)
      {Log.Message("For 3012 page type, 6 products are displayed in DRE section");}
      else{Log.Error("For 3012 page, " + dreProductList.length + " products are displayed in DRE section instead of 6");}
    }
      
    //for 3016 page:
    if(aqString.Find(currentURL, "3016") != -1)
    {
      //check the sponsored product is NOT displayed
      if(sponsoredProduct.length == 1)
      {Log.Error("Sponsored product is displayed in the DRE section");}
      else{Log.Message(sponsoredProduct.length + " numbers of ponsored products sections were found. Expected for 3016 page type: 0");}
        
      //check the number of products displayed
      if(dreProductList.length == 6)
      {Log.Message("For 3016 page type, 6 products are displayed in DRE section");}
      else{Log.Error("For 3016 page, " + dreProductList.length + " products are displayed in DRE section instead of 6");}
    } 
      
    //get list of button values (Download or Visit Site) that are visible within the DRE section (using xPath)
    var downloadButtonXPath = panelAdSection.EvaluateXPath("//li[contains(@class, 'column slide selected')]/.//span[contains(@class, 'dln-cta')]");
    if(downloadButtonXPath != null)
    {
      //convert the array to JScript
      var actionButtons = (new VBArray(downloadButtonXPath)).toArray();
    }
    else
    {
      //post error to log and stop current iteration
      Log.Error("No download buttons were found in the DRE section. Stopping current iteration...");
      Runner.Stop(true);
    }
    
    for(i = 0; i < actionButtons.length; i++)
    {
      //if there is a product with the Visit Site button within the DRE
      if(actionButtons[i].className == "dln-cta visit-now")
      //if(actionButtons[i].innerText == "Visit Site")
      {
        Log.Message("Clicking a 'Visit Site' button within the DRE section");
        
        ButObject =  actionButtons[i];
        Sys.Desktop.MouseDown(1,ButObject.ScreenLeft,ButObject.ScreenTop);
        Sys.Desktop.MouseUp(1,ButObject.ScreenLeft,ButObject.ScreenTop);
        //click the Visit Site button -> page should open in new tab with a 3rd party site
        delay(5000);
        
        //verify if a 'Continue to Download' pop-up is opened in an overlay
        var externalSitePopup = Aliases.BrowserProcess.Page.WaitAliasChild("ExternalSitePopup",3000)
        if(externalSitePopup.Exists)
        {
           var continueToDownload = externalSitePopup.WaitAliasChild("ContinueToDownloadButton",100)
           if(continueToDownload.Exists)
           {continueToDownload.Click();}
           else{Log.Error("Continue to download button is not displayed in DRE section");}
        }
        
        page.Wait();
        Sys.Refresh()  
        //search all level 1 pages from the IE process that contain "http://" string in the URL property and store them into array
        var pagesList = browser.FindAllChildren("URL", "http*://*", 1).toArray();
          
        //loop through the array
        for(var i = 0; i < pagesList.length; i++)
        {
          //wait for the page to load
          page = browser.Page(pagesList[i].URL);
          page.Wait();
              
          //for pages that don't contain in their URL the server being tested
          if(aqString.Find(pagesList[i].URL, Project.Variables.ServerName) == -1)
          {
            //verify page status is 200 / 302
            VerifyWebObject(pagesList[i].URL)
              
            //only if a 3rd party site was opened in a new tab.
            if(pagesList.length > 1)
            {  
      				//for IE8, click Yes on the Security Warning message that might appear
                if(Project.Variables.CurrentBrowser == "iexplore")
                {
                 if(Project.Variables.IEVersion == 8)
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
                }
              //close the tab
              pagesList[i].Close();
            }
          }
          else
          {
          
           pagesList[i].Wait()
            //if page contains the server being tested
            //get current URL
            var currentURL = page.URL;
           // page.Wait();
            
            //verify the end page URL contains 3055 
            results = aqString.Find(currentURL, "3055"); 
            if(results != -1)
            {
              Log.Message("User was redirected to correct page: contains 3055");
              Log.Picture(Sys.Desktop.Picture(), "Showing a 3055 page");
            }
            else{Log.Error("User was NOT redirected to correct page as the page does not contain 3055. URL of the page: " + currentURL);}
          }
        }
        break;
      }
        
      //if all products from the lists have been checked and none of them has a Visit Site button
      if(i == actionButtons.length -1)
      {
        ButObject = actionButtons[0]
        Log.Message("Clicking a 'Download' button within the DRE section");
        //click the last Download button (counting is actually done backwards into the DOM -> index 0 is actually the last product
        //and index 3 is actually the first product)
       
          //Object.Click()
          Sys.Desktop.MouseDown(1,ButObject.ScreenLeft,ButObject.ScreenTop)
           Sys.Desktop.MouseUp(1,ButObject.ScreenLeft,ButObject.ScreenTop)
          page.Wait();
       delay(5000);
 
        
        //get current URL
        currentURL = page.URL;
        //if URL contains 3001 - user was redirected to a 3001 page
        if(aqString.Find(currentURL, "3001") != -1)
        {Log.Message("User was correctly redirected to a 3001 page");}
        else
        {
          Log.Error("User was not redirected to a 3001 page");
          Log.Error("User was redirected to the following non-3001 URL: " + currentURL);
        }
      }
    }  
}
