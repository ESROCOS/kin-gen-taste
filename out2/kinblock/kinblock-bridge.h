/********************************************************** 
   This file was generated automatically: DO NOT MODIFY

    This header file is part of the user-code that
    implements a Taste function block component generated
    with the ESROCOS robot modeling tool.
    It exposes the function declarations used
    in the Taste function block.

  
  Delivered by: KU Leuven, Belgium, 2018
  Generated on: Fri Apr  6 15:44:44 2018 (UTC)
  Generated by: Enea Scioni
  License:      BSD2-clause

**********************************************************/

#ifndef __RM_TOOL_H_KINBLOCK_USER_CODE_IMPL__
#define __RM_TOOL_H_KINBLOCK_USER_CODE_IMPL__

#ifdef __cplusplus
extern "C" {
#endif

#include "../dataview/dataview-uniq.h"

/* ONLY declarations of functions used in the taste-usercode here */
/* Initialize model constants */
void load_model_constants();

int solver_fk1(const asn1SccJointState *IN_joints, asn1SccPose *outval_1);

int solver_fk2(const asn1SccJointState *IN_joints, asn1SccPose *outval_1);

int solver_ik1(const asn1SccJointState *IN_q, const asn1SccVector3d *IN_vector, asn1SccJointState *OUT_qd_ik);

int solver_ik2(const asn1SccVector3d *IN_position, const asn1SccJointState*IN_orientation, asn1SccJointState*IN_guess, asn1SccJointState *OUT_q_ik);

#ifdef __cplusplus
}
#endif

#endif // __RM_TOOL_H_KINBLOCK_USER_CODE_IMPL__
