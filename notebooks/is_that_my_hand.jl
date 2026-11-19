### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 5a0d31cf-9c88-49ed-8437-d6a204b61541
html"""
<div style="background: linear-gradient(135deg, #1d1446 0%, #4b2a8a 55%, #c2569b 100%);
            border-radius: 14px; padding: 36px 32px; color: white;">
  <div style="font-size: 13px; letter-spacing: 3px; opacity: 0.85;">18.C25 · FALL 2026 · LEXCEA KING &amp; YUSEF HOSEIN</div>
  <div style="font-size: 44px; font-weight: 800; margin: 8px 0;">✋ Is That My Hand?</div>
  <div style="font-size: 20px; opacity: 0.92;">Bayesian causal inference, and how the brain decides what happened to the body</div>
</div>
"""

# ╔═╡ 140c9ee7-5c22-47d9-9b44-e785026de1d8
begin
    using PlutoUI, Plots, Distributions, Random, Statistics
    default(legendfontsize=9, titlefontsize=11, guidefontsize=10)
    TableOfContents(title="Is that my hand?", depth=2)
end

# ╔═╡ c02bcb93-428d-42e3-8c08-566364e98b72
html"""
<h2>Roadmap</h2>
<div style="display:grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 8px;">
  <div style="border-left:6px solid #c2569b; background:#fbeef5; border-radius:0; padding:12px 14px;">
    <div style="font-size:12px; letter-spacing:2px; color:#8f2f6a; font-weight:700;">PART 1–3 · LEXCEA</div>
    <div style="font-size:17px; font-weight:700; margin:4px 0; color:#222;">🤞 Your body is a guess</div>
    <div style="font-size:14px; color:#444;">A finger illusion, the body's senses, and the rubber hand illusion</div>
  </div>
  <div style="border-left:6px solid #4b2a8a; background:#f1ecfa; border-radius:0; padding:12px 14px;">
    <div style="font-size:12px; letter-spacing:2px; color:#4b2a8a; font-weight:700;">PART 4 · YUSEF</div>
    <div style="font-size:17px; font-weight:700; margin:4px 0; color:#222;">⚖️ Combining two senses</div>
    <div style="font-size:14px; color:#444;">Precision weighting: trust the sharper sense more</div>
  </div>
  <div style="border-left:6px solid #2a7fa8; background:#ebf4fa; border-radius:0; padding:12px 14px;">
    <div style="font-size:12px; letter-spacing:2px; color:#1f5f7f; font-weight:700;">PART 5 · YUSEF</div>
    <div style="font-size:17px; font-weight:700; margin:4px 0; color:#222;">🔀 Should I combine at all?</div>
    <div style="font-size:14px; color:#444;">One cause or two? Bayes' rule over explanations</div>
  </div>
  <div style="border-left:6px solid #d9772b; background:#fdf3ec; border-radius:0; padding:12px 14px;">
    <div style="font-size:12px; letter-spacing:2px; color:#a5531c; font-weight:700;">PART 6–7 · BOTH</div>
    <div style="font-size:17px; font-weight:700; margin:4px 0; color:#222;">🧠 The brain &amp; the big picture</div>
    <div style="font-size:14px; color:#444;">Where this happens in the brain, and what to take away</div>
  </div>
</div>
<p style="margin-top:12px; color:#ffffff; font-size:14px;"><b>Thread running through it all:</b> before the brain can decide <i>where</i> something happened, it has to decide <i>how many things</i> happened.</p>
<p style="color:#dddddd; font-size:13px;"><i>Most code is hidden. Click the eye icon next to a cell to see it.</i></p>
"""

# ╔═╡ a8f97c98-59ff-475f-9526-a4abb1d3c2c7
md"""
## 1. Try this first

Everyone grab a **pencil** (or use the tip of your nose).

1. On one hand, **cross your middle finger over your index finger**, so the two fingertips sit side by side but swapped.
2. **Close your eyes.**
3. Gently roll the pencil back and forth in the little gap between your two fingertips.

You *know* it's one pencil. But what does it **feel** like: one object, or two?

!!! tip "Uncross and compare"
    Now uncross your fingers and do the same thing. What changes?
"""

# ╔═╡ 8e3f7d21-f1d1-4a8c-ab06-ba4afd4c9ae3
md"""
### What just happened?

Many of you probably felt **two** pencils, even though you were holding the pencil yourself and *knew* there was only one. **Knowing the truth doesn't switch the illusion off.**

What happens when people *don't* know what's touching them? Researchers blindfolded 30 adults, crossed two of their fingers, and pressed a **single** small ball into the gap. They asked each time: *"one object or two?"*
"""

# ╔═╡ 7d03ccad-7eac-449c-b051-e259ab5fc2d8
let
    bar(["Crossed fingers", "Fingers side by side\n(normal)"], [93.0, 16.7],
        yerr=[2.3, 3.3], c=[:coral, :teal], legend=false, bar_width=0.55,
        ylims=(0, 105), ylabel="% of answers that were \"two objects\"",
        title="One ball, blindfolded: \"how many objects?\"", size=(700, 380))
    annotate!([(0.5, 99, text("93%", 12, :black)), (1.5, 23, text("17%", 12, :black))])   # categorical bars sit at x = 0.5, 1.5
end

# ╔═╡ 6d3a5319-cd52-4a16-8df5-1a8a7d8295a9
md"""
With crossed fingers, people said **"two"** on about **93%** of trials. With the same fingers side by side, they mostly got it right. The few mistakes came almost entirely from an awkward finger pairing (index + ring finger); for index + middle side by side, only about 4% of answers were "two". (Data: Fiorio et al., 2014, *PLoS ONE*. The 30 participants were 15 healthy adults and 15 people with Parkinson's disease, who showed the illusion just as strongly.)

To rule out people simply guessing "two" whenever their fingers felt crossed, the researchers also touched just **one** finger while the fingers were crossed. People answered correctly about **99%** of the time. So the "two" really comes from the touch at the crossing point.
"""

# ╔═╡ 9bde1632-a746-4caf-ad80-4f7d817ef722
html"""
<svg viewBox="0 0 720 270" width="100%" style="max-width:720px; font-family: sans-serif;">
  <text x="120" y="28" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">Normal fingers</text>
  <text x="360" y="28" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">Crossed fingers</text>
  <text x="600" y="28" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">What your brain assumes</text>
  <text x="120" y="48" text-anchor="middle" font-size="12" fill="#e6e6e6">(looking at the fingertips end-on)</text>
  <text x="360" y="48" text-anchor="middle" font-size="12" fill="#e6e6e6">same pencil, fingers swapped</text>
  <text x="600" y="48" text-anchor="middle" font-size="12" fill="#e6e6e6">fingers in their usual places</text>

  <!-- Panel 1: normal. Index left, middle right, pencil touches INNER sides -->
  <circle cx="82" cy="120" r="28" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <circle cx="158" cy="120" r="28" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <path d="M103.45 102 A28 28 0 0 1 103.45 138" fill="none" stroke="#1d9e75" stroke-width="6" stroke-linecap="round"/>
  <path d="M60.55 138 A28 28 0 0 1 60.55 102" fill="none" stroke="#d85a30" stroke-width="6" stroke-linecap="round"/>
  <path d="M136.55 138 A28 28 0 0 1 136.55 102" fill="none" stroke="#1d9e75" stroke-width="6" stroke-linecap="round"/>
  <path d="M179.45 102 A28 28 0 0 1 179.45 138" fill="none" stroke="#d85a30" stroke-width="6" stroke-linecap="round"/>
  <circle cx="120" cy="120" r="9" fill="#c8c8c8" stroke="#ffffff" stroke-width="1.5"/>
  <text x="82" y="125" text-anchor="middle" font-size="13" fill="#6b4226">index</text>
  <text x="158" y="125" text-anchor="middle" font-size="13" fill="#6b4226">middle</text>
  <text x="120" y="182" text-anchor="middle" font-size="13" fill="#ffffff">pencil touches both <tspan fill="#5dcaa5" font-weight="700">inner</tspan> sides</text>
  <text x="120" y="200" text-anchor="middle" font-size="13" fill="#ffffff">→ feels like <tspan font-weight="700">one</tspan> object ✓</text>

  <!-- Panel 2: crossed. Middle left, index right, pencil touches OUTER sides -->
  <circle cx="322" cy="120" r="28" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <circle cx="398" cy="120" r="28" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <path d="M343.45 102 A28 28 0 0 1 343.45 138" fill="none" stroke="#d85a30" stroke-width="6" stroke-linecap="round"/>
  <path d="M300.55 138 A28 28 0 0 1 300.55 102" fill="none" stroke="#1d9e75" stroke-width="6" stroke-linecap="round"/>
  <path d="M376.55 138 A28 28 0 0 1 376.55 102" fill="none" stroke="#d85a30" stroke-width="6" stroke-linecap="round"/>
  <path d="M419.45 102 A28 28 0 0 1 419.45 138" fill="none" stroke="#1d9e75" stroke-width="6" stroke-linecap="round"/>
  <circle cx="360" cy="120" r="9" fill="#c8c8c8" stroke="#ffffff" stroke-width="1.5"/>
  <text x="322" y="125" text-anchor="middle" font-size="13" fill="#6b4226">middle</text>
  <text x="398" y="125" text-anchor="middle" font-size="13" fill="#6b4226">index</text>
  <text x="360" y="182" text-anchor="middle" font-size="13" fill="#ffffff">pencil touches both <tspan fill="#f0997b" font-weight="700">outer</tspan> sides</text>
  <text x="360" y="200" text-anchor="middle" font-size="13" fill="#ffffff">→ unusual signal…</text>

  <!-- Panel 3: brain's assumption. Normal layout, two pencils on OUTER sides -->
  <circle cx="562" cy="120" r="28" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <circle cx="638" cy="120" r="28" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <path d="M583.45 102 A28 28 0 0 1 583.45 138" fill="none" stroke="#1d9e75" stroke-width="6" stroke-linecap="round"/>
  <path d="M540.55 138 A28 28 0 0 1 540.55 102" fill="none" stroke="#d85a30" stroke-width="6" stroke-linecap="round"/>
  <path d="M616.55 138 A28 28 0 0 1 616.55 102" fill="none" stroke="#1d9e75" stroke-width="6" stroke-linecap="round"/>
  <path d="M659.45 102 A28 28 0 0 1 659.45 138" fill="none" stroke="#d85a30" stroke-width="6" stroke-linecap="round"/>
  <circle cx="525" cy="120" r="9" fill="#c8c8c8" stroke="#ffffff" stroke-width="1.5"/>
  <circle cx="675" cy="120" r="9" fill="#c8c8c8" stroke="#ffffff" stroke-width="1.5"/>
  <text x="562" y="125" text-anchor="middle" font-size="13" fill="#6b4226">index</text>
  <text x="638" y="125" text-anchor="middle" font-size="13" fill="#6b4226">middle</text>
  <text x="600" y="182" text-anchor="middle" font-size="13" fill="#ffffff">both <tspan fill="#f0997b" font-weight="700">outer</tspan> sides touched usually</text>
  <text x="600" y="200" text-anchor="middle" font-size="13" fill="#ffffff">means <tspan font-weight="700">two</tspan> objects ✗</text>

  <!-- Legend -->
  <rect x="210" y="232" width="18" height="8" fill="#1d9e75"/>
  <text x="234" y="240" font-size="13" fill="#ffffff">inner side (faces the other finger)</text>
  <rect x="440" y="232" width="18" height="8" fill="#d85a30"/>
  <text x="464" y="240" font-size="13" fill="#ffffff">outer side</text>
</svg>
"""

# ╔═╡ d6489731-b03f-420d-ae29-b315cfce0cdb
md"""
Each fingertip has an **inner side** (facing the other finger) and an **outer side**. In everyday life, one small object can touch both *inner* sides at once, but touching both *outer* sides at the same moment practically always means **two separate objects**.

Crossing your fingers breaks that rule. Your brain doesn't adjust for the crossed fingers. It sticks with its everyday assumption and reports **two pencils**.

Your brain was answering a question it answers all day long, usually without you noticing:

> **How many things caused what I'm feeling, and where are they?**

Today we build a mathematical model of how a brain could answer that question, why the answer is usually right, and why it sometimes isn't.
"""

# ╔═╡ 7b3696c3-a667-47d8-8797-11da04aada56
md"""
## 2. Your body is a guess

It feels like you simply *know* where your arm is and what's touching it. In fact, your brain never observes your body directly. It receives reports from several senses, and each report is a little bit wrong.

The body sends four main kinds of reports:

| Sense | What it reports | Where it comes from |
|:--|:--|:--|
| **Vision** | where your body *looks* like it is | the eyes |
| **Touch** | pressure, vibration, texture on the skin | receptors in the skin |
| **Proprioception** | where your limbs are *without looking* | stretch sensors in muscles, tendons and joints |
| **Nociception** | possible tissue damage | "danger" receptors called nociceptors |

**Somatosensation** is the umbrella word for the body senses: touch, proprioception, nociception and temperature.

*Nociception is not the same thing as pain. Nociception is the danger signal; pain is the experience the brain may build from it.*
"""

# ╔═╡ cd83b195-a73d-4704-88e2-8a3c1dbc11d7
html"""
<svg viewBox="0 0 720 280" width="100%" style="max-width:720px; font-family: sans-serif;">
  <!-- arm -->
  <rect x="60" y="115" width="390" height="50" rx="25" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <rect x="430" y="104" width="80" height="72" rx="18" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <rect x="500" y="106" width="58" height="13" rx="6" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <rect x="500" y="122" width="64" height="13" rx="6" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <rect x="500" y="138" width="60" height="13" rx="6" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <rect x="500" y="154" width="50" height="13" rx="6" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <rect x="455" y="86" width="44" height="14" rx="7" fill="#f6d5bb" stroke="#b9805a" stroke-width="1.5"/>
  <!-- joints -->
  <circle cx="92" cy="140" r="7" fill="#7f77dd"/>
  <circle cx="436" cy="140" r="7" fill="#7f77dd"/>
  <!-- touch point -->
  <circle cx="556" cy="128" r="6" fill="#1d9e75"/>
  <!-- damage point -->
  <text x="230" y="147" text-anchor="middle" font-size="20" fill="#e24b4a">✸</text>

  <!-- vision: eye -->
  <ellipse cx="150" cy="38" rx="22" ry="12" fill="white" stroke="#185fa5" stroke-width="2"/>
  <circle cx="150" cy="38" r="6" fill="#185fa5"/>
  <line x1="160" y1="52" x2="250" y2="112" stroke="#185fa5" stroke-width="1.5" stroke-dasharray="5 4"/>
  <text x="182" y="34" font-size="14" font-weight="700" fill="#85b7eb">Vision</text>
  <text x="182" y="52" font-size="12" fill="#ffffff">where the arm looks like it is</text>

  <!-- touch -->
  <line x1="556" y1="120" x2="600" y2="60" stroke="#1d9e75" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="560" y="34" font-size="14" font-weight="700" fill="#5dcaa5">Touch</text>
  <text x="560" y="52" font-size="12" fill="#ffffff">pressure on the skin</text>

  <!-- proprioception -->
  <line x1="436" y1="148" x2="455" y2="215" stroke="#534ab7" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="400" y="234" font-size="14" font-weight="700" fill="#afa9ec">Proprioception</text>
  <text x="400" y="252" font-size="12" fill="#ffffff">joint angles → where the limb is, eyes closed</text>

  <!-- nociception -->
  <line x1="230" y1="152" x2="230" y2="215" stroke="#a32d2d" stroke-width="1" stroke-dasharray="4 3"/>
  <text x="190" y="234" font-size="14" font-weight="700" fill="#f09595">Nociception</text>
  <text x="190" y="252" font-size="12" fill="#ffffff">"something may be damaged"</text>
</svg>
"""

# ╔═╡ b539a425-1a44-404a-8ec0-d8733585ebcc
md"""
### Every sense is noisy, and the noise changes

**The task.** Imagine one simple test, repeated many times:

> Someone touches a spot on your arm (or your hand rests somewhere you can't see), and you are asked: **"Point to where it is."**

You won't hit exactly the right spot every time. Repeat the test 100 times and your pointing errors pile up into a **bell curve** centred on the true spot:

- **Narrow curve:** you're almost always close, so the sense is **reliable**.
- **Wide curve:** your answers scatter, so the sense is **vague**.

How wide the curve is depends on *which* sense you're relying on and the situation:

- **Vision** is sharp in daylight and blurry in a dark room.
- **Touch** is very precise on a fingertip and much vaguer on your back.
- **Proprioception** gets worse when your muscles are tired, after a joint injury, and with age. It can also *improve* with training: dancers and gymnasts are unusually good at it.

So each sense hands the brain **a guess with an error bar**.

**Pick a situation:** $(@bind sense_case Select(["vis_day" => "Look at your hand in good light, point to it", "vis_dark" => "Look at your hand in a dim room, point to it", "prop_rest" => "Eyes closed, rested: point to your other hand", "prop_tired" => "Eyes closed, tired muscles: point to your other hand", "touch_finger" => "Eyes closed: someone taps your fingertip, point to the spot", "touch_back" => "Eyes closed: someone taps your back, point to the spot"]))
"""

# ╔═╡ bc05446d-d53f-4317-9734-90e2298e8c25
begin
    # Illustrative widths (cm), chosen to show the idea, not measured values.
    sense_sigma = Dict("vis_day" => 0.5, "vis_dark" => 3.0, "prop_rest" => 2.0,
                       "prop_tired" => 4.0, "touch_finger" => 0.3, "touch_back" => 3.0)
    sense_label = Dict("vis_day" => "Vision, good light", "vis_dark" => "Vision, dim room",
                       "prop_rest" => "Proprioception, rested", "prop_tired" => "Proprioception, tired",
                       "touch_finger" => "Touch on a fingertip", "touch_back" => "Touch on the back")
end

# ╔═╡ 407d29cc-13bc-45ee-bdca-c43ac45dab6d
let
    σ = sense_sigma[sense_case]
    xg = range(-12, 12, length=600)
    p = plot(xg, pdf.(Normal(0, σ), xg), lw=3, c=:teal, fill=(0, 0.25, :teal),
        label="spread of pointing answers", xlims=(-12, 12), ylims=(0, 1.4),
        xlabel="how far off the pointing is (cm)", ylabel="how often",
        title="$(sense_label[sense_case]): typical error ≈ ±$(σ) cm", size=(780, 330))
    vline!(p, [0], c=:black, ls=:dash, label="true spot")
    p
end

# ╔═╡ 61888ebf-d926-4ff2-a3d5-fee3c2150b85
md"""
**What to notice:** each curve shows where someone's pointing answers would land if they repeated the task many times; 0 is the true spot. A **narrow** curve means a **trustworthy** sense; a **wide** curve means a vague one. The width is called the **standard deviation**, ``\sigma``, and it is exactly the "noise" the brain will use to decide how much to trust each sense. Hold on to this picture. The rest of the talk is about what the brain should do when two of these curves disagree.

*The widths above are illustrative, chosen to show the idea; they are not measured values.*
"""

# ╔═╡ 94117795-b3fc-4ad6-8344-ab09049d89aa
md"""
## 3. The rubber hand illusion

This is one of the most famous experiments in body perception (Botvinick & Cohen, 1998).

1. You rest your hand on a table, **hidden behind a screen**.
2. A **rubber hand** is placed in plain view, about 15–20 cm away.
3. Someone uses two paintbrushes to stroke **your hidden hand and the rubber hand at exactly the same time, on the same finger**.

▶️ **Video:** [JoVE: Studying proprioception using the rubber hand illusion](https://app.jove.com/v/10291)
"""

# ╔═╡ 7e19cd4d-7bdf-4ac1-86e5-51a212bfc6e8
html"""
<svg viewBox="0 0 720 330" width="100%" style="max-width:720px; font-family: sans-serif;">
  <rect x="60" y="60" width="600" height="200" rx="10" fill="#f4efe6" stroke="#a89c86" stroke-width="1.5"/>
  <rect x="64" y="64" width="282" height="192" rx="8" fill="#d9d4ca" opacity="0.6"/>
  <line x1="350" y1="64" x2="350" y2="256" stroke="#555" stroke-width="5"/>
  <text x="205" y="44" text-anchor="middle" font-size="15" font-weight="700" fill="#5dcaa5">Real hand (hidden)</text>
  <text x="500" y="44" text-anchor="middle" font-size="15" font-weight="700" fill="#f0997b">Rubber hand (visible)</text>
  <g fill="#9fe1cb" stroke="#0f6e56" stroke-width="1">
    <rect x="175" y="140" width="60" height="70" rx="12"/>
    <rect x="177" y="100" width="11" height="44" rx="5"/>
    <rect x="191" y="94" width="11" height="50" rx="5"/>
    <rect x="205" y="96" width="11" height="48" rx="5"/>
    <rect x="219" y="104" width="11" height="40" rx="5"/>
  </g>
  <g fill="#f5c4b3" stroke="#993c1d" stroke-width="1">
    <rect x="470" y="140" width="60" height="70" rx="12"/>
    <rect x="472" y="100" width="11" height="44" rx="5"/>
    <rect x="486" y="94" width="11" height="50" rx="5"/>
    <rect x="500" y="96" width="11" height="48" rx="5"/>
    <rect x="514" y="104" width="11" height="40" rx="5"/>
  </g>
  <line x1="250" y1="150" x2="278" y2="122" stroke="#ba7517" stroke-width="5" stroke-linecap="round"/>
  <line x1="545" y1="150" x2="573" y2="122" stroke="#ba7517" stroke-width="5" stroke-linecap="round"/>
  <text x="284" y="116" font-size="13" fill="#854f0b">brush</text>
  <text x="579" y="116" font-size="13" fill="#854f0b">brush</text>
  <text x="356" y="250" font-size="12" fill="#555">screen</text>
  <defs><marker id="rh_arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M1 1L9 5L1 9z" fill="#d85a30"/></marker></defs>
  <line x1="210" y1="236" x2="336" y2="236" stroke="#d85a30" stroke-width="2.5" stroke-dasharray="6 4" marker-end="url(#rh_arrow)"/>
  <text x="210" y="228" font-size="12" fill="#993c1d">felt position drifts →</text>
  <text x="360" y="292" text-anchor="middle" font-size="13" fill="#ffffff">Both brushes stroke the same finger at the same moment.</text>
  <text x="360" y="312" text-anchor="middle" font-size="13" fill="#ffffff">After a minute or two, the touch seems to come from the rubber hand.</text>
</svg>
"""

# ╔═╡ fecceedb-4153-4e21-bdf4-71046aa43f1f
md"""
!!! tip "Predict first"
    After a few minutes of brushing, the experimenter asks: *"Close your eyes and point to where your real hand is."* Where do people point?

**What happens:**

- Many people start to **feel the touch on the rubber hand**, as if it were their own.
- When asked to point to their real hand, they point **a few centimetres toward the rubber hand**. Their hand never moved; their brain's *belief* about where it is did. This shift is called **proprioceptive drift**.

**When the illusion breaks:**

- **Out of sync:** if the two brushes are out of step, the illusion mostly disappears (Botvinick & Cohen, 1998).
- **Too far away:** if the rubber hand is placed far from the real one, the illusion weakens. In one study it dropped off beyond roughly 30 cm (Lloyd, 2007).

**Why does the brain do this?** It gets two reports. Vision says *"the brushed hand is **here**"* (precise). Touch and proprioception say *"my hand is roughly **over there**"* (fuzzy, because the hand is hidden). Because the timing matches so well, the simplest explanation is **one hand, touched once**. So the brain merges the reports, pulled toward the more reliable one.

### Two opposite mistakes

| | What's really there | What the brain concludes |
|:--|:--|:--|
| **Crossed fingers** | one pencil | two objects: **split** one cause into two |
| **Rubber hand** | two hands | one hand: **merged** two causes into one |

Both are the same decision going wrong in opposite directions: **how many causes are behind what I'm sensing?** Next, Yusef turns that decision into math.
"""

# ╔═╡ 3ba13c91-522f-4028-b472-31953935b7f8
md"""
## 4. Act 1: Combining two senses

Start with the easy case: **assume both reports come from the same hand.** What's the best guess of where it is?

### You already do this every day

- **Two friends guess how far away a bus stop is.** One has great eyesight; the other forgot their glasses. You wouldn't average their guesses evenly. You'd **lean toward the friend who can actually see**.
- **Two weather apps disagree** about tomorrow's high. If one has been right all month and the other is usually off, you trust the reliable one more.

The brain does the same thing with its senses. Each sense gives a **guess** and an **error bar** (how sure it is, ``\sigma``, from Section 2). The brain gives each sense a **trust score** based on that error bar:

```math
\text{trust} = \frac{1}{\sigma^2}
```

Because the error bar is squared, a sense that is **twice as sharp gets four times the trust**. The final guess is a weighted average, where each sense's weight is its share of the total trust:

```math
\hat{x} \;=\; w_v\,x_v \;+\; w_s\,x_s
\qquad\qquad
w_v = \frac{\text{trust}_v}{\text{trust}_v + \text{trust}_s},\quad w_s = 1 - w_v
```

### A worked example

| | Vision | Touch |
|:--|:--:|:--:|
| Guess | 8 cm | 6 cm |
| Error bar ``\sigma`` | 1 cm | 2 cm |
| Trust ``1/\sigma^2`` | 1 | 0.25 |
| **Share of trust** | **80%** | **20%** |

```math
\hat{x} = 0.8 \times 8 \;+\; 0.2 \times 6 \;=\; 7.6 \text{ cm}
```

Not 7 cm (the plain average): **7.6 cm, closer to the sense you can trust.**

**Bonus:** combining two senses also makes the brain *more sure* than either sense alone. Two independent witnesses beat one.
"""

# ╔═╡ 211ed627-9a96-4cc5-9f0a-f7a7f3aadbd1
md"""
### Try it

Touch says the hand is at ``x_s = 6`` cm. Move what vision reports, and how big each sense's error bar is.

| Control | | Meaning |
|:--|:--|:--|
| Seen position ``x_v`` (cm) | $(@bind xv1 Slider(0:0.5:14, default=8, show_value=true)) | where vision says the hand is |
| Vision error bar ``\sigma_v`` (cm) | $(@bind σv1 Slider(0.2:0.1:5.0, default=1.0, show_value=true)) | drag right = dim the lights |
| Touch error bar ``\sigma_s`` (cm) | $(@bind σs1 Slider(0.2:0.1:5.0, default=2.0, show_value=true)) | drag right = tired muscles |

!!! tip "Predict first"
    With vision at 8 cm and touch at 6 cm, a plain average says 7 cm. With vision twice as sharp as touch, will the brain say more or less than 7?
"""

# ╔═╡ 33c450d3-a1df-473d-b24c-ed64d1e1389a
begin
    xs1 = 6.0                                   # felt position (cm)
    prec_v1 = 1 / σv1^2                         # trust score of vision (1/σ²)
    prec_s1 = 1 / σs1^2                         # trust score of touch (1/σ²)
    w_v1 = prec_v1 / (prec_v1 + prec_s1)        # share of trust given to vision
    xhat1 = (xv1 * prec_v1 + xs1 * prec_s1) / (prec_v1 + prec_s1)   # combined estimate
    σpost1 = sqrt(1 / (prec_v1 + prec_s1))      # combined error bar
end

# ╔═╡ 85a0b6e6-ffc3-46c5-86e0-e5a5a1a5b500
md"""
🧠 The brain places the hand at **$(round(xhat1, digits=2)) cm**, trusting vision **$(round(Int, 100w_v1))%** and touch **$(100 - round(Int, 100w_v1))%**. A plain average would say $((xv1 + xs1) / 2) cm.

Combined error bar: **± $(round(σpost1, digits=2)) cm**, tighter than vision alone (± $(σv1)) or touch alone (± $(σs1)).
"""

# ╔═╡ e1733d0c-f176-448d-bba9-a3bba2d0f073
let
    xg = range(0, 14, length=700)
    p1 = plot(xg, pdf.(Normal(xv1, σv1), xg), lw=3, c=:royalblue, label="vision says")
    plot!(p1, xg, pdf.(Normal(xs1, σs1), xg), lw=3, c=:darkorange, label="touch says")
    plot!(p1, xg, pdf.(Normal(xhat1, σpost1), xg), lw=3, c=:purple,
        fill=(0, 0.15, :purple), label="combined belief")
    vline!(p1, [(xv1 + xs1) / 2], ls=:dot, lw=2, c=:gray, label="plain average")
    vline!(p1, [xhat1], lw=2, c=:purple, label="")
    plot!(p1, xlims=(0, 14), ylabel="belief", legend=:topleft,
        title="Weight on vision = $(round(Int, 100w_v1))%")

    p2 = plot(xlims=(0, 14), ylims=(-1, 1.2), yticks=false, legend=false, grid=false,
        xlabel="position along the table (cm)")
    plot!(p2, Shape([0, 14, 14, 0], [-0.3, -0.3, 0.3, 0.3]), c=RGB(0.97, 0.86, 0.76), lc=RGB(0.72, 0.5, 0.35))
    scatter!(p2, [xv1], [0], m=(:circle, 10, :royalblue))
    scatter!(p2, [xs1], [0], m=(:diamond, 10, :darkorange))
    scatter!(p2, [xhat1], [0], m=(:star5, 14, :purple))
    annotate!(p2, xv1, 0.75, text("seen", 9, :royalblue))
    annotate!(p2, xs1, -0.75, text("felt", 9, :darkorange))
    annotate!(p2, xhat1, 0.75, text("perceived", 9, :purple))

    plot(p1, p2, layout=grid(2, 1, heights=[0.74, 0.26]), size=(800, 500))
end

# ╔═╡ 0eab2d22-1389-44e4-aa19-9f3f54743d0f
md"""
### What should you notice?

- **Vision sharper than touch** → the purple star sits closer to the **seen** position.
- **Touch sharper than vision** (dim the lights!) → it slides toward the **felt** position.
- **Equal noise** → and *only* then → it lands on the plain average.
- The purple curve is always the **narrowest**: combining two independent reports makes you more certain.
- The brain doesn't just average; it **weights each sense by how trustworthy it is**. This is called **cue integration**, and people's judgments match it closely in experiments (Ernst & Banks, 2002).
"""

# ╔═╡ a0ad8af5-bc35-4200-bcbf-3ad3d7897d78
md"""
### Does combining really help? Run 10,000 practice rounds

Put a real hand at 7 cm. In each round, vision and touch each make a noisy guess (using the slider settings above), and we combine them with the trust formula. Then we look at how far off the guesses land.
"""

# ╔═╡ 04ad38eb-d6b9-4623-b6bb-50f5846e23e9
begin
    sim_truth = 7.0
    sim_rng = MersenneTwister(2026)
    sim_v = sim_truth .+ σv1 .* randn(sim_rng, 10_000)        # 10,000 vision readings
    sim_s = sim_truth .+ σs1 .* randn(sim_rng, 10_000)        # 10,000 touch readings
    sim_f = (sim_v .* prec_v1 .+ sim_s .* prec_s1) ./ (prec_v1 + prec_s1)   # combine each pair
end;

# ╔═╡ af271878-c699-4ed5-bfb1-500ec4be147d
let
    bins = range(sim_truth - 12, sim_truth + 12, length=161)
    histogram(sim_s, bins=bins, normalize=:pdf, alpha=0.45, c=:darkorange, lc=:darkorange, label="touch alone")
    histogram!(sim_v, bins=bins, normalize=:pdf, alpha=0.45, c=:royalblue, lc=:royalblue, label="vision alone")
    histogram!(sim_f, bins=bins, normalize=:pdf, alpha=0.6, c=:purple, lc=:purple, label="combined")
    vline!([sim_truth], c=:black, ls=:dash, lw=2, label="true hand")
    plot!(xlims=(sim_truth - 10, sim_truth + 10), xlabel="estimated position (cm)", ylabel="density",
        title="10,000 simulated trials", size=(800, 380))
end

# ╔═╡ 32672d4c-daa8-4a6f-a933-0fc62c6f0065
md"""
| Typical error (cm) | Predicted | 10,000 rounds |
|:--|:--:|:--:|
| Vision alone | $(σv1) | $(round(std(sim_v), digits=2)) |
| Touch alone | $(σs1) | $(round(std(sim_s), digits=2)) |
| **Combined** | **$(round(σpost1, digits=2))** | **$(round(std(sim_f), digits=2))** |

The combined guesses (purple) land closer to the truth than either sense alone, exactly as predicted.
"""

# ╔═╡ 55de59ef-8802-4df4-998d-0060bc0480cb
md"""
## 5. Act 2: Should I combine at all?

The trust formula from Act 1 has a hidden assumption: **both reports come from the same hand.** It will *always* merge them.

Move the rubber hand **40 cm** away. Vision is much sharper than your sense of a hidden hand, so forced merging puts your hand almost 40 cm away, floating somewhere it obviously isn't. Real people don't do this; the illusion just switches off.

So before asking *"where is my hand?"*, the brain has to ask: **"did these two reports come from one thing, or two?"**

### You already do this every day too

- **At the movies**, the voice comes from speakers on the wall, but you hear it coming from the actor's mouth. Your brain decides *sound + moving lips = one event*. If the audio is badly out of sync, the illusion breaks and you notice the dubbing.
- **Lightning and thunder.** A flash, then a rumble a few seconds later: *same storm*. A flash, and a bang ten minutes later: *probably something else*.
- **A phone buzzes** just as you feel something in your pocket: *my phone*. A phone rings across the room: *someone else's*.

We give this question a name, ``C``:

- ``C = 1``: **one cause.** One hand produced both what I see and what I feel.
- ``C = 2``: **two causes.** What I see (a rubber hand) and what I feel (my real hand) are different things.
"""

# ╔═╡ 77862ae2-ebb9-4364-beac-7c1bb710c1c0
html"""
<svg viewBox="0 0 720 350" width="100%" style="max-width:720px; font-family: sans-serif;">
  <defs><marker id="gm_arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M1 1L9 5L1 9z" fill="#d0d0d0"/></marker></defs>
  <rect x="255" y="8" width="210" height="42" rx="8" fill="#eeedfe" stroke="#534ab7"/>
  <text x="360" y="34" text-anchor="middle" font-size="15" font-weight="700" fill="#3c3489">How many causes? C</text>
  <line x1="330" y1="50" x2="200" y2="82" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#gm_arrow)"/>
  <line x1="390" y1="50" x2="520" y2="82" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#gm_arrow)"/>

  <rect x="30" y="86" width="320" height="232" rx="12" fill="none" stroke="#bbbbbb" stroke-dasharray="6 4"/>
  <text x="190" y="110" text-anchor="middle" font-size="14" font-weight="700" fill="#ffffff">C = 1 · one hand</text>
  <rect x="110" y="126" width="160" height="44" rx="8" fill="#eeedfe" stroke="#534ab7"/>
  <text x="190" y="153" text-anchor="middle" font-size="14" fill="#3c3489">hand position x</text>
  <line x1="165" y1="170" x2="115" y2="240" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#gm_arrow)"/>
  <line x1="215" y1="170" x2="265" y2="240" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#gm_arrow)"/>
  <rect x="50" y="244" width="125" height="44" rx="8" fill="#e6f1fb" stroke="#185fa5"/>
  <text x="112" y="271" text-anchor="middle" font-size="14" fill="#0c447c">seen xᵥ</text>
  <rect x="205" y="244" width="125" height="44" rx="8" fill="#faeeda" stroke="#854f0b"/>
  <text x="267" y="271" text-anchor="middle" font-size="14" fill="#633806">felt xₛ</text>

  <rect x="370" y="86" width="320" height="232" rx="12" fill="none" stroke="#bbbbbb" stroke-dasharray="6 4"/>
  <text x="530" y="110" text-anchor="middle" font-size="14" font-weight="700" fill="#ffffff">C = 2 · two separate things</text>
  <rect x="385" y="126" width="140" height="44" rx="8" fill="#fbeaf0" stroke="#993556"/>
  <text x="455" y="153" text-anchor="middle" font-size="14" fill="#72243e">rubber hand x₁</text>
  <rect x="540" y="126" width="140" height="44" rx="8" fill="#e1f5ee" stroke="#0f6e56"/>
  <text x="610" y="153" text-anchor="middle" font-size="14" fill="#085041">real hand x₂</text>
  <line x1="455" y1="170" x2="455" y2="240" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#gm_arrow)"/>
  <line x1="610" y1="170" x2="610" y2="240" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#gm_arrow)"/>
  <rect x="393" y="244" width="125" height="44" rx="8" fill="#e6f1fb" stroke="#185fa5"/>
  <text x="455" y="271" text-anchor="middle" font-size="14" fill="#0c447c">seen xᵥ</text>
  <rect x="548" y="244" width="125" height="44" rx="8" fill="#faeeda" stroke="#854f0b"/>
  <text x="610" y="271" text-anchor="middle" font-size="14" fill="#633806">felt xₛ</text>
  <text x="360" y="342" text-anchor="middle" font-size="12" fill="#ffffff">Arrows point from causes to what they produce. The brain only sees the bottom row and has to work backwards.</text>
</svg>
"""

# ╔═╡ 361ea8d1-d302-4eca-818f-bee36b343568
md"""
### How the brain decides: two ingredients

**1. What did I expect before comparing the signals?** Before checking *where* the seen and felt touches are, the brain already has a starting expectation from context and past experience: how often does a touch I see and a touch I feel at the same moment come from the same thing? When the brushing is perfectly in sync, almost always. This starting expectation is called the **prior**.

*Everyday version:* your phone buzzes in your pocket. Before thinking about it, you assume it's **your** phone, because that's almost always true. If you then see your phone sitting on the table, the evidence overrides that starting expectation.

**2. How well does each explanation fit what I sensed?**

- If it's **one hand**, the two reports should roughly agree, off only by normal sensing error. A small gap fits well; a huge gap is very hard to explain.
- If it's **two things**, the reports could be anywhere. Any gap is possible, but no particular gap is especially expected.

Bayes' rule multiplies the two ingredients. It is easiest to write with **odds** (like betting odds):

```math
\text{odds after} \;=\; \text{evidence ratio} \;\times\; \text{odds before}
```

The **evidence ratio** says how many times better "one hand" explains what was sensed than "two things" does.

**Example.** Before comparing the signals, the brain bets **4 to 1** on one hand (80%). The senses fit "one hand" **3 times** better than "two things". After: ``3 \times 4 = 12`` to 1, which is about **92%** one hand.

### The gap only matters relative to the error bars

Two people measure the same table: 150 cm and 152 cm.

- With **tape measures**, a 2 cm disagreement is suspicious. Did they measure different tables?
- **Pacing it out with their feet**, 2 cm is nothing. Of course they disagree a little.

Same gap, different conclusion, because the **error bars** are different. The brain judges the gap between seen and felt the same way.
"""

# ╔═╡ b23d6194-0c73-400a-81af-99310af5b2fb
begin
    μ0_prior = 0.0     # cm: prior centre for hand-like object positions
    σ0_prior = 30.0    # cm: prior spread

    # log of P(x_v, x_s | one cause), with the true position integrated out (Körding et al., 2007)
    function log_like_common(xv, xs, σv, σs; μ0=μ0_prior, σ0=σ0_prior)
        V = σv^2 * σs^2 + σv^2 * σ0^2 + σs^2 * σ0^2
        Q = (xv - xs)^2 * σ0^2 + (xv - μ0)^2 * σs^2 + (xs - μ0)^2 * σv^2
        return -Q / (2V) - log(2π) - 0.5 * log(V)
    end

    # log of P(x_v, x_s | two separate causes)
    log_like_separate(xv, xs, σv, σs; μ0=μ0_prior, σ0=σ0_prior) =
        logpdf(Normal(μ0, sqrt(σv^2 + σ0^2)), xv) + logpdf(Normal(μ0, sqrt(σs^2 + σ0^2)), xs)

    like_common(args...; kw...)   = exp(log_like_common(args...; kw...))
    like_separate(args...; kw...) = exp(log_like_separate(args...; kw...))

    # Bayes' rule: P(one cause | data). Computed with logs so tiny numbers don't underflow.
    function p_common(xv, xs, σv, σs, prior; kw...)
        a = log_like_common(xv, xs, σv, σs; kw...) + log(prior)
        b = log_like_separate(xv, xs, σv, σs; kw...) + log(1 - prior)
        return 1 / (1 + exp(b - a))
    end

    # Where is the felt hand? (prior included; reduces to Act 1 as σ0 → ∞)
    fused_estimate(xv, xs, σv, σs; μ0=μ0_prior, σ0=σ0_prior) =
        (xv / σv^2 + xs / σs^2 + μ0 / σ0^2) / (1 / σv^2 + 1 / σs^2 + 1 / σ0^2)
    alone_estimate(xs, σs; μ0=μ0_prior, σ0=σ0_prior) =
        (xs / σs^2 + μ0 / σ0^2) / (1 / σs^2 + 1 / σ0^2)
end

# ╔═╡ cd3c4149-11d4-4d94-8e05-b2b8d7acc5eb
begin
    hw2_BF = like_common(8.0, 6.0, 1.0, 2.0; μ0=7.0, σ0=10.0) / like_separate(8.0, 6.0, 1.0, 2.0; μ0=7.0, σ0=10.0)
    hw2_post = p_common(8.0, 6.0, 1.0, 2.0, 0.7; μ0=7.0, σ0=10.0)
end;

# ╔═╡ 712d0b34-9cc7-41e1-8c05-9c350e1750b6
md"""
### Checking our HW2 numbers

In HW2 we **made up** the evidence: we guessed one hand fits **3 times** better, which gave **87.5%**. The model above *computes* the evidence ratio from the error bars instead (vision 8 cm ± 1, touch 6 cm ± 2). It gets **$(round(hw2_BF, digits=1)) times** better, giving **$(round(100 * hw2_post, digits=1))%**. Our guess was close, and now it has a reason behind it.
"""

# ╔═╡ cb210d1e-b8bf-4542-b346-844f6d0b7896
md"""
### What does "P(same hand)" mean?

From here on, the key number is **P(same hand)**, short for ``P(C{=}1 \mid x_v, x_s)``. It is the brain's answer to:

> *"How sure am I that the hand I **see** being brushed and the hand I **feel** being brushed are the **same hand**?"*

- **High (e.g. 80%):** the brain treats them as one hand → it merges the two reports → you feel the touch on the rubber hand and your felt hand drifts toward it. **The illusion happens.**
- **Low (e.g. 5%):** the brain treats them as two different things → it keeps the reports separate → **no illusion, no drift.**

It is **not** the chance that the rubber hand really is your hand (it never is). It is the brain's **belief**, based only on what it can see and feel. When that belief is high but wrong, that *is* the illusion.

### Try it: when does the brain give up on "one hand"?

Your real hand is at 0 cm. The rubber hand is ``d`` cm away. Vision reports the rubber hand's position; proprioception reports your real hand's.

| Control | | Meaning |
|:--|:--|:--|
| Rubber hand distance ``d`` (cm) | $(@bind d2 Slider(0:1:60, default=15, show_value=true)) | how far apart the two reports are |
| Vision error bar ``\sigma_v`` (cm) | $(@bind σv2 Slider(0.5:0.5:6, default=2, show_value=true)) | how sharp the seen hand is |
| Hidden-hand error bar ``\sigma_s`` (cm) | $(@bind σs2 Slider(1:1:20, default=10, show_value=true)) | how vague the hidden hand is |
| Starting expectation | $(@bind prior2 Slider(0.05:0.05:0.95, default=0.8, show_value=true)) | how likely "same hand" seemed before comparing the signals (in-sync brushing → high) |

!!! tip "Predict first"
    At what distance do you think the brain stops believing it's one hand? Make a guess, then drag ``d``.
"""

# ╔═╡ e12fdddc-eb25-480b-8f2b-f166b176e288
begin
    L1_2 = like_common(Float64(d2), 0.0, σv2, σs2)
    L2_2 = like_separate(Float64(d2), 0.0, σv2, σs2)
    BF2 = L1_2 / L2_2
    prior_odds2 = prior2 / (1 - prior2)
    post2 = p_common(Float64(d2), 0.0, σv2, σs2, prior2)
    z2 = d2 / sqrt(σv2^2 + σs2^2)
end;

# ╔═╡ d3a76cb3-751a-42b9-b4b9-49561774811c
let
    pct = round(Int, 100 * post2)
    HTML("""
    <div style="margin:4px 0 6px; font-size:15px; font-weight:600;">Brain's belief that the seen hand and the felt hand are the same hand: P(same hand)</div>
    <div style="background:#e8e4f3; border-radius:8px; height:30px; width:100%; position:relative; overflow:hidden;">
      <div style="background:#7b4bd1; height:100%; width:$(pct)%;"></div>
      <div style="position:absolute; top:5px; left:12px; font-weight:700; color:#111; text-shadow:0 0 4px white;">$(pct)% one hand · $(100 - pct)% two separate things</div>
    </div>
    """)
end

# ╔═╡ db1f6cf9-cc88-4dfc-9521-766795e8235c
md"""
The rubber hand is **$(d2) cm** away. With these error bars, that gap is about **$(round(z2, digits=1)) typical errors** wide.

- **Odds before** (from the starting expectation):$(round(prior_odds2, digits=2)) to 1
- **Evidence ratio** (how much better "one hand" fits): $(round(BF2, sigdigits=3))
- **Odds after** = $(round(BF2, sigdigits=3)) × $(round(prior_odds2, digits=2)) = $(round(BF2 * prior_odds2, sigdigits=3)) to 1, so **P(same hand) = $(round(100 * post2, digits=1))%**

*An evidence ratio above 1 means the senses favour one hand; below 1, they favour two separate things.*
"""

# ╔═╡ 861c7864-ff78-4fe3-a4df-64ba69d2ea88
let
    dr = 0:0.25:60
    sharp = [p_common(d, 0.0, σv2 / 2, σs2 / 2, prior2) for d in dr]
    mid   = [p_common(d, 0.0, σv2, σs2, prior2) for d in dr]
    noisy = [p_common(d, 0.0, 2σv2, 2σs2, prior2) for d in dr]
    plot(dr, sharp, lw=2, ls=:dash, c=:teal, label="both senses twice as sharp")
    plot!(dr, mid, lw=3.5, c=:purple, label="your settings")
    plot!(dr, noisy, lw=2, ls=:dash, c=:darkorange, label="both senses twice as noisy")
    hline!([0.5], ls=:dot, c=:gray, label="")
    scatter!([d2], [post2], m=(:circle, 9, :purple), label="")
    plot!(xlabel="distance between real and rubber hand (cm)", ylabel="P(same hand)",
        ylims=(0, 1.02), legend=:topright, size=(800, 400),
        title="When does the brain stop believing it's one hand?")
end

# ╔═╡ 598dc18c-01e3-4abe-b4c0-aa8c927650c3
md"""
### What should you notice?

- **More distance → less belief in one hand.** Large disagreements are hard to blame on noise.
- **Disagreement only counts relative to noise.** The *same* 15 cm gap is strong evidence for "two things" when the senses are sharp (teal) and barely matters when they're noisy (orange).
- **Noise protects the current explanation.** A brain that knows its senses are vague can shrug off contradictions: *"that's probably just noise."* A brain with sharp senses must take them seriously.
- **The prior shifts the whole curve.** Lower ``P(C{=}1)`` (like out-of-sync brushing) and the brain gives up on "one hand" much sooner, with *identical* sensory evidence.
"""

# ╔═╡ f1a6abe3-c037-45d9-b8e2-4cf8746d34b5
md"""
## 6. Is this what the brain does?

Brain-imaging studies suggest the brain handles these questions in stages:
"""

# ╔═╡ 8a2438cf-59ca-4bbf-82ca-f6245b8b84e3
html"""
<svg viewBox="0 0 760 310" width="100%" style="max-width:760px; font-family: sans-serif;">
  <path d="M90 170 C70 100 130 40 230 35 C320 30 400 45 440 95 C470 135 465 190 430 215 C400 238 340 240 290 232 C230 240 150 235 115 210 C100 200 94 186 90 170 Z"
        fill="#f4eef3" stroke="#9a7b93" stroke-width="2"/>
  <ellipse cx="385" cy="245" rx="55" ry="26" fill="#ece6ea" stroke="#9a7b93" stroke-width="1.5"/>
  <text x="130" y="252" font-size="12" fill="#dddddd">← front</text>
  <text x="445" y="290" font-size="12" fill="#dddddd">back →</text>

  <circle cx="165" cy="90" r="24" fill="#97c459" opacity="0.85"/>
  <circle cx="250" cy="62" r="22" fill="#ef9f27" opacity="0.85"/>
  <circle cx="330" cy="95" r="26" fill="#7f77dd" opacity="0.85"/>
  <circle cx="420" cy="160" r="24" fill="#378add" opacity="0.85"/>

  <line x1="430" y1="150" x2="500" y2="200" stroke="#378add" stroke-width="1" stroke-dasharray="4 3"/>
  <line x1="352" y1="85" x2="500" y2="135" stroke="#7f77dd" stroke-width="1" stroke-dasharray="4 3"/>
  <line x1="268" y1="50" x2="500" y2="70" stroke="#ef9f27" stroke-width="1" stroke-dasharray="4 3"/>
  <line x1="160" y1="113" x2="95" y2="262" stroke="#639922" stroke-width="1" stroke-dasharray="4 3"/>

  <text x="505" y="66" font-size="14" font-weight="700" fill="#fac775">Somatosensory cortex</text>
  <text x="505" y="84" font-size="12" fill="#ffffff">what you feel, kept separate</text>
  <text x="505" y="131" font-size="14" font-weight="700" fill="#cecbf6">Posterior parietal cortex</text>
  <text x="505" y="149" font-size="12" fill="#ffffff">combines senses, weighs "same cause?"</text>
  <text x="505" y="196" font-size="14" font-weight="700" fill="#b5d4f4">Early visual cortex</text>
  <text x="505" y="214" font-size="12" fill="#ffffff">what you see, kept separate</text>
  <text x="40" y="280" font-size="14" font-weight="700" fill="#c0dd97">Premotor cortex</text>
  <text x="40" y="298" font-size="12" fill="#ffffff">activity tracks "that's my hand"</text>
</svg>
"""

# ╔═╡ a1d99e09-26a6-44ae-b9c4-b65d09d1fe62
md"""
- **Early sensory areas** keep each sense's report mostly separate.
- **Parietal cortex** (the intraparietal sulcus) is where signals are combined. Rohe & Noppeney (2015) found a hierarchy there: one region always blended the senses, and a region further along made the **"one cause or two?"** decision, just like our model. *(Their study used sights and sounds rather than touch, but it's the same computation.)*
- **Premotor cortex** activity rose with the strength of the rubber hand illusion: the more people felt *"that's my hand"*, the stronger the signal (Ehrsson et al., 2004).

**What we are *not* claiming:** neurons don't write down Bayes' rule. The math describes **what a good solution looks like**; the brain seems to approximate it with networks of neurons whose details are still being worked out.
"""

# ╔═╡ ac5c1621-6422-4db3-a9bc-86eeb7635af9
md"""
## 7. The big picture
"""

# ╔═╡ 890e15ed-97e3-4b86-9e53-38af69073cd6
html"""
<svg viewBox="0 0 720 330" width="100%" style="max-width:720px; font-family: sans-serif;">
  <defs><marker id="sum_arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M1 1L9 5L1 9z" fill="#d0d0d0"/></marker></defs>
  <rect x="20" y="40" width="150" height="50" rx="8" fill="#e6f1fb" stroke="#185fa5"/>
  <text x="95" y="70" text-anchor="middle" font-size="14" font-weight="700" fill="#0c447c">What I see</text>
  <rect x="20" y="110" width="150" height="50" rx="8" fill="#faeeda" stroke="#854f0b"/>
  <text x="95" y="140" text-anchor="middle" font-size="14" font-weight="700" fill="#633806">What I feel</text>
  <line x1="170" y1="65" x2="226" y2="90" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#sum_arrow)"/>
  <line x1="170" y1="135" x2="226" y2="112" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#sum_arrow)"/>
  <rect x="230" y="65" width="190" height="70" rx="8" fill="#eeedfe" stroke="#534ab7"/>
  <text x="325" y="94" text-anchor="middle" font-size="15" font-weight="700" fill="#3c3489">One cause or two?</text>
  <text x="325" y="115" text-anchor="middle" font-size="12" fill="#534ab7">gap vs. error bars + expectation</text>
  <line x1="420" y1="90" x2="476" y2="62" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#sum_arrow)"/>
  <line x1="420" y1="110" x2="476" y2="138" stroke="#d0d0d0" stroke-width="1.5" marker-end="url(#sum_arrow)"/>
  <rect x="480" y="30" width="220" height="56" rx="8" fill="#e1f5ee" stroke="#0f6e56"/>
  <text x="590" y="53" text-anchor="middle" font-size="14" font-weight="700" fill="#085041">One → blend them</text>
  <text x="590" y="73" text-anchor="middle" font-size="12" fill="#0f6e56">trust the sharper sense more</text>
  <rect x="480" y="114" width="220" height="56" rx="8" fill="#faece7" stroke="#993c1d"/>
  <text x="590" y="137" text-anchor="middle" font-size="14" font-weight="700" fill="#712b13">Two → keep them apart</text>
  <text x="590" y="157" text-anchor="middle" font-size="12" fill="#993c1d">no blending, no illusion</text>

  <text x="360" y="208" text-anchor="middle" font-size="14" font-weight="700" fill="#ffffff">When that decision goes wrong, we get an illusion</text>
  <rect x="20" y="222" width="330" height="90" rx="10" fill="#f4efe6" stroke="#a89c86"/>
  <text x="185" y="248" text-anchor="middle" font-size="14" font-weight="700" fill="#333">🤞 Crossed fingers</text>
  <text x="185" y="272" text-anchor="middle" font-size="13" fill="#333">one pencil → brain says two</text>
  <text x="185" y="294" text-anchor="middle" font-size="12" fill="#555">it assumed the fingers were uncrossed</text>
  <rect x="370" y="222" width="330" height="90" rx="10" fill="#f4efe6" stroke="#a89c86"/>
  <text x="535" y="248" text-anchor="middle" font-size="14" font-weight="700" fill="#333">✋ Rubber hand</text>
  <text x="535" y="272" text-anchor="middle" font-size="13" fill="#333">two hands → brain says one</text>
  <text x="535" y="294" text-anchor="middle" font-size="12" fill="#555">in-sync touches looked like one event</text>
</svg>
"""

# ╔═╡ b54376b7-b33c-4d60-ad94-646fafad58b6
md"""
**What we want you to walk away with:**

1. **Your senses don't hand the brain facts. They hand it guesses with error bars.**
2. **If two senses report the same event, the brain blends them, trusting the sharper one more.** That's why vision at 8 cm and touch at 6 cm becomes 7.6 cm, not 7.
3. **But first, the brain has to decide whether it *is* the same event.** It judges the disagreement *relative to the error bars*, combined with what it expected. The same 15 cm gap can mean "my hand" or "not my hand."

> **Perception isn't a recording of the world. It's the brain's best guess about what happened, and *how many things* happened.**
"""

# ╔═╡ a613eef6-6ece-485d-8e8d-e97e948bcd8f
md"""
### References

*Our model uses one-dimensional positions, Gaussian noise and illustrative noise levels. It is built to teach the idea, not to fit real data.*


- Botvinick, M. & Cohen, J. (1998). Rubber hands "feel" touch that eyes see. *Nature*, 391, 756.
- Ernst, M. O. & Banks, M. S. (2002). Humans integrate visual and haptic information in a statistically optimal fashion. *Nature*, 415, 429–433.
- Ehrsson, H. H., Spence, C. & Passingham, R. E. (2004). That's my hand! Activity in premotor cortex reflects feeling of ownership of a limb. *Science*, 305, 875–877.
- Fiorio, M., Marotta, A., Ottaviani, S., Pozzer, L. & Tinazzi, M. (2014). Aristotle's illusion in Parkinson's disease: evidence for normal interdigit tactile perception. *PLoS ONE*, 9(2), e88686.
- Körding, K. P. et al. (2007). Causal inference in multisensory perception. *PLoS ONE*, 2(9), e943.
- Lloyd, D. M. (2007). Spatial limits on referred touch to an alien limb may reflect boundaries of visuo-tactile peripersonal space surrounding the hand. *Brain and Cognition*, 64, 104–109.
- Rohe, T. & Noppeney, U. (2015). Cortical hierarchies perform Bayesian causal inference in multisensory perception. *PLoS Biology*, 13(2), e1002073.
"""

# ╔═╡ Cell order:
# ╟─5a0d31cf-9c88-49ed-8437-d6a204b61541
# ╟─140c9ee7-5c22-47d9-9b44-e785026de1d8
# ╟─c02bcb93-428d-42e3-8c08-566364e98b72
# ╟─a8f97c98-59ff-475f-9526-a4abb1d3c2c7
# ╟─8e3f7d21-f1d1-4a8c-ab06-ba4afd4c9ae3
# ╟─7d03ccad-7eac-449c-b051-e259ab5fc2d8
# ╟─6d3a5319-cd52-4a16-8df5-1a8a7d8295a9
# ╟─9bde1632-a746-4caf-ad80-4f7d817ef722
# ╟─d6489731-b03f-420d-ae29-b315cfce0cdb
# ╟─7b3696c3-a667-47d8-8797-11da04aada56
# ╟─cd83b195-a73d-4704-88e2-8a3c1dbc11d7
# ╟─b539a425-1a44-404a-8ec0-d8733585ebcc
# ╟─bc05446d-d53f-4317-9734-90e2298e8c25
# ╟─407d29cc-13bc-45ee-bdca-c43ac45dab6d
# ╟─61888ebf-d926-4ff2-a3d5-fee3c2150b85
# ╟─94117795-b3fc-4ad6-8344-ab09049d89aa
# ╟─7e19cd4d-7bdf-4ac1-86e5-51a212bfc6e8
# ╟─fecceedb-4153-4e21-bdf4-71046aa43f1f
# ╟─3ba13c91-522f-4028-b472-31953935b7f8
# ╟─211ed627-9a96-4cc5-9f0a-f7a7f3aadbd1
# ╠═33c450d3-a1df-473d-b24c-ed64d1e1389a
# ╟─85a0b6e6-ffc3-46c5-86e0-e5a5a1a5b500
# ╟─e1733d0c-f176-448d-bba9-a3bba2d0f073
# ╟─0eab2d22-1389-44e4-aa19-9f3f54743d0f
# ╟─a0ad8af5-bc35-4200-bcbf-3ad3d7897d78
# ╟─04ad38eb-d6b9-4623-b6bb-50f5846e23e9
# ╟─af271878-c699-4ed5-bfb1-500ec4be147d
# ╟─32672d4c-daa8-4a6f-a933-0fc62c6f0065
# ╟─55de59ef-8802-4df4-998d-0060bc0480cb
# ╟─77862ae2-ebb9-4364-beac-7c1bb710c1c0
# ╟─361ea8d1-d302-4eca-818f-bee36b343568
# ╟─b23d6194-0c73-400a-81af-99310af5b2fb
# ╟─cd3c4149-11d4-4d94-8e05-b2b8d7acc5eb
# ╟─712d0b34-9cc7-41e1-8c05-9c350e1750b6
# ╟─cb210d1e-b8bf-4542-b346-844f6d0b7896
# ╟─e12fdddc-eb25-480b-8f2b-f166b176e288
# ╟─d3a76cb3-751a-42b9-b4b9-49561774811c
# ╟─db1f6cf9-cc88-4dfc-9521-766795e8235c
# ╟─861c7864-ff78-4fe3-a4df-64ba69d2ea88
# ╟─598dc18c-01e3-4abe-b4c0-aa8c927650c3
# ╟─f1a6abe3-c037-45d9-b8e2-4cf8746d34b5
# ╟─8a2438cf-59ca-4bbf-82ca-f6245b8b84e3
# ╟─a1d99e09-26a6-44ae-b9c4-b65d09d1fe62
# ╟─ac5c1621-6422-4db3-a9bc-86eeb7635af9
# ╟─890e15ed-97e3-4b86-9e53-38af69073cd6
# ╟─b54376b7-b33c-4d60-ad94-646fafad58b6
# ╟─a613eef6-6ece-485d-8e8d-e97e948bcd8f
