local function gen_linkings(path,liblist)
  local yaml = require('yaml')
  
  -- The impl. of file check is not safe
  -- since it opens the file. FIXME
  local file_check = function(filename)
    local file_found=io.open(filename, "r")
    if not file_found then return false end
      file_found:close()
    return true
  end
  
  local data = {}
  local lfile = outdir..'/linkings.yml'
  if not file_check(lfile) then
    os.execute('touch '..lfile)
  else
    local fd = io.open(lfile,'r')
    data=yaml.load(fd:read("*all"))
    fd:close()
  end

  if not data then
    errmsg("linkings.yml is not a valid yaml (.yml) file,  or empty")
    return
  end
  
  if not data.libs then
    data.libs = {}
  end
  
  for i,v in pairs(liblist) do
    local exists = false
    for k,val in pairs(data.libs) do
      if val == v then exists = true; break; end
    end 
    if not exists then data.libs[#data.libs+1] = v end
  end
  
  local fd = io.open(lfile,'w')
  fd:write(yaml.dump(data))
  fd:close()
end


return gen_linkings