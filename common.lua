function gen_filecomment(config)
  local license = config.license or 'unknown'
  local author  = config.author or 'unknown'
  local ok, res = utils.preproc([[
/********************************************************** 
   This file was generated automatically: DO NOT MODIFY

$(what)
  
  Delivered by: KU Leuven, Belgium, 2018
  Generated on: $(datestr) (UTC)
  Generated by: $(author)
  License:      $(license)

**********************************************************/

]], {table=table,
--     datestr  = os.date("!%c"),
     datestr  = 'Fri Apr  6 15:44:44 2018',
     license  = license,
     author   = author,
     what     = config.what})

    if not ok then error(res) end
    return res
end



function gen_signature_solver_wrap(config)
  local ok, res = utils.preproc([[

int solver_fk_compute(const asn1SccJoints* in1,
                      asn1SccPose* out1);
]],{ table=table})
    if not ok then error(res) end
    return res
end





function gen_include_solverheaders(config)
  local ok, res = utils.preproc([[

/* API solvers declaration used in this usercode */
@for i,v in pairs(solverlist) do
#include "$(v).h"
@end

]],{table=table, pairs=pairs,
  solverlist = config.solverlist
})
    if not ok then error(res) end
    return res
end



function usage()
  print( [[
gen-taste-block: Generates glue-code to integrate the ESROCOS Robot Modelling
  tool within the TASTE framework

Usage: gen-signature [OPTIONS]
    -fb         <fnc-block>      name of the Taste function block component
    --outdir    <folder>         all files generated in <folder> (optional),
                                 outdir override options [-m, -o]
    -h        prints this help
]])
end



local M = {}
M.usage = usage
M.gen_filecomment = gen_filecomment
return M