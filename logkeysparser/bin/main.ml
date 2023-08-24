open Printf
open Eio.Std
open Cmdliner

let read_file filename =
  let open Eio.File in
  let file = ref None in
  let content = ref "" in

  (* Open the file *)
  match Eio_main.run (openfile filename) with
  | Ok f -> file := Some f
  | Error e ->
      Printf.eprintf "Error opening file: %s\n" filename;
      exit 1;

      (* Read the content *)
      (match !file with
      | Some f -> (
          match Eio_main.run (read f) with
          | Ok c -> content := c
          | Error e ->
              Printf.eprintf "Error reading file: %s\n" filename;
              exit 1)
      | None -> ());

      (* Close the file *)
      (match !file with
      | Some f -> ignore (Eio_main.run (close f))
      | None -> ());

      !content

let count_keys content =
  let table = Hashtbl.create 255 in
  String.iter
    (fun ch ->
      let current_count =
        if Hashtbl.mem table ch then Hashtbl.find table ch else 0
      in
      Hashtbl.replace table ch (current_count + 1))
    content;
  table

let main filename =
  Luv.Loop.(run default) (fun () ->
      match Eio_main.run (read_file filename) with
      | Ok content ->
          let counts = count_keys content in
          Hashtbl.iter (fun key count -> printf "'%c' -> %d\n" key count) counts;
          `Ok ()
      | Error _ -> `Error (false, sprintf "Error reading file: %s" filename))
  |> ignore

let cmdline_term =
  let open Cmdliner in
  let doc =
    "Parse a logkeys output file and display the occurrence of each key."
  in
  let filename =
    Arg.(
      required
      & pos 0 (some string) None
      & info [] ~docv:"FILENAME" ~doc:"The path to the logkeys output file.")
  in
  Term.(const main $ filename)

let () =
  let open Cmdliner in
  let info =
    Term.info "logkeys_parser" ~version:"1.0" ~doc:"Logkeys output parser"
  in
  match Term.eval (cmdline_term, info) with `Error _ -> exit 1 | _ -> exit 0
