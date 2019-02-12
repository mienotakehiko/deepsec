(* sets of integers. We define an additional function testing if a set is a
singleton (in which case it returns the corresponding element). *)
module IntSet = struct
  include Set.Make(struct type t = int let compare = compare end)

  let is_singleton (s:t) : int option =
    match choose_opt s with
    | None -> None
    | Some n -> if equal s (singleton n) then Some n else None
end


(* constraints on permutations are roughly abstracted as the sets of possible
values for each permuted element. *)
type constr = IntSet.t array * IntSet.t array

(* the constraint Top for permutations on {1,...,n} *)
let constr_top (n:int) : constr =
  let rec gen ac i = if i = n then ac else gen (IntSet.add i ac) (i+1) in
  Array.init n (fun _ -> gen IntSet.empty 0)

(* checks trivial unsatisfiability.
NB. If this function returns false, it does not mean that the constraint is
satisfiable. *)
let unsat (c:constr) : bool = Array.exists (IntSet.is_empty) c

(* a non-empty set of permutations is then represented as a constraint and its
minimal solution w.r.t. a fixed ordering (here the lexicographic ordering). *)
type solution = int array
type permutations = constr * solution


(* TODO. a function removing incompatible parts of contraints *)
(* NB. A subfunction should do one pass and return true or false if a
simplification was made. Then the global function would iterate it until
fixpoint. *)

représenter dans le type constr un truc qui permet d'inverser rapidement la permutation, ça permet de détecter des simplifications

let simplify_at_index (c:constr) (i:int) (v:int) : unit =
  Array.iteri (fun j s -> if j <> i then c.(j) <- IntSet.remove v c.(j)) c

let rec simplify_once (c:constr) (a:int) (b:int) : bool =
  a <= b &&
  match IntSet.is_singleton c.(a) with
  | None -> simplify_once c (a+1) b
  | Some n -> simplify_at_index c a n; true

let simplify (c:constr) : unit =
  while simplify_once c 0 (Array.length c-1) do () done


(* TODO. a function updating a constraint with an information of the form
pi(i) \in E *)
let update (p:permutations) (i:int) (iset:int list) : unit =
  ();
  simplify (fst p)