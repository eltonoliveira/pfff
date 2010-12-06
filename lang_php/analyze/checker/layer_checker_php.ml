(* Yoann Padioleau
 *
 * Copyright (C) 2010 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)

open Common

open Ast_php

module E = Error_php
open Error_php

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*
 * Structure similar to other layer generator.
 *)

(*****************************************************************************)
(* Types *)
(*****************************************************************************)

(* ugly: there is some duplication with Error_php.error
 * coupling: with the Error_php.error type 
 *)
let properties = [

  "eUseOfUndefinedVariable", "red" ;
  "eUnusedVariable-Local", "purple";
  "eDeadStatement", "salmon";

  (* ugly: coupling with scope_code.ml *)
  "eUnusedVariable-Global", "green";
  "eUnusedVariable-Local", "green";
  "eUnusedVariable-Param", "green";
  "eUnusedVariable-Static", "green";
  "eUnusedVariable-Class", "green";
  "eUnusedVariable-LocalExn", "green";
  "eUnusedVariable-LocalIterator", "green";
  "eUnusedVariable-ListBinded", "green";
  "eUnusedVariable-NoScope", "green";

  (* ugly: coupling with entity_php.ml *)
  "eUndefinedEntity-function",    "blue";
  "eUndefinedEntity-class",    "blue";
  "eUndefinedEntity-method",    "blue";

  "eMultiDefinedEntity-function", "blue2";
  "eMultiDefinedEntity-class", "blue2";
  "eMultiDefinedEntity-method", "blue2";

  "eTooManyArguments", "blue3";
  "eNotEnoughArguments", "blue4";

  (* ugly: coupling with error_code.ml *)
  "eWrongKeywordArgument-Bad", "yellow";
  "eWrongKeywordArgument-ReallyBad", "yellow";
  "eWrongKeywordArgument-ReallyReallyBad", "yellow";


  "eUseOfUndefinedMember", "cyan";
  "eUglyGlobalDynamic", "cyan";
  "eWeirdForeachNoIteratorVar", "cyan";

  "eDeadBreak", "tan1";
  "eDeadReturn", "tan2";
  "eCfgError", "tan";

]

(*****************************************************************************)
(* Code *)
(*****************************************************************************)

let info_of_error_and_kind err =

  let kind = 
    match err with
  | UndefinedEntity (kind, _) -> 
      "eUndefinedEntity-" ^ Entity_php.string_of_id_kind kind
  | MultiDefinedEntity (kind, _, _) ->
      "eMultiDefinedEntity-" ^ Entity_php.string_of_id_kind kind

  | TooManyArguments _ ->"eTooManyArguments"
  | NotEnoughArguments _ ->"eNotEnoughArguments"

  | WrongKeywordArgument (_, _, severity) ->
      "eWrongKeywordArgument-" ^ (Error_php.string_of_severity severity)

  | UseOfUndefinedVariable _ -> 
      "eUseOfUndefinedVariable"
  | UnusedVariable (_, scope) ->
      "eUnusedVariable-" ^ Scope_code.string_of_scope scope

  | UseOfUndefinedMember _ ->"eUseOfUndefinedMember"
  | UglyGlobalDynamic _ -> "eUglyGlobalDynamic"
  | WeirdForeachNoIteratorVar _ -> "eWeirdForeachNoIteratorVar"

  | CfgError (Controlflow_build_php.DeadCode (info, node_kind)) ->
      (match node_kind with
      | Controlflow_php.Break -> "eDeadBreak"
      | Controlflow_php.Return -> "eDeadReturn"
      | _ -> "eDeadStatement"
      )
  | CfgError ( _) ->
      "eCfgError"
  | CfgPilError ( _) ->
      "eCfgError"

  in
  E.info_of_error err +> Common.fmap (fun info ->
    info, kind
  )

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)

let gen_layer ~root ~output errors = 

  let infos = errors +> Common.map_filter info_of_error_and_kind in

  let layer = Layer_code.simple_layer_of_parse_infos ~root infos properties in
  pr2 ("generating layer in " ^ output);
  Layer_code.save_layer layer output;
  ()
