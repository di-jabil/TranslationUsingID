--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local csv = require "csv"

--[[
This function will switch the UI over the language specified by name in the function argument
It does this by opening a master language database (CSV file in this case) and looking for the 
matching language tag and then runs associating the corresponding language id to the variable
in Storyboard.

The CSV file uses the following 'schema'
id,language_name,language2_name, ...
<id number>,<utf8 text>,<utf8 text>
<id number>,<utf8 text>,<utf8 text>
... 

The <id number> field is assumed to correspond to a Storyboard variable on the 'translation_id' 
layer of the model.  The mapping function from language data base id to Storyboard variable is:
 translation_id.id_<id_number>
 
These are of course just conventions for this sample 
--]]
function LoadLanguage(language_name)
  local db = csv.open(gre.SCRIPT_ROOT.."/../translations/translation_db.csv")
  
  if(db == nil) then
    print("Can't access language data base")
    return
  end
  
  -- Read the database content.
  -- The first line of the database to matches our language_name to a column of text
  -- Every line afterwards will set variables
	local column = nil
  local data = {}
--[[  for fields in db:lines() do -- column numbers are keys
    for k,v in pairs(fields) do
      print(string.format("key: %s, value: %s", k, v))
    end
  end ]]
	
	for fields in db:lines() do
	 if(column == nil) then
	   column = FindColumnMatch(fields, language_name)
	   if(column == nil) then
	     print("Can't find language column for " .. language_name)
	     return
	   end
	 else
	   local id = fields[1]
	   local key = string.format("translation_id_layer.id_%d", id)
	   data[key] = fields[column] 
	 end
	end
	db:close()
	
	-- Apply the text changes to the engine
  gre.set_data(data)	  
  
  LoadAttributes(language_name)
end

--[[
  If you had additional attributes you needed to set (ie fonts) then you could keep 
  a separate, Storyboard specific, database to manage those changes
--]]
function LoadAttributes(language_name)
  local db = csv.open(gre.SCRIPT_ROOT.."/../translations/attribute_db.csv")
  
  if(db == nil) then
    print("Can't access attribute data base")
    return
  end
  
  -- Read the database content.
  -- The first line of the database to matches our language_name to a column of text
  -- Every line afterwards will set variables
  local column = nil
  local data = {}
  
  for fields in db:lines() do
   if(column == nil) then
     column = FindColumnMatch(fields, language_name)
     if(column == nil) then
       print("Can't find language column for " .. language_name)
       return
     end
   else
     local key = fields[1]
     data[key] = fields[column] 
   end
  end
  db:close()
  
  -- Apply the changes to the engine
  gre.set_data(data)    
end

function FindColumnMatch(fields, language) 
  for column,text in pairs(fields) do
    if(language == text) then
      return column
    end
  end
  return nil
end

--[[
This is just a callback that bounces its language parameter to the load function
--]]
function CBLoadLanguage(mapargs)
	local target_language = mapargs.language
	
	if(target_language == nil) then
    print("Missing language")
	end

	LoadLanguage(target_language)
end
