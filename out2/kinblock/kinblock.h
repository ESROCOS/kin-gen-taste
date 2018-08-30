/********************************************************** 
   This file was generated automatically: DO NOT MODIFY

    This header file is part of the user-code for the
    Taste function block component generated
    with the ESROCOS robot modeling tool.

  
  Delivered by: KU Leuven, Belgium, 2018
  Generated on: Fri Apr  6 15:44:44 2018 (UTC)
  Generated by: Enea Scioni
  License:      BSD2-clause

**********************************************************/

#ifndef __USER_CODE_H_kinblock__
#define __USER_CODE_H_kinblock__

#include "C_ASN1_Types.h"
    
#ifdef __cplusplus
extern "C" {
#endif

void kinblock_startup();

void fk1_PI_req(const asn1SccJointState *IN_joints, asn1SccPose *outval_1);

void fk2_PI_req(const asn1SccJointState *IN_joints, asn1SccPose *outval_1);

void ik1_PI_req(const asn1SccJointState *IN_q, const asn1SccVector3d *IN_vector, asn1SccJointState *OUT_qd_ik);

void ik2_PI_req(const asn1SccVector3d *IN_position, const asn1SccJointState*IN_orientation, asn1SccJointState*IN_guess, asn1SccJointState *OUT_q_ik);

#ifdef __cplusplus
}
#endif

#endif
