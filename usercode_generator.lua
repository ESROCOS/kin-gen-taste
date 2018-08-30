
local metadata_interpreter = require('metadata_interpreter')

local function gen_uc_header_decl_open(config)
  local ok, res = utils.preproc([[
#ifndef __USER_CODE_H_$(fnc_block)__
#define __USER_CODE_H_$(fnc_block)__

#include "C_ASN1_Types.h"
    
#ifdef __cplusplus
extern "C" {
#endif

]], {table=table, fnc_block = config.fnc_block})
  if not ok then error(res) end
  return res
end



local function gen_uc_header_decl_close(config)
  local ok, res = utils.preproc([[

#ifdef __cplusplus
}
#endif

#endif
]], {table=table})
  if not ok then error(res) end
  return res
end



local function gen_uc_header_includes(config)
  local ok, res = utils.preproc([[
    // All includes files
]], {table=table})
  if not ok then error(res) end
  return res
end



local function gen_uc_header_query_holders(config)
  local ok, res = utils.preproc([[
// All query holders
struct query_holder_FNC {
  joint_state input;
  pose_t      output;
};
]], {table=table})
  if not ok then error(res) end
  return res
end



-- generation hard-coded
local function gen_uc_header_prepare_inputs(config)
  local ok, res = utils.preproc([[
// All prepare_input_XXX
bool prepare_input_FNC(const asn1SccJoints& arg1, joint_state& arg2);
]], {table=table})
  if not ok then error(res) end
  return res
end



function gen_uc_header_prepare_outputs(config)
  local ok, res = utils.preproc([[
// All prepare_output_XXX
bool prepare_output_FNC(const pose_t& arg1, asn1SccPose& arg2);
]], {table=table})
  if not ok then error(res) end
  return res
end



local function gen_uc_header_solvers(config)
  local ok, res = utils.preproc([[
// All query solvers, what I want to wrap
extern void FNC(const mc_config& mc, const joint_state&, pose_t& frame);
]], {table=table})
  if not ok then error(res) end
  return res
end



local function gen_uc_source_includes(config)
  local ok, res = utils.preproc([[

#include "$(fnc_block).h"

/* This should be placed in the source folder of the target functionblock */
#include "$(fnc_block)-bridge.h"

]],{table=table,
  fnc_block = config.fnc_block
})
  if not ok then error(res) end
  return res
end



local function gen_uc_source_startup(config)
  local ok, res = utils.preproc([[

void $(fnc_block)_startup()
{
  load_model_constants();
}

]],{table=table,
  fnc_block=config.fnc_block
})
  if not ok then error(res) end
  return res
end


local function gen_uc_header_startup(config)
  local ok, res = utils.preproc([[

void $(fnc_block)_startup();

]],{table=table,
  fnc_block=config.fnc_block
})
  if not ok then error(res) end
  return res
end

local function gen_uc_header_sporadic(function_name, metadata)
  local decl_input, call_input = metadata_interpreter.generate_inputs(metadata, true)
  local decl_output, init_output, call_output, para_output = metadata_interpreter.generate_outputs(metadata, true)

  local ok, res = utils.preproc([[

void $(function_name)_PI_req($(decl_input));

extern void $(function_name)_RI_RI1($(para_output));

]],{table=table,
  function_name=function_name,
    decl_input = decl_input,
    call_input = call_input,
    decl_output = decl_output,
    call_output = call_output,
    init_output = init_output,
    para_output = para_output
})
  if not ok then error(res) end
  return res
end


local function gen_uc_header_nonsporadic(function_name, metadata)
  local decl_input, call_input = metadata_interpreter.generate_inputs(metadata, true)
  local decl_output, init_output, call_output, para_output = metadata_interpreter.generate_outputs(metadata, true)
  local ok, res = utils.preproc([[

void $(function_name)_PI_req($(decl_input), $(para_output));

]],{table=table,
  function_name = function_name,
    decl_input = decl_input,
    call_input = call_input,
    decl_output = decl_output,
    call_output = call_output,
    init_output = init_output,
    para_output = para_output
})
  if not ok then error(res) end
  return res
end



local function gen_uc_source_solvercall_sporadic(function_name, metadata)
  local decl_input, call_input = metadata_interpreter.generate_inputs(metadata, false)
  local decl_output, init_output, call_output = metadata_interpreter.generate_outputs(metadata, false)
  local ok, res = utils.preproc([[

void $(function_name)_PI_req($(decl_input))
{
  $(decl_output)
  $(init_output)
  solver_$(function_name)($(call_input),$(call_output));
  $(function_name)_RI_RI1($(call_output));
}

]],{table=table,
  function_name   = function_name,
  solver_name = function_name,
    decl_input = decl_input,
    call_input = call_input,
    decl_output = decl_output,
    call_output = call_output,
    init_output = init_output
})
  if not ok then error(res) end
  return res
end


local function gen_uc_source_solvercall_nonsporadic(function_name, metadata)
  local decl_input, call_input = metadata_interpreter.generate_inputs(metadata, true)
  local decl_output, init_output, call_output, para_output = metadata_interpreter.generate_outputs(metadata, true)
  local ok, res = utils.preproc([[

void $(function_name)_PI_req($(decl_input), $(para_output))
{
  solver_$(function_name)($(call_input),$(call_output));
}

]],{table=table,
  function_name   = function_name,
    decl_input = decl_input,
    call_input = call_input,
    decl_output = decl_output,
    call_output = call_output,
    init_output = init_output,
    para_output = para_output
})
  if not ok then error(res) end
  return res
end



local function gen_uc_header_file(block_name, sporadic, function_list, metadata)
  local c = {
    author  = 'Enea Scioni',
    license = 'BSD2-clause',
    fnc_block = block_name,
    functions = function_list,
    what    = [[
    This header file is part of the user-code for the
    Taste function block component generated
    with the ESROCOS robot modeling tool.
]]
  }
  local filecomment_content = gen_filecomment(c)
  local header_open_content = gen_uc_header_decl_open(c)
  local header_startup = gen_uc_header_startup(c)
  local header_declarations = ''
  if sporadic then
    for i,fun in pairs(function_list) do
      local declaration = gen_uc_header_sporadic(fun.function_name, metadata[fun.function_name])
      header_declarations = header_declarations .. declaration
    end
  else
    for i,fun in pairs(function_list) do
      local declaration = gen_uc_header_nonsporadic(fun.function_name, metadata[fun.function_name])
      header_declarations = header_declarations .. declaration
    end
  end
  local header_close_content = gen_uc_header_decl_close(c)
  return filecomment_content..header_open_content..header_startup..header_declarations..header_close_content
end



local function gen_uc_source_file(fn, sporadic, function_list, metadata)
  local c = {
    author  = 'Enea Scioni',
    license = 'BSD2-clause',
    what    = [[
    This source file is part of the user-code that
    implements a Taste function block component generated
    with the ESROCOS robot modeling tool.
]]
  }
  local filecomment_content = gen_filecomment(c)
  c = {
    fnc_block=fn
  }
  local includes_content = gen_uc_source_includes(c)
  local source_startup_content = gen_uc_source_startup(c)
  local solvercall_content = ''
  if sporadic then
    for i,fun in pairs(function_list) do
      local content = gen_uc_source_solvercall_sporadic(fun.function_name, metadata[fun.function_name])
      solvercall_content = solvercall_content..content
    end
  else
    for i,fun in pairs(function_list) do
      local content = gen_uc_source_solvercall_nonsporadic(fun.function_name, metadata[fun.function_name])
      solvercall_content = solvercall_content..content
    end
  end
  return filecomment_content..includes_content..source_startup_content..solvercall_content
end

local M = {}
M.gen_uc_header_file = gen_uc_header_file
M.gen_uc_source_file = gen_uc_source_file
return M
