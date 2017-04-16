(** Management of tests *)

open Term
open Data_structure

type html_code =
  | NoScript of string
  | Script of string * string * (int * int * int option) list

(** The type [data_IO] represents all the informations required by the test manager for each tested function.
    The first three lists represent the different tests and their status. Each test is representing by a pair of string [(str1,str2)] where
    [str1] corresponds to the actual tests with complete information (no pretty print), and where [str2] represents the HTML code that will
    used for the UI. *)
type data_IO =
  {
    scripts : bool;

    validated_tests : (string, html_code * int) Hashtbl.t; (** The tests that have been validated by a user *)
    tests_to_check : (string, html_code * int) Hashtbl.t; (** The tests that have been produced during previous testing execution but haven't been validated yet. *)
    faulty_tests : (string, html_code * string * html_code * int) Hashtbl.t; (** The tests that have been found faulty during the verification process. *)

    is_being_tested : bool; (** When [is_being_tested] is set to [false], no test is produce for this function *)

    file : string (** Core name of the files that will be generated for this function. *)
  }

(** Preload the tests, validated or not. *)
val preload : unit -> unit

val preload_tests : data_IO -> unit

(** Publish all the tests, validated or not, i.e. it generates every html and txt files for each tested function. *)
val publish : unit -> unit

val publish_tests : data_IO -> unit

val publish_faulty_tests :  data_IO -> unit

(** This function updates the testing functions. This must be executed before running running any tests otherwise the tests will not be produced *)
val update : unit -> unit

(** [validate data [i_1;...;i_k]] valides the [i_1]-th, ..., [i_k]-th tests from [data.tests_to_check]. The first element of [data.tests_to_check] is considered
    as the 1-fst test of [data.tests_to_check].*)
val validate : data_IO -> int list -> unit

(** [validate data] validates all the tests in [data.tests_to_check].*)
val validate_all_tests : data_IO -> unit

(** {2 Functions to be tested} *)

(** For each tested function, we need to associate some data of type [data_IO] as well as a function that will produce the test resulting of an application
    of the function and a function that will load the test. By convention, we use the full name of the function. For example, consider the function [A.B.C.function_test : 'a -> 'b -> 'c -> bool].
    The data I/O for testing [A.B.C.function_test] will be stored in

    [val data_A_B_C_function_test : data_IO]

    the function producing the test will be as follows:

    [val apply_A_B_C_function_test : 'a -> 'b -> 'c -> string]

    and the function loading the test will be as follows:

    [val load_A_B_C_function_test : 'a -> 'b -> 'c -> bool -> string]
*)

(** {3 Term.Subst.Unify} *)

val data_IO_Term_Subst_unify : data_IO

val apply_Term_Subst_unify : ('a, 'b) atom -> (('a, 'b) term * ('a, 'b) term) list -> string

val load_Term_Subst_unify : int -> ('a, 'b) atom -> (('a, 'b) term * ('a, 'b) term) list -> ('a, 'b) Subst.t option -> html_code

(** {3 Term.Subst.is_matchable} *)

val data_IO_Term_Subst_is_matchable : data_IO

val apply_Term_Subst_is_matchable : ('a, 'b) atom -> ('a, 'b) term list -> ('a, 'b) term list -> string

val load_Term_Subst_is_matchable : int -> ('a, 'b) atom -> ('a, 'b) term list -> ('a, 'b) term list -> bool -> html_code

(** {3 Term.Subst.is_extended_by} *)

val data_IO_Term_Subst_is_extended_by : data_IO

val apply_Term_Subst_is_extended_by : ('a, 'b) atom -> ('a, 'b) Subst.t -> ('a, 'b) Subst.t -> string

val load_Term_Subst_is_extended_by : int -> ('a, 'b) atom -> ('a, 'b) Subst.t -> ('a, 'b) Subst.t -> bool -> html_code

(** {3 Term.Subst.is_equal_equations} *)

val data_IO_Term_Subst_is_equal_equations : data_IO

val apply_Term_Subst_is_equal_equations : ('a, 'b) atom -> ('a, 'b) Subst.t -> ('a, 'b) Subst.t -> string

val load_Term_Subst_is_equal_equations : int -> ('a, 'b) atom -> ('a, 'b) Subst.t -> ('a, 'b) Subst.t -> bool -> html_code

(** {3 Term.Modulo.syntactic_equations_of_equations} *)

val data_IO_Term_Modulo_syntactic_equations_of_equations : data_IO

val apply_Term_Modulo_syntactic_equations_of_equations : Modulo.equation list -> string

val load_Term_Modulo_syntactic_equations_of_equations : int -> Modulo.equation list -> (fst_ord, name) Subst.t list Modulo.result -> html_code

(** {3 Term.Rewrite_rules.normalise} *)

val data_IO_Term_Rewrite_rules_normalise : data_IO

val apply_Term_Rewrite_rules_normalise : protocol_term -> string

val load_Term_Rewrite_rules_normalise : int -> protocol_term -> protocol_term -> html_code

(** {3 Term.Rewrite_rules.skeletons} *)

val data_IO_Term_Rewrite_rules_skeletons : data_IO

val apply_Term_Rewrite_rules_skeletons : protocol_term -> symbol -> int -> string

val load_Term_Rewrite_rules_skeletons : int -> protocol_term -> symbol -> int -> Rewrite_rules.skeleton list -> html_code

(** {3 Term.Rewrite_rules.generic_rewrite_rules_formula} *)

val data_IO_Term_Rewrite_rules_generic_rewrite_rules_formula : data_IO

val apply_Term_Rewrite_rules_generic_rewrite_rules_formula : Fact.deduction -> Rewrite_rules.skeleton -> string

val load_Term_Rewrite_rules_generic_rewrite_rules_formula : int -> Fact.deduction -> Rewrite_rules.skeleton -> Fact.deduction_formula list -> html_code

(** {3 Data_structure.Eq.implies} *)

val data_IO_Data_structure_Eq_implies : data_IO

val apply_Data_structure_Eq_implies : ('a, 'b) atom -> ('a, 'b) Eq.t -> ('a, 'b) term -> ('a, 'b) term -> string

val load_Data_structure_Eq_implies : int -> ('a, 'b) atom -> ('a, 'b) Eq.t -> ('a, 'b) term -> ('a, 'b) term -> bool -> html_code

(** {3 Data_structure.Tools.partial_consequence} *)

val data_IO_Data_structure_Tools_partial_consequence : data_IO

val apply_Data_structure_Tools_partial_consequence : ('a, 'b) atom -> SDF.t -> DF.t -> ('a, 'b) term -> string

val load_Data_structure_Tools_partial_consequence : int -> ('a, 'b) atom -> SDF.t -> DF.t -> ('a, 'b) term -> (recipe * protocol_term) option -> html_code

(** {3 Data_structure.Tools.partial_consequence_additional} *)

val data_IO_Data_structure_Tools_partial_consequence_additional : data_IO

val apply_Data_structure_Tools_partial_consequence_additional : ('a, 'b) atom -> SDF.t -> DF.t -> BasicFact.t list -> ('a, 'b) term -> string

val load_Data_structure_Tools_partial_consequence_additional : int -> ('a, 'b) atom -> SDF.t -> DF.t -> BasicFact.t list -> ('a, 'b) term -> (recipe * protocol_term) option -> html_code

(** {3 Data_structure.Tools.uniform_consequence} *)

val data_IO_Data_structure_Tools_uniform_consequence : data_IO

val apply_Data_structure_Tools_uniform_consequence : SDF.t -> DF.t -> Uniformity_Set.t -> protocol_term -> string

val load_Data_structure_Tools_uniform_consequence : int -> SDF.t -> DF.t -> Uniformity_Set.t -> protocol_term -> recipe option -> html_code

(** {3 Process.of_expansed_process} *)

val data_IO_Process_of_expansed_process : data_IO

val apply_Process_of_expansed_process : Process.expansed_process -> string

val load_Process_of_expansed_process : int -> Process.expansed_process  -> Process.process -> html_code

(** {3 Process.next_output} *)

val data_IO_Process_next_output : data_IO

val apply_Process_next_output : Process.semantics -> Process.equivalence -> Process.process -> (fst_ord, name) Subst.t -> string

val load_Process_next_output : int -> Process.semantics -> Process.equivalence -> Process.process -> (fst_ord, name) Subst.t -> (Process.process * Process.output_gathering) list -> html_code

(** {3 Process.next_input} *)

val data_IO_Process_next_input : data_IO

val apply_Process_next_input : Process.semantics -> Process.equivalence -> Process.process -> (fst_ord, name) Subst.t -> string

val load_Process_next_input : int -> Process.semantics -> Process.equivalence -> Process.process -> (fst_ord, name) Subst.t -> (Process.process * Process.input_gathering) list -> html_code

(** {3 Constraint_system.mgs} *)

val data_IO_Constraint_system_mgs : data_IO

val apply_Constraint_system_mgs : Constraint_system.simple -> string

val load_Constraint_system_mgs : int -> Constraint_system.simple -> (Constraint_system.mgs * (fst_ord, name) Subst.t * Constraint_system.simple) list -> html_code

(** {3 Constraint_system.one_mgs} *)

val data_IO_Constraint_system_one_mgs : data_IO

val apply_Constraint_system_one_mgs : Constraint_system.simple -> string

val load_Constraint_system_one_mgs : int -> Constraint_system.simple -> (Constraint_system.mgs * (fst_ord, name) Subst.t * Constraint_system.simple) option -> html_code

(** {3 Constraint_system.simple_of_formula} *)

val data_IO_Constraint_system_simple_of_formula : data_IO

val apply_Constraint_system_simple_of_formula : 'a Fact.t -> 'b Constraint_system.t -> 'a Fact.formula -> string

val load_Constraint_system_simple_of_formula : int -> 'a Fact.t -> 'b Constraint_system.t -> 'a Fact.formula -> (fst_ord, name) Variable.Renaming.t * (snd_ord, axiom) Variable.Renaming.t * Constraint_system.simple -> html_code

(** {3 Constraint_system.simple_of_disequation} *)

val data_IO_Constraint_system_simple_of_disequation : data_IO

val apply_Constraint_system_simple_of_disequation : 'a Constraint_system.t -> (fst_ord, name) Diseq.t -> string

val load_Constraint_system_simple_of_disequation : int -> 'a Constraint_system.t -> (fst_ord, name) Diseq.t -> (fst_ord, name) Variable.Renaming.t * Constraint_system.simple -> html_code

(** {3 Constraint_system.apply_mgs} *)

val data_IO_Constraint_system_apply_mgs : data_IO

val apply_Constraint_system_apply_mgs : 'a Constraint_system.t -> Constraint_system.mgs -> string

val load_Constraint_system_apply_mgs : int -> 'a Constraint_system.t -> Constraint_system.mgs -> 'a Constraint_system.t option -> html_code

(** {3 Constraint_system.apply_mgs_on_formula} *)

val data_IO_Constraint_system_apply_mgs_on_formula : data_IO

val apply_Constraint_system_apply_mgs_on_formula : 'a Fact.t -> 'b Constraint_system.t -> Constraint_system.mgs -> 'a Fact.formula -> string

val load_Constraint_system_apply_mgs_on_formula : int -> 'a Fact.t -> 'b Constraint_system.t -> Constraint_system.mgs -> 'a Fact.formula -> 'a Fact.formula option -> html_code

(** {3 The transformation rules in Constraint_system.Rule} *)

val data_IO_Constraint_system_Rule_sat : data_IO

val data_IO_Constraint_system_Rule_sat_disequation : data_IO

val data_IO_Constraint_system_Rule_sat_formula : data_IO

val data_IO_Constraint_system_Rule_equality_constructor : data_IO

val data_IO_Constraint_system_Rule_equality : data_IO

val data_IO_Constraint_system_Rule_rewrite : data_IO

val apply_Constraint_system_Rule_rules : ('a Constraint_system.Set.t -> 'a Constraint_system.Rule.continuation -> unit) -> 'a Constraint_system.Set.t -> string

val load_Constraint_system_Rule_rules : int -> 'a Constraint_system.Set.t -> unit Constraint_system.Set.t list * unit Constraint_system.Set.t list * unit Constraint_system.Set.t list -> html_code

(** {3 Constraint_system.Rule.normalisation} *)

val data_IO_Constraint_system_Rule_normalisation : data_IO

val apply_Constraint_system_Rule_normalisation : 'a Constraint_system.Set.t -> string

val load_Constraint_system_Rule_normalisation : int -> 'a Constraint_system.Set.t -> unit Constraint_system.Set.t list ->  html_code
