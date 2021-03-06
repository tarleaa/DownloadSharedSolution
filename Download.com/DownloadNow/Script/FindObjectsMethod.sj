//USEUNIT LoggingAttribute
//method that searches for the object on the whole page
//parameters: 
//name -> name of the property to search
//proprValue -> the value of the name property
//report (optional) -> returns error, warning of no message when object not found
//depth (optional) -> the depth in which the object will be searched in


//searches the entire page object and all it's children for a given object
function findChildMethod(name, proprValue, report, depth)
{
  
    //get the current page
    var browser = Sys.Browser(Project.Variables.CurrentBrowser);
    var page = browser.Page("*");
  
    //if depth parameter was not specified, default it to 2000;
    if(depth == null)
    { 
      depth = 2000; 
    }
  
    //search the object using the specified parameters
    var objectSearch = page.FindChild(name, proprValue, depth);
    if(objectSearch.Exists) //if object exists
    {
      Log.Message("Object with property value '" + proprValue +  "' was found");
      return objectSearch; //return the object to the caller function
    }
    else
    {
      if(report == null) // if report parameter was not specified, return an 'Error' that the object was not found
      {
        Log.Error("Object with property value '" + proprValue +  "' was NOT found");
        return null;
      }
    
      if(report == 'warning') //if report paramter was specified as 'warning', return a 'Warning' that the object was not found
      {
        Log.Warning("Object with property value '" + proprValue +  "' was NOT found");
        return null;
      }
    
      if(report == 'noNotification') //if report paramter was specified as 'nonotification', don't return any message regarding the object.
      {
        return null;
      }
  }
}