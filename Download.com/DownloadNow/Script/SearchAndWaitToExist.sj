//USEUNIT DRESection
//USEUNIT LoggingAttribute
//function which searches for an object by it's proprName and proprValue
//and waits (up to 60 seconds) for the object to appear on screen
//parentObject - the object from which the search starts from
//name - name of the property to search for
//value - value of the property to search for
//depth (optional) - how deep on the Object Tree to look for
//refreshTree (optional parameter) - refreshes the object tree

function SearchWaitToExist(name, value, depth, refreshTree)
{
    //get the current browser
    var browser = Sys.Browser(Project.Variables.CurrentBrowser);
    
    //set the default depth value, in case it's not specified
    if(depth == null)
    {
      depth = 50;
    }
    //set a reference time for 60 seconds into the future
    var endTime = aqDateTime.AddSeconds(aqDateTime.Time(), 60);
    
    //while the 60 seconds haven't expired, search for the objeect
    while (endTime > aqDateTime.Time())
    {
      //find the object
      var object = browser.FindChild(name, value, depth);
      //if object exist and is visible in scree
      if(object.Exists && object.Visible)
      {
        return object;
      }
      else
      {       
        //if refreshTree was passed to the method, refresh the tree.
        if(refreshTree != null)
        {
          Sys.Refresh();
        }
        //if on last iteration, post error
        if(endTime < aqDateTime.Time())
        {
          Log.Error("Object with property name '" + name + "' and property value '" + value + "' was not found, after searching for 30 seconds.");
          return object;
        }
      }
    }
}
