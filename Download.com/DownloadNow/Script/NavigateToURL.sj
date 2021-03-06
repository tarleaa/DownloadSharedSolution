//USEUNIT BetaCookie
//USEUNIT LoggingAttribute
//USEUNIT RunKillBrowsers

/// <summary>
/// Navigate to the specified page by opening a specified browser.
/// </summary>
/// <param name="browserName">
/// Specify the browser which will be launched (from 'Test Items' project page)
/// </param>
/// <param name="url">
/// Specify the URL to be opened
/// </param>
function NavigateToURLs(browserName, url)
{
    //open browser
    switch ( browserName )
    {
      case "iexplore":
        StartBrowser("iexplore");
        browser = Sys.Browser("iexplore");
        break;
    
      case "firefox":
        StartBrowser("firefox");
        browser = Sys.Browser("firefox");
        break;
              
      case "chrome":
        StartBrowser("chrome");
        browser = Sys.Browser("chrome");
        break;
        
      default:
        Log.Error("Entered browser name is not supported");
        break;
    }
    
    //if server name contains 'beta', set the cookie to grant access:
    if(aqString.Find(Project.Variables.ServerName, "beta") != -1)
    {
      //call the SetBetaCookie method from the 'BetaCookie' file
      SetBetaCookie();
    } 
    
    //navigate to URL
    browser.ToURL(Project.Variables.ServerName + url);
    var page = browser.Page(Project.Variables.ServerName + url);
    page.Wait();
    Aliases.BrowserProcess.Page.Keys("^0");
}