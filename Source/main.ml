(******* Display index page *******)


let print_index path n res_list =

  let path_index = Filename.concat !Config.path_index "index.html" in
  let path_index_old = Filename.concat !Config.path_index "index_old.html" in

  let initial_index = not (Sys.file_exists path_index) in
  let path_template =
    if initial_index then
      Filename.concat !Config.path_html_template "index.html"
    else
      begin
	Sys.rename path_index path_index_old;
	path_index_old
      end
  in
  
  let out_html = open_out path_index in
  let in_template = open_in path_template in

  let template_result = "<!-- Results deepsec -->" in 
  let template_stylesheet = "<!-- Stylesheet deepsec -->" in

  let line = ref (input_line in_template) in  
  if initial_index then
    begin
      while !line <> template_stylesheet do
	Printf.fprintf out_html "%s\n" !line;
	line := input_line in_template
      done;
      line := input_line in_template;

      Printf.fprintf out_html " <link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">\n" (Filename.concat (Filename.concat !Config.path_deepsec "Style") "style.css");
    end;
  
  while !line <> template_result do
    Printf.fprintf out_html "%s\n" !line;
    line := input_line in_template
  done;
  Printf.fprintf out_html "%s\n" !line; (* print template_stylesheet *)
  Printf.fprintf out_html "        <p>File run with DeepSec : %s</p>\n\n" path;
  let time = Unix.localtime (Unix.time ()) in 
  Printf.fprintf out_html "        <p> on %s </p>\n\n" (Display.mkDate time); 
  Printf.fprintf out_html "        <p>This file contained %d quer%s:\n" n (if n > 1 then "ies" else "y ");
  if n <> 0
  then
    begin
      Printf.fprintf out_html "          <ul>\n";
      let rec print_queries = function
        | (k, _) when k > n -> ()
        | (k, (res,rt)::tl) ->
          Printf.fprintf out_html
	    "            <li>Query %d:</br>\n Result: the processes are %s</br>\n \nRunning time: %s (%s)</br>\n<a href=\"result/result_query_%d_%s.html\">Details</a></li>\n"
	    k
	    (match res with | Equivalence.Equivalent -> "equivalent" | Equivalence.Not_Equivalent _ -> "not equivalent")
	    (Display.mkRuntime rt)
	    (if !Config.distributed then "Workers: "^(Distributed_equivalence.DistribEquivalence.display_workers ()) else "Not distributed") 
	    k !Config.tmp_file;
          print_queries ((k+1), tl)
	| (_ , _) -> failwith "Number of queries and number of results differ"
      in
      print_queries (1, res_list);
      Printf.fprintf out_html "          </ul>\n";
    end;
  if not initial_index then Printf.fprintf out_html "        <hr class=\"small-separation\"></br>\n";
  
  try
    while true do
      let l = input_line in_template in
      Printf.fprintf out_html "%s\n" l;
    done
  with
  | End_of_file ->
    close_in in_template; close_out out_html; if not initial_index then Sys.remove path_index_old

(******* Help ******)

let print_help () =
  Printf.printf "Name : DeepSec\n";
  Printf.printf "   DEciding Equivalence Properties for SECurity protocols\n\n";
  Printf.printf "Version 1.0alpha\n\n";
  Printf.printf "Synopsis:\n";
  Printf.printf "      deepsec [-distributed <int>] [-distant_workers <string> <string> <int>] [-nb_sets <int>]\n";
  Printf.printf "              [-no_display_attack_trace] [-semantics Classic|Private|Eavesdrop] file\n\n";
  Printf.printf "Options:\n";
  Printf.printf "      -deepsec_dir p: Specify (absolute) path to deepsec directory.\n\n";
  Printf.printf "      -out_dir p: Specify path to the output directory.\n\n";  
  Printf.printf "      -distributed n: Activate the distributed computing with n local workers.\n\n";
  Printf.printf "      -distant_workers machine path n: This option allows you to specify additional worker\n";
  Printf.printf "         that are not located in the DeepSec distribution of the server and that will be\n";
  Printf.printf "         accessed through and ssh connexion. In particular, <machine> should correspond to the\n";
  Printf.printf "         adress of the distant machine, and <path> should be the path of the folder in which\n";
  Printf.printf "         the DeepSec distribution is located on <machine>. Note that it is CRUCIAL that both\n";
  Printf.printf "         the local machine and the distant machine have the distribution of DeepSec and Ocaml.\n";
  Printf.printf "         The argument <n> corresponds to the number of worker that will be launch on <machine>.\n\n";
  Printf.printf "         Example : \n";
  Printf.printf "           -distant_workers my_login@my_distant_server path_to_deepsec_on_my_distant_server/deepsec 3\n";
  Printf.printf "         will run 3 workers on the machine that be accessed via ssh my_login@my_distant_server\n";
  Printf.printf "         and on which the folder [deepsec] containing the distribution of DeepSec is located\n";
  Printf.printf "         at path_to_deepsec_on_my_distant_server/deepsec/.\n\n";
  Printf.printf "      -nb_sets n: Specify n to be the number of sets of constraint systems generated by deepsec\n";
  Printf.printf "         and that will be distributed to the workers.\n\n";
  Printf.printf "      -no_display_attack_trace: Does not display the attack trace. It only indicates whether\n";
  Printf.printf "         the queries are true or false. This could be activated for efficiency purposes.\n\n";
  Printf.printf "Testing interface and debug mode:\n";
  Printf.printf "   A testing interface is available for developer to check any update they provide\n";
  Printf.printf "   to the code. It can also be used by users to verify more in depth that DeepSec \n";
  Printf.printf "   is behaving as expacted. To enable this testing interface, DeepSec must be recompile\n";
  Printf.printf "   as follows.\n\n";
  Printf.printf "      make testing\n";
  Printf.printf "      make\n\n";
  Printf.printf "   WARNING : Using the testing interface will slow down heavely the verification of\n";
  Printf.printf "   of processes as it generates multiple tests, display them on html pages, etc.\n";
  Printf.printf "   To disable the testing interface, one should once again compile DeepSec as follows.\n\n";
  Printf.printf "      make without_testing\n";
  Printf.printf "      make\n\n";
  Printf.printf "   Similarly, DeepSec also have a debug mode that verify multiple invariants during\n";
  Printf.printf "   its execution. It also slows down the verification of processes. To enable the debug\n";
  Printf.printf "   mode, DeepSec must be compoiled as follows.\n\n";
  Printf.printf "      make debug\n";
  Printf.printf "      make\n\n";
  Printf.printf "   To disable the debug mode, compile DeepSec as follows.\n";
  Printf.printf "      make without_debug\n";
  Printf.printf "      make\n\n";
  Printf.printf "   Remark: The testing interface and debug mode are independant and can be enable at the\n";
  Printf.printf "   same time by compiling DeepSec with for example: make testing; make debug; make\n"

(******* Parsing *****)

let parse_file path =

  Printf.printf "Opening file %s\n" path;

  let channel_in = open_in path in
  let lexbuf = Lexing.from_channel channel_in in

  let _ =
    try
      while true do
        Parser_functions.parse_one_declaration (Grammar.main Lexer.token lexbuf)
      done
    with
      | Failure msg -> Printf.printf "%s\n" msg; exit 0
      | End_of_file -> () in

  Parser_functions.query_list := List.rev !Parser_functions.query_list; (*putting queries in the same order as in the file *)
  close_in channel_in

(****** Main ******)

let start_time = ref (Unix.time ())
    
let rec excecute_queries id = function
  | [] -> []
  | (Process.Trace_Equivalence,exproc1,exproc2)::q ->
    start_time :=  (Unix.time ());
    let proc1 = Process.of_expansed_process exproc1 in
    let proc2 = Process.of_expansed_process exproc2 in
    
    Printf.printf "Executing query %d...\n" id;
    
    let result =
      if !Config.distributed
      then
        begin
          let result,init_proc1, init_proc2 = Distributed_equivalence.trace_equivalence !Process.chosen_semantics proc1 proc2 in
	  let running_time = ( Unix.time () -. !start_time ) in
          if !Config.display_trace
          then Equivalence.publish_trace_equivalence_result id !Process.chosen_semantics init_proc1 init_proc2 result running_time;
          (result, running_time)
        end
      else
        begin
          let result = Equivalence.trace_equivalence !Process.chosen_semantics proc1 proc2 in
	  let running_time = ( Unix.time () -. !start_time ) in
          if !Config.display_trace
          then Equivalence.publish_trace_equivalence_result id !Process.chosen_semantics proc1 proc2 result running_time;
          (result, running_time)
        end
    in

    begin match result with
    | (Equivalence.Equivalent, _) ->
      if !Config.display_trace
      then Printf.printf "Query %d: Equivalent processes : See a summary of the input file on the HTML interface.\n" id
      else Printf.printf "Query %d: Equivalent processes.\n" id
    | (Equivalence.Not_Equivalent _, _) ->
      if !Config.display_trace
      then Printf.printf "Query %d: Processes not equivalent : See a summary of the input file and the attack trace on the HTML interface.\n" id
      else Printf.printf "Query %d: Processes not equivalent.\n" id
    end;
    result::(excecute_queries (id+1) q)
  | _ -> Config.internal_error "Observational_equivalence not implemented"

    
let _ =
  let path = ref "" in
  let arret = ref false in
  let i = ref 1 in  
  
  while !i < Array.length Sys.argv && not !arret do
    match (Sys.argv).(!i) with
      | "-distributed" when not (!i+1 = (Array.length Sys.argv)) ->
          Config.distributed := true;
          Distributed_equivalence.DistribEquivalence.local_workers (int_of_string (Sys.argv).(!i+1));
          i := !i + 2
      | "-distant_workers" when not (!i+3 = (Array.length Sys.argv)) ->
          Config.distributed := true;
          Distributed_equivalence.DistribEquivalence.add_distant_worker (Sys.argv).(!i+1) (Sys.argv).(!i+2) (int_of_string (Sys.argv).(!i+3));
          i := !i + 4
      | "-nb_sets" when not (!i+1 = (Array.length Sys.argv)) ->
          Distributed_equivalence.DistribEquivalence.minimum_nb_of_jobs := int_of_string (Sys.argv).(!i+1);
          i := !i + 2
      | "-semantics" when not (!i+1 = (Array.length Sys.argv)) ->
          begin match (Sys.argv).(!i+1) with
            | "Classic" -> Process.chosen_semantics := Process.Classic
            | "Private" -> Process.chosen_semantics := Process.Private
            | "Eavesddrop" -> Process.chosen_semantics := Process.Eavesdrop
            | _ -> print_help (); arret := true
          end;
          i := !i + 2
      | "-no_display_attack_trace" ->
          Config.display_trace := false;
        i := !i + 1
      | "-deepsec_dir" when not (!i+1 = (Array.length Sys.argv)) ->
	Config.path_deepsec := (Sys.argv).(!i+1);
	i := !i + 2
      | "-out_dir" when not (!i+1 = (Array.length Sys.argv)) ->
	Config.path_index := (Sys.argv).(!i+1);
	i := !i + 2
      | str_path ->
          if !i = Array.length Sys.argv - 1
          then path := str_path
          else arret := true;
          i := !i + 1
  done;
  
  if Array.length Sys.argv <= 1
  then arret := true;

  if !Config.path_deepsec = "" then
    begin
      Config.path_deepsec:=
	(
	  try Sys.getenv "DEEPSEC_DIR" with 
	    Not_found -> Printf.printf "Environment variable DEEPSEC_DIR not defined and -deepsec_dir not specified on command line\n"; exit 1
	)
    end;

  if Filename.is_relative !Config.path_deepsec then 
    begin
      (* convert to absolute path *)
      let save_current_dir=Sys.getcwd () in
      Sys.chdir !Config.path_deepsec;
      Config.path_deepsec:=Sys.getcwd ();
      Sys.chdir save_current_dir;
    end;
  if !arret || !path = ""
  then print_help ()
  else
    begin
      Config.path_html_template := ( Filename.concat (Filename.concat (!Config.path_deepsec) "Source") "html_templates/" ); 
      
      if !Config.path_index= "" then  Config.path_index:= Filename.dirname !path; (*default location for results is the folder of the input file*)

      let create_if_not_exist dir_name =
	if not (Sys.file_exists dir_name) then Unix.mkdir (dir_name) 0o770
      in

      let path_result = (Filename.concat !Config.path_index "result") in
      create_if_not_exist path_result;
      let prefix = "result_query_1_" and suffix = ".html" in
      let tmp = Filename.basename (Filename.temp_file ~temp_dir:path_result prefix suffix) in
      let len_tmp = String.length tmp
      and len_prefix = String.length prefix
      and len_suffix = String.length suffix in
      Config.tmp_file:= String.sub tmp (len_prefix) ( len_tmp - ( len_prefix + len_suffix ) );
      
      if Config.test_activated
      then
        begin
          Printf.printf "Loading the regression suite...\n";
          flush_all ();
	  let testing_data_dir = (Filename.concat !Config.path_deepsec "testing_data") in
	  create_if_not_exist testing_data_dir;
	  create_if_not_exist (Filename.concat testing_data_dir "tests_to_check");
          Testing_load_verify.load ();
          Testing_functions.update ()
        end;

      Term.Symbol.empty_signature ();
      parse_file !path;

      if Config.test_activated
      then
        begin
          try
            let l = excecute_queries 1 !Parser_functions.query_list in
            let nb_queries = List.length !Parser_functions.query_list in
            print_index !path nb_queries l;
            Testing_functions.publish ();
            Testing_load_verify.publish_index ()
          with
          | _ ->
            Testing_functions.publish ();
            Testing_load_verify.publish_index ()
        end
      else
        begin
          let l = excecute_queries 1 !Parser_functions.query_list in
          let nb_queries = List.length !Parser_functions.query_list in
          print_index !path nb_queries l;
        end
    end;
  exit 0
