(*
 * Copyright (c) 2015 David Sheets <sheets@alum.mit.edu>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

type t = string list

let default_template = Filename.concat "default" ""

let global = [
  "page.xml";
  "nav.xml";
]

let index : t = global @ [
  "doc.xml";
  "index.xml";
  (*"publish.xml";*)
]

let interface : t = global @ [
  "interface.xml";
  "type.xml";
  "doc.xml";
  "module.xml";
  (*"publish.xml";*)
]

let ns = function "t" -> Some Blueprint.xmlns | _ -> None

(* TODO: proper error handling *)
let load_file file =
  try Unix.handle_unix_error (Blueprint_unix.of_file ~ns) file
  with
  | Blueprint.Error err ->
    Printf.eprintf "Template error:\n%s\n%!" (Blueprint.error_message err);
    exit 1
  | Xmlm.Error ((line,col),err) ->
    Printf.eprintf "XML error at line %d column %d:\n%s\n%!"
      line col (Xmlm.error_message err);
    exit 1

let load share spec =
  let dir = Filename.(concat (concat share "templates") default_template) in
  List.fold_left (fun template name ->
    let t = load_file (dir ^ name) in
    Blueprint.Scope.overlay t template
  ) (Blueprint.Tree.empty ()) spec
