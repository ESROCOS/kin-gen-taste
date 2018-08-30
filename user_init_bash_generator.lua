local function gen_user_init_bash(target)
  local ok, res = utils.preproc([[
echo -e "\033[0;36m====== RM-TOOL:: generating support library  ======\e[0;39m"
cd $(target)/rmtool
make
cd ..
echo -e "\e[36m====== RM-TOOL:: support library generated in $(target)/rmtool ======\e[39m"
]], { table=table,
  target=target
})  
  if not ok then error(res) end
  return res
end

local M = {}
M.gen_user_init_bash = gen_user_init_bash
return M
