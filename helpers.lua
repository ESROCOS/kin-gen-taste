function write_out_file(path, filename, res)
    local fd = io.open(path..filename,'w')
    fd:write(res)
    fd:close()
end


--- helper, print a bright red errormsg
function errmsg(...)
   print(ansicolors.bright(ansicolors.red(table.concat({...}, ' '))))
end

--- helper, print a yellow warning msg
function warnmsg(...)
   print(ansicolors.yellow(table.concat({...}, ' ')))
end

--- helper, print a green sucess msg
function succmsg(...)
   print(ansicolors.green(table.concat({...}, ' ')))
end


local M = {}
M.write_out = write_out
M.write_out_file = write_out_file
M.errmsg = errmsg
M.warnmsg = warnmsg
M.succmsg = succmsg
return M