local M = {}

M.pose = 'asn1SccPose'
M.vector_3d = 'asn1SccVector3d'
M.orientation = 'asn1SccQuaterniond'
M.position = 'asn1SccPosition'
M.joint_state = 'asn1SccJointState'
--M.rot_m_t = 'asn1_ROTATION_MATRIX_DOES_NOT_EXIST_PLEASE_UPDATE'
M.rot_m_t = 'asn1SccJointState'


local initialize = {}
initialize.pose = 'asn1SccPose_Initialize'
initialize.joint_state = 'asn1SccJointState_Initialize'

M.init = initialize

return M
