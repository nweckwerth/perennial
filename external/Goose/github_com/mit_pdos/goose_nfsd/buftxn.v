(* autogenerated from github.com/mit-pdos/goose-nfsd/buftxn *)
From Perennial.goose_lang Require Import prelude.
From Perennial.goose_lang Require Import ffi.disk_prelude.

From Goose Require github_com.mit_pdos.goose_nfsd.addr.
From Goose Require github_com.mit_pdos.goose_nfsd.buf.
From Goose Require github_com.mit_pdos.goose_nfsd.txn.
From Goose Require github_com.mit_pdos.goose_nfsd.util.

Module BufTxn.
  Definition S := struct.decl [
    "txn" :: struct.ptrT txn.Txn.S;
    "bufs" :: struct.ptrT buf.BufMap.S;
    "Id" :: uint64T
  ].
End BufTxn.

Definition Begin: val :=
  rec: "Begin" "txn" :=
    let: "trans" := struct.new BufTxn.S [
      "txn" ::= "txn";
      "bufs" ::= buf.MkBufMap #();
      "Id" ::= txn.Txn__GetTransId "txn"
    ] in
    util.DPrintf #1 (#(str"Begin: %v
    ")) (struct.loadF BufTxn.S "Id" "trans");;
    "trans".

Definition BufTxn__ReadBuf: val :=
  rec: "BufTxn__ReadBuf" "buftxn" "addr" :=
    let: "b" := buf.BufMap__Lookup (struct.loadF BufTxn.S "bufs" "buftxn") "addr" in
    (if: ("b" = slice.nil)
    then
      let: "buf" := txn.Txn__Load (struct.loadF BufTxn.S "txn" "buftxn") "addr" in
      buf.BufMap__Insert (struct.loadF BufTxn.S "bufs" "buftxn") "buf";;
      buf.BufMap__Lookup (struct.loadF BufTxn.S "bufs" "buftxn") "addr"
    else "b").

(* Caller overwrites addr without reading it *)
Definition BufTxn__OverWrite: val :=
  rec: "BufTxn__OverWrite" "buftxn" "addr" "data" :=
    let: "b" := ref (buf.BufMap__Lookup (struct.loadF BufTxn.S "bufs" "buftxn") "addr") in
    (if: (![refT (struct.t buf.Buf.S)] "b" = slice.nil)
    then
      "b" <-[refT (struct.t buf.Buf.S)] buf.MkBuf "addr" "data";;
      buf.BufMap__Insert (struct.loadF BufTxn.S "bufs" "buftxn") (![refT (struct.t buf.Buf.S)] "b")
    else
      (if: slice.len "data" * #8 ≠ struct.get addr.Addr.S "Sz" (struct.loadF buf.Buf.S "Addr" (![refT (struct.t buf.Buf.S)] "b"))
      then
        Panic "overwrite";;
        #()
      else #());;
      struct.storeF buf.Buf.S "Blk" (![refT (struct.t buf.Buf.S)] "b") "data");;
    buf.Buf__SetDirty (![refT (struct.t buf.Buf.S)] "b").

Definition BufTxn__NDirty: val :=
  rec: "BufTxn__NDirty" "buftxn" :=
    buf.BufMap__Ndirty (struct.loadF BufTxn.S "bufs" "buftxn").

Definition BufTxn__LogSz: val :=
  rec: "BufTxn__LogSz" "buftxn" :=
    txn.Txn__LogSz (struct.loadF BufTxn.S "txn" "buftxn").

Definition BufTxn__LogSzBytes: val :=
  rec: "BufTxn__LogSzBytes" "buftxn" :=
    txn.Txn__LogSz (struct.loadF BufTxn.S "txn" "buftxn") * disk.BlockSize.

(* Commit dirty bufs of this transaction *)
Definition BufTxn__CommitWait: val :=
  rec: "BufTxn__CommitWait" "buftxn" "wait" :=
    util.DPrintf #1 (#(str"Commit %d w %v
    ")) (struct.loadF BufTxn.S "Id" "buftxn") "wait";;
    let: "ok" := txn.Txn__CommitWait (struct.loadF BufTxn.S "txn" "buftxn") (buf.BufMap__DirtyBufs (struct.loadF BufTxn.S "bufs" "buftxn")) "wait" (struct.loadF BufTxn.S "Id" "buftxn") in
    "ok".

Definition BufTxn__Flush: val :=
  rec: "BufTxn__Flush" "buftxn" :=
    let: "ok" := txn.Txn__Flush (struct.loadF BufTxn.S "txn" "buftxn") in
    "ok".
