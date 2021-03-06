function CorrectRGBComponent(component)
{
  component = aqConvert.VarToInt(component);
  if (component < 0)
  {component = 0;}
  else
  {
    if (component > 255)
    {component = 255;}
  }
  return component;
}

function RGB(r, g, b)
{
  r = CorrectRGBComponent(r);
  g = CorrectRGBComponent(g);
  b = CorrectRGBComponent(b);
  return r | (g << 8) | (b << 16);
}

function UseCaseStyle()
{
  var attribute;
  attribute = Log.CreateNewAttributes();
  attribute.Bold = true;
  //dark blue
  attribute.FontColor = RGB(17, 17, 235);
  //yellow
  attribute.BackColor = RGB(239, 255, 0);
  
  return attribute;
}

function IterationStyle()
{
  var attribute;
  attribute = Log.CreateNewAttributes();
  attribute.Bold = true;
  //white
  attribute.FontColor = RGB(0, 0, 0);
  //light blue
  attribute.BackColor = RGB(204, 229, 255);
  
  return attribute;
}

