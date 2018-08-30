local ilk_keywords = require('keywords')
local asn1_types = require('asn1_types')
local constants = require('constants')


local function generate_inputs(metadata)
    local result_decl = ''
    local result_call = ''
    if metadata.ops.type == ilk_keywords.solver_type.forward then
        result_decl = 'const '.. asn1_types.joint_state ..' *IN_joints'
        result_call = 'IN_joints'
    elseif metadata.ops.type == ilk_keywords.solver_type.inverse then
        if metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.position then
            result_decl = 'const '.. asn1_types.vector_3d ..' *IN_position, const '.. asn1_types.rot_m_t ..'*IN_orientation, ' .. asn1_types.joint_state ..'*IN_guess'
            result_call = 'IN_position, IN_orientation, IN_guess'
        elseif metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.velocity then
            result_decl = 'const '.. asn1_types.joint_state.. ' *IN_q, const '.. asn1_types.vector_3d ..' *IN_vector'
            result_call = 'IN_q, IN_vector'
        end
    end
    return result_decl, result_call
end



local function generate_outputs(metadata, external)
    local result_decl = ''
    local result_call = ''
    local result_init = ''
    local result_para = ''
    local para_prefix = ''
    local external = external or false
    if external then
        para_prefix = '*'
    end
    if metadata.type == ilk_keywords.solver_type.forward then
        local counter = 0
        for i,v in pairs(metadata.ops.outputs) do
            if v.otype == 'pose' then
                counter = counter + 1
                result_decl = result_decl.. asn1_types.pose ..' outval_'..counter..'; '
                result_para = result_para.. asn1_types.pose ..' '..para_prefix..'outval_'..counter..','
                result_init = result_init.. asn1_types.init.pose ..'(outval_'..counter..'); '
                result_call = result_call..'outval_'..counter..','
            end
        end
        result_para = result_para:sub(1, -2)
        result_call = result_call:sub(1, -2)
    elseif metadata.type == ilk_keywords.solver_type.inverse then
        if metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.position then
            result_decl = asn1_types.joint_state ..' OUT_q_ik;'
            result_para = asn1_types.joint_state ..' *OUT_q_ik'
            result_init = asn1_types.init.joint_state .. '(OUT_q_ik);'
            result_call = 'OUT_q_ik'
        elseif metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.velocity then
            result_decl = asn1_types.joint_state.. ' OUT_qd_ik;'
            result_para = asn1_types.joint_state.. ' *OUT_qd_ik'
            result_init = asn1_types.init.joint_state .. '(OUT_qd_ik);'
            result_call = 'OUT_qd_ik'
        end
    end
    return result_decl, result_init, result_call, result_para
end


--id fk1(const ur5::mc_config& mc,
--       const ur5::joint_state& input,
--       kul::pose_t& fr_wrist_3__fr_base,
--       ur5::t_J_fr_wrist_3_fr_base& J_fr_wrist_3_fr_base,
--       ur5::t_J_fr_wrist_3_fr_elbow& J_fr_wrist_3_fr_elbow);
--
--void fk2(const ur5::mc_config& mc, const ur5::joint_state& input, kul::pose_t& fr_forearm__fr_base);
--void fk__ik1(const ur5::mc_config& mc, const ur5::joint_state& input, kul::pose_t& fr_wrist_3__fr_base, ur5::t_J_fr_wrist_3_fr_base& J_fr_wrist_3_fr_base);
--void ik1(const ur5::mc_config& mc, const ur5::joint_state& q, const kul::vector3_t &vector, ur5::joint_state& qd_ik);
--
--void ik2(const ur5::mc_config& mc, const kul::ik_pos_cfg& cfg,      <-- positional  ^-- velocity
--            const kul::vector3_t& desired_position,
--            const kul::rot_m_t& desired_orientation,
--            const ur5::joint_state& q_guess,
--            ur5::joint_state& q_ik, kul::ik_pos_dbg &dbg);

--
--M.backend_namespace = 'kul'
--M.pose_type = 'pose_t'
--M.input_type = 'joint_state'

local function generate_solver_signatures(metadata)
    local result_decl = ''
    local result_call = ''
    local robot_name = metadata.ops.robot_name
    result_call = result_call .. constants.mc_variable .. ','
    if metadata.ops.type == ilk_keywords.solver_type.forward then
        result_decl = result_decl .. robot_name..'::'..constants.input_type..' input; '
        result_call = result_call .. 'input,'
        local counter = 0
        for i,v in pairs(metadata.ops.outputs) do
            if v.otype == 'pose' then
                counter = counter + 1
                result_decl = result_decl .. constants.backend_namespace..'::'..constants.pose_type..' output_'..counter..'; '
                result_call = result_call .. 'output_'..counter..','
            elseif v.otype == 'jacobian' then
                counter = counter + 1
                result_decl = result_decl .. robot_name..'::'..constants.jacobian_type..' output_'..counter..'; '
                result_call = result_call .. 'output_'..counter..','
            end
        end
        result_call = result_call:sub(1, -2)
    elseif metadata.ops.type == ilk_keywords.solver_type.inverse then
        if metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.position then
            result_decl = result_decl .. constants.backend_namespace..'::ik_pos_cfg cfg; '
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.position_type ..' desired_position; '
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.orientation_type ..' desired_orientation; '
            result_decl = result_decl .. robot_name ..'::' .. constants.input_type .. ' q_guess; '
            result_decl = result_decl .. robot_name ..'::' .. constants.input_type .. ' q_ik; '
            result_decl = result_decl .. constants.backend_namespace .. '::ik_pos_dbg dbg; '
            result_call = result_call .. 'cfg, desired_position, desired_orientation, q_guess, q_ik, dbg'
        elseif metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.velocity then
            result_decl = result_decl .. robot_name .. '::' .. constants.input_type .. ' q; '
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.velocity_linear_type ..' vector; '
            result_decl = result_decl .. robot_name .. '::' .. constants.input_type .. ' qd_ik; '
            result_call = result_call .. 'q, vector, qd_ik'
        end
    end
    return result_decl, result_call
end


local M = {}
M.generate_inputs = generate_inputs
M.generate_outputs = generate_outputs
M.generate_solver_signatures = generate_solver_signatures
return M
