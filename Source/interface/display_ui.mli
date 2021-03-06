(**************************************************************************)
(*                                                                        *)
(*                               DeepSec                                  *)
(*                                                                        *)
(*               Vincent Cheval, project PESTO, INRIA Nancy               *)
(*                Steve Kremer, project PESTO, INRIA Nancy                *)
(*            Itsaka Rakotonirina, project PESTO, INRIA Nancy             *)
(*                                                                        *)
(*   Copyright (C) INRIA 2017-2020                                        *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU General Public License version 3.0 as described in the       *)
(*   file LICENSE                                                         *)
(*                                                                        *)
(**************************************************************************)

open Types
open Types_ui

(*** Display ***)

val display_position : json_position -> string

val display_transition : json_transition -> string

val display_process : int -> json_process -> string

val display_association : full_association -> string

val display_verification_result : verification_result -> unit

(*** Id retrieval ***)

val get_variable_id : full_association -> variable -> int * int list

val get_name_id : full_association -> name -> int * int list

(*** Display of Json ***)

val display_json : json -> string

(* Generation of association from signature *)

val record_from_signature : association ref -> unit

val record_from_process : association ref -> process -> unit

(* Traces and processes *)

val of_json_process : full_association -> json_process -> json

(* Batch / Run / Query result *)

val of_query_result : query_result -> json

val of_run_result : run_result -> json

val of_batch_result : batch_result -> json

(* Output commands *)

val send_output_command : output_command -> unit
