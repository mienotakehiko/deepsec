open Testing_functions
open Testing_parser_functions

(** An element of type [data_verification] must be associated to each tested function. *)
type data_verification =
  {
    data_IO : data_IO; (** The data I/O associated to the function defined in the module [Testing_functions] (ex: [Testing_function.data_IO_Term_Subst_unify]). *)
    name : string; (** The name of the function. This will be use when calling the executatble. We take the convention to indicate the full name of the function (ex : ["Term.Subst.unify"]).*)
    parsing_function : (Lexing.lexbuf -> Testing_grammar.token) -> Lexing.lexbuf -> (parsing_mode -> string); (** The function generated by the parser for tests defined in the generated module [Testing_grammar] (ex: [Testing_grammar.parse_Term_Subst_unify]). *)
  }

(** {3 Functions to be tested} *)

let data_verification_Term_Subst_unify =
  {
    data_IO = data_IO_Term_Subst_unify;
    name = "Term.Subst.unify";
    parsing_function = Testing_grammar.parse_Term_Subst_unify
  }

let data_verification_Term_Subst_is_matchable =
  {
    data_IO = data_IO_Term_Subst_is_matchable;
    name = "Term.Subst.is_matchable";
    parsing_function = Testing_grammar.parse_Term_Subst_is_matchable
  }

let data_verification_Term_Subst_is_extended_by =
  {
    data_IO = data_IO_Term_Subst_is_extended_by;
    name = "Term.Subst.is_extended_by";
    parsing_function = Testing_grammar.parse_Term_Subst_is_extended_by
  }

let data_verification_Term_Subst_is_equal_equations =
  {
    data_IO = data_IO_Term_Subst_is_equal_equations;
    name = "Term.Subst.is_equal_equations";
    parsing_function = Testing_grammar.parse_Term_Subst_is_equal_equations
  }

let data_verification_Term_Modulo_syntactic_equations_of_equations =
  {
    data_IO = data_IO_Term_Modulo_syntactic_equations_of_equations;
    name = "Term.Modulo.syntactic_equations_of_equations";
    parsing_function = Testing_grammar.parse_Term_Modulo_syntactic_equations_of_equations
  }

let data_verification_Term_Rewrite_rules_normalise =
  {
    data_IO = data_IO_Term_Rewrite_rules_normalise;
    name = "Term.Rewrite_rules.normalise";
    parsing_function = Testing_grammar.parse_Term_Rewrite_rules_normalise
  }

let data_verification_Term_Rewrite_rules_skeletons =
  {
    data_IO = data_IO_Term_Rewrite_rules_skeletons;
    name = "Term.Rewrite_rules.skeletons";
    parsing_function = Testing_grammar.parse_Term_Rewrite_rules_skeletons
  }

let data_verification_Term_Rewrite_rules_generic_rewrite_rules_formula =
  {
    data_IO = data_IO_Term_Rewrite_rules_generic_rewrite_rules_formula;
    name = "Term.Rewrite_rules.generic_rewrite_rules_formula";
    parsing_function = Testing_grammar.parse_Term_Rewrite_rules_generic_rewrite_rules_formula
  }

let data_verification_Data_structure_Eq_implies =
  {
    data_IO = data_IO_Data_structure_Eq_implies;
    name = "Data_structure.Eq.implies";
    parsing_function = Testing_grammar.parse_Data_structure_Eq_implies
  }

let data_verification_Data_structure_Tools_partial_consequence =
  {
    data_IO = data_IO_Data_structure_Tools_partial_consequence;
    name = "Data_structure.Tools.partial_consequence";
    parsing_function = Testing_grammar.parse_Data_structure_Tools_partial_consequence
  }

let data_verification_Data_structure_Tools_partial_consequence_additional =
  {
    data_IO = data_IO_Data_structure_Tools_partial_consequence_additional;
    name = "Data_structure.Tools.partial_consequence_additional";
    parsing_function = Testing_grammar.parse_Data_structure_Tools_partial_consequence_additional
  }

let all_data_verification =
  [
    data_verification_Term_Subst_unify;
    data_verification_Term_Subst_is_matchable;
    data_verification_Term_Subst_is_extended_by;
    data_verification_Term_Subst_is_equal_equations;
    data_verification_Term_Modulo_syntactic_equations_of_equations;
    data_verification_Term_Rewrite_rules_normalise;
    data_verification_Term_Rewrite_rules_skeletons;
    data_verification_Term_Rewrite_rules_generic_rewrite_rules_formula;
    data_verification_Data_structure_Eq_implies;
    data_verification_Data_structure_Tools_partial_consequence;
    data_verification_Data_structure_Tools_partial_consequence_additional
  ]

(** {3 Verification of tests} *)

(** [verify_function data] verifies all the tests for the function associated to [data]. *)
let verify_function data_verif =
  let nb_of_tests = List.length data_verif.data_IO.validated_tests in

  Printf.printf "### Testing the function %s... \n" data_verif.name;

  let test_number = ref 1
  and faulty_tests = ref [] in

  List.iter (fun (valid_test,_) ->
    let lexbuf = Lexing.from_string valid_test in
    let test = (data_verif.parsing_function Testing_lexer.token lexbuf) Verify in
    if test <> valid_test
    then faulty_tests := (!test_number, valid_test, test) :: !faulty_tests;

    incr test_number
  ) data_verif.data_IO.validated_tests;

  faulty_tests := List.rev !faulty_tests;

  if !faulty_tests = []
  then Printf.printf "All %d tests of the function %s were successful\n " nb_of_tests data_verif.name
  else
    begin
      let nb_of_faulty_tests = List.length !faulty_tests in
      Printf.printf "%d tests of the function %s were successful but %d were unsuccessful.\n\n"  (nb_of_tests - nb_of_faulty_tests) data_verif.name nb_of_faulty_tests;

      List.iter (fun (nb,valid_test,faulty_test) ->
        Printf.printf "**** Test %d of %s was unsuccessful.\n" nb data_verif.name;
        Printf.printf "---- Validated test :\n%s" valid_test;
        Printf.printf "---- Test obtained after verification :\n%s\n" faulty_test
      ) !faulty_tests
    end

(** [verify_all] verifies all the tests of all the functions. *)
let verify_all () = List.iter verify_function all_data_verification

(** {3 Loading of tests} *)

let load_function data_verif =

  data_verif.data_IO.validated_tests <-
    List.map (fun (terminal_test,_) ->
      let lexbuf = Lexing.from_string terminal_test in
      let latex_test = (data_verif.parsing_function Testing_lexer.token lexbuf) Load in
      (terminal_test,latex_test)
    ) data_verif.data_IO.validated_tests;

  data_verif.data_IO.tests_to_check <-
    List.map (fun (terminal_test,_) ->
      let lexbuf = Lexing.from_string terminal_test in
      let latex_test = (data_verif.parsing_function Testing_lexer.token lexbuf) Load in
      (terminal_test,latex_test)
    ) data_verif.data_IO.tests_to_check

let load () =
  preload ();
  List.iter load_function all_data_verification

(** {3 Other publications} *)

let template_line_validated = "            <!-- Validated_tests -->"
let template_line_to_check = "            <!-- Tests_to_check -->"

let publish_index () =
  let path_html = Printf.sprintf "%stesting_data/testing.html" !Config.path_index
  and path_template = Printf.sprintf "%stesting.html" !Config.path_html_template in

  let out_html = open_out path_html in
  let open_template = open_in path_template in

  let print_validated_address data =
    Printf.fprintf out_html "<li>Function <a href=\"%svalidated_tests/%s.html\">%s</a> (Number of tests : %d)</li>"
      !Config.path_index
      data.data_IO.file
      data.name
      (List.length data.data_IO.validated_tests)
  in

  let print_to_check_address data =
    Printf.fprintf out_html "<li>Function <a href=\"%stests_to_check/%s.html\">%s</a> (Number of tests : %d)</li>"
      !Config.path_index
      data.data_IO.file
      data.name
      ((List.length data.data_IO.tests_to_check) + (List.length data.data_IO.additional_tests))
  in

  let line = ref "" in
  while !line <> template_line_validated do
    let l = input_line open_template in
    if l <> template_line_validated
    then Printf.fprintf out_html "%s\n" l;
    line := l
  done;

  List.iter print_validated_address all_data_verification ;

  let l = input_line open_template in
  Printf.fprintf out_html "%s\n" l;
  line := l;

  while !line <> template_line_to_check do
    let l = input_line open_template in
    if l <> template_line_to_check
    then Printf.fprintf out_html "%s\n" l;
    line := l
  done;

  List.iter print_to_check_address all_data_verification ;

  try
    while true do
      let l = input_line open_template in
      Printf.fprintf out_html "%s\n" l;
    done
  with
    | End_of_file -> close_out out_html
