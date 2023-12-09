import Coxeter.Basic
import Coxeter.Bruhat
import Coxeter.Rpoly
import Coxeter.Length_reduced_word
import Coxeter.Wellfounded

import Mathlib.Data.Polynomial.Degree.Definitions
import Mathlib.Data.Polynomial.Reverse
import Mathlib.Data.Polynomial.Basic
import Mathlib.LinearAlgebra.FreeModule.Basic
import Mathlib.Data.Polynomial.Laurent
import Mathlib.Algebra.DirectSum.Basic

variable {G :(Type _)} [Group G] {S : (Set G)} [orderTwoGen S] [CoxeterSystem G S]
local notation :max "ℓ(" g ")" => (@length G  _ S _ g)
open Classical



def Hecke (G:Type _):= DirectSum G (fun _ => LaurentPolynomial ℤ)
--def Hecke (G:Type _):= Π₀ (i:G), (fun _ => LaurentPolynomial ℤ) i

noncomputable instance Hecke.AddCommMonoid : AddCommMonoid (Hecke G):= instAddCommMonoidDirectSum G _

noncomputable instance Hecke.Module : Module (LaurentPolynomial ℤ) (Hecke G):= DFinsupp.module

noncomputable instance Hecke.AddCommGroup : AddCommGroup (Hecke G) := Module.addCommMonoidToAddCommGroup (LaurentPolynomial ℤ)

noncomputable instance Hecke.Module.Free : Module.Free (LaurentPolynomial ℤ) (Hecke G):= Module.Free.directSum _ _

noncomputable instance Hecke.Sub : Sub (Hecke G) := DFinsupp.instSubDFinsuppToZeroToNegZeroClassToSubNegZeroMonoidToSubtractionMonoid
--Dfinsupp.funlike
instance Hecke.funLike : FunLike (Hecke G) G (fun _ => LaurentPolynomial ℤ):= instFunLikeDirectSum _ _

noncomputable instance LaurentPolynomial.CommSemiring : CommSemiring (LaurentPolynomial ℤ):=
AddMonoidAlgebra.commSemiring

noncomputable def TT : G → Hecke G:= fun w => DFinsupp.single w 1

instance TT.Basis : Basis G (LaurentPolynomial ℤ) (Hecke G) := by{
  --@Finsupp.basisSingleOne (LaurentPolynomial ℤ) G _
  sorry
}

#check finsum_eq_sum
#check Basis.sum_repr
-- ∀ h:Hecke G, h = ∑ᶠ w, (h w) * TT w
@[simp]
noncomputable def repr_of_Hecke_respect_TT (h:Hecke G):= Finsupp.total G (Hecke G) (LaurentPolynomial ℤ) (@TT G) (Basis.repr (@TT.Basis G) h)



lemma repr_apply (h:Hecke G):  @repr_of_Hecke_respect_TT G h = finsum fun w => (h w) • TT w :=by {
  simp
  rw [ Finsupp.total_apply]
  sorry
}

--Ts *Tw = Ts*Ts*Tu= (q-1)Ts*Tu+qTu=(q-1) Tw + qT(s*w) if s∈D_L w
noncomputable def q :=@LaurentPolynomial.T ℤ _ 1

local notation : max "q⁻¹" => @LaurentPolynomial.T ℤ _ (-1)

--DFinsupp.single w (q-1) + DFinsupp.single (s*w) q))
noncomputable def mulsw (s:S) (w:G)  : Hecke G :=
  if s.val ∈ D_L w then
  ((q-1) • TT w + q • TT (s*w))
  else TT (s*w)

--Ts* ∑ᶠ w, h (w) * TT w = ∑ᶠ h w * Ts * T w
noncomputable def muls (s:S) (h:Hecke G) : Hecke G:=
finsum (fun w:G =>  (h w) • (mulsw s w) )
--∑ᶠ (w :G), ((h w) • (mulsw s w):Hecke G)

noncomputable def mulws (w:G) (s:S) : Hecke G :=
  if s.val ∈ D_R w then
  ((q-1) • TT w + q • TT (w*s))
  else TT (w*s)

noncomputable def muls_right (h:Hecke G) (s:S)  : Hecke G:=
finsum (fun w:G =>  (h w) • (mulws w s) )

noncomputable def mulw.F (u :G) (F:(w:G) → llr w u → Hecke G → Hecke G) (v:Hecke G): Hecke G:=
if h:u =1 then v
  else(
    let s:= Classical.choice (nonemptyD_L u h)
    have :s.val ∈ S:= Set.mem_of_mem_of_subset s.2 (Set.inter_subset_right _ S)
    @muls G _ S _ ⟨s,this⟩ (F (s.val*u) (@llr_of_mem_D_L G _ S _ u s ) v)
  )

noncomputable def mulw :G → Hecke G → Hecke G := @WellFounded.fix G (fun _ => Hecke G → Hecke G) llr well_founded_llr mulw.F

lemma mulw_zero : ∀ w:G ,mulw w 0 = 0:= by{
  intro w
  rw [mulw,WellFounded.fix,WellFounded.fixF]
  sorry

}

noncomputable def HeckeMul (h1:Hecke G) (h2:Hecke G) : Hecke G :=
finsum (fun w:G => (h1 w) • mulw w h2)
--

noncomputable instance Hecke.Mul : Mul (Hecke G) where
mul:=HeckeMul


lemma finsupp_mul_of_directsum  (a c: Hecke G): Function.support (fun w ↦ ↑(a w) • mulw w c) ⊆  {i | ↑(a i) ≠ 0} := by {
  simp only [ne_eq, Function.support_subset_iff, Set.mem_setOf_eq]
  intro x
  apply Function.mt
  intro h
  rw [h]
  simp
}

local notation : max "End_ε" => Module.End (LaurentPolynomial ℤ) (Hecke G)

noncomputable instance End_ε.Algebra : Algebra (LaurentPolynomial ℤ) End_ε :=
Module.End.instAlgebra (LaurentPolynomial ℤ) (LaurentPolynomial ℤ) (Hecke G)
#check End_ε

noncomputable def opl (s:S) : (Hecke G)→ (Hecke G) := fun h:(Hecke G) => muls s h

--noncomputable def opl1 (w:G) := DirectSum.toModule  (LaurentPolynomial ℤ) G (Hecke G) (fun w:G => (fun (Hecke G) w => mulw w ))

noncomputable def opr (s:S) : (Hecke G )→ (Hecke G) := fun h:(Hecke G) => muls_right h s

noncomputable def opl' (s:S): End_ε :={
  toFun:=opl s
  map_add':=sorry
  map_smul':=by{
    intro r x
    simp[opl,muls]
    rw[smul_finsum' r _]
    apply finsum_congr
    intro g
    rw [DirectSum.smul_apply,smul_smul]
    simp only [smul_eq_mul]
    sorry
  }
}

def generator_set := (@opl' G _ S _)'' Set.univ

noncomputable def subalg := Algebra.adjoin (LaurentPolynomial ℤ) (@generator_set G _ S _)

@[simp]
noncomputable def alg_hom_aux : @subalg G _ S _ → (Hecke G) := fun f => f.1 (TT 1)
--compiler IR check failed at 'alg_hom_aux._rarg', error: unknown declaration 'TT'




#check alg_hom_aux
noncomputable instance subalg.AddCommMonoid : AddCommMonoid (@subalg G _ S _) :=sorry

noncomputable instance subalg.Algebra :Algebra (LaurentPolynomial ℤ) (@subalg G _ S _) := Subalgebra.algebra (subalg)

noncomputable instance subalg.Module : Module (LaurentPolynomial ℤ) (@subalg G _ S _) :=sorry
--@Algebra.toModule (LaurentPolynomial ℤ) (@subalg G _ S _) _ _ _


--prove alg_hom is module homo
noncomputable instance alg_hom_aux.IsLinearMap : IsLinearMap (LaurentPolynomial ℤ) (@alg_hom_aux G _ S _) where
map_add:=by{
  intro x y
  simp [alg_hom_aux]
  rw [Subalgebra.coe_add subalg x y]
  exact @LinearMap.add_apply (LaurentPolynomial ℤ) (LaurentPolynomial ℤ) (Hecke G) (Hecke G) _ _ _ _ _ _ (_) x.1 y.1 (TT 1)
}
map_smul:=by {
  intro c x
  simp [alg_hom_aux]
  rw [@Subalgebra.coe_smul (LaurentPolynomial ℤ) (LaurentPolynomial ℤ) End_ε _ _ _ subalg _ _ _ _ c x]
}

lemma alg_hom_injective_aux (f:@subalg G _ S _) (h: alg_hom_aux f = 0) : f = 0:= by {
  simp at h
}
#check Function.bijective_iff_has_inverse

lemma alg_hom_aux_bijective : Function.Bijective (@alg_hom_aux G _ S _) := by {
  constructor
  {
    simp[Function.Injective]
    intro f1 x f2 y h
    sorry
  }
  {
    simp[Function.Surjective]
    sorry
  }
}


--synthesized type class instance is not definitionally equal to expression inferred by typing rules, synthesized
--   Distrib.toAdd
-- inferred
--   AddSemigroup.toAdd
noncomputable instance alg_hom_aux.LinearEquiv : LinearEquiv (@RingHom.id (LaurentPolynomial ℤ) _)  (@subalg G _ S _) (Hecke G) :=by{
  sorry
}


lemma HeckeMul.mul_zero : ∀ (a : Hecke G), HeckeMul a 0 = 0 := by{
  intro a
  simp[HeckeMul]
  apply finsum_eq_zero_of_forall_eq_zero
  intro w
  rw [mulw_zero]
  simp
}

lemma HeckeMul.mul_zero1 : ∀ (a : Hecke G),  a * 0 = 0 := by{
  intro a
  apply finsum_eq_zero_of_forall_eq_zero
  intro w
  rw [mulw_zero]
  simp
}

lemma HeckeMul.zero_mul : ∀ (a : Hecke G),  0 * a = 0 := by{
  intro a
  apply finsum_eq_zero_of_forall_eq_zero
  intro w
  rw [DirectSum.zero_apply]
  simp
}

lemma Hecke.one_mul : ∀ (a : Hecke G), TT 1 * a = a := by{
  intro a
  sorry
}

#check DirectSum.add_apply




lemma Hecke.right_distrib : ∀ (a b c : Hecke G),  HeckeMul (a + b)  c =  HeckeMul a c + HeckeMul b c :=by{
  intro a b c
  simp[HeckeMul]
  rw [←finsum_add_distrib]--,←@Module.add_smul (LaurentPolynomial ℤ) (Hecke G) _ _ _ ]
  congr
  ext
  rw [←@Module.add_smul (LaurentPolynomial ℤ) (Hecke G)]
  congr
  exact Set.Finite.subset (DFinsupp.finite_support a) (finsupp_mul_of_directsum a c)
  exact Set.Finite.subset (DFinsupp.finite_support b) (finsupp_mul_of_directsum b c)
}



-- To show (a * (TT s * TT sw)) * c = a * ( (TT s * TT sw) * c )

lemma Hecke.assoc : ∀ (a b c : Hecke G), a * b * c = a * (b * c) := by {
  intro a b c
  apply (DirectSum.ext_iff (LaurentPolynomial ℤ)).2
  intro i
  rw [DirectSum.component,DFinsupp.lapply]
  simp
  sorry
}


noncomputable def Hecke_inv_s (s:S) := q⁻¹ • (TT s.val) - (1-q⁻¹) • (TT 1)

noncomputable def Hecke_invG.F (u:G) (F: (w:G) → llr w u → Hecke G): Hecke G:= if h:u=1 then TT 1
else (
   let s:= Classical.choice (nonemptyD_L u h)
   HeckeMul (F (s*u) (@llr_of_mem_D_L G _ S _ u s)) (Hecke_inv_s s)
  )


noncomputable def Hecke_invG : G → Hecke G := @WellFounded.fix G (fun _ => Hecke G) llr well_founded_llr Hecke_invG.F



noncomputable instance Hecke.Semiring : Semiring (Hecke G) where
  add:= AddCommMonoid.add
  add_assoc:= AddCommMonoid.add_assoc
  zero:=0
  zero_add:=AddCommMonoid.zero_add
  add_zero:=AddCommMonoid.add_zero
  add_comm:=AddCommMonoid.add_comm
  nsmul:= AddCommMonoid.nsmul
  nsmul_zero:=AddCommMonoid.nsmul_zero
  nsmul_succ:=AddCommMonoid.nsmul_succ
  mul:=HeckeMul
  mul_zero:= HeckeMul.mul_zero
  zero_mul:= HeckeMul.zero_mul
  left_distrib:=by {
    intro a b c
    sorry
    --rw [DirectSum.add_apply]
  }
  right_distrib:= Hecke.right_distrib
  mul_assoc:=sorry
  one:=TT 1
  one_mul:=sorry
  mul_one:=sorry


noncomputable instance Hecke.algebra : Algebra (LaurentPolynomial ℤ) (Hecke G):=
Algebra.ofModule (sorry) (sorry)
--∀ (r : LaurentPolynomial ℤ) (x y : Hecke G), r • x * y = r • (x * y)
-- r • x * y = r • ∑ᶠ w , (x w) • TT w  *  y = ∑ᶠ w, r •((x w) • TT w)  * y = ∑ᶠ w, ( (r * (x w)) • TT w) * y
--r • (x * y) = r • ∑ᶠ w, (x w) • (mulw w y) = ∑ᶠ w, ( (r * (x w)) • (TT w * y))

#check Basis.repr_sum_self
#check Finsupp.basisSingleOne
#check Finsupp.total

#check Basis.total_repr

lemma Hecke_left_invG (u:G): (Hecke_invG u) * TT u  = 1 := by{sorry}

lemma Hecke_right_invG (u:G): TT u * (Hecke_invG u) = 1 :=by{
  rw [Hecke_invG]
  sorry
  }



def length_le_set (w:G) := {x:G| ℓ(x) ≤ ℓ(w)}

variable {R:@Rpoly G _ S _}

theorem Hecke_inverseG (w:G) : (Hecke_invG w⁻¹) = ((-1)^ℓ(w) * (q⁻¹)^ℓ(w)) • finsum (fun (x: length_le_set w) => (Polynomial.toLaurent ((-1)^ℓ(x)*(R.R x w))) • TT x.val):=sorry



section involution

noncomputable def iot_A : LaurentPolynomial ℤ →  LaurentPolynomial ℤ := LaurentPolynomial.invert

noncomputable def iot_T : G → Hecke G := fun w => Hecke_invG w

noncomputable def iot :Hecke G → Hecke G := fun h => finsum (fun x:G =>iot_A (h x) • TT x)

lemma iot_mul (x y :Hecke G) : iot (x*y) = iot x * iot y:= sorry

noncomputable instance iot.AlgHom : AlgHom (LaurentPolynomial ℤ) (Hecke G) (Hecke G) where
toFun:=iot
map_one':=sorry
map_mul':=iot_mul
map_zero':=sorry
map_add':=sorry
commutes':=sorry


end involution
