open Extensions
open Types_ui

(*** Main function ***)

let display_trace json_file =

  (* Opening and parse the json_file *)
  let full_path = Filename.concat !Config.path_database json_file in
  let json = Parsing_functions_ui.parse_json_from_file full_path in

  (* Retrieve the query result *)
  let (query_result,_) = Parsing_functions_ui.query_result_of json_file json in

  match query_result.q_status with
    | QCompleted (Some attack_trace) ->
        let process = List.nth query_result.processes (attack_trace.id_proc - 1) in
        let transitions = attack_trace.transitions in
        let semantics = query_result.semantics in
        let association = query_result.association in

        (* We reset the signature *)
        Interface.setup_signature query_result;
        Rewrite_rules.initialise_all_skeletons ();

        let conf_csys_list = Interface.execute_process semantics process transitions in
        let conf_list = List.map (fun csys -> csys.Constraint_system.additional_data) conf_csys_list in

        Display_ui.send_output_command (DTCurrent_step(association,List.hd conf_list,-1));

        begin try
          while true do
            let in_cmd_str = read_line () in
            let in_cmd_json = Parsing_functions_ui.parse_json_from_string in_cmd_str in
            let in_cmd = Parsing_functions_ui.input_command_of in_cmd_json in

            match in_cmd with
              | DTGo_to n ->
                  let conf = List.nth conf_list (n+1) in
                  Display_ui.send_output_command (DTCurrent_step(association,conf,n))
              | Die -> raise Exit
              | _ -> Display_ui.send_output_command (Init_internal_error ("Unexpected input command.",true))
          done
        with Exit -> Display_ui.send_output_command ExitUi
        end
    | _ ->
        Display_ui.send_output_command DTNo_attacker_trace;
        Display_ui.send_output_command ExitUi

let rec cut_list n = function
  | [] -> Config.internal_error "[simulator.ml >> cut_list] Wrong index."
  | t::_ when n = 0 -> t, [t]
  | t::q ->
      let (t',q') = cut_list (n-1) q in
      t',t::q'

let attack_simulator json_file =

  (* Opening and parse the json_file *)
  let full_path = Filename.concat !Config.path_database json_file in
  let json = Parsing_functions_ui.parse_json_from_file full_path in

  (* Retrieve the query result *)
  let (query_result,assoc_tbl) = Parsing_functions_ui.query_result_of json_file json in

  match query_result.q_status with
    | QCompleted (Some attack_trace) ->
        let process = List.nth query_result.processes (attack_trace.id_proc - 1) in
        let transitions = attack_trace.transitions in
        let semantics = query_result.semantics in
        let association = query_result.association in

        (* We reset the signature *)
        Interface.setup_signature query_result;
        Rewrite_rules.initialise_all_skeletons ();

        (* We start by generating the attack trace *)
        let conf_csys_list = Interface.execute_process semantics process transitions in
        let conf_list = List.map (fun csys -> csys.Constraint_system.additional_data) conf_csys_list in

        let full_frame = (List.hd (List.rev conf_list)).frame in

        (* Id process *)
        let simulated_id_proc = if attack_trace.id_proc = 1 then 2 else 1
        and attacked_id_proc = attack_trace.id_proc in

        (* We now generates the initial simulated step *)
        let simulated_states = ref [Interface.initial_attack_simulator_state semantics transitions (List.nth query_result.processes (simulated_id_proc -1))] in

        let get_current_step_simulated state new_trans =
          ASCurrent_step_simulated (
            association,
            state.Interface.simulated_csys.Constraint_system.additional_data,
            new_trans,
            state.Interface.all_available_actions,
            state.Interface.default_available_actions,
            state.Interface.status_equivalence,
            simulated_id_proc
          )
        in

        Display_ui.send_output_command (ASCurrent_step_attacked(association,List.hd conf_list,-1,attacked_id_proc));
        Display_ui.send_output_command (get_current_step_simulated (List.hd !simulated_states) []);

        begin try
          while true do
            let in_cmd_str = read_line () in
            let in_cmd_json = Parsing_functions_ui.parse_json_from_string in_cmd_str in
            let in_cmd = Parsing_functions_ui.input_command_of ~assoc:(Some assoc_tbl) in_cmd_json in

            match in_cmd with
              | ASGo_to(id_proc,n) ->
                  if id_proc = attacked_id_proc
                  then
                    let conf = List.nth conf_list (n+1) in
                    Display_ui.send_output_command (ASCurrent_step_attacked(association,conf,n,id_proc))
                  else
                    begin
                      let (state,cut_state_list) = cut_list (n+1) !simulated_states in
                      simulated_states := cut_state_list;
                      Display_ui.send_output_command (get_current_step_simulated state [])
                    end
              | ASNext_step trans ->
                  let last_state = List.hd (List.rev !simulated_states) in
                  let (new_states, new_transitions) = Interface.attack_simulator_apply_next_step semantics attacked_id_proc full_frame transitions last_state trans in
                  let new_last_state = List.hd (List.rev new_states) in
                  simulated_states := !simulated_states @ new_states;

                  if last_state.Interface.attacked_id_transition <> new_last_state.Interface.attacked_id_transition
                  then
                    begin
                      let conf = List.nth conf_list (new_last_state.Interface.attacked_id_transition+1) in
                      Display_ui.send_output_command (ASCurrent_step_attacked(association,conf,new_last_state.Interface.attacked_id_transition,attacked_id_proc))
                    end;

                  Display_ui.send_output_command (get_current_step_simulated new_last_state new_transitions)
              | Die -> raise Exit
              | _ -> Display_ui.send_output_command (Init_internal_error ("Unexpected input command.",true))
          done
        with Exit -> Display_ui.send_output_command ExitUi
        end
    | _ ->
        Display_ui.send_output_command ASNo_attacker_trace;
        Display_ui.send_output_command ExitUi
