Require Import Spec.Proc.
Require Import Spec.Hoare.

Require Import Helpers.RelationAlgebra.

Import RelationNotations.

Section Abstraction.
  Context (AState CState:Type).
  Context (abs: AState -> CState -> Prop).

  Definition absr : relation AState CState unit :=
    fun s cs _ => abs s cs.

  Definition refines T
             (p: relation CState CState T)
             (spec: relation AState AState T) :=
    absr;; p ---> v <- spec; absr;; pure v.

  (* define refinement as transforming an abstract specification to a concrete
  one (a program satisfying the abstract spec should satisfy the concrete spec
  after refinement-preserving compilation) *)
  Definition refine_spec
             A T R
             (spec: Specification A T R AState)
    : Specification (AState*A) T R CState :=
    fun '(s, a) cs =>
      {| pre := abs s cs /\
                (spec a s).(pre);
         post := fun cs' r =>
                   exists s', abs s' cs' /\
                         (spec a s).(post) s' r;
         recovered := fun cs' r =>
                        exists s', abs s' cs' /\
                              (spec a s).(recovered) s' r; |}.

  Section Dynamics.
    Context C_Op (c_sem: Dynamics C_Op CState).
    Notation c_proc := (proc C_Op).
    Notation c_exec := c_sem.(exec).
    Notation c_rexec := c_sem.(rexec).

    Definition crash_refines T R
               (p: c_proc T) (rec: c_proc R)
               (exec_spec: relation AState AState T)
               (rexec_spec: relation AState AState R) :=
      refines (c_exec p) exec_spec /\
      refines (c_rexec p rec) rexec_spec.
  End Dynamics.

End Abstraction.
