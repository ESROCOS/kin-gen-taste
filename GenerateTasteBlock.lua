#!/usr/bin/env lua

utils = require('utils')
local ansicolors = require('ansicolors')
local vlog  = require('vlog')

helpers = require('helpers')
common = require('common')
makefile_generator = require('makefile_generator')
gen_linkings = require('linkings_generator')
gen_uc_wrapper = require('usercode_wrapper_generator')
gen_uc = require('usercode_generator')
gen_user_init_bash = require('user_init_bash_generator')
config_reader = require('read_config')






---
-- Program enters here
-----------------------------------
local opttab=utils.proc_args(arg)

if opttab['-h'] then usage(); os.exit(1) end

--[[ List of the information needed
     * outdir
     * name of the function block name
     * interface type (s[poradic], [p]rotected or [u]nprotected)
     * list of solvers implemented in generated library
--]] 

config = config_reader.read_config("config.yml")



outdir = config.output_directory
taste_fnc_block = config.block_name
interface = string.sub(config.interface_type,1,1)
sporadic = interface == 's'
solver_filename = config.solver_filename
solver_functions = config.solver_functions
model_constants = config.model_constants

local metadata = config_reader.read_config("metadata.yml")


-- Create glue-code folder
os.execute('mkdir -p '..outdir..'/'..taste_fnc_block)
os.execute('mkdir -p '..outdir..'/'..taste_fnc_block..'/rmtool')

-- create taste-mockup.h

-- create user-code
--- Header file
content = gen_uc.gen_uc_header_file(taste_fnc_block, sporadic, solver_functions, metadata)
helpers.write_out_file(outdir..'/'..taste_fnc_block..'/', taste_fnc_block..'.h', content)

--- Source file
content = gen_uc.gen_uc_source_file(taste_fnc_block, sporadic, solver_functions, metadata)
helpers.write_out_file(outdir..'/'..taste_fnc_block ..'/', taste_fnc_block..'.cc', content)

-- Create sources wrappers in rmtool
--content = gen_uc_wrapper.gen_uc_wrapper_header_impl(taste_fnc_block, solver_functions, solver_filename, metadata)
--helpers.write_out_file(outdir..'/'..taste_fnc_block..'/rmtool/', taste_fnc_block..'-usercode-impl.h', content)

content = gen_uc_wrapper.gen_uc_wrapper_header(taste_fnc_block, solver_functions, metadata)
helpers.write_out_file(outdir..'/'..taste_fnc_block..'/rmtool/', taste_fnc_block..'-bridge.h', content)

content = gen_uc_wrapper.gen_uc_wrapper_source(taste_fnc_block, solver_functions, solver_filename, model_constants, metadata)
helpers.write_out_file(outdir..'/'..taste_fnc_block..'/rmtool/', taste_fnc_block..'-bridge.cc', content)

-- Then copying the header...
os.execute('cp '..outdir..'/'..taste_fnc_block..'/rmtool/'..taste_fnc_block..'-bridge.h '..outdir..'/'..taste_fnc_block..'/')

-- create makefile
content = makefile_generator.gen_rmtool_makefile(taste_fnc_block)
helpers.write_out_file(outdir..'/'..taste_fnc_block..'/rmtool/', 'Makefile', content)
-- create testing

-- generate bash script
content = gen_user_init_bash.gen_user_init_bash(taste_fnc_block)
helpers.write_out_file(outdir..'/', 'user_init_post.sh', content)

-- generate linkings.yml
local solver_library_location = config.solver_library_location
if solver_library_location == '' then
    solver_library_location = outdir..'/'..taste_fnc_block.. '/rmtool/lib'..config.solver_filename..'.a'
end

gen_linkings(outdir,
  {outdir..'/'..taste_fnc_block..'/rmtool/libkinsolverbridge.a',
   solver_library_location
  }
)


  
