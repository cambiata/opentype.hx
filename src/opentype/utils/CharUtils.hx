package opentype.utils;

function isWhiteSpace(c:String):Bool 	
   return c != null ? ~/\s/.match(c): false;   

function isLatinChar(c:String):Bool 
   return c != null ? ~/[A-z]/.match(c): false;
   
function isTashkeelArabicChar(c:String):Bool 
   return c != null ? ~/[\u0600-\u0605\u060C-\u060E\u0610-\u061B\u061E\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED]/.match(c): false;


 function isIsolatedArabicChar(c:String):Bool 
   return c != null ? ~/[\u0630\u0690\u0621\u0631\u0661\u0671\u0622\u0632\u0672\u0692\u06C2\u0623\u0673\u0693\u06C3\u0624\u0694\u06C4\u0625\u0675\u0695\u06C5\u06E5\u0676\u0696\u06C6\u0627\u0677\u0697\u06C7\u0648\u0688\u0698\u06C8\u0689\u0699\u06C9\u068A\u06CA\u066B\u068B\u06CB\u068C\u068D\u06CD\u06FD\u068E\u06EE\u06FE\u062F\u068F\u06CF\u06EF]/.match(c): false;


 function isArabicChar(c:String):Bool 
   return c != null ? ~/[\u0600-\u065F\u066A-\u06D2\u06FA-\u06FF]/.match(c): false;

