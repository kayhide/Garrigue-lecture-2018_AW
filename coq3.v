Section Socrates.

Variable A : Set.
Variables human mortal : A -> Prop.
Variable socrates : A.

Hypothesis hm : forall x, human x -> mortal x.
Hypothesis hs : human socrates.

Theorem ms : mortal socrates.
Proof.
  apply (hm socrates).
  assumption.
Qed.
Print ms.
(* ms = hm socrates hs *)
(* : mortal socrates   *)
End Socrates.

(*
�� �� �� �̊Ԃ� De Morgan �̖@�����Ȃ肽�D�O��Ɠ��l�ɁC�� �𓱏o���悤�Ƃ����Ƃ��� classic
���g��Ȃ���΂Ȃ�Ȃ��D
*)

Section Laws.

Variables (A:Set) (P Q:A->Prop).

Lemma DeMorgan2 : (~ exists x, P x) -> forall x, ~ P x.
Proof.
  intros N x Px.
  apply N.
  exists x.
  apply Px.
Qed.

Theorem exists_or : (exists x, P x \/ Q x) -> (exists x, P x) \/ (exists x, Q x).
Proof.
  intros H.
  destruct H as [x [p|q]]. (* ���܂Ŕj�� *)
  left. exists x. assumption.
  right. exists x. assumption.
Qed.

Hypothesis classic : forall P, ~~P -> P.

Lemma DeMorgan2' : (~ forall x, P x) -> exists x, ~ P x.
Proof.
  intros np.
  apply classic.
  intros nen.
  apply np; clear np.
  intros a; apply classic.
  intros np.
  apply nen.
  exists a; assumption.
Qed.

(* End Negation. *)
End Laws.

(* ���K��� 1.1 �ȉ��̒藝�� Coq �ŏؖ�����D*)
Section Coq3.

Variable A : Set.
Variable R : A -> A -> Prop.
Variables P Q : A -> Prop.

Theorem exists_postpone :
(exists x, forall y, R x y) -> (forall y, exists x, R x y).
Proof.
  intros H y.
  destruct H.
  exists x.
  apply H.
Qed.

Theorem or_exists : (exists x, P x) \/ (exists x, Q x) -> exists x, P x \/ Q x.
Proof.
  intros [p|q].
  - destruct p.
    exists x.
    left; assumption.
  - destruct q.
    exists x.
    right; assumption.
Qed.

Hypothesis classic : forall P, ~~P -> P.

Theorem remove_c : forall a,
(forall x y, Q x -> Q y) ->
(forall c, ((exists x, P x) -> P c) -> Q c) -> Q a.
Proof.
  intros a Qxy PQc.
  apply classic.
  intros nQa.
  apply nQa.
  apply PQc.
  intros [x px].
  elimtype False.
  apply nQa.
  apply Qxy with (x := x).
  apply PQc.
  intros.
  assumption.
Qed.

(* (forall c, ((exists x, P x) -> P c) -> False) -> (forall c, (exists x, Px) /\ forall c. not P c) *)
End Coq3.


(* 2 �A�[�@ *)

(*Coq �Ńf�[�^�^���`����ƁC�����I�ɋA�[�@�̌��������������D*)
Module MyNat.
Inductive nat : Set := O : nat | S : nat -> nat.
(* nat is defined
   nat_rect is defined
   nat_ind is defined
   nat_rec is defined *)

(* Check nat_ind.
   nat_ind
   : forall P : nat -> Prop, 
  P O ->
  (forall n : nat, P n -> P (S n)) ->
  forall n : nat, P n
�����ƕ�����₷�������ƁCnat ind �̌^�� ��P, P 0 �� (��n, P n �� P (S n)) �� (��n, P n) ��
����D���� P �� 0 �łȂ肽���C�C�ӂ� n �ɂ��� P �� n �łȂ肽�Ă΁Cn + 1 �ł����Ȃ肽��
�Ƃ��ؖ��ł���΁C�C�ӂ� n �ɂ��� P ���Ȃ肽�D
���Ȃ݂ɁCnat rec �̒�`������ƁC *)
Check nat_rec.
(* nat_rec
   : forall P : nat -> Set,
   P O ->
   (forall n : nat, P n -> P (S n)) ->
   forall n : nat, P n
P �� Prop �ł͂Ȃ� Set ��Ԃ����ƈȊO�C�S�������ł���D
�{���̒�`������ƁC
*)
Print nat_rect.
(* nat_rect =
   fun (P : nat -> Type) (f : P O) (f0 : forall n : nat, P n -> P (S n)) => 
fix F (n : nat) : P n :=
match n as n0 return (P n0) with
| O => f
| S n0 => f0 n0 (F n0)
end

���͕��ʂ̍ċA�֐����l�Cfix �� match ���g���Ē�`����Ă���D*)
End MyNat. (* ���ʂ� nat �ɖ߂� *)

Definition plus' : nat -> nat -> nat.
  intros m n.
  induction m.
  exact n. (* n ��Ԃ� *)
  exact (S IHm). (* �A�[�@�ɂ���ē���ꂽ IHm �̌�҂�Ԃ� *)
Defined. (* �v�Z���\�ɂ��邽�߂� Defined �ŕ��� *)

Print plus'.
(* fun m n : nat => nat_rec (fun _ : nat => nat) n (fun _ IHm : nat => S IHm) m *)

Eval compute in plus' 2 3.
(* = 5 *)

Lemma plus_assoc : forall m n p, m + (n + p) = (m + n) + p.
Proof.
  intros m n p.
  induction m.
  simpl. (* �v�Z���� *)
  SearchPattern (?X = ?X). (* ���˗��𒲂ׂ� *)
   (* eq_refl: forall (A : Type) (x : A), x = x  *)
  apply eq_refl.
  simpl.
  rewrite IHm. (* ������s�� *)
  reflexivity. (* apply eq_refl �Ɠ��� *)
Qed.

(* ���K��� 2.1 �ȉ��̒藝���ؖ�����D*)
Theorem plus_0 : forall n, n + 0 = n.
Proof.
  induction n.
  - reflexivity.
  - simpl.
    rewrite IHn.
    reflexivity.
Qed.

Theorem plus_m_Sn : forall m n, m + (S n) = S (m + n).
Proof.
  intros m n.
  induction m.
  - reflexivity.
  - simpl.
    rewrite IHm.
    reflexivity.
Qed.

Theorem plus_comm : forall m n, m + n = n + m.
Proof.
  intros m n.
  induction m.
  - simpl.
    symmetry.
    apply plus_0.
  - simpl.
    rewrite IHm.
    symmetry.
    apply plus_m_Sn.
Qed.

Theorem plus_distr : forall m n p, (m + n) * p = m * p + n * p.
Proof.
  intros m n.
  induction m.
  - reflexivity.
  - simpl.
    intros p.
    rewrite IHm.
    apply plus_assoc.
Qed.

Theorem mult_assoc : forall m n p, m * (n * p) = (m * n) * p.
Proof.
  intros m n p.
  induction m.
  - reflexivity.
  - simpl.
    rewrite IHm.
    symmetry.
    apply plus_distr.
Qed.
