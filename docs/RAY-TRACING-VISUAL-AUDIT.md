# Ray-tracing visual investigation

September 13 follow-up: the reported scene was **Training**. The PC shadow
dispatch had a gameplay/menu-preview flow gate, so Training never used DXR.
Removed that gate: all model-bearing flows can use tracing. The native EX
viewer/continue model now joins the caster scene before dispatch too.
Ground receivers remain conditional on the source shadow plane.

Rebuilt `build/current/starfox_pc.exe`. New resident-versus-readback capture
assertion passes byte-for-byte for Original/EX Corneria, Training-map geometry,
and the Original title. Training capture has 1,727 shaded ground pixels and
1,505 model pixels; title has 8,633 model pixels and no invented ground.
Proof: `tmp/shadow-training-enabled/bb2dead5ee2d4cf7b870daedc7c82f6d`
and `tmp/shadow-title-enabled/8329c6408ca24479ab94114a58a28a52`.
These captures do not constitute visual acceptance of every scene.

Follow-up EX Continue/model-viewer capture also passes normal resident versus
readback byte equality: 2,004 shaded model pixels, zero ground pixels.
Inspected `tmp/shadow-continue-enabled/c700971682e24428a4f762bdfb7d2b08/resident.bmp`.
Actual F1 open/resume/reopen events still pass for EX after this dispatch change.

September 13 current-build recheck: the tilted pillar fixture still differs at
967 mask pixels (maximum 160), or 966 / maximum 40 with float-quantized geometry.
CPU/GPU geometry and CPU/GPU composition captures are byte-identical; the
displayed-grass assertion passes. Inspected the DXR capture: diagonal pillar
and ship ground shadows are present. This narrows the remaining difference to
tracing/precision, not either presentation path; it does not resolve that
difference. Proof: `tmp/shadow-current-pillar-audit/476eb581321d4144991f89981b580450`.

September 12: user reports DXR looks worse than the former Enhanced Shadows.
Reported missing pillar/angled ground shadows fixed locally after the user
identified the Level 1-1 pillars. Headset/user acceptance remains outstanding.

## Confirmed cause and fix

Scenery classification depended on model/world effects, bloom or smoothing
being enabled. With those off, ray tracing generated a correct ground mask,
but the grass retained protected 2D/HUD tags and rejected the mask. Background
classification is now independent of effect settings. No light angle change
was necessary: left/behind illumination again casts diagonal ground shadows.

Level 1-1, tick 300, six frames, 2x: the pre-fix mask had 8,902 ground-shadow
pixels while a pillar floor sample remained unchanged. After the fix, the
sample matches RGB * (255 - mask) / 255; an automated assertion now checks
displayed grass rather than merely counting mask pixels. All other optional
visual effects are explicitly disabled in this regression. CPU/GPU composition
captures are byte-identical. Ray tracing off/unavailable preserves native
shadows, and the removed Enhanced Shadows override remains inactive.

Visually inspected proof: tmp/shadow-pillars-fixed/ddf451c3c1bc4309bd25bc745ca5479c/dxr.bmp.
Fresh regression: tmp/shadow-pillars-regression/bcd8941ad00e407a9004b97bd704e9cc.

Separate remaining detail: this tilted pillar fixture has 967 CPU/DXR mask
differences (max 160), predominantly on pillar faces. This is not the cause of
the missing ground shadows, which affected both backends' composition. It
still needs investigation; the earlier flat-camera equality is not universal.

Follow-up precision isolation: the same CPU algorithm supplied with DXR's
float-quantized vertices differs at 966 pixels, maximum 40 rather than 160.
Thus geometry quantization explains the worst outlier, but not all residual
sample differences. This does not prove a receiver-bias fix; ray arithmetic
and edge/sample classification remain to investigate. The added comparison is
test-only, executes on the last requested frame and does not alter normal
rendering. Fresh ground-composition assertion still passes. Evidence:
tmp/shadow-pillar-precision/f8d08fb0817c4567b1c1fa96e1fcf08a/reference.log.

## Earlier evidence (before the pillar-specific reproduction)

- v0.0.6 and current runtime use the same world light vector (-1,-1,-1),
  transformed into camera space. Old CPU and current DXR use the same 0.015
  angular spread, eight samples, depth-dependent bias and maximum darkening 160.
- Fresh hardware diagnostic on RTX 5070 Ti: CPU/DXR masks identical at 1x/2x;
  one pixel out of 1,433,600 differs by 20 at 4x. Geometry/light changes,
  receiver tests, packing and resource reuse pass.
- Added test-only STARFOX_TEST_SHADOW_REFERENCE and check_ray_tracing.ps1
  -CompareCpu to compare identical live geometry/camera/light. This does not
  restore a public CPU shadow setting or change release visuals.
- Corneria, Original, GPU, 16:9, 2x, tick-1000 preroll and six presentation
  frames: zero differences across 358,400 mask pixels; final CPU-reference/DXR
  BMPs byte-identical. DXR capture visually inspected. Proof directory:
  tmp/shadow-visual-investigation/8e3e4bf259f2467e98505d9f10e3b1da.

This rules out a backend light-angle or mask mismatch for this fixture only.
An additional `-CompareGeometry` diagnostic selects CPU-generated geometry
with DXR still enabled, while retaining the shared presentation path. In the
same Corneria fixture, the complete CPU/GPU geometry BMPs are also byte-identical.
Evidence: tmp/shadow-geometry-investigation/0d8cd5c34ab44976b063f36c24d80516.
The historical caster audit found the same face eligibility, triangulation and
destruction offset; the newer shadow-only entry skips rasterization, not casters.
This does not establish equality for animated/rotated or other stage geometry.
The independent Level 3 Corneria fixture (LEVEL3_1, same tick/scale settings)
also has zero mask differences and byte-identical CPU-reference/DXR and
CPU/GPU-geometry presentations. Proof:
tmp/shadow-corneria3-audit/b763cc3d51974e68abd6d467889d25e9.
The diagnostic now accepts Level, PrerollTicks and RenderScale parameters so
reported scenes can be reproduced without editing its environment setup.
It does not compare the entire old release's geometry/presentation pipeline,
nor establish which stage/settings caused the user's visual regression. Next:
compare historical caster/presentation behavior and broader live scenes before
changing lighting parameters arbitrarily.
