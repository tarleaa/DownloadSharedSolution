function GeneralEvents_OnStopTest(Sender)
{
  if (Log.ErrCount >0 && Project.Variables.sendEmailOnError == 1)
    {
      PackResultsEmail()
    }
}

function sendreport(mFrom, mTo, mSubject, mBody, mAttach)
{
  var i, schema, mConfig, mMessage;

  try
  {
    schema = "http://schemas.microsoft.com/cdo/configuration/";
    mConfig = Sys.OleObject("CDO.Configuration");
    mConfig.Fields.Item(schema + "sendusing") = 2; // cdoSendUsingPort
    mConfig.Fields.Item(schema + "smtpserver") = "smtp.gmail.com"; // SMTP server
    mConfig.Fields.Item(schema + "smtpserverport") = 465; // Port number
    mConfig.Fields.Item(schema + "smtpauthenticate") = 1; // Authentication mechanism
        mConfig.Fields.Item(schema + "smtpusessl") = true;

    mConfig.Fields.Item(schema + "sendusername") = "tkmseie@gmail.com"; // User name (if needed)
    mConfig.Fields.Item(schema + "sendpassword") = "thilakkumar123"; // User password (if needed)
    mConfig.Fields.Update();

    mMessage = Sys.OleObject("CDO.Message");
    mMessage.Configuration = mConfig;
    mMessage.From = mFrom;
    mMessage.To = mTo;
    mMessage.Subject = mSubject;
    mMessage.HTMLBody = mBody;

    aqString.ListSeparator = ",";
    for(i = 0; i < aqString.GetListLength(mAttach); i++)
      mMessage.AddAttachment(aqString.GetListItem(mAttach, i));
    mMessage.Send();
  }
  catch (exception)
  {
    Log.Error("E-mail cannot be sent", exception.description);
    return false;
  }
  Log.Message("Message to <" + mTo + "> was successfully sent");
  return true;
}

function PackResultsEmail()
{
  var ArchivePath;
  // Specifies the path to the resulting archive
  ArchivePath = Project.ConfigPath+"Reports\\" + Project.TestItems.Current.Name;
  subjectVal = "Testcomplete Report for the Test Item: " + Project.TestItems.Current.Name
  messageBody = "Hi, Attached the Testcomplete report for the Test Item '"+  Project.TestItems.Current.Name+". Please unzip & open with testcomplete"
  // Compresses the current test results
  if (slPacker.PackCurrentTest(ArchivePath))
    Log.Message("The test results have been compressed successfully");

  if( sendreport("tkmseie@gmail.com", Project.Variables.toEmailAddress, subjectVal, 
             messageBody,ArchivePath+".zip") )
             Log.Message("Message was sent")
    // Message was sent
  else
  {
    Log.Error("Not sent")
    // Message was not sent
    }
}

