# Two-stage analytical pipeline (`analytical/`)

Predicts an SRR / CSRR design's resonance and effective-medium response in
MATLAB so that CST is only needed to confirm the final numbers.

```
geometry ──▶ Stage 1 (L, C, f0) ──▶ Stage 2a  slab  S11/S21 ─▶ NRW/Smith ─▶ εeff(f), μeff(f)
                                └──▶ Stage 2b  line-coupled  S21 notch
CST .s2p ───────────────────────────────────────────────────▶ NRW/Smith ─▶ εeff(f), μeff(f)   (overlay)
```

Entry point: `runAnalyticalPipeline(geom, params, opts)` — `geom` is the
`buildMetamaterial` output, `params` the GUI struct. The GUI calls it from the
**Two-Stage Analysis** panel; Stage 1 alone also drives the HUD.

Convention throughout: `exp(-i ω t)`. Passive media have `Im(ε) ≥ 0`,
`Im(μ) ≥ 0`, `Re(z) ≥ 0`, `Im(n) ≥ 0`.

---

## Stage 1 — equivalent circuit (`srrLcModel.m`)

Symbols (SI): `c` trace width, `d` edge-to-edge ring separation, `g` split-gap
width, `r_out`/`r_in` outer/inner radii of the whole inclusion,
`r0 = (r_out+r_in)/2`, `d_avg = r_out+r_in`, `ρ = (r_out−r_in)/(r_out+r_in)`,
`p0` mean-ring perimeter, `N` ring count, `ε_r`, `h` substrate.

**Inter-ring capacitance** — coplanar-strip line (`coplanarStripCpul.m`):

```
k  = d / (d + 2c),      k' = √(1 − k²)
C_pul = ε0 · ε_eff · K(k') / K(k)
```

`K(k')/K(k)` via Hilberg's closed form (`ellipticKratio.m`). `ε_eff` from a
partial-capacitance substrate filling factor, → `(ε_r+1)/2` as `h → ∞`.

```
C0  = (N−1) · p0 · C_pul          (coupled ring pairs)
C_gap = ε0 ε_eff (c·t_metal/g) + ε0 ε_eff (c + t_metal)
C_s = C0/4 + C_gap                (two half-rings in series)
```

**Loop inductance** — Mohan current-sheet form (`ringInductance.m`), used by
Bilotti/Toscano for SRR/MSRR:

```
L_s = (μ0 · d_avg · c1 / 2) · ( ln(c2/ρ) + c3 ρ + c4 ρ² )
   circular : c1..c4 = 1.00, 2.46, 0.00, 0.20
   square   : c1..c4 = 1.27, 2.07, 0.18, 0.13
```

Single equivalent loop (`n = 1`): an MSRR's miniaturisation is carried by the
`(N−1)` capacitance term, not an `n²` inductance (that is only for galvanically
connected spirals).

**Resonance**: `f0 = 1 / (2π √(L_s C_s))`.

**CSRR**: Babinet swap `L ↔ C` with `η_eff² = μ0 / (4 ε0 ε_eff)`. Ideal
Babinet leaves `f0` unchanged — the SRR/CSRR distinction is carried by Stage 2
(magnetic vs electric Lorentzian).

Shape: `params.type == 'ssrr'` → square, else circular. `params.splitGap`
feeds `g` (for `ssrr` it is `params.gapSSRR`).

---

## Stage 2a — effective medium + slab + retrieval

`effectiveMediumLorentz.m` — Lorentzian (Pendry / Marqués):

```
χ(ω) = −F ω² / (ω² − ω0² + i ω Γ),     Γ = ω0 / Q,   F = footprint / cell area
SRR : μ_eff = 1 + χ,             ε_eff = ε_r (1 + i tanδ)
CSRR: ε_eff = ε_r(1 + i tanδ)(1 + χ), μ_eff = 1
```

`slabSParameters.m` — Airy/Fresnel slab of thickness `d_slab` (default =
substrate thickness; override with `opts.dSlab`):

```
n = √(εμ),  z = √(μ/ε),  R = (z−1)/(z+1),  P = exp(i n k0 d)
S21 = (1−R²) P / (1 − R² P²)
S11 = R (1−P²) / (1 − R² P²)
```

`nrwRetrieval.m` — inverse (Smith 2002 / Chen 2004), branch rules
`Re(z) ≥ 0`, `|exp(i n k0 d)| ≤ 1`, phase `unwrap` from the low-frequency end:

```
z = √( ((1+S11)² − S21²) / ((1−S11)² − S21²) )
E = S21 / (1 − S11 (z−1)/(z+1))
n = ( unwrap(arg E) − i ln|E| ) / (k0 d)
ε = n/z,   μ = n z
```

Round-trips to `< 1e-6` (`tests/test_nrw_roundtrip.m`). The **same function**
runs on CST S-parameters read by `readTouchstone.m` (`.s1p/.s2p`, RI/MA/DB).

---

## Stage 2b — transmission-line-coupled (`lineLoadedSParameters.m`)

Baena-2005 topology, simplified to one lumped resonator on a matched line
(`abcd2s.m`):

- **CSRR** — shunt series `L-C` branch to ground → shorts the line at `f0`.
- **SRR**  — series parallel `L-C` tank in the line → blocks the line at `f0`.

Both give a transmission zero at `s1.f0`. Notch **placement** is meaningful;
notch **depth/Q** needs the geometry-specific line coupling (`opts.coupling`)
or CST.

---

## Limitations

- Quasi-static closed forms: expect `f0` within a factor ~1.5–2 of CST. Use the
  pipeline for band placement and relative trends; CST for final numbers.
- No continuous wire medium → bare-SRR `ε_eff ≈ ε_r` (not negative); the SRR
  supplies the Lorentzian `μ`. CSRR is the dual. Matches the current CST export.
- SSRR split position / asymmetry not modelled (single averaged `C_s`).
- Slab retrieval thickness is a modelling choice; retrieved `ε/μ` scale with it.
  Keep `opts.dSlab` consistent between the analytical run and the CST de-embed.

## References

- Baena et al., *IEEE T-MTT* 53(4), 2005.
- Bilotti, Toscano, Vegni et al., *IEEE T-MTT* 55(12) & *IEEE T-AP* 55(8), 2007.
- Marqués, Martín, Sorolla, *Metamaterials with Negative Parameters*, Wiley 2007.
- Smith, Schultz, Markoš, Soukoulis, *Phys. Rev. B* 65, 195104 (2002);
  Chen et al., *Phys. Rev. E* 70, 016608 (2004).
- Mohan et al., *IEEE JSSC* 34(10), 1999 (current-sheet inductance).
