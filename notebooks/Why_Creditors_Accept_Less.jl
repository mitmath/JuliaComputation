### A Pluto.jl notebook ###
# v1.0.4

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

# ╔═╡ 13ece63b-4a1b-4472-aa38-f11bc3802833
using Plots, PlutoUI, Random, Statistics

# ╔═╡ a5faec45-e576-42d2-9336-49beda888682
md"""
# Why Creditors Accept Less
### A stochastic model of corporate debt restructuring
*Max Del Pino · 18.C25*

In August 2023, Carvana's bondholders agreed to trade their bonds for new ones worth as little as **65 cents on the dollar**. More than 90% of them signed up before the offer was even launched. Why would anyone voluntarily accept less than they are owed, and how does everyone decide how much less?

This notebook builds the math to answer that question, one layer at a time, and then tests it on Carvana's real deal.
"""

# ╔═╡ ac216e33-8373-4ee8-8355-1c2755569fd1
md"""
### Background: what happens when a company can't pay

**A company's debt works a lot like a mortgage.** Imagine you own a house worth 300,000 dollars with a 250,000 dollar mortgage. If house prices fall and the house is worth only 200,000, you could keep paying, hoping prices recover, or stop paying and hand the house to the bank. A company's shareholders face the same choice. Thanks to **limited liability**, they can always walk away and hand the company to its lenders, and they lose only what they put in. Part 1 works out exactly when walking away makes sense.

**Lenders stand in line.** A company usually owes money to several groups of lenders, and its contracts say who gets paid first if things go wrong. Bankers call this list the **capital structure**, or "cap stack." Secured lenders are first in line, then other creditors in order of seniority, and shareholders get whatever is left.
"""

# ╔═╡ bb51b3fd-f34c-4d49-a3dd-0bb84249d0fe
html"""
<svg viewBox="0 0 760 330" width="100%" style="max-width:760px;font-family:inherit" role="img" aria-label="Capital structure: secured loan, senior notes, junior notes, equity, paid in that order; a dashed line shows where the company's value runs out, inside the junior notes, which makes them the fulcrum">
  <rect x="60" y="20" width="300" height="60" rx="6" fill="#1f4e79"/>
  <text x="210" y="56" text-anchor="middle" fill="#ffffff" font-size="16">Secured loan</text>
  <rect x="60" y="86" width="300" height="70" rx="6" fill="#2b6f8f"/>
  <text x="210" y="126" text-anchor="middle" fill="#ffffff" font-size="16">Senior notes</text>
  <rect x="60" y="162" width="300" height="80" rx="6" fill="#a8434f"/>
  <text x="210" y="190" text-anchor="middle" fill="#ffffff" font-size="16">Junior notes</text>
  <rect x="60" y="248" width="300" height="60" rx="6" fill="#3a7d44"/>
  <text x="210" y="283" text-anchor="middle" fill="#ffffff" font-size="16">Equity (shareholders)</text>
  <line x1="30" y1="25" x2="30" y2="300" stroke="#888" stroke-width="2"/>
  <polygon points="22,296 38,296 30,312" fill="#888"/>
  <text x="22" y="18" fill="currentColor" font-size="13">paid first</text>
  <line x1="40" y1="215" x2="420" y2="215" stroke="currentColor" stroke-width="2" stroke-dasharray="7,5"/>
  <text x="430" y="210" fill="currentColor" font-size="14">What the company is worth</text>
  <text x="430" y="228" fill="currentColor" font-size="14">if it is sold or liquidated</text>
  <text x="430" y="40" fill="currentColor" font-size="13">Above the line: paid in full</text>
  <text x="430" y="262" fill="currentColor" font-size="13">The class the line cuts through is the</text>
  <text x="430" y="280" fill="currentColor" font-size="13"><tspan font-weight="bold">fulcrum</tspan>: it usually ends up owning the company</text>
  <text x="430" y="310" fill="currentColor" font-size="13">Below the line: wiped out</text>
</svg>
"""

# ╔═╡ 40a7b207-8c68-4fa5-bab7-9f2d81ba464e
md"""
**Why not just sell everything and pay people in order?** Because liquidation destroys value. Lawyers' fees, fire-sale prices, and lost customers and employees can cost a large share of what the company is worth. If the company keeps operating, that value is saved, and that saved value is something everyone can fight over. **Restructuring** is the process of deciding who gets it. It can happen two ways:
"""

# ╔═╡ 55ea8f32-410d-410a-a2eb-894cfefc1f67
html"""
<svg viewBox="0 0 760 300" width="100%" style="max-width:760px;font-family:inherit" role="img" aria-label="A distressed company can restructure out of court through voluntary deals that holdouts can refuse, or in court through Chapter 11, where a vote binds the whole class">
  <rect x="230" y="10" width="300" height="50" rx="8" fill="#555"/>
  <text x="380" y="41" text-anchor="middle" fill="#ffffff" font-size="15">A company can't comfortably pay its debt</text>
  <line x1="320" y1="60" x2="190" y2="100" stroke="#888" stroke-width="2"/>
  <line x1="440" y1="60" x2="570" y2="100" stroke="#888" stroke-width="2"/>
  <rect x="30" y="100" width="320" height="46" rx="8" fill="#2b6f8f"/>
  <text x="190" y="129" text-anchor="middle" fill="#ffffff" font-size="15">Out of court: negotiate a deal</text>
  <rect x="410" y="100" width="320" height="46" rx="8" fill="#a8434f"/>
  <text x="570" y="129" text-anchor="middle" fill="#ffffff" font-size="15">In court: Chapter 11 bankruptcy</text>
  <text x="40" y="172" fill="currentColor" font-size="13">• Exchange offers (swap old debt for new)</text>
  <text x="40" y="194" fill="currentColor" font-size="13">• Amend &amp; extend (push out maturities)</text>
  <text x="40" y="216" fill="currentColor" font-size="13">• Uptiers, dropdowns, double-dips (LMEs)</text>
  <text x="40" y="238" fill="currentColor" font-size="13">• Discounted buybacks</text>
  <text x="40" y="270" fill="currentColor" font-size="13" font-style="italic">Voluntary: each holder can refuse (holdouts)</text>
  <text x="420" y="172" fill="currentColor" font-size="13">• Creditors vote on a reorganization plan</text>
  <text x="420" y="194" fill="currentColor" font-size="13">• A class accepts with 2/3 of the amount</text>
  <text x="432" y="216" fill="currentColor" font-size="13">and more than 1/2 of the holders</text>
  <text x="420" y="238" fill="currentColor" font-size="13">• Or the court can "cram down" a plan</text>
  <text x="420" y="270" fill="currentColor" font-size="13" font-style="italic">Binding: the vote binds the whole class</text>
</svg>
"""

# ╔═╡ 7beacf24-01e2-4227-bdcd-5800461be2c4
md"""
Out-of-court deals are faster and cheaper, which is why companies try them first. Since about 2020, companies and lender groups have invented many new versions, called **liability management exercises (LMEs)**, and they are one of the most active areas of finance today.

**A few terms used throughout:**

| Term | Meaning |
|:--|:--|
| Face value / par | What a bond promises to repay (here, 100) |
| Coupon | The yearly interest payment |
| Default | The company stops paying |
| Recovery | What a lender gets back after a default |
| Exchange rate | New debt received per 100 of old debt in a swap |
| Holdout | A lender who refuses a voluntary deal |
| Coop | A cooperation agreement: lenders promise to negotiate as one group |

### The plan for this talk
"""

# ╔═╡ 82045e67-573a-4b56-a7b9-df72a6abb72a
html"""
<svg viewBox="0 0 760 170" width="100%" style="max-width:760px;font-family:inherit" role="img" aria-label="Roadmap: Part 1 when a firm defaults, Part 2 how creditors split value, Part 3 Carvana, Part 4 the restructuring toolkit, then the conclusion">
  <rect x="5" y="20" width="140" height="80" rx="8" fill="#1f4e79"/>
  <text x="75" y="48" text-anchor="middle" fill="#ffffff" font-size="14" font-weight="bold">Part 1</text>
  <text x="75" y="68" text-anchor="middle" fill="#ffffff" font-size="12">When does a</text>
  <text x="75" y="84" text-anchor="middle" fill="#ffffff" font-size="12">firm default?</text>
  <rect x="158" y="20" width="140" height="80" rx="8" fill="#2b6f8f"/>
  <text x="228" y="48" text-anchor="middle" fill="#ffffff" font-size="14" font-weight="bold">Part 2</text>
  <text x="228" y="68" text-anchor="middle" fill="#ffffff" font-size="12">How do creditors</text>
  <text x="228" y="84" text-anchor="middle" fill="#ffffff" font-size="12">split the value?</text>
  <rect x="311" y="20" width="140" height="80" rx="8" fill="#a8434f"/>
  <text x="381" y="48" text-anchor="middle" fill="#ffffff" font-size="14" font-weight="bold">Part 3</text>
  <text x="381" y="68" text-anchor="middle" fill="#ffffff" font-size="12">Does it fit a</text>
  <text x="381" y="84" text-anchor="middle" fill="#ffffff" font-size="12">real deal? (Carvana)</text>
  <rect x="464" y="20" width="140" height="80" rx="8" fill="#3a7d44"/>
  <text x="534" y="48" text-anchor="middle" fill="#ffffff" font-size="14" font-weight="bold">Part 4</text>
  <text x="534" y="68" text-anchor="middle" fill="#ffffff" font-size="12">The toolkit: what</text>
  <text x="534" y="84" text-anchor="middle" fill="#ffffff" font-size="12">each move does</text>
  <rect x="617" y="20" width="138" height="80" rx="8" fill="#555"/>
  <text x="686" y="48" text-anchor="middle" fill="#ffffff" font-size="14" font-weight="bold">Conclusion</text>
  <text x="686" y="68" text-anchor="middle" fill="#ffffff" font-size="12">Every move pulls</text>
  <text x="686" y="84" text-anchor="middle" fill="#ffffff" font-size="12">one lever</text>
  <text x="75" y="125" text-anchor="middle" fill="currentColor" font-size="11">Itô's lemma, ODEs,</text>
  <text x="75" y="141" text-anchor="middle" fill="currentColor" font-size="11">optimal stopping</text>
  <text x="228" y="125" text-anchor="middle" fill="currentColor" font-size="11">Nash bargaining,</text>
  <text x="228" y="141" text-anchor="middle" fill="currentColor" font-size="11">first-passage times</text>
  <text x="381" y="125" text-anchor="middle" fill="currentColor" font-size="11">calibration to</text>
  <text x="381" y="141" text-anchor="middle" fill="currentColor" font-size="11">SEC filings</text>
  <text x="534" y="125" text-anchor="middle" fill="currentColor" font-size="11">coalition games,</text>
  <text x="534" y="141" text-anchor="middle" fill="currentColor" font-size="11">Monte Carlo</text>
  <text x="686" y="125" text-anchor="middle" fill="currentColor" font-size="11">takeaways and</text>
  <text x="686" y="141" text-anchor="middle" fill="currentColor" font-size="11">open questions</text>
</svg>
"""

# ╔═╡ 4a79638b-dd00-4799-b8bd-6b9bed5bb1ba
md"""
### Project map: every restructuring move changes one lever

Restructuring bankers have a long menu of transactions. Mathematically, almost every one of them changes one of a few levers in this model, and the model shows who gains and who loses from each move.

| Lever in the model | What the move changes | Strategies | Real cases | Section |
|:--|:--|:--|:--|:--|
| Default timing | When shareholders stop paying | Strategic default | — | Part 1 |
| Priority (waterfall order) | Who is paid first | Exchanges, pro rata and non-pro rata uptiers | Carvana, Serta | 2A, 2B, 4A |
| Maturity (first-passage time) | When debt comes due | Holdouts, amend & extend | AMC, STG, Carvana | 2C, 4B |
| Amount of debt | How much is owed | Discounted buybacks | — | 4C |
| Where the assets sit | Which creditors can reach which assets | Dropdowns, unrestricted subsidiaries, guarantee releases, non-guarantor subsidiaries | J.Crew, PetSmart/Chewy | 4D |
| Number of claims | How many claims a creditor holds against the same value | Double-dips, "pari-plus" | Trinseo, STG | 4D |
| Who is in the coalition | Which holders vote and bargain together | Cooperation agreements, anti-coop terms, Chapter 11 votes, cramdown | Cision, Warner Bros. Discovery | 4E |


"""

# ╔═╡ 5848067f-26e8-42ae-b78c-f452dba1f85c
TableOfContents(depth=2)

# ╔═╡ da79fe3f-8976-4357-8b89-56f29909b5af
md"""
# Part 1: When do shareholders stop paying?

### The idea
A firm's asset value moves randomly over time. Shareholders pay the interest on the firm's debt, but because of limited liability they can walk away at any time and hand the firm to the creditors. This notebook finds the asset value at which walking away is optimal for shareholders (the **default boundary**), and shows a surprising result: the riskier the firm, the *longer* shareholders keep paying. Equity behaves like an option on the firm, and options become more valuable with more volatility.

This is the foundation for everything that follows: Part 2 adds several classes of lenders and the bargaining between them, and the default boundary found here tells us when a firm is in trouble and how much value is at stake.
"""

# ╔═╡ 05e902f4-2e91-4405-a200-a4ef49b68422
md"""
### The model
- The firm's asset value `V` follows geometric Brownian motion: `dV = μV dt + σV dW`.
- The firm has perpetual debt paying a constant annual coupon `C`. Coupons are tax-deductible at tax rate `τ`.
- If shareholders default, creditors take over the firm, but a fraction `α` of its value is lost to bankruptcy costs.
- Applying Itô's lemma gives an ODE that every claim on the firm must satisfy: `½σ²V²F'' + rVF' − rF + (payout) = 0`. Its solutions are combinations of `V` and `V^(−X)` with `X = 2r/σ²`.
- Shareholders choose the default point to maximize equity value (smooth pasting), which gives `V_B = (1 − τ)C / (r + σ²/2)`.
- Applying the boundary conditions gives each claim's value. With `p_B = (V/V_B)^(−X)`, the present value of 1 paid at default:
  - **Debt:** `D(V) = C/r + ((1 − α)V_B − C/r) · p_B`. Its coupons forever, minus what creditors lose at default.
  - **Equity:** `E(V) = V − (1 − τ)C/r + ((1 − τ)C/r − V_B) · p_B`. Assets minus after-tax coupons forever, plus the option to default.
  - **Firm value** = debt + equity.
"""

# ╔═╡ 17297e74-49ff-441a-8a64-3f1762d9c227
md"""
**Asset volatility σ:** $(@bind σ Slider(0.05:0.01:0.60, default=0.25, show_value=true))

**Bankruptcy cost α** (fraction of value lost in liquidation): $(@bind α Slider(0.0:0.05:0.80, default=0.30, show_value=true))

**Tax rate τ:** $(@bind τ Slider(0.0:0.05:0.40, default=0.25, show_value=true))

**Annual coupon C:** $(@bind C Slider(1.0:0.5:10.0, default=5.0, show_value=true))
"""

# ╔═╡ 0c8ddcc5-3569-415c-bcea-5b0a8f0f7906
begin
    r = 0.05  # risk-free interest rate

    X(σ) = 2r / σ^2

    default_boundary(C, σ, τ) = (1 - τ) * C / (r + σ^2 / 2)

    # value of the debt: riskless coupons minus the loss creditors take at default
    function debt_value(V, C, σ, τ, α)
        VB = default_boundary(C, σ, τ)
        V <= VB && return (1 - α) * V
        p = (V / VB)^(-X(σ))  # acts like the present value of 1 paid at default
        return C / r + ((1 - α) * VB - C / r) * p
    end

    # value of the equity: assets minus after-tax coupons, plus the option to default
    function equity_value(V, C, σ, τ)
        VB = default_boundary(C, σ, τ)
        V <= VB && return 0.0
        p = (V / VB)^(-X(σ))
        return V - (1 - τ) * C / r + ((1 - τ) * C / r - VB) * p
    end

    firm_value(V, C, σ, τ, α) = debt_value(V, C, σ, τ, α) + equity_value(V, C, σ, τ)
end

# ╔═╡ 6fbc99b5-7033-4181-8075-18180e28eb9f
begin
    VB_now = default_boundary(C, σ, τ)
    Vs = range(1, 250, length=500)

    plt = plot(Vs, [equity_value(V, C, σ, τ) for V in Vs], label="equity", lw=2.5, color=:seagreen)
    plot!(plt, Vs, [debt_value(V, C, σ, τ, α) for V in Vs], label="debt", lw=2.5, color=:crimson)
    plot!(plt, Vs, [firm_value(V, C, σ, τ, α) for V in Vs], label="total (debt + equity)", lw=2.5, color=:navy, ls=:dash)
    plot!(plt, Vs, Vs, label="asset value V", color=:gray, ls=:dot)
    vline!(plt, [VB_now], label="default boundary = $(round(VB_now, digits=1))", color=:black, lw=1.5)
    plot!(plt, xlabel="asset value V", ylabel="value", title="Leland model: who owns what",
      legend=:topleft, size=(800, 450), framestyle=:box,
      left_margin=5Plots.mm, bottom_margin=5Plots.mm)
end

# ╔═╡ 63332502-359d-42e2-8ee6-1c2cfec9e656
md"""
### What to notice
1. **Equity flattens out as it hits the default boundary.** Its slope goes to zero right at the boundary. That is the smooth-pasting condition: shareholders default exactly where one more dollar of assets stops being worth anything extra to them.
2. **Equity is still worth something even when it looks hopeless.** Just above the boundary, the firm may owe far more than it is worth, yet equity is positive because the firm might recover. That is option value from limited liability.
3. **Debt drops sharply near default**, because creditors absorb the bankruptcy cost α. Increase α and watch the debt curve fall.
4. **The total can exceed V** when the firm is healthy, because coupons are tax-deductible. Increase τ to see the tax benefit grow. Bankruptcy costs pull the total back down near default, which is the tradeoff that determines how much debt a firm should take on.
5. **Increase σ and the default boundary moves left** (the chart below). Riskier firms keep paying longer, because their shareholders' option to wait is worth more.
"""

# ╔═╡ 06e28c47-3e43-4ad2-9717-ba799ab983b2
begin
    σs = range(0.05, 0.60, length=200)
    p2 = plot(σs, [default_boundary(C, s, τ) for s in σs], lw=2.5, color=:navy, label="default boundary",
              xlabel="asset volatility σ", ylabel="asset value at default",
             title="Riskier firms default later", size=(800, 350), framestyle=:box,
left_margin=5Plots.mm, bottom_margin=6Plots.mm)
    scatter!(p2, [σ], [VB_now], color=:crimson, markersize=7, label="current σ")
end

# ╔═╡ 3ef381b4-9d2e-454d-b248-c31b802005e4
md"""
### Simulating firms
Each line is one possible future for the firm's asset value. A path turns red and stops when it hits the default boundary. The simulation uses the exact solution of geometric Brownian motion, whose log grows at `μ − σ²/2` rather than `μ`: that is the Itô correction.

**Starting asset value V₀:** $(@bind V0 Slider(50.0:5.0:250.0, default=100.0, show_value=true))

**Expected asset growth μ:** $(@bind μ Slider(-0.05:0.01:0.15, default=0.05, show_value=true))
"""

# ╔═╡ c2bafdde-5635-4809-917b-d86da7e7ed00
function simulate_paths(V0, μ, σ, VB; T=10.0, steps=2520, npaths=1000, seed=1)
    rng = MersenneTwister(seed)
    dt = T / steps
    paths = fill(NaN, steps + 1, npaths)
    defaulted = falses(npaths)
    for j in 1:npaths
        V = V0
        paths[1, j] = V
        if V <= VB
            defaulted[j] = true
            continue
        end
        for i in 1:steps
            V *= exp((μ - σ^2 / 2) * dt + σ * sqrt(dt) * randn(rng))
            if V <= VB
                paths[i+1, j] = VB
                defaulted[j] = true
                break
            end
            paths[i+1, j] = V
        end
    end
    return paths, defaulted, dt
end

# ╔═╡ 0b4b3faa-260c-4485-a57e-8adee27a788c
begin
    paths, defaulted, dt_sim = simulate_paths(V0, μ, σ, VB_now)
    ts = (0:size(paths, 1)-1) .* dt_sim
    p3 = plot(xlabel="years", ylabel="asset value V", legend=false, size=(800, 400), framestyle=:box,
          left_margin=5Plots.mm, bottom_margin=6Plots.mm,
          title="25 sample firms ($(round(100 * mean(defaulted), digits=1))% of 1,000 default within 10 years)")
    for j in 1:25
        plot!(p3, ts, paths[:, j], color=defaulted[j] ? :crimson : :steelblue, alpha=0.6)
    end
    hline!(p3, [VB_now], color=:black, lw=2)
    p3
end

# ╔═╡ f3fba586-98d2-4faa-8487-964b38617db1
begin
    h = 1e-3
    Vtest = 1.5 * VB_now
    E(v) = equity_value(v, C, σ, τ)
    E1 = (E(Vtest + h) - E(Vtest - h)) / (2h)
    E2 = (E(Vtest + h) - 2E(Vtest) + E(Vtest - h)) / h^2
    ode_residual = 0.5σ^2 * Vtest^2 * E2 + r * Vtest * E1 - r * E(Vtest) - (1 - τ) * C
    slope_at_boundary = (E(VB_now + h) - E(VB_now)) / h

    details("Checks: Part 1", Markdown.parse("""
    These numerical checks test the closed-form solution against the math it is supposed to satisfy:

    - **Equity ODE residual** at 1.5 times the default boundary: `$(round(ode_residual, sigdigits=3))` (should be close to 0)
    - **Slope of equity just above the default boundary:** `$(round(slope_at_boundary, sigdigits=3))` (should be close to 0 by smooth pasting)
    """))
end

# ╔═╡ 1df6068d-1223-45e8-bc16-90d9a2df6487
md"""
### What this gets right and what it leaves out
**Gets right:** the core mechanism of strategic default. Shareholders decide when to stop paying, limited liability gives equity option value, and bankruptcy costs and taxes determine how value is split between debt and equity.

**Leaves out:**
- **Renegotiation.** In this model, default goes straight to liquidation. In reality, creditors and shareholders (or senior and junior creditors) bargain to avoid destroying value. Part 2 adds this with Nash bargaining.
- **A realistic capital structure.** There is one class of perpetual debt, not senior and junior tranches with maturities, and no voting by creditor classes.
- **Jumps.** Asset value moves continuously, so sudden collapses are impossible.
- **Observability.** The model takes asset value and volatility as known, but in practice only the stock price is observed.
- **Constant volatility and interest rates.**

### Resources
- Leland, H. (1994). "Corporate Debt Value, Bond Covenants, and Optimal Capital Structure." *Journal of Finance*.
- Professor Edelman's email on the intuition behind stochastic integration (Sept 30, 2026).
- Claude (Anthropic) helped draft this notebook's code. I ran it, tested the checks above, and can explain each formula.
"""

# ╔═╡ 20e091fc-6d37-4044-a80c-a1b1a808ef55
md"""
# Part 2: Negotiating Between Tranches

Part 1 had one class of debt and treated default as the end of the story. Real restructurings are fights over how value is split among **several tranches** of debt, and most of them are negotiated before anyone files. This part adds a senior and a junior tranche (2A) and then models the negotiation of a distressed exchange as a Nash bargaining problem (2B).

## 2A: The waterfall and the fulcrum

The firm now has two classes of perpetual debt:
- **Senior debt** with face value `Pₛ` and annual coupon `cₛ`
- **Junior debt** with face value `Pⱼ` and annual coupon `cⱼ`

Shareholders pay the total coupon `C = cₛ + cⱼ`, so the default boundary from Part 1 still applies with that total. What changes is what each tranche recovers at default. After bankruptcy costs, `(1 − α)V` is left, and it is paid out by **absolute priority**: senior first, up to its face value, then junior with whatever is left.

Each tranche is then priced with the same Leland machinery as Part 1. A tranche paying coupon `cᵢ` that recovers `Rᵢ` at default is worth

`Dᵢ(V) = cᵢ/r + (Rᵢ − cᵢ/r)(V/V_B)^(−X)`

which is the value of its coupons forever, adjusted for the loss at default (recall that `(V/V_B)^(−X)` acts like the present value of 1 paid at default).

The **fulcrum** is the most senior tranche that is not paid in full at default. In practice, it is the class that ends up owning the company after a restructuring.

These sliders set the debt structure. Volatility `σ`, bankruptcy cost `α`, and tax rate `τ` come from the sliders in Part 1.

**Senior face value Pₛ:** $(@bind sr_face Slider(10.0:5.0:80.0, default=40.0, show_value=true))

**Senior coupon rate:** $(@bind sr_rate Slider(0.03:0.005:0.10, default=0.06, show_value=true))

**Junior face value Pⱼ:** $(@bind jr_face Slider(10.0:5.0:80.0, default=60.0, show_value=true))

**Junior coupon rate:** $(@bind jr_rate Slider(0.05:0.005:0.14, default=0.09, show_value=true))
"""

# ╔═╡ de61b8b5-c79f-400c-ac0d-1c54ac6a65d3
begin
    # absolute priority: senior is paid first, junior gets what is left, equity gets any residual
    function liquidation_waterfall(V, Ps, Pj, α)
        L = (1 - α) * V
        senior = min(L, Ps)
        junior = min(max(L - Ps, 0.0), Pj)
        return (senior=senior, junior=junior, equity=max(L - Ps - Pj, 0.0))
    end

    # Leland values of equity, senior debt, and junior debt with two tranches
    function tranche_values(V, cs, cj, Ps, Pj, σ, τ, α)
        C = cs + cj
        VB = default_boundary(C, σ, τ)
        if V <= VB
            w = liquidation_waterfall(V, Ps, Pj, α)
            return (E=0.0, Ds=w.senior, Dj=w.junior, VB=VB, firm=w.senior + w.junior)
        end
        p = (V / VB)^(-X(σ))                      # value of 1 paid at default
        w = liquidation_waterfall(VB, Ps, Pj, α)  # recoveries if default happens at the boundary
        Ds = cs / r + (w.senior - cs / r) * p
        Dj = cj / r + (w.junior - cj / r) * p
        E = V - (1 - τ) * C / r + ((1 - τ) * C / r - VB) * p
        firm = V + τ * C / r * (1 - p) - α * VB * p  # assets + tax shield - bankruptcy costs
        return (E=E, Ds=Ds, Dj=Dj, VB=VB, firm=firm)
    end
end

# ╔═╡ f1ffafba-1e68-433e-99c0-996d0904f7e7
begin
    Vs_2A = range(1, 200, length=500)
    liq = [liquidation_waterfall(v, sr_face, jr_face, α) for v in Vs_2A]
    pa1 = plot(Vs_2A, [100 * w.senior / sr_face for w in liq], label="senior", lw=2.5, color=:navy)
    plot!(pa1, Vs_2A, [100 * w.junior / jr_face for w in liq], label="junior", lw=2.5, color=:crimson)
    plot!(pa1, xlabel="asset value V at filing", ylabel="recovery (% of face)",
          title="Liquidation waterfall: who is paid if the firm files", legend=:bottomright)

    cs_2A, cj_2A = sr_rate * sr_face, jr_rate * jr_face
    gc = [tranche_values(v, cs_2A, cj_2A, sr_face, jr_face, σ, τ, α) for v in Vs_2A]
    VB_2A = gc[1].VB
    pa2 = plot(Vs_2A, [g.Ds for g in gc], label="senior debt", lw=2.5, color=:navy)
    plot!(pa2, Vs_2A, [g.Dj for g in gc], label="junior debt", lw=2.5, color=:crimson)
    plot!(pa2, Vs_2A, [g.E for g in gc], label="equity", lw=2.5, color=:seagreen)
    vline!(pa2, [VB_2A], label="default boundary", color=:black)
    plot!(pa2, xlabel="asset value V", ylabel="value",
          title="Going-concern values with two tranches", legend=:topleft)

    plot(pa1, pa2, layout=(2, 1), size=(800, 700), framestyle=:box)
end

# ╔═╡ 6335d344-87d0-426d-969b-7d3d0df63ef5
begin
    at_boundary = liquidation_waterfall(VB_2A, sr_face, jr_face, α)
    fulcrum = at_boundary.senior < sr_face ? "senior" :
              at_boundary.junior < jr_face ? "junior" : "none (all debt is covered)"
    identity_err_2A = maximum(abs(g.E + g.Ds + g.Dj - g.firm) for g in gc)
    assumption_2A = (1 - α) * VB_2A <= sr_face + jr_face

    Markdown.parse("""
    **At the default boundary** (`V_B` = $(round(VB_2A, digits=1))), liquidation leaves $(round((1 - α) * VB_2A, digits=1)). The senior recovers $(round(100 * at_boundary.senior / sr_face, digits=0))% of face and the junior $(round(100 * at_boundary.junior / jr_face, digits=0))%. **Fulcrum tranche: $(fulcrum).**
    """)
end

# ╔═╡ db2c8b5a-6c8c-4a47-bce0-03fbb5357a7a
details("Checks: 2A", Markdown.parse("""
- Equity + senior + junior equals total firm value (assets + tax shield − expected bankruptcy costs), largest error: `$(round(identity_err_2A, sigdigits=3))` (should be close to 0)
- Debt is impaired at default, an assumption of these formulas: $(assumption_2A ? "satisfied" : "**violated** for these settings, so the values above are not reliable")
"""))

# ╔═╡ 09ca50b3-c1fa-4a68-be9f-d8784d23b95c
md"""
### What to notice in 2A
1. **The waterfall has kinks.** The junior recovers nothing until the senior is paid in full, then recovers one-for-one. Which tranche sits on the steep part depends on the asset value.
2. **The fulcrum tranche behaves like equity.** Near the default boundary, junior debt rises steeply with asset value, much like the equity curve. That is why the fulcrum class usually ends up owning the reorganized company: its payoff already moves like ownership.
3. **The senior is fairly flat.** It is protected by the junior beneath it, so its value barely moves until asset values fall far enough to reach it.

## 2B: Bargaining over a distressed exchange

**The situation.** The firm's assets have fallen *below* its default boundary, so without a deal shareholders would stop paying and the firm would file. Filing triggers the waterfall above, with bankruptcy costs destroying a fraction `α` of the assets.

**The deal.** Junior holders exchange each 100 of face value for `100x` of new junior debt with the same coupon rate. `x` is the **exchange rate**. A lower `x` cuts the firm's coupon, which lowers its default boundary below the current asset value, so the firm keeps operating.

**The bargaining problem.** Shareholders and junior holders negotiate over `x`. Each side's **disagreement payoff** is what it gets if the firm files: shareholders get nothing, and junior holders get their waterfall recovery `dⱼ`. The Nash bargaining solution picks the `x` that maximizes

`[E(x) − 0]^η · [Dⱼ(x) − dⱼ]^(1−η)`

where `η` is the shareholders' bargaining power and both payoffs are priced with the Leland formulas. This is a nonlinear problem because `x` changes the default boundary and therefore every value, so it is solved numerically over a fine grid of exchange rates.

**The debt-overhang effect.** The junior's value of its new debt, `Dⱼ(x)`, is not increasing in `x`. More face value means a higher coupon and a higher default boundary, so past some point each extra dollar of face makes default so likely that the total value falls. Even with all the bargaining power, junior holders would not push `x` past that peak.

**Asset value as a share of the pre-deal default boundary:** $(@bind distress Slider(0.80:0.01:0.99, default=0.97, show_value=true))

**Shareholders' bargaining power η:** $(@bind η Slider(0.0:0.05:1.0, default=0.5, show_value=true))
"""

# ╔═╡ 94853dea-cb83-4d41-8503-c5837b8df9e4
begin
    cs0, cj0 = sr_rate * sr_face, jr_rate * jr_face
    VB_pre = default_boundary(cs0 + cj0, σ, τ)
    V_deal = distress * VB_pre
    status_quo = liquidation_waterfall(V_deal, sr_face, jr_face, α)  # outcome if no deal: the firm files

    xs = range(0.0005, 1.0, length=2000)  # candidate exchange rates
    deal = [tranche_values(V_deal, cs0, cj0 * x, sr_face, jr_face * x, σ, τ, α) for x in xs]
    E_x = [d.E for d in deal]
    Dj_x = [d.Dj for d in deal]
    Ds_x = [d.Ds for d in deal]
    alive = [d.VB < V_deal for d in deal]  # the firm keeps operating after the deal
    gain_E = E_x .- status_quo.equity
    gain_J = Dj_x .- status_quo.junior
    feasible = alive .& (gain_E .> 0) .& (gain_J .> 0)  # both sides prefer the deal to filing

    nash_obj(i, η) = feasible[i] ? η * log(gain_E[i]) + (1 - η) * log(gain_J[i]) : -Inf

    function nash_solution(η)
        any(feasible) || return 0  # 0 means no deal both sides prefer
        return argmax([nash_obj(i, η) for i in eachindex(xs)])
    end

    nash_rate(η) = (k = nash_solution(η); k > 0 ? 100 * xs[k] : NaN)

    k_nash = nash_solution(η)
    k_creditor = argmax(ifelse.(alive, Dj_x, -Inf))  # rate that maximizes the junior's own value
end

# ╔═╡ 9ecf45f2-48a5-4e6c-b5f6-38f7d70010fe
begin
    xr = 100 .* collect(xs)
    pb1 = plot(xr, ifelse.(alive, Dj_x, NaN), label="junior: value of new debt", lw=2.5, color=:crimson)
    hline!(pb1, [status_quo.junior], label="junior: recovery if the firm files", color=:crimson, ls=:dash)
    plot!(pb1, xr, ifelse.(alive, E_x, NaN), label="shareholders: equity", lw=2.5, color=:seagreen)
    plot!(pb1, xr, ifelse.(alive, Ds_x, NaN), label="senior: debt value", lw=2, color=:navy)
    hline!(pb1, [status_quo.senior], label="senior: recovery if the firm files", color=:navy, ls=:dash)
    vline!(pb1, [xr[k_creditor]], label="junior's value-maximizing rate", color=:gray, ls=:dot, lw=2)
    if k_nash > 0
        vline!(pb1, [xr[k_nash]], label="Nash bargaining outcome", color=:black, lw=2)
    end
    plot!(pb1, xlabel="exchange rate (new face per 100 of old junior face)", ylabel="value",
          title="Payoffs from the exchange", legend=:outerright)

    ηs = 0.0:0.02:1.0
    pb2 = plot(ηs, nash_rate.(ηs), lw=2.5, color=:black, label="Nash exchange rate",
               xlabel="shareholders' bargaining power η", ylabel="exchange rate",
               title="Who has the leverage sets the exchange rate", legend=:topright)
    scatter!(pb2, [η], [k_nash > 0 ? xr[k_nash] : NaN], color=:crimson, markersize=7, label="current η")

    plot(pb1, pb2, layout=(2, 1), size=(900, 750), framestyle=:box, left_margin=6Plots.mm, bottom_margin=4Plots.mm)
end

# ╔═╡ 66cd009b-0654-4546-8e45-27afdc4a0fc1
if k_nash > 0
    d_star = deal[k_nash]
    Markdown.parse("""
    **If the firm files** (asset value $(round(V_deal, digits=1)), below the pre-deal boundary of $(round(VB_pre, digits=1))): the senior recovers $(round(status_quo.senior, digits=1)), the junior $(round(status_quo.junior, digits=1)), and shareholders nothing.

    **Nash bargaining outcome at η = $(η):** the junior exchanges at **$(round(xr[k_nash], digits=1))** per 100 of face. Afterward, the junior's new debt is worth $(round(d_star.Dj, digits=1)), equity is worth $(round(d_star.E, digits=1)), and the senior's debt is worth $(round(d_star.Ds, digits=1)). The new default boundary is $(round(d_star.VB, digits=1)).

    **Junior's value-maximizing exchange rate:** $(round(xr[k_creditor], digits=1)) per 100 of face. Asking for more face value than this would *lower* the junior's own value.
    """)
else
    Markdown.parse("""
    **No deal makes both sides better off than filing for these settings.** Try a different asset value or debt structure.
    """)
end

# ╔═╡ f138d0cb-6c14-4bcb-a65c-015bf8b840e2
begin
    identity_err_2B = maximum((abs(d.E + d.Ds + d.Dj - d.firm) for (d, a) in zip(deal, alive) if a); init=0.0)
    η0_gap = abs(nash_rate(0.0) - 100 * xs[k_creditor])
    local_max = k_nash > 1 && k_nash < length(xs) &&
                nash_obj(k_nash, η) >= nash_obj(k_nash - 1, η) &&
                nash_obj(k_nash, η) >= nash_obj(k_nash + 1, η)

    # re-solve on a 100x finer grid around the answer to check the grid is fine enough
    fine_rate = if k_nash > 0
        fine_x = range(xs[max(k_nash - 2, 1)], xs[min(k_nash + 2, length(xs))], length=401)
        fine_obj = map(fine_x) do x
            d = tranche_values(V_deal, cs0, cj0 * x, sr_face, jr_face * x, σ, τ, α)
            gE, gJ = d.E - status_quo.equity, d.Dj - status_quo.junior
            (d.VB < V_deal && gE > 0 && gJ > 0) ? η * log(gE) + (1 - η) * log(gJ) : -Inf
        end
        100 * fine_x[argmax(fine_obj)]
    else
        NaN
    end

    details("Checks: 2B", Markdown.parse("""
    - Equity + senior + junior equals total firm value for every feasible exchange rate, largest error: `$(round(identity_err_2B, sigdigits=3))` (should be close to 0)
    - With η = 0 (junior has all the power), the Nash rate should equal the junior's value-maximizing rate. Gap: `$(round(η0_gap, digits=3))` (should be within one grid step, 0.05)
    - The Nash solution is a local maximum of the Nash product: `$(local_max)`
    - Re-solving on a 100× finer grid gives `$(round(fine_rate, digits=2))` vs. `$(k_nash > 0 ? round(xr[k_nash], digits=2) : NaN)` (should agree to about 0.05)
    """))
end

# ╔═╡ 83aae712-4fa8-4f92-9ede-85976f84a68c
md"""
### What to notice in 2B
1. **Bargaining power sets the exchange rate.** As η rises, shareholders keep more of the value saved by not filing and the junior accepts a deeper cut. At η = 1 the junior gets just over its filing recovery; at η = 0 it gets its value-maximizing rate.
2. **Even with all the bargaining power, the junior takes a haircut.** Its value-maximizing rate is well below 100 because of debt overhang: leaving too much debt on a weak firm makes default so likely that the debt is worth less.
3. **The senior is not at the table, but its value changes.** Depending on the settings, the exchange can make the senior better or worse off than in a filing, even though it agreed to nothing. In practice this is why senior consent rights and intercreditor terms matter so much.
4. **Why are real exchange rates often much higher, closer to 90?** In this model the firm is already insolvent, so the deal has to restore solvency, which requires a deep cut. Many real exchanges are liquidity deals for firms that are not yet at the boundary: they extend maturities and add cash with only a shallow haircut. The model suggests the cost of that choice: the firm stays close to its new default boundary, which Part 2C will quantify as a probability of default before the next maturity.

### What 2A–2B get right and leave out
**Gets right:** absolute priority, the fulcrum, and a bargaining problem in which the exchange rate changes the firm's default risk and therefore every party's payoff.

**Leaves out:** only two tranches and two bargainers (real deals involve groups of holders who disagree with each other, which is Part 4E); no new money, maturity extensions, or change in priority (an uptier would move the exchanged debt ahead of the senior); and bargaining power is a free parameter rather than something derived from voting rules or document terms.

**Sources for the qualitative claims:** Leland (1994); Fan & Sundaresan (2000); RestructuringInterviews.com write-ups on Cision, AMC, and cooperation agreements.
"""

# ╔═╡ 60843037-ec7c-496e-b9f6-7fed5fdc0221
md"""
## 2C: The holdout problem

An out-of-court exchange is voluntary. Each junior holder decides for itself whether to swap into the new debt or **hold out** and keep its old bond. A holdout keeps two things participants give up:
- its full face value of 100, paid at the bond's **maturity date T** if the firm survives that long ("temporal seniority"), and
- its original coupon on 100 of face rather than on the reduced face.

Contract terms that set a bond's payment amount and maturity can't be changed without each holder's own consent (the Trust Indenture Act protects these "sacred rights"), so participants can't vote them away. What they can do is attach **exit consents** to the exchange: just before exchanging, participants vote to strip the old bond's covenants, which lets the company move the new debt ahead of the holdouts. In the model, a fraction `s` of the holdouts' bankruptcy recovery shifts to participants.

### The math: first-passage times
Whether holding out pays depends on one question: **does the firm hit its default boundary before the holdout's bond matures?** Let `τ_B` be the first time asset value falls to the boundary `B`. With `b = ln(V/B)` and log-drift `ν`, the reflection principle for Brownian motion gives the probability of defaulting before `T`:

`P(τ_B ≤ T) = N((−b − νT)/(σ√T)) + (B/V)^(2ν/σ²) · N((−b + νT)/(σ√T))`

where `N` is the standard normal CDF. Pricing also needs the discounted version, the present value of 1 paid at the moment of default if it happens before `T`. With `ζ = √(ν² + 2rσ²)`:

`E[e^(−rτ_B); τ_B ≤ T] = (V/B)^(−(ν+ζ)/σ²) · N((−b + ζT)/(σ√T)) + (V/B)^(−(ν−ζ)/σ²) · N((−b − ζT)/(σ√T))`

As `T → ∞` this becomes `(V/B)^(−X)`, the same factor used throughout Part 1, which is one of the checks below.

**Holdout value per 100 of face.** With coupon `c` paid until default or maturity, survival probability `S = 1 − P(τ_B ≤ T)`, discounted default factor `G = E[e^(−rτ_B); τ_B ≤ T]`, and recovery `R_h` at default,

`H = (c/r) · (1 − G − e^(−rT)S) + 100 · e^(−rT)S + R_h · G`

The first term is the coupons, the second is par at maturity, and the third is the recovery if the firm defaults first. Pricing uses the risk-neutral drift `ν = r − σ²/2`.

**Participant value per 100 of old face** is the Leland value from 2A of new perpetual debt with face `100x`, plus the recovery shifted from holdouts by the exit consents:

`P = c_p/r + (R_p − c_p/r)(V/V_B)^(−X)`, with `c_p = c · 100x` and `R_p = 100x · ρ + s · 100 · ρ · h/(1 − h)`

where `c` is the junior coupon rate, `ρ` is the junior's recovery per unit of face at default, and `h` is the fraction of holders holding out. The first recovery term is the participant's own share of the waterfall; the second is what exit consents take from holdouts (a fraction `s` of each holdout's recovery), shared among the `1 − h` participants. A holdout's recovery shrinks to `(1 − s) · 100 · ρ`, which is the last term of `H` above. The default boundary `V_B` rises with `h`, because holdouts keep their full face and coupon.

### The participation game
When a fraction `h` of holders holds out, the firm keeps more debt, so its default boundary rises and **everyone** is worse off. A single small holder ignores that effect on others and compares `Δ(h) = H(h) − P(h)`, the gain from holding out:
- If `Δ(0) ≤ 0`, full participation is an equilibrium: no holder gains by defecting.
- If `Δ` starts positive and falls to zero at some `h*`, holders defect until `h*`. The deal closes with `h*` holdouts if that is within the deal's minimum participation condition.
- If `Δ` stays positive up to the minimum participation threshold, holders keep defecting until the deal fails and the firm files.

A "deal fails" equilibrium always exists too: if everyone else holds out, one holder's choice can't save the deal. This coordination problem is the subject of Gertner & Scharfstein (1991).

This section uses the firm and debt structure from 2B, with the exchange offered at the rate below.

**Exchange rate offered (new face per 100 of old junior face):** $(@bind x_offer Slider(20:1:95, default=85, show_value=true))

**Holdout bond's time to maturity T (years):** $(@bind T_mat Slider(0.25:0.25:10.0, default=2.0, show_value=true))

**Exit-consent severity s** (share of holdouts' recovery shifted to participants): $(@bind sev Slider(0.0:0.05:1.0, default=0.5, show_value=true))

**Minimum participation condition:** $(@bind min_part Slider(0.50:0.05:1.0, default=0.85, show_value=true))
"""

# ╔═╡ 9ddc05cc-3be8-4757-a74d-1e9fe53e85f2
begin
    # standard normal CDF from the complementary error function approximation
    # in Numerical Recipes (erfcc); accurate to about 1e-7, so no extra package is needed
    function normcdf(z)
        u = -z / sqrt(2)  # N(z) = erfc(-z/√2) / 2
        t = 1 / (1 + 0.5 * abs(u))
        y = t * exp(-u^2 - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 +
            t * (-0.18628806 + t * (0.27886807 + t * (-1.13520398 + t * (1.48851587 +
            t * (-0.82215223 + t * 0.17087277)))))))))
        return (u >= 0 ? y : 2 - y) / 2
    end

    # P(firm value falls from V to the boundary B before time T), log-drift ν
    function prob_hit_before(V, B, ν, σ, T)
        b, sT = log(V / B), σ * sqrt(T)
        return normcdf((-b - ν * T) / sT) + (B / V)^(2ν / σ^2) * normcdf((-b + ν * T) / sT)
    end

    # E[e^(-r τ_B); τ_B ≤ T]: present value of 1 paid at default, if default happens before T
    function pv_hit_before(V, B, ν, σ, r, T)
        b, sT = log(V / B), σ * sqrt(T)
        ζ = sqrt(ν^2 + 2r * σ^2)
        return (V / B)^(-(ν + ζ) / σ^2) * normcdf((-b + ζ * T) / sT) +
               (V / B)^(-(ν - ζ) / σ^2) * normcdf((-b - ζ * T) / sT)
    end

    # payoffs per 100 of old junior face when a fraction hold_frac holds out
    function exchange_outcome(x, hold_frac, T, s_exit)
        fac = (1 - hold_frac) * x + hold_frac              # junior face remaining, per unit of old face
        VB_h = default_boundary(cs0 + cj0 * fac, σ, τ)
        VB_h >= V_deal && return nothing                   # the deal doesn't restore solvency
        ρ = liquidation_waterfall(VB_h, sr_face, jr_face * fac, α).junior / (jr_face * fac)  # junior recovery per unit of face
        p = (V_deal / VB_h)^(-X(σ))

        c_part = jr_rate * 100 * x
        R_part = 100 * x * ρ + s_exit * 100 * ρ * hold_frac / (1 - hold_frac)
        part = c_part / r + (R_part - c_part / r) * p      # Leland perpetual debt value

        ν_rn = r - σ^2 / 2                                 # risk-neutral log-drift
        S = 1 - prob_hit_before(V_deal, VB_h, ν_rn, σ, T)
        Gd = pv_hit_before(V_deal, VB_h, ν_rn, σ, r, T)
        c_hold = jr_rate * 100
        hold = c_hold / r * (1 - Gd - exp(-r * T) * S) + 100 * exp(-r * T) * S + (1 - s_exit) * 100 * ρ * Gd
        return (part=part, hold=hold, VB=VB_h, survive=S, ρ=ρ)
    end

    filing_per_100 = 100 * status_quo.junior / jr_face   # junior recovery per 100 if the firm files
end

# ╔═╡ a531dfdf-13e3-47cf-8749-11eea93e9d16
begin
    x_frac = x_offer / 100
    hold_grid = collect(0.0:0.005:(1 - min_part))
    outcomes = [exchange_outcome(x_frac, hf, T_mat, sev) for hf in hold_grid]
    n_ok = something(findfirst(isnothing, outcomes), length(outcomes) + 1) - 1
    Δ_hold = [o.hold - o.part for o in outcomes[1:n_ok]]

    eq_kind, eq_hold = if n_ok == 0
        (:insolvent, NaN)
    elseif Δ_hold[1] <= 0
        (:full, 0.0)
    elseif (k_eq = findfirst(<=(0), Δ_hold)) !== nothing
        (:interior, hold_grid[k_eq])
    else
        (:fails, NaN)
    end
end

# ╔═╡ d755d9ad-d109-4f80-ba2f-e3cdf158c7bf
if eq_kind == :insolvent
    md"**At this exchange rate the deal leaves too much debt to restore solvency.** Lower the exchange rate."
else
    o0 = outcomes[1]
    p_rn = 1 - o0.survive
    p_real = prob_hit_before(V_deal, o0.VB, μ - σ^2 / 2, σ, T_mat)
    verdict = eq_kind == :full ? "**Full participation is an equilibrium.** No individual holder gains by holding out, so the deal closes with everyone in." :
              eq_kind == :interior ? "**Holders defect until $(round(100 * eq_hold, digits=1))% hold out**, where holding out stops paying. That is within the $(round(Int, 100 * (1 - min_part)))% the deal allows, so it closes with a stub of holdouts left behind." :
              "**Holding out pays at every participation level the deal allows**, so holders keep defecting until participation falls below $(round(Int, 100 * min_part))% and the deal fails. The firm files, and junior holders get $(round(filing_per_100, digits=1)) per 100."
    Markdown.parse("""
    **With full participation:** the new default boundary is $(round(o0.VB, digits=1)) vs. asset value $(round(V_deal, digits=1)). The probability of default before the holdout bond matures is $(round(100 * p_rn, digits=1))% under risk-neutral pricing and $(round(100 * p_real, digits=1))% under the real-world growth rate μ = $(μ) from Part 1.

    Per 100 of old face, a participant's new debt is worth **$(round(o0.part, digits=1))**, a lone holdout's bond is worth **$(round(o0.hold, digits=1))**, and filing would pay $(round(filing_per_100, digits=1)).

    $(verdict)
    """)
end

# ╔═╡ 07c638c0-daea-48f3-8435-cd490ca13f97
begin
    T_grid = 0.25:0.25:10.0
    by_T = [exchange_outcome(x_frac, 0.0, t, sev) for t in T_grid]
    pc1 = plot(xlabel="holdout bond's time to maturity T (years)", ylabel="value per 100 of old face",
               title="Holding out vs. participating (one small holder)", legend=:topright)
    if all(!isnothing, by_T)
        plot!(pc1, T_grid, [o.hold for o in by_T], lw=2.5, color=:crimson, label="hold out")
        plot!(pc1, T_grid, [o.part for o in by_T], lw=2.5, color=:navy, label="participate")
        vline!(pc1, [T_mat], color=:gray, ls=:dot, label="current T")
    end
    hline!(pc1, [filing_per_100], color=:black, ls=:dash, label="if the firm files")

    pc2 = plot(xlabel="fraction of holders holding out", ylabel="gain from holding out, Δ",
               title="The participation game", legend=:topright)
    if n_ok > 0
        plot!(pc2, hold_grid[1:n_ok], Δ_hold, lw=2.5, color=:black, label="Δ = hold out − participate")
    end
    hline!(pc2, [0.0], color=:gray, label="")
    vline!(pc2, [1 - min_part], color=:crimson, ls=:dash, label="deal fails beyond here")
    if eq_kind == :interior
        scatter!(pc2, [eq_hold], [0.0], color=:crimson, markersize=7, label="equilibrium")
    end

    plot(pc1, pc2, layout=(2, 1), size=(800, 700), framestyle=:box)
end

# ╔═╡ 78f69312-3bb1-4b2d-84db-4da0154f52d2
begin
    sev_grid = 0.0:0.05:1.0
    Δ_map = [(o = exchange_outcome(x_frac, 0.0, t, s); isnothing(o) ? NaN : o.hold - o.part)
             for s in sev_grid, t in T_grid]
    lim = maximum(abs, filter(!isnan, Δ_map); init=1.0)
 heatmap(T_grid, sev_grid, Δ_map, c=cgrad(:RdBu, rev=true), clims=(-lim, lim),
        xlabel="holdout bond's time to maturity T (years)", ylabel="exit-consent severity s",
        title="Where holding out pays (red) and where it doesn't (blue)",
        colorbar_title="Δ", size=(800, 450), framestyle=:box,
        left_margin=5Plots.mm, bottom_margin=6Plots.mm)
    if !any(isnan, Δ_map)
        contour!(T_grid, sev_grid, Δ_map, levels=[0.0], color=:black, lw=2, colorbar_entry=false)
    end
    current()
end

# ╔═╡ f0a1bac3-246b-46be-b494-e8159fe5905b
begin
    # Monte Carlo check of the first-passage formula, with and without the Brownian-bridge correction
    function mc_first_passage(V0, B, ν, σ, T; npaths=20_000, steps=250, seed=7)
        rng = MersenneTwister(seed)
        dt = T / steps
        naive, bridge = 0.0, 0.0
        for j in 1:npaths
            d = log(V0 / B)            # log-distance to the boundary
            survive = 1.0              # probability of not crossing between the simulated points
            hit = false
            for i in 1:steps
                d_next = d + ν * dt + σ * sqrt(dt) * randn(rng)
                if d_next <= 0
                    hit = true
                    break
                end
                survive *= 1 - exp(-2d * d_next / (σ^2 * dt))  # chance a Brownian bridge dips below 0
                d = d_next
            end
            naive += hit
            bridge += hit ? 1.0 : 1 - survive
        end
        return naive / npaths, bridge / npaths
    end

    if eq_kind == :insolvent
        md"*Checks need a feasible exchange rate.*"
    else
        B_chk = outcomes[1].VB
        ν_chk = r - σ^2 / 2
        p_formula = prob_hit_before(V_deal, B_chk, ν_chk, σ, T_mat)
        p_naive, p_bridge = mc_first_passage(V_deal, B_chk, ν_chk, σ, T_mat)
        leland_limit_err = abs(pv_hit_before(V_deal, B_chk, ν_chk, σ, r, 1000.0) - (V_deal / B_chk)^(-X(σ)))
        o_long = exchange_outcome(x_frac, 0.0, 1000.0, 0.0)
        perpetual = jr_rate * 100 / r + (100 * o_long.ρ - jr_rate * 100 / r) * (V_deal / B_chk)^(-X(σ))
        long_bond_err = abs(o_long.hold - perpetual)

        details("Checks: 2C", Markdown.parse("""
        - **First-passage formula vs. Monte Carlo** (20,000 paths): formula `$(round(p_formula, digits=4))`, simulation checking the boundary only at the simulated points `$(round(p_naive, digits=4))`, simulation with the Brownian-bridge correction `$(round(p_bridge, digits=4))`. The bridge-corrected value should be within about 0.007 of the formula. The uncorrected simulation should come out lower, because it misses paths that dip below the boundary between steps, the same issue as the daily checks in Part 1's simulation.
        - **Long-maturity limit of the discounted default factor** vs. Leland's `(V/B)^(−X)`, error: `$(round(leland_limit_err, sigdigits=3))` (should be close to 0)
        - **A holdout bond with a 1,000-year maturity** should be worth the same as a perpetual Leland bond, error: `$(round(long_bond_err, sigdigits=3))` (should be close to 0)
        """))
    end
end

# ╔═╡ 41195afb-7e37-4ee1-bd7f-d004e3bacb3e
md"""
### What to notice in 2C
1. **Short maturities make holding out pay.** With a near-dated bond, the firm will probably survive long enough to pay the holdout in full, so the holdout free-rides on everyone else's concessions. Move T from 2 down to 1 and the deal fails; move it up to 3 and everyone participates. This is the AMC vs. STG contrast: AMC's left-behind notes were close to maturity at a healthier firm, while STG's maturity was far off.
2. **Exit consents are the counterweight.** Raising `s` shrinks the region where holding out pays (the red area in the heatmap), because holdouts lose more if the firm defaults before they're paid. But they matter less when default before maturity is unlikely, which is why exit consents alone can't fix a short-dated holdout problem.
3. **Holding out has an externality.** Every holdout keeps more debt on the firm, raising the default boundary for everyone. That's why the gain from holding out falls as more holders defect, and why an equilibrium can leave a stub of holdouts behind.
4. **Deep haircuts don't work out of court.** Set the exchange rate near the 2B Nash outcome (around 33) and holding out pays at every maturity and exit-consent level: a holdout keeps a claim to 100 at maturity while participants accept a third of that. That is the model's version of why deeply distressed firms use Chapter 11: a plan confirmed by two-thirds in amount and more than half in number of each voting class binds everyone in that class, holdouts included.
5. **Raising the exchange rate can increase participation.** More face value for participants means more debt and more default risk, which hurts the holdout's chance of being paid at maturity more than it hurts participants.

### What 2C gets right and leaves out
**Gets right:** the race between maturity and default that drives holdout behavior, the externality holdouts impose, and the role of exit consents in out-of-court exchanges.

**Leaves out:** the default boundary is held at its perpetual-debt level even though the holdout bond has a finite maturity (in reality, shareholders' default decision would change as the maturity approaches); the firm is assumed to pay the stub at maturity if it hasn't defaulted; holders are identical (Part 4E gives them different entry prices); and there's no litigation or "nuisance value," which may have been the main reason STG's holdouts stayed out.

**Sources:** Gertner, R. & Scharfstein, D. (1991). "A Theory of Workouts and the Effects of Reorganization Law." *Journal of Finance*; RestructuringInterviews.com, Restructuring Overview guide and the AMC and STG write-ups. First-passage formulas: standard results for Brownian motion with drift (see Shreve, *Stochastic Calculus for Finance II*, chapter 7).
"""

# ╔═╡ ca197279-bd25-4c7b-9440-50a422d91df6
md"""
# Part 3: Calibrating to a real deal (Carvana, 2023)

**What happened.** By spring 2023, Carvana owed about 5.7 billion dollars in unsecured notes across five series. A first exchange offer failed in June 2023 when it couldn't reach its 500 million dollar minimum, partly because a creditor group including Apollo and Pimco opposed it. The company then negotiated with that group, and in August 2023 offered:
- **2025 notes:** 85 cents in cash per dollar of face (a cash tender)
- **2027, 2028, 2029, 2030 notes:** new **secured** notes worth 76.7, 66.8, 65.0, and 89.4 per 100 of face, ranked ahead of anything left unsecured (an uptier)
- **Exit consents:** tendering holders consented to strip "substantially all of the restrictive covenants" from the old notes.

More than 90% of holders had committed in advance. Final participation was 80.3% for the 2025 notes and 94.7%, 96.3%, 96.6%, and 99.2% for the others. Total debt fell by more than 1.3 billion dollars.

**The light calibration.** Most inputs come straight from the filings (face amounts, coupons, maturities, offer terms). Asset value can't be observed, and Carvana's stock was too volatile in 2023 to back it out reliably, so instead I back out the **asset value that makes the model price the 2025 notes at 78**, their reported price just before the first offer failed. Then the model, with no further fitting, predicts what a holdout in each series would be worth after the deal. If the company priced each series sensibly, its offer should be close to the model's holdout value: enough to make holders indifferent, but no more.

**Approximations (stated honestly):** Debt ranked ahead of the notes (real estate financing, finance leases, and the drawn floor-plan facility) is lumped into one senior tranche of about 1.6 billion dollars at about 6.5%, estimated from the balance sheet totals; asset-backed receivable facilities are excluded because they are paid from their own receivables. The new notes are treated as perpetual 9% debt (ignoring their initial PIK periods and 2028–2031 maturities). The tax rate is set to 0 because Carvana had large tax losses. Maturities are measured from mid-2023, and r = 5% as in the rest of the notebook. Volatility and bankruptcy costs are sliders because they can't be read off a filing.

**Asset volatility σ:** $(@bind cv_σ Slider(0.25:0.05:0.60, default=0.40, show_value=true))

**Bankruptcy cost α:** $(@bind cv_α Slider(0.10:0.05:0.50, default=0.30, show_value=true))
"""

# ╔═╡ c219b166-80e7-4a27-9391-c5e5a5f6187d
html"""
<svg viewBox="0 0 760 200" width="100%" style="max-width:760px;font-family:inherit" role="img" aria-label="Carvana timeline: creditor group forms in 2022; first exchange offer in March 2023; it fails in June; agreement with noteholders on July 19; offers launched August 2; results August 31 with 80 to 99 percent participation and over 1.3 billion dollars of debt cut">
  <line x1="40" y1="70" x2="720" y2="70" stroke="#888" stroke-width="3"/>
  <circle cx="60" cy="70" r="9" fill="#555"/>
  <circle cx="190" cy="70" r="9" fill="#2b6f8f"/>
  <circle cx="320" cy="70" r="9" fill="#a8434f"/>
  <circle cx="450" cy="70" r="9" fill="#2b6f8f"/>
  <circle cx="570" cy="70" r="9" fill="#2b6f8f"/>
  <circle cx="700" cy="70" r="9" fill="#3a7d44"/>
  <text x="60" y="45" text-anchor="middle" fill="currentColor" font-size="13" font-weight="bold">2022</text>
  <text x="190" y="45" text-anchor="middle" fill="currentColor" font-size="13" font-weight="bold">Mar 2023</text>
  <text x="320" y="45" text-anchor="middle" fill="currentColor" font-size="13" font-weight="bold">Jun 2023</text>
  <text x="450" y="45" text-anchor="middle" fill="currentColor" font-size="13" font-weight="bold">Jul 19</text>
  <text x="570" y="45" text-anchor="middle" fill="currentColor" font-size="13" font-weight="bold">Aug 2</text>
  <text x="700" y="45" text-anchor="middle" fill="currentColor" font-size="13" font-weight="bold">Aug 31</text>
  <text x="60" y="100" text-anchor="middle" fill="currentColor" font-size="12">Creditor group</text>
  <text x="60" y="116" text-anchor="middle" fill="currentColor" font-size="12">forms (Apollo,</text>
  <text x="60" y="132" text-anchor="middle" fill="currentColor" font-size="12">Pimco, others)</text>
  <text x="190" y="100" text-anchor="middle" fill="currentColor" font-size="12">First exchange</text>
  <text x="190" y="116" text-anchor="middle" fill="currentColor" font-size="12">offer, opposed</text>
  <text x="190" y="132" text-anchor="middle" fill="currentColor" font-size="12">by the group</text>
  <text x="320" y="100" text-anchor="middle" fill="currentColor" font-size="12">Fails: misses its</text>
  <text x="320" y="116" text-anchor="middle" fill="currentColor" font-size="12">500 million dollar</text>
  <text x="320" y="132" text-anchor="middle" fill="currentColor" font-size="12">minimum</text>
  <text x="450" y="100" text-anchor="middle" fill="currentColor" font-size="12">Deal agreed with</text>
  <text x="450" y="116" text-anchor="middle" fill="currentColor" font-size="12">the group; over</text>
  <text x="450" y="132" text-anchor="middle" fill="currentColor" font-size="12">90% committed</text>
  <text x="570" y="100" text-anchor="middle" fill="currentColor" font-size="12">Offers launched:</text>
  <text x="570" y="116" text-anchor="middle" fill="currentColor" font-size="12">cash tender, uptier,</text>
  <text x="570" y="132" text-anchor="middle" fill="currentColor" font-size="12">exit consents</text>
  <text x="700" y="100" text-anchor="middle" fill="currentColor" font-size="12">80–99%</text>
  <text x="700" y="116" text-anchor="middle" fill="currentColor" font-size="12">participate; debt</text>
  <text x="700" y="132" text-anchor="middle" fill="currentColor" font-size="12">cut by 1.3 billion+</text>
  <text x="380" y="180" text-anchor="middle" fill="currentColor" font-size="13" font-style="italic">The first offer went around the creditor group and failed; the second was negotiated with it and succeeded.</text>
</svg>
"""

# ╔═╡ a6b4a7f4-5a65-42ac-979b-b46f66ea9ce4
begin
    # Carvana's unsecured notes in mid-2023 (amounts in billions of dollars)
    cv_names = ["2025 notes (5.625%)", "2027 notes (5.500%)", "2028 notes (5.875%)", "2029 notes (4.875%)", "2030 notes (10.250%)"]
    cv_face = [0.500, 0.600, 0.600, 0.750, 3.275]
    cv_cpn = [0.05625, 0.055, 0.05875, 0.04875, 0.1025]
    cv_T = [2.3, 4.3, 5.3, 6.3, 6.9]                     # years to maturity from mid-2023 (approximate)
    cv_offer_notes = [NaN, 0.76738, 0.668, 0.65008, 0.8935]  # new secured notes per 1 of face
    cv_offer_cash = 0.85                                 # cash per 1 of face for the 2025 notes
    cv_particip = [0.803, 0.947, 0.963, 0.966, 0.992]    # share of each series that participated
    cv_S, cv_cS = 1.6, 0.065                             # debt ranked ahead of the notes (estimate)
    cv_new_cpn = 0.09                                    # cash coupon on the new secured notes
    cv_price_2025 = 0.78                                 # reported price of the 2025 notes before the deal

    cv_U = sum(cv_face)
    cv_cU = sum(cv_face .* cv_cpn)                       # annual coupon on all unsecured notes
    cv_N = sum(cv_face[i] * cv_offer_notes[i] for i in 2:5)  # new secured notes issued at full participation
    cv_cash = cv_offer_cash * cv_face[1]                 # cash paid out in the 2025 tender

    # recoveries at default: senior first, then the new secured notes, then unsecured
    function cv_waterfall(VB, αv, S, N, U)
        L = (1 - αv) * VB
        sr = min(L, S)
        nw = min(max(L - S, 0.0), N)
        un = min(max(L - S - N, 0.0), U)
        return (senior=sr, new=nw, unsecured=un)
    end

    # value per 1 of face of a bond with coupon c and maturity T (the 2C holdout formula)
    function cv_bond(V, B, c, T, R, σv)
        ν = r - σv^2 / 2
        S = 1 - prob_hit_before(V, B, ν, σv, T)
        Gd = pv_hit_before(V, B, ν, σv, r, T)
        return c / r * (1 - Gd - exp(-r * T) * S) + exp(-r * T) * S + R * Gd
    end

    # model price of the 2025 notes before the deal, at asset value V
    function cv_price_pre(V, σv, αv)
        B = default_boundary(cv_S * cv_cS + cv_cU, σv, 0.0)  # tax rate 0: Carvana had large tax losses
        V <= B && return NaN
        R = cv_waterfall(B, αv, cv_S, 0.0, cv_U).unsecured / cv_U
        return cv_bond(V, B, cv_cpn[1], cv_T[1], R, σv)
    end

    # asset value that reproduces the observed 2025 note price (bisection)
    function cv_implied_V(σv, αv)
        B = default_boundary(cv_S * cv_cS + cv_cU, σv, 0.0)
        lo, hi = B * (1 + 1e-6), 20B
        for _ in 1:200
            mid = (lo + hi) / 2
            cv_price_pre(mid, σv, αv) < cv_price_2025 ? (lo = mid) : (hi = mid)
        end
        return (lo + hi) / 2
    end
end

# ╔═╡ 34db0b16-4294-4a54-9634-3db02709a0b8
begin
    cv_V = cv_implied_V(cv_σ, cv_α)
    cv_Bpre = default_boundary(cv_S * cv_cS + cv_cU, cv_σ, 0.0)
    cv_Vpost = cv_V - cv_cash                            # the cash tender is paid from assets
    cv_Bpost = default_boundary(cv_S * cv_cS + cv_new_cpn * cv_N, cv_σ, 0.0)
    cv_p = (cv_Vpost / cv_Bpost)^(-X(cv_σ))
    cv_w = cv_waterfall(cv_Bpost, cv_α, cv_S, cv_N, 0.0)
    cv_newval = cv_new_cpn / r + (cv_w.new / cv_N - cv_new_cpn / r) * cv_p   # value per 1 of face of the new notes
    cv_Rhold = (1 - cv_α) * cv_Bpost > cv_S + cv_N ? 1.0 : 0.0              # holdouts rank behind the new secured notes
    cv_hold = [cv_bond(cv_Vpost, cv_Bpost, cv_cpn[i], cv_T[i], cv_Rhold, cv_σ) for i in 1:5]
    cv_offer = [i == 1 ? cv_offer_cash : cv_offer_notes[i] * cv_newval for i in 1:5]
    cv_corr = cor(cv_hold[2:5], cv_offer[2:5])
end

# ╔═╡ 476f3a02-a5c4-46a5-8feb-082c453936a4
begin
    cv_rows = ["| $(cv_names[i]) | $(cv_T[i]) | $(round(100 * cv_offer[i], digits=1))$(i == 1 ? " (cash)" : "") | $(round(100 * cv_hold[i], digits=1)) | $(round(100 * (cv_offer[i] - cv_hold[i]), digits=1)) | $(round(100 * cv_particip[i], digits=1))% |" for i in 1:5]
    Markdown.parse("""
    **Implied asset value:** $(round(cv_V, digits=2)) billion (pre-deal default boundary $(round(cv_Bpre, digits=2)) billion). **After the deal:** default boundary $(round(cv_Bpost, digits=2)) billion; each 1 of face of the new secured notes is worth $(round(cv_newval, digits=3)).

    | Series | Years to maturity | Offer, value per 100 | Model holdout value per 100 | Offer minus holdout | Actual participation |
    |:--|--:|--:|--:|--:|--:|
    $(join(cv_rows, "\n"))

    **Correlation between the offer value and the model holdout value across the four exchanged series: $(round(cv_corr, digits=3)).**
    """)
end

# ╔═╡ fee13f01-3167-4982-8db8-22c54d599c64
begin
    pcv = plot([45, 95], [45, 95], color=:gray, ls=:dash, label="offer = holdout value",
           xlabel="model: value of holding out (per 100)", ylabel="Carvana's offer: value of participating (per 100)",
           title="Did Carvana price each series at its holdout value?", legend=:topleft,
           size=(800, 500), framestyle=:box, xlims=(45, 95), ylims=(45, 95),
           left_margin=6Plots.mm, bottom_margin=5Plots.mm)
    scatter!(pcv, 100 .* cv_hold, 100 .* cv_offer, color=[:crimson, :navy, :navy, :navy, :navy], markersize=7, label="")
    for i in 1:5
        annotate!(pcv, 100 * cv_hold[i] + 1, 100 * cv_offer[i], text(cv_names[i][1:4], 9, :left))
    end
    pcv
end

# ╔═╡ 8eb64a8f-792d-4846-9bba-8a3845e4ef61
details("Checks: Part 3", Markdown.parse("""
- The model price of the 2025 notes at the implied asset value: `$(round(cv_price_pre(cv_V, cv_σ, cv_α), digits=4))` (should equal the observed 0.78; at very low volatility and bankruptcy costs no asset value can produce a price that low, and this check will show it)
- New secured notes issued at full participation: `$(round(cv_N, digits=3))` billion (the launch announcement says up to 4.275 billion)
- The deal must leave the firm above its new default boundary: asset value after the deal `$(round(cv_Vpost, digits=2))` vs. boundary `$(round(cv_Bpost, digits=2))`
"""))

# ╔═╡ b01f3dab-e030-4b2d-ac91-cc707ba0d591
md"""
### What to notice in Part 3
1. **The offers track the holdout values.** For the four exchanged series, Carvana's offers line up closely with what the model says a holdout would be worth, with a correlation around 0.95 across the whole volatility range. The model was fitted to only one bond price, so this is a genuine out-of-sample test. The ranking also makes sense: the high-coupon 2030 notes got the best exchange ratio because holding them out is worth the most, and the low-coupon, long-dated 2029 notes got the worst.
2. **Exit consents and the uptier did the heavy lifting.** Because a holdout would rank behind 4.3 billion dollars of new secured notes, its bankruptcy recovery is close to zero in the model. Its value comes almost entirely from the chance of being paid in full at maturity, which is the 2C mechanism.
3. **What the model doesn't explain: the 2025 notes.** The model says 85 cents in cash beat holding out, yet only 80.3% tendered, the lowest of any series. Possible reasons: holders who expected a turnaround (the real-world growth rate μ is higher than the risk-neutral one used for pricing), the 2025 notes being the closest to maturity (temporal seniority, as at AMC), or smaller holders outside the creditor group. In hindsight, Carvana's turnaround made holding out look smart, but that's the real-world path, not the price at the time.
4. **Participation was decided by a coalition, not by individuals.** More than 90% of holders were committed before launch. That's Part 4E's subject: the bargaining happens inside the creditor group, and the offer only has to be good enough for the group.

**Sources:** Carvana Form 8-Ks of June 1, 2023 (termination of the first offers), August 2, 2023 (exchange offer launch and terms), and August 31, 2023 (results); Carvana 10-Q for the quarter ended June 30, 2023 (balance sheet totals); Bloomberg via BNN Bloomberg (2025 note price and the creditor group).
"""

# ╔═╡ 87e2c7f9-745a-4ac6-89ac-28734f4cc630
md"""
# Part 4: The restructuring toolkit

Each section below takes one lever from the project map and shows who gains and who loses when a company pulls it. Volatility `σ`, bankruptcy cost `α`, and tax rate `τ` come from the Part 1 sliders unless a section says otherwise.

## 4A: Uptiers and the coalition game (priority)

In an **uptier**, some lenders exchange their debt into new debt ranked *ahead* of the old debt, usually while providing new money. In a **pro rata** uptier, every lender is offered the same deal. In a **non-pro rata** uptier, the company works with a majority group only, and the excluded minority is left behind, now subordinated. In 2020, a majority group of Serta Simmons' first-lien lenders did this; in December 2024 the Fifth Circuit ruled the transaction wasn't permitted under the loan agreement's "open market purchase" exception.

**The model.** A firm owes 100 of debt with an 8% coupon. A coalition holding a fraction `m` of the debt exchanges into priority debt (`k` of new face per 1 of old face) and lends new money `NM`, also with priority. Amending the loan to allow this needs "required lenders," usually a simple majority, so `m` must be at least 0.5. Each tranche is priced with the Leland formulas from 2A at the new default boundary. Setting `m = 1` gives the pro rata case.

**The coalition game.** The coalition's gain comes at the outsiders' expense, and it's split among fewer lenders when the coalition is smaller. So the model predicts what political scientists call the **size principle** (Riker, 1962): coalitions should be just big enough to win.

**Asset value V:** $(@bind up_V Slider(75.0:1.0:120.0, default=85.0, show_value=true))

**Exchange ratio k** (new priority face per 1 of old face): $(@bind up_k Slider(0.70:0.05:1.0, default=0.90, show_value=true))

**New money from the coalition NM:** $(@bind up_NM Slider(0.0:2.0:30.0, default=10.0, show_value=true))

**Coalition size m:** $(@bind up_m Slider(0.50:0.01:1.0, default=0.60, show_value=true))
"""

# ╔═╡ bc127fb8-c962-432e-9bcc-a78b6016ad86
begin
    up_D, up_c = 100.0, 0.08

    # before any deal: one class of debt
    function up_status_quo(V)
        B = default_boundary(up_c * up_D, σ, τ)
        V <= B && return (debt=100 * (1 - α) * V / up_D, E=0.0, B=B)
        p = (V / B)^(-X(σ))
        L = (1 - α) * B
        Dv = up_c * up_D / r + (min(L, up_D) - up_c * up_D / r) * p
        E = V - (1 - τ) * up_c * up_D / r + ((1 - τ) * up_c * up_D / r - B) * p
        return (debt=100 * Dv / up_D, E=E, B=B)
    end

    # a coalition holding fraction m swaps into priority debt and adds new money; the rest are left behind
    function up_uptier(m, k, NM, V)
        Fp = k * m * up_D + NM          # priority debt held by the coalition
        Fo = (1 - m) * up_D             # old debt held by outsiders
        Va = V + NM                     # new money adds to assets
        C = up_c * (Fp + Fo)
        B = default_boundary(C, σ, τ)
        Va <= B && return nothing
        p = (Va / B)^(-X(σ))
        L = (1 - α) * B
        Rp = min(L, Fp)
        Ro = min(max(L - Fp, 0.0), Fo)
        Dp = up_c * Fp / r + (Rp - up_c * Fp / r) * p
        Do = Fo > 0 ? up_c * Fo / r + (Ro - up_c * Fo / r) * p : 0.0
        E = Va - (1 - τ) * C / r + ((1 - τ) * C / r - B) * p
        firm = Va + τ * C / r * (1 - p) - α * B * p
        return (insider=100 * (Dp - NM) / (m * up_D),       # net of the new money they put in
                outsider=Fo > 0 ? 100 * Do / Fo : NaN,
                E=E, B=B, err=abs(Dp + Do + E - firm))
    end
end

# ╔═╡ 16d73146-deaf-405e-a8b4-a34e1c0d93d9
begin
    up_sq = up_status_quo(up_V)
    up_ms = 0.50:0.01:1.0
    up_res = [up_uptier(m, up_k, up_NM, up_V) for m in up_ms]
    up_ok = [!isnothing(o) for o in up_res]
    up_ins = [o === nothing ? NaN : o.insider for o in up_res]
    up_out = [o === nothing ? NaN : o.outsider for o in up_res]

   pup = plot(up_ms, up_ins, lw=2.5, color=:navy, label="coalition member (net of new money)",
           xlabel="coalition size m (share of the old debt)", ylabel="value per 100 of old face",
           title="Non-pro rata uptier: who gains?", legend=:outerright, size=(950, 450),
           framestyle=:box, left_margin=6Plots.mm, bottom_margin=5Plots.mm)
    plot!(pup, up_ms, up_out, lw=2.5, color=:crimson, label="excluded lender")
    hline!(pup, [up_sq.debt], color=:black, ls=:dash, label="every lender, no deal")
    vline!(pup, [up_m], color=:gray, ls=:dot, label="current m")
    pup
end

# ╔═╡ 7dc3e286-66a7-40fe-81dd-86f48003fae4
let o = up_uptier(up_m, up_k, up_NM, up_V)
    if o === nothing
        md"**At these settings the deal leaves the firm below its default boundary.** Lower the exchange ratio or raise the asset value."
    else
        Markdown.parse("""
        **With no deal**, every lender's debt is worth $(round(up_sq.debt, digits=1)) per 100 and equity is worth $(round(up_sq.E, digits=2)).

        **With a coalition of $(round(Int, 100 * up_m))%:** a coalition member's position is worth **$(round(o.insider, digits=1))** per 100 of old face (net of its new money), an excluded lender's is worth **$(round(o.outsider, digits=1))**, and equity is worth $(round(o.E, digits=2)). The new default boundary is $(round(o.B, digits=1)) vs. assets of $(round(up_V + up_NM, digits=1)).
        """)
    end
end

# ╔═╡ cb2f6bb1-1657-4199-be0d-3b211d91bcea
details("Checks: 4A", Markdown.parse("""
- Priority debt + old debt + equity equals total firm value, largest error across coalition sizes: `$(round(maximum((x.err for x in up_res if x !== nothing); init=0.0), sigdigits=3))` (should be close to 0)
"""))

# ╔═╡ d966bb86-d999-42cc-91f1-6255298c807e
md"""
### What to notice in 4A
1. **Smaller coalitions capture more per member.** The coalition member's value falls as `m` rises, while the excluded lenders' value stays low. The best coalition to be in is the smallest one that can still amend the documents. That's why lenders rushed to be in the majority group in deals like Serta, and why "required lender" thresholds matter so much.
2. **Exclusion is a transfer, not value creation.** Move `m` to 1 (pro rata) and compare: the debt reduction from `k < 1` helps equity either way, but in the non-pro rata case most of what insiders gain comes directly out of the excluded lenders' recovery.
3. **The threat is what drives cooperation agreements.** Lenders who fear being left out sign coops that commit them to negotiate as one group, which takes away the company's ability to pick a minimum winning coalition. Anti-coop terms in new debt documents (as in Warner Bros. Discovery's debt) try to keep that option open. Part 4E models the voting side.

**Leaves out:** litigation risk, which after the Fifth Circuit's Serta ruling is a real cost of non-pro rata deals; also different lenders' new money capacity, and the bargaining over `k` itself (which 2B could supply).
"""

# ╔═╡ fe1c43ac-e6c6-4eae-90a5-0406689bf1fd
md"""
## 4B: Amend & extend (maturity)

In an **amend & extend**, lenders agree to push out their maturity, usually in exchange for a higher coupon. Using the 2C formula for a bond that matures at `T`, we can compute exactly how much extra coupon makes a lender indifferent between its current bond (7% coupon, maturing in 2 years) and an extended one.

The firm's default boundary is fixed at 50, and the slider sets how far above it the firm's assets are. A distance of 1.1 means assets are 10% above the boundary.

**Distance to the default boundary (V / B):** $(@bind ae_dist Slider(1.05:0.05:3.0, default=1.30, show_value=true))

**Lender's recovery at default (per 1 of face):** $(@bind ae_R Slider(0.0:0.05:0.8, default=0.40, show_value=true))
"""

# ╔═╡ 9dd297e6-378d-472d-9178-bcfb0b56d66a
begin
    ae_B, ae_c1, ae_T1 = 50.0, 0.07, 2.0

    # coupon on a bond maturing at T2 that is worth the same as the current bond
    function ae_breakeven(dist, T2, R)
        V = dist * ae_B
        target = cv_bond(V, ae_B, ae_c1, ae_T1, R, σ)
        lo, hi = -0.5, 3.0
        for _ in 1:100
            mid = (lo + hi) / 2
            cv_bond(V, ae_B, mid, T2, R, σ) < target ? (lo = mid) : (hi = mid)
        end
        return (lo + hi) / 2
    end

    ae_T2s = 2.5:0.5:10.0
    pae = plot(xlabel="new maturity (years)", ylabel="coupon step-up needed (basis points)",
           title="What lenders need to extend from 2 years", legend=:outerright,
           size=(950, 450), framestyle=:box, left_margin=6Plots.mm, bottom_margin=5Plots.mm)
    for (d, col) in zip([1.1, 1.6, 2.5], [:crimson, :goldenrod, :seagreen])
        plot!(pae, ae_T2s, [1e4 * (ae_breakeven(d, t, ae_R) - ae_c1) for t in ae_T2s], lw=2, color=col, ls=:dash, label="V/B = $(d)")
    end
    plot!(pae, ae_T2s, [1e4 * (ae_breakeven(ae_dist, t, ae_R) - ae_c1) for t in ae_T2s], lw=3, color=:black, label="current V/B = $(ae_dist)")
    hline!(pae, [0.0], color=:gray, label="")
    pae
end

# ╔═╡ 8d16d6fc-059f-448d-a1e5-5fc31b684f44
Markdown.parse("""
### What to notice in 4B
1. **Distressed firms pay heavily to extend.** Close to the boundary, lenders need a step-up of a couple of hundred basis points, because the extension turns a likely payment at maturity into a long exposure to default.
2. **Healthy firms can extend for free, or even get paid to.** Far from the boundary the step-up turns negative: a safe bond paying more than the risk-free rate is worth more the longer it lasts.
3. **Recovery matters.** Raise the recovery and the step-up shrinks, because default costs the lender less. That's why secured lenders extend more cheaply, and why A&E deals often come bundled with collateral (Carvana's extension came with an uptier into secured notes).

**Leaves out:** the default boundary is held fixed even though extending changes when shareholders would default, and A&E deals usually also involve fees and covenant changes.
""")

# ╔═╡ d8dce3de-85c1-412b-974b-4d391ba38868
details("Checks: 4B", Markdown.parse("""
- "Extending" to the same 2-year maturity should need no step-up: `$(round(1e4 * (ae_breakeven(ae_dist, ae_T1, ae_R) - ae_c1), digits=3))` basis points (should be close to 0)
"""))

# ╔═╡ 82200042-5dc5-45de-a085-5bd4ecaaf872
md"""
## 4C: Discounted buybacks (amount of debt)

When a company's bonds trade below par, buying them back looks like free money: spend 8 dollars, retire 11 dollars of debt. Bulow and Rogoff (1988) showed for sovereign debt why this is misleading, and the same logic holds here. Once some debt is retired, the remaining bonds become safer and rise in price, so most of the gain goes to the creditors who **didn't** sell.

**The model.** A firm owes 100 of debt with an 8% coupon. It uses cash `K` from its assets to buy back debt at the current market price. Afterward it has less debt and fewer assets, and both are priced with the Leland formulas.

**Asset value V:** $(@bind bb_V Slider(76.0:1.0:130.0, default=85.0, show_value=true))
"""

# ╔═╡ 3857c43f-2ff9-4d34-b640-1f2c738df3cc
begin
    bb_D, bb_c = 100.0, 0.08
    function bb_values(V, D)
        C = bb_c * D
        B = default_boundary(C, σ, τ)
        V <= B && return (debt=(1 - α) * V, E=0.0, B=B)
        p = (V / B)^(-X(σ))
        L = (1 - α) * B
        return (debt=C / r + (min(L, D) - C / r) * p, E=V - (1 - τ) * C / r + ((1 - τ) * C / r - B) * p, B=B)
    end

    bb_pre = bb_values(bb_V, bb_D)
    bb_price = bb_pre.debt / bb_D
    bb_Ks = 0.0:0.5:15.0
    bb_after = [bb_values(bb_V - K, bb_D - K / bb_price) for K in bb_Ks]
    bb_equity_gain = [a.E - bb_pre.E for a in bb_after]
    bb_creditor_gain = [a.debt + K - bb_pre.debt for (a, K) in zip(bb_after, bb_Ks)]  # sellers get K, holders keep the rest
    bb_book_gain = [K / bb_price - K for K in bb_Ks]                                   # face retired minus cash spent

   pbb = plot(bb_Ks, bb_book_gain, lw=2.5, color=:gray, ls=:dash, label="accounting gain (face retired − cash)",
           xlabel="cash spent on the buyback K", ylabel="gain",
           title="Who gains from buying back debt at $(round(100 * bb_price, digits=1)) cents?",
           legend=:topleft, size=(800, 450), framestyle=:box,
           left_margin=5Plots.mm, bottom_margin=6Plots.mm)
    plot!(pbb, bb_Ks, bb_creditor_gain, lw=2.5, color=:crimson, label="creditors")
    plot!(pbb, bb_Ks, bb_equity_gain, lw=2.5, color=:seagreen, label="shareholders")
    pbb
end

# ╔═╡ 05116d94-9873-4a2d-8ec1-ecd34f940803
Markdown.parse("""
With assets of $(round(bb_V, digits=1)), the debt trades at **$(round(100 * bb_price, digits=1))** per 100. Spending 8 would retire $(round(8 / bb_price, digits=1)) of face, an accounting gain of $(round(8 / bb_price - 8, digits=2)), but shareholders gain only $(round(bb_equity_gain[findfirst(==(8.0), bb_Ks)], digits=2)) while creditors gain $(round(bb_creditor_gain[findfirst(==(8.0), bb_Ks)], digits=2)).

### What to notice in 4C
1. **The accounting gain is mostly an illusion for shareholders.** The remaining debt becomes safer, so its price rises, and that rise is a transfer to the creditors who kept their bonds.
2. **The effect is strongest for distressed firms.** Raise `V` and the debt trades near or above par, so a buyback barely changes anything.
3. **This is why companies prefer exchanges and tenders with conditions** (like Carvana's 85-cent cash tender bundled with exit consents) over open-market buybacks: conditions let the company capture more of the discount.

**Source:** Bulow, J. & Rogoff, K. (1988). "The Buyback Boondoggle." *Brookings Papers on Economic Activity*.
""")

# ╔═╡ 340539fc-f905-4c41-8370-3bdc565baad0
details("Checks: 4C", Markdown.parse("""
- The price of the remaining debt rises after a buyback: from $(round(100 * bb_price, digits=2)) to $(round(100 * bb_after[end].debt / (bb_D - 15 / bb_price), digits=2)) per 100 after spending 15
"""))

# ╔═╡ ba0cc4f2-e277-4bca-895b-903e0706725c
md"""
## 4D: Moving assets and multiplying claims (multi-entity structures)

Everything so far had one pool of assets. Real companies are groups of separate legal entities, and many of the newest LMEs work by changing **which entity owes what to whom**. This section models a group with three entities:
- **Parent:** 70 of operating assets; issues the existing debt
- **OpSub:** a subsidiary with 30 of operating assets; it guarantees the existing debt to start
- **FinCo:** a financing subsidiary with no assets of its own

Asset values at the horizon `T = 3` years are correlated lognormals, simulated with the risk-neutral drift (correlation `ρ` between Parent and OpSub assets; volatility `σ` from Part 1). The existing lenders (`D` = 80 of face, due at `T`) are compared under five ways of raising new money `N`:

| Structure | What changes | Real example |
|:--|:--|:--|
| **No new money** | Benchmark | — |
| **Pari new money** | New debt ranks equally with the existing debt, with the same guarantees | Plain new issue |
| **Guarantee release** | OpSub stops guaranteeing the existing debt, and the new debt is issued by OpSub, so it reaches OpSub's assets first | PetSmart/Chewy (2018) |
| **Dropdown** | Assets are moved from Parent into OpSub, which leaves the lending group; the new debt is secured on them | J.Crew (2016–17) |
| **Double-dip** | FinCo issues the new debt and lends the cash to Parent. The new lenders get a guarantee claim against Parent **and** FinCo's intercompany claim against Parent, plus OpSub's guarantee, capped at 100% of face | Trinseo (2023), STG |

**How a payout is computed.** In each simulated scenario, every entity pays its creditors by priority, pro rata within a priority level, with no creditor recovering more than its face value in total. OpSub's and FinCo's leftover value belongs to Parent, and FinCo's only asset is what it recovers on its intercompany claim, so the entities' payouts depend on each other. The notebook solves this circularity by iterating to a **fixed point**. If any lender is not paid in full, the whole group is in default and bankruptcy costs `α` are applied to all assets.

**Correlation ρ between Parent and OpSub assets:** $(@bind me_ρ Slider(0.0:0.1:0.9, default=0.5, show_value=true))

**New money N:** $(@bind me_N Slider(5.0:5.0:40.0, default=15.0, show_value=true))

**Assets moved in the dropdown:** $(@bind me_move Slider(0.0:5.0:40.0, default=20.0, show_value=true))
"""

# ╔═╡ f8f3a861-dc93-4484-9afa-8818e1854ae0
html"""
<svg viewBox="0 0 760 325" width="100%" style="max-width:760px;font-family:inherit" role="img" aria-label="Double-dip: new lenders lend to FinCo, which lends the cash on to Parent; Parent also guarantees the new loan, so new lenders have two claims on Parent's value while existing lenders have one">
  <defs>
    <marker id="dd_gray" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#888"/></marker>
    <marker id="dd_red" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#c0505c"/></marker>
  </defs>
  <rect x="20" y="20" width="180" height="60" rx="8" fill="#555"/>
  <text x="110" y="56" text-anchor="middle" fill="#ffffff" font-size="15">Existing lenders</text>
  <rect x="290" y="20" width="180" height="60" rx="8" fill="#1f4e79"/>
  <text x="380" y="46" text-anchor="middle" fill="#ffffff" font-size="15" font-weight="bold">Parent</text>
  <text x="380" y="66" text-anchor="middle" fill="#ffffff" font-size="12">70 of assets + new cash</text>
  <rect x="20" y="210" width="180" height="60" rx="8" fill="#2b6f8f"/>
  <text x="110" y="236" text-anchor="middle" fill="#ffffff" font-size="15" font-weight="bold">OpSub</text>
  <text x="110" y="256" text-anchor="middle" fill="#ffffff" font-size="12">30 of assets</text>
  <rect x="290" y="210" width="180" height="60" rx="8" fill="#2b6f8f"/>
  <text x="380" y="236" text-anchor="middle" fill="#ffffff" font-size="15" font-weight="bold">FinCo</text>
  <text x="380" y="256" text-anchor="middle" fill="#ffffff" font-size="12">no assets of its own</text>
  <rect x="560" y="210" width="180" height="60" rx="8" fill="#555"/>
  <text x="650" y="246" text-anchor="middle" fill="#ffffff" font-size="15">New lenders</text>
  <line x1="200" y1="50" x2="286" y2="50" stroke="#888" stroke-width="2" marker-end="url(#dd_gray)"/>
  <text x="243" y="42" text-anchor="middle" fill="currentColor" font-size="12">loan</text>
  <line x1="110" y1="80" x2="110" y2="206" stroke="#888" stroke-width="2" stroke-dasharray="6,4" marker-end="url(#dd_gray)"/>
  <text x="118" y="150" fill="currentColor" font-size="12">guarantee</text>
  <line x1="560" y1="240" x2="474" y2="240" stroke="#888" stroke-width="2" marker-end="url(#dd_gray)"/>
  <text x="517" y="232" text-anchor="middle" fill="currentColor" font-size="12">loan</text>
  <line x1="380" y1="210" x2="380" y2="84" stroke="#c0505c" stroke-width="3" marker-end="url(#dd_red)"/>
  <text x="390" y="140" fill="#c0505c" font-size="13" font-weight="bold">Dip 2: FinCo's loan of</text>
  <text x="390" y="157" fill="#c0505c" font-size="13" font-weight="bold">the cash to Parent</text>
  <line x1="640" y1="210" x2="474" y2="64" stroke="#c0505c" stroke-width="3" stroke-dasharray="6,4" marker-end="url(#dd_red)"/>
  <text x="580" y="112" fill="#c0505c" font-size="13" font-weight="bold">Dip 1: guarantee</text>
  <text x="580" y="129" fill="#c0505c" font-size="13" font-weight="bold">from Parent</text>
  <text x="380" y="298" text-anchor="middle" fill="currentColor" font-size="13" font-style="italic">New lenders hold two claims on Parent's value; existing lenders hold one.</text>
  <text x="380" y="315" text-anchor="middle" fill="currentColor" font-size="13" font-style="italic">Arrows point from each lender to whom it can claim against. Solid: loans. Dashed: guarantees.</text>
</svg>
"""

# ╔═╡ aada86d6-b33d-4bd0-93f9-067652ceee11
begin
    # pay `amount` pro rata by face, but never above each claim's cap; returns payments and what is left
    function me_waterfill(amount, faces, caps)
        n = length(faces)
        paid = zeros(n)
        active = [i for i in 1:n if caps[i] > 1e-12]
        rem = amount
        while rem > 1e-12 && !isempty(active)
            tot = sum(faces[i] for i in active)
            over = [i for i in active if paid[i] + rem * faces[i] / tot >= caps[i] - 1e-12]
            if isempty(over)
                for i in active
                    paid[i] += rem * faces[i] / tot
                end
                rem = 0.0
            else
                for i in over
                    rem -= caps[i] - paid[i]
                    paid[i] = caps[i]
                end
                active = setdiff(active, over)
            end
        end
        return paid, rem
    end

    # pay one entity's claims in order of rank (1 = most senior)
    function me_pay(pool, faces, ranks, caps)
        paid = zeros(length(faces))
        rem = pool
        for rk in sort(unique(ranks))
            idx = findall(==(rk), ranks)
            pd, rem = me_waterfill(rem, faces[idx], caps[idx])
            paid[idx] .= pd
        end
        return paid, rem
    end

    # solve all three entities together (1 = Parent, 2 = OpSub, 3 = FinCo) by fixed-point iteration
    function me_solve(assets, claims, holder_face; maxit=500)
        n = length(claims)
        paid = zeros(n)
        resid = zeros(3)
        for it in 1:maxit
            old = vcat(paid, resid)
            for e in (2, 3, 1)
                ic_rec = sum((paid[i] for i in 1:n if claims[i].holder == :IC); init=0.0)
                pool = e == 1 ? assets[1] + resid[2] + resid[3] :   # Parent owns the subsidiaries' leftover value
                       e == 2 ? assets[2] :
                       assets[3] + ic_rec                            # FinCo's asset is its intercompany claim
                idx = [i for i in 1:n if claims[i].entity == e]
                if isempty(idx)
                    resid[e] = pool
                    continue
                end
                caps = map(idx) do i
                    h = claims[i].holder
                    haskey(holder_face, h) || return claims[i].face
                    other = sum((paid[j] for j in 1:n if j != i && claims[j].holder == h); init=0.0)
                    return clamp(holder_face[h] - other, 0.0, claims[i].face)  # total recovery capped at face
                end
                pd, rem = me_pay(pool, [claims[i].face for i in idx], [claims[i].rank for i in idx], caps)
                paid[idx] .= pd
                resid[e] = rem
            end
            maximum(abs.(vcat(paid, resid) .- old)) < 1e-12 && it > 2 && break
        end
        return paid, resid
    end
end

# ╔═╡ 061c5279-051f-441c-a0f5-ba8ebc9ac17b
begin
    me_claim(holder, entity, rank, face) = (holder=holder, entity=entity, rank=rank, face=face)
    me_names = ["No new money", "Pari new money", "Guarantee release", "Dropdown", "Double-dip"]
    me_D = 80.0
    me_T = 3.0

    function me_scenario(name, D, N, move)
        base = [70.0, 30.0, 0.0]
        cash = N   # new money is held as cash at Parent
        if name == "No new money"
            claims = [me_claim(:D, 1, 2, D), me_claim(:D, 2, 2, D)]
            cash = 0.0
        elseif name == "Pari new money"
            claims = [me_claim(:D, 1, 2, D), me_claim(:D, 2, 2, D), me_claim(:N, 1, 2, N), me_claim(:N, 2, 2, N)]
        elseif name == "Guarantee release"
            claims = [me_claim(:D, 1, 2, D), me_claim(:N, 2, 2, N)]
        elseif name == "Dropdown"
            claims = [me_claim(:D, 1, 2, D), me_claim(:N, 2, 1, N)]
            base = [70.0 - move, 30.0 + move, 0.0]
        else  # Double-dip
            claims = [me_claim(:D, 1, 2, D), me_claim(:D, 2, 2, D),
                      me_claim(:N, 3, 2, N), me_claim(:N, 1, 2, N), me_claim(:N, 2, 2, N),
                      me_claim(:IC, 1, 2, N)]   # FinCo's intercompany loan to Parent
        end
        return base, cash, claims
    end

    function me_run(name, ρv, D, N, move; npaths=10_000, seed=11)
        base, cash, claims = me_scenario(name, D, N, move)
        holder_face = Dict(:D => D, :N => N)
        hasN = any(c.holder == :N for c in claims)
        rng = MersenneTwister(seed)
        disc = exp(-r * me_T)
        totD, totN, totE = 0.0, 0.0, 0.0
        max_rec, ident, n_def = 0.0, 0.0, 0
        recover(paid, h) = sum((paid[i] for i in eachindex(claims) if claims[i].holder == h); init=0.0)
        for path in 1:npaths
            z1 = randn(rng)
            z2 = ρv * z1 + sqrt(1 - ρv^2) * randn(rng)
            A = [base[1] * exp((r - σ^2 / 2) * me_T + σ * sqrt(me_T) * z1) + cash * exp(r * me_T),
                 base[2] * exp((r - σ^2 / 2) * me_T + σ * sqrt(me_T) * z2), 0.0]
            paid, resid = me_solve(A, claims, holder_face)
            recD, recN = recover(paid, :D), recover(paid, :N)
            if recD < D - 1e-9 || (hasN && recN < N - 1e-9)   # the group defaults: bankruptcy costs on all assets
                n_def += 1
                A = A .* (1 - α)
                paid, resid = me_solve(A, claims, holder_face)
                recD, recN = recover(paid, :D), recover(paid, :N)
            end
            totD += recD
            totN += recN
            totE += resid[1]
            max_rec = max(max_rec, recD / D, hasN ? recN / N : 0.0)
            ident = max(ident, abs(recD + recN + resid[1] - sum(A)))
        end
        return (D=100 * disc * totD / npaths / D, N=hasN ? 100 * disc * totN / npaths / N : NaN,
                E=disc * totE / npaths, max_rec=max_rec, ident=ident, pdef=n_def / npaths)
    end
end

# ╔═╡ 6b5ada3f-fb5e-4307-a001-e6fa21c85220
begin
    me_res = [me_run(nm, me_ρ, me_D, me_N, me_move) for nm in me_names]
    pme = bar((1:5) .- 0.2, [o.D for o in me_res], bar_width=0.4, color=:crimson, label="existing lenders (per 100)",
          xticks=(1:5, me_names), ylabel="value per 100 of face", title="Who gains from each structure?",
          ylims=(0, 100), legend=:topleft, size=(850, 450), framestyle=:box,
          left_margin=6Plots.mm, bottom_margin=5Plots.mm)
    bar!(pme, (2:5) .+ 0.2, [o.N for o in me_res[2:5]], bar_width=0.4, color=:navy, label="new lenders (per 100)")
    pme
end

# ╔═╡ 4cfcdad0-25c0-4f26-8924-36c867f6fcb2
begin
    me_rows = ["| $(me_names[i]) | $(round(me_res[i].D, digits=2)) | $(i == 1 ? "—" : round(me_res[i].N, digits=2)) | $(round(me_res[i].E, digits=2)) | $(round(100 * me_res[i].pdef, digits=1))% |" for i in 1:5]
    Markdown.parse("""
    | Structure | Existing lenders, per 100 | New lenders, per 100 | Equity | Probability the group defaults |
    |:--|--:|--:|--:|--:|
    $(join(me_rows, "\n"))
    """)
end

# ╔═╡ b26293b4-b4ec-453c-942f-ca6e0ed8291d
begin
    me_ρs = 0.0:0.15:0.9
    pme2 = plot(xlabel="correlation ρ between Parent and OpSub assets", ylabel="new lenders' value per 100",
                title="How much is each structure worth to the new lenders?", legend=:outerright,
                size=(900, 430), framestyle=:box, left_margin=6Plots.mm, bottom_margin=6Plots.mm)
    for (nm, col) in zip(["Pari new money", "Guarantee release", "Dropdown", "Double-dip"], [:gray, :goldenrod, :seagreen, :navy])
        plot!(pme2, me_ρs, [me_run(nm, ρv, me_D, me_N, me_move; npaths=2000).N for ρv in me_ρs], lw=2.5, color=col, label=nm)
    end
    pme2
end

# ╔═╡ fd6926a9-16f5-44cd-9203-ac3743baf124
begin
    # single-entity check against the Merton (1974) closed form: debt = D e^(-rT) - put
    function me_merton_check(; A0=100.0, D=80.0, npaths=20_000, seed=5)
        rng = MersenneTwister(seed)
        claims = [me_claim(:D, 1, 1, D)]
        tot = 0.0
        for _ in 1:npaths
            AT = A0 * exp((r - σ^2 / 2) * me_T + σ * sqrt(me_T) * randn(rng))
            paid, _ = me_solve([AT, 0.0, 0.0], claims, Dict(:D => D))
            tot += paid[1]
        end
        d1 = (log(A0 / D) + (r + σ^2 / 2) * me_T) / (σ * sqrt(me_T))
        d2 = d1 - σ * sqrt(me_T)
        put = D * exp(-r * me_T) * normcdf(-d2) - A0 * normcdf(-d1)
        return exp(-r * me_T) * tot / npaths, D * exp(-r * me_T) - put
    end
    me_mc, me_cf = me_merton_check()

    details("Checks: 4D", Markdown.parse("""
    - **Engine vs. the Merton closed form** (one entity, no bankruptcy costs): simulation `$(round(me_mc, digits=3))` vs. formula `$(round(me_cf, digits=3))` (should agree to within about 0.2)
    - **Conservation:** in every simulated scenario, all creditors' recoveries plus equity equal the group's assets after bankruptcy costs. Largest error: `$(round(maximum(o.ident for o in me_res), sigdigits=3))` (should be below 0.01; the fixed-point iteration stops at a tolerance)
    - **No double recovery:** the most any creditor recovered, as a share of its face: `$(round(maximum(o.max_rec for o in me_res), digits=6))` (should be at most 1)
    """))
end

# ╔═╡ 4f5dfd1d-d1f5-4bbb-bd2e-f0d79c2a44e3
md"""
### What to notice in 4D
1. **Every structure is a transfer.** Relative to pari new money, the guarantee release, dropdown, and double-dip all raise the new lenders' value and lower the existing lenders'. Equity barely moves, so the gain is taken almost entirely from the existing lenders. Multiplied by the size of each class, the new lenders' gain and the existing lenders' loss nearly offset.
2. **The double-dip works through intercompany claims.** The new lenders share Parent's assets twice: once through their guarantee and once through FinCo's intercompany loan, whose recovery flows only to them. That's why a double-dip is called "pari-plus."
3. **The double-dip is worth most when assets fail together.** Raise `ρ`: Parent and OpSub tend to lose value at the same time, the group defaults more often, and pari new money loses value. The double-dip's extra claim holds up better, so its edge over pari grows with correlation (at the default settings, from about 4 points per 100 at `ρ = 0` to about 6 at `ρ = 0.9`).
4. **The size of the new debt matters.** With small new money, a claim on OpSub's assets is almost always enough. Raise `N` toward the size of OpSub's assets (30) and the guarantee release becomes worse for the new lenders than pari, because they have no claim on Parent.

**Leaves out:** the legal fights over whether a transaction was permitted (the J.Crew blocker, basket capacity), which is often where these deals are actually decided; and the existing lenders' response, such as a coop or litigation.
"""

# ╔═╡ cfc60ca3-2438-477b-8d8d-e44e00678861
md"""
## 4E: Who votes? Coops, holdouts, and the Chapter 11 endgame (coalitions)

Whether a deal happens depends on how many holders accept, and that depends on **who holds the debt**. A holder that bought at par (a CLO or insurer, say) is often constrained from realizing a big loss; a distressed fund that bought at 60 is happy with 75. In Cision's restructuring, this split showed up as a group in which some holders pushed for about 90 while discount buyers would accept about 80.

**The model.** A class of debt is held by 30 holders with very unequal sizes (a few large funds and many small holders). Each holder is a par buyer (entry price 90–100) with probability set by the slider, otherwise a discount buyer (entry price 55–80). A holder accepts an offer `x` if it exceeds its reservation value:

`reservation = max(alternative, w · entry price + (1 − w) · alternative) + noise`

where `alternative` is what the holder expects if the deal fails and `w` is how strongly entry prices anchor demands. The simulation then checks whether the deal passes under three rules:
- **Out-of-court exchange:** at least 90% of the debt by amount must accept (a typical minimum participation condition).
- **Exchange with a coop:** the largest holders, together holding a set share of the debt, sign a cooperation agreement. If two-thirds of the coop by amount approve, all its members accept; otherwise none do. Everyone else decides individually.
- **Chapter 11 vote:** the class accepts a plan if holders of at least two-thirds of the amount **and** more than half of the number of holders vote yes (Bankruptcy Code section 1126(c)). Accepting binds the whole class, holdouts included.

**What isn't simulated.** If a class rejects a plan, a court can still **cram it down** if at least one impaired class accepts and the plan is "fair and equitable," which means respecting absolute priority. Since 2020, the UK's **Part 26A** restructuring plans have allowed cross-class cramdown with a "no worse off" test, which has made the UK a popular venue. Both set the fallback every out-of-court negotiation is bargaining against.

**Share of the class held by par buyers:** $(@bind vt_par Slider(0.0:0.1:1.0, default=0.4, show_value=true))

**Anchoring to entry price w:** $(@bind vt_w Slider(0.0:0.1:1.0, default=0.5, show_value=true))

**Value of the alternative if the deal fails (per 100):** $(@bind vt_alt Slider(40.0:5.0:80.0, default=60.0, show_value=true))

**Share of the debt held by coop members:** $(@bind vt_coop Slider(0.3:0.1:0.9, default=0.6, show_value=true))
"""

# ╔═╡ 0025c197-d534-4093-82a7-a4c052c87c7b
begin
    # probability that a deal at offer x passes: (exchange, exchange with coop, Chapter 11 vote)
    function vt_sim(x, share_par, w, alt, coop_share; n=30, trials=1000, seed=3, noise=3.0, qmin=0.9, equal_sizes=false)
        rng = MersenneTwister(seed)
        wins = zeros(3)
        for t in 1:trials
            hsize = equal_sizes ? ones(n) : [rand(rng)^(-1 / 1.5) for _ in 1:n]  # Pareto: a few very large holders
            hsize ./= sum(hsize)
            par = [rand(rng) < share_par for _ in 1:n]
            entry = [par[i] ? 90 + 10 * rand(rng) : 55 + 25 * rand(rng) for i in 1:n]
            resv = [max(alt, w * entry[i] + (1 - w) * alt) + noise * randn(rng) for i in 1:n]
            acc = x .>= resv
            amt = sum(hsize[acc])
            wins[1] += amt >= qmin - 1e-9
            wins[3] += (amt >= 2 / 3 - 1e-9) && (count(acc) > n / 2)
            order = sortperm(hsize, rev=true)
            k = something(findfirst(>=(coop_share), cumsum(hsize[order])), n)
            coop = falses(n)
            coop[order[1:k]] .= true
            coop_yes = sum(hsize[coop .& acc]) >= 2 / 3 * sum(hsize[coop]) - 1e-9
            acc_coop = copy(acc)
            acc_coop[coop] .= coop_yes
            wins[2] += sum(hsize[acc_coop]) >= qmin - 1e-9
        end
        return wins ./ trials
    end

    vt_xs = 50.0:1.0:100.0
    vt_curves = [vt_sim(x, vt_par, vt_w, vt_alt, vt_coop) for x in vt_xs]
    vt_needed = [begin
                     k = findfirst(c -> c[j] >= 0.9, vt_curves)
                     k === nothing ? NaN : vt_xs[k]
                 end for j in 1:3]

    pvt = plot(vt_xs, [c[1] for c in vt_curves], lw=2.5, color=:crimson, label="out-of-court exchange (90% minimum)",
               xlabel="offer (per 100 of face)", ylabel="probability the deal passes",
               title="The same offer, three sets of rules", legend=:bottomright, size=(800, 450), framestyle=:box)
    plot!(pvt, vt_xs, [c[2] for c in vt_curves], lw=2.5, color=:goldenrod, label="exchange with a coop")
    plot!(pvt, vt_xs, [c[3] for c in vt_curves], lw=2.5, color=:navy, label="Chapter 11 class vote")
    hline!(pvt, [0.9], color=:gray, ls=:dot, label="")
    pvt
end

# ╔═╡ 3e5a1b0c-2f6d-4c8e-9a71-5d2b8c4f6e13
begin
    # exact check: equal-sized holders, no anchoring (w = 0), so each holder accepts independently
    function vt_exact(x, alt; n=30, noise=3.0, qmin=0.9)
        q = normcdf((x - alt) / noise)       # each holder's probability of accepting
        tail(kmin) = sum(binomial(big(n), k) * q^k * (1 - q)^(n - k) for k in kmin:n)
        return Float64(tail(ceil(Int, qmin * n - 1e-9))), Float64(tail(max(ceil(Int, 2n / 3 - 1e-9), n ÷ 2 + 1)))
    end
    vt_x_ex, vt_x_ch = vt_alt + 4.0, vt_alt + 1.0   # offers where each probability is far from 0 and 1
    vt_exact_ex = vt_exact(vt_x_ex, vt_alt)[1]
    vt_exact_ch11 = vt_exact(vt_x_ch, vt_alt)[2]
    vt_mc_ex = vt_sim(vt_x_ex, vt_par, 0.0, vt_alt, vt_coop; trials=20_000, equal_sizes=true)[1]
    vt_mc_ch11 = vt_sim(vt_x_ch, vt_par, 0.0, vt_alt, vt_coop; trials=20_000, equal_sizes=true)[3]

    Markdown.parse("""
    **Offer needed for a 90% chance of passing:** exchange **$(vt_needed[1])**, exchange with a coop **$(vt_needed[2])**, Chapter 11 vote **$(vt_needed[3])**.
    """)
end

# ╔═╡ 3841ebf2-08fe-4231-a83a-bf62587e93ba
begin
    details("Checks: 4E", Markdown.parse("""
    **Exact binomial probabilities** (equal-sized holders and no anchoring, so each holder accepts independently): exchange at an offer of $(vt_x_ex), simulated `$(round(vt_mc_ex, digits=3))` vs. exact `$(round(vt_exact_ex, digits=3))`; Chapter 11 vote at $(vt_x_ch), simulated `$(round(vt_mc_ch11, digits=3))` vs. exact `$(round(vt_exact_ch11, digits=3))` (each should agree to within about 0.01)
    """))
end

# ╔═╡ 7c41d9e2-8b3f-4a65-b0d7-1e9f2a6c3d58
md"""
### What to notice in 4E
1. **Chapter 11 is cheaper for the company.** The same class accepts a lower offer under a two-thirds vote that binds everyone than under a 90% participation condition. That's the holdout problem from 2C in another form, and why "sign this or we'll file" is a credible threat.
2. **Who holds the debt changes the price.** Raise the par buyers' share or the anchoring `w` and every curve shifts right. That's the par-buyer vs. discount-buyer split in one slider.
3. **A coop helps a deal pass once the group agrees.** It turns many individual decisions into one bloc decision, which removes holdouts inside the group. That's why the company in Carvana's second attempt negotiated with the group rather than around it. In exchange, the group bargains harder (a higher `η` in 2B) and protects its members from being excluded in a non-pro rata deal (4A).
4. **Anti-coop terms are the company's counter-move.** By restricting coops, a company keeps the option to pick a minimum winning coalition, at the cost of more holdouts in any pro rata deal.

**Leaves out:** strategic voting (holders here vote sincerely), side payments, and the time and cost of a Chapter 11 case, which in practice is what makes companies try out of court first.
"""

# ╔═╡ d6fbd184-b7cc-448c-8afd-5afff58fa889
md"""
# Conclusion

### The one idea
**Restructuring exists because liquidation destroys value.** Keeping a company alive saves that value, and every restructuring is a fight over who captures it. The menu of strategies looks bewildering, but each one pulls one of a few levers in a single model: when the firm defaults, who is paid first, when debt matures, where the assets sit, how many claims a lender holds, and who is in the voting coalition.

### What each part showed

| Part | Question | What the model says |
|:--|:--|:--|
| 1 | When do shareholders stop paying? | At the default boundary `V_B = (1 − τ)C / (r + σ²/2)`. Riskier firms default *later*, because limited liability makes equity an option. |
| 2A | Who gets paid at default? | Absolute priority sets the order, and the fulcrum tranche behaves like equity. |
| 2B | How is the saved value split? | Bargaining power sets the exchange rate. Debt overhang means even creditors with all the power should accept a haircut. |
| 2C | Why do holdouts break deals? | Short maturities make holding out pay, exit consents push back, and deep haircuts only work in Chapter 11. |
| 3 | Does it fit a real deal? | Fitted to a single bond price, the model's holdout values track Carvana's actual offers across its note series (correlation about 0.95). |
| 4A | Uptiers | The smallest coalition that can amend the documents captures the most, which is why coops exist. |
| 4B | Amend & extend | Distressed firms pay heavily to extend; healthy firms can extend for free. |
| 4C | Buybacks | Most of the gain goes to the creditors who didn't sell. |
| 4D | Dropdowns, releases, double-dips | Each moves value from existing lenders to new ones; the double-dip is worth most when assets fail together. |
| 4E | Coops and voting | Chapter 11's voting rules make deals cheaper, and who holds the debt changes the price. |

### Three takeaways
1. **Limited liability turns equity into an option**, and that one fact drives when firms default and why shareholders gamble near the end.
2. **Restructuring is a bargaining game in which everyone's fallback is a filing.** Change the fallback (exit consents, Chapter 11 votes, coops) and you change the deal.
3. **The fine print is the math.** Priority, maturity, entity structure, and voting thresholds are the parameters, and the model shows who wins when each one moves.

### What the model leaves out
Asset values move continuously (no sudden collapses); the default boundary doesn't change as a bond nears maturity; bargaining power is a slider rather than derived from the voting rules; and the legal fights over whether a transaction was permitted, which often decide real cases, aren't modeled.

### Next steps
A time-dependent default boundary (a free-boundary PDE), jumps in asset values, deriving bargaining power from the voting simulation, and a full calibration that backs out asset value and volatility from market prices.
"""

# ╔═╡ 3fa31dc8-c1b3-4dc3-b0bb-7d54343fdf38
md"""
## References

**Models and methods**
- Merton, R. (1974). "On the Pricing of Corporate Debt: The Risk Structure of Interest Rates." *Journal of Finance*.
- Leland, H. (1994). "Corporate Debt Value, Bond Covenants, and Optimal Capital Structure." *Journal of Finance*.
- Fan, H. & Sundaresan, S. (2000). "Debt Valuation, Renegotiation, and Optimal Dividend Policy." *Review of Financial Studies*.
- Gertner, R. & Scharfstein, D. (1991). "A Theory of Workouts and the Effects of Reorganization Law." *Journal of Finance*.
- Bulow, J. & Rogoff, K. (1988). "The Buyback Boondoggle." *Brookings Papers on Economic Activity*.
- Andrade, G. & Kaplan, S. (1998). "How Costly Is Financial (Not Economic) Distress?" *Journal of Finance*.
- Riker, W. (1962). *The Theory of Political Coalitions*.
- Shreve, S. *Stochastic Calculus for Finance II*.
- Professor Edelman, email on the intuition behind stochastic integration (Sept 30, 2026).

**The Carvana case**
- Carvana Form 8-Ks: termination of the first exchange offers (June 1, 2023), exchange offer launch and terms (Aug. 2, 2023), and results (Aug. 31, 2023).
- Carvana Form 10-Q for the quarter ended June 30, 2023.
- Bloomberg, via BNN Bloomberg: "Carvana cancels 1 billion dollar debt swap as creditors hold out" (June 2023).

**Industry commentary** (one source; used for intuition and case examples)
- RestructuringInterviews.com guides and write-ups on Cision, AMC, STG, Trinseo, Serta, cooperation agreements, and double-dips.

**Tools:** Claude (Anthropic) helped draft code and explanations. I ran the notebook, checked each section against its tests, and can explain each formula.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Plots = "~1.41.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.1"
manifest_format = "2.1"
project_hash = "afca714ef5af0e0c526669188984c47815c4c678"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
registries = "General"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
registries = "General"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
registries = "General"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1fa950ebc3e37eccd51c6a8fe1f92f7d86263522"
registries = "General"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.7+0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
registries = "General"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
registries = "General"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
registries = "General"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
registries = "General"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
registries = "General"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
registries = "General"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
registries = "General"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
registries = "General"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
registries = "General"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
registries = "General"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
registries = "General"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "7a58e45171b63ed4782f2d36fdee8713a469e6e0"
registries = "General"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.1.2+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
registries = "General"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
registries = "General"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
registries = "General"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
registries = "General"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
registries = "General"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "64bbbb7d1499297751b536dd39c58b20750ab1db"
registries = "General"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.5.1+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "4d777f73c46b46b8b5276206059cf8a195499314"
registries = "General"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.27"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f8eb8f7ba13ea75083531647fc8faeda8d541f07"
registries = "General"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.27+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
registries = "General"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
registries = "General"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
registries = "General"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
registries = "General"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
registries = "General"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
registries = "General"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
registries = "General"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
registries = "General"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
registries = "General"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
registries = "General"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
registries = "General"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "88352712893ec50bee3680605891eaf0e9ed6368"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.8.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
registries = "General"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
registries = "General"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
registries = "General"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
registries = "General"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
registries = "General"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
registries = "General"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "1.0.0"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "Zstd_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.18.0+1"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.1+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "OpenSSL_jll", "Zlib_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.104+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
registries = "General"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
registries = "General"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
registries = "General"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
registries = "General"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
registries = "General"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
registries = "General"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "bba2d9aa057d8f126415de240573e86a8f39d2a1"
registries = "General"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.1"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
registries = "General"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
registries = "General"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
registries = "General"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
registries = "General"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
registries = "General"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
registries = "General"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
registries = "General"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05f45c2e0de6259db764adbfd2f1dc6d3f8de13c"
registries = "General"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.46.0+0"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
registries = "General"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools"]
git-tree-sha1 = "663e8b48b789916221e0765393b289ca6c88f24e"
registries = "General"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
registries = "General"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "Zstd_jll", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.13.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
registries = "General"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "83bd514e8ff16b5858ac54c53fa0bcf6002a3b00"
registries = "General"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.7"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
registries = "General"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
registries = "General"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
registries = "General"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "144895f6166994730ee7ff8113b981fc360638f1"
registries = "General"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.10.2+2"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll", "Qt6Svg_jll"]
git-tree-sha1 = "159d253ab126d5b29230cf53521899bea4ef4648"
registries = "General"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.10.2+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "4d85eedf69d875982c46643f6b4f66919d7e157b"
registries = "General"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.10.2+1"

[[deps.Qt6Svg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "81587ff5ff25a4e1115ce191e36285ede0334c9d"
registries = "General"
uuid = "6de9746b-f93d-5813-b365-ba18ad4a9cf3"
version = "6.10.2+0"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "672c938b4b4e3e0169a07a5f227029d4905456f2"
registries = "General"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.10.2+1"

[[deps.REPL]]
deps = ["Base64", "Dates", "FileWatching", "InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
registries = "General"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
registries = "General"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
registries = "General"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
registries = "General"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
registries = "General"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
registries = "General"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates"]
git-tree-sha1 = "8238217340ad0aaabe11afe39c1098b5bc9f4c8e"
registries = "General"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.1.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
registries = "General"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.13.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
registries = "General"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
registries = "General"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
registries = "General"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "2d0fc55c61321ba245c47be599570d11bac50303"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.8.5"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.10.1+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
registries = "General"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
registries = "General"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
registries = "General"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
registries = "General"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
registries = "General"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
registries = "General"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
registries = "General"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
registries = "General"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
registries = "General"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
registries = "General"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
registries = "General"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
registries = "General"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
registries = "General"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
registries = "General"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
registries = "General"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "dcb316b3ce0941f195537dda56bea4517fcd3ff5"
registries = "General"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.4+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "0ba01bc7396896a4ace8aab67db31403c71628f4"
registries = "General"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.7+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c174ef70c96c76f4c3f4d3cfbe09d018bcd1b53"
registries = "General"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
registries = "General"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
registries = "General"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
registries = "General"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "ed756a03e95fff88d8f738ebc2849431bdd4fd1a"
registries = "General"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.2.0+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
registries = "General"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
registries = "General"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
registries = "General"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
registries = "General"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
registries = "General"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
registries = "General"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
registries = "General"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "2e59214e017a55cb87474a00fa76035c82ac0e17"
registries = "General"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.47.0+2"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
registries = "General"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl"]
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
registries = "General"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
registries = "General"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ef17c47d22224aaecc76e597ab21a072e025cf7b"
registries = "General"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.14.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
registries = "General"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
registries = "General"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
registries = "General"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
registries = "General"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
registries = "General"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
registries = "General"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e51150d5ab85cee6fc36726850f0e627ad2e4aba"
registries = "General"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.58+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
registries = "General"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
registries = "General"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
registries = "General"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.67.1+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.8.2+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
registries = "General"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
registries = "General"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
registries = "General"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╟─a5faec45-e576-42d2-9336-49beda888682
# ╟─ac216e33-8373-4ee8-8355-1c2755569fd1
# ╟─bb51b3fd-f34c-4d49-a3dd-0bb84249d0fe
# ╟─40a7b207-8c68-4fa5-bab7-9f2d81ba464e
# ╟─55ea8f32-410d-410a-a2eb-894cfefc1f67
# ╟─7beacf24-01e2-4227-bdcd-5800461be2c4
# ╟─82045e67-573a-4b56-a7b9-df72a6abb72a
# ╟─4a79638b-dd00-4799-b8bd-6b9bed5bb1ba
# ╟─5848067f-26e8-42ae-b78c-f452dba1f85c
# ╟─da79fe3f-8976-4357-8b89-56f29909b5af
# ╟─13ece63b-4a1b-4472-aa38-f11bc3802833
# ╟─05e902f4-2e91-4405-a200-a4ef49b68422
# ╟─17297e74-49ff-441a-8a64-3f1762d9c227
# ╟─0c8ddcc5-3569-415c-bcea-5b0a8f0f7906
# ╟─6fbc99b5-7033-4181-8075-18180e28eb9f
# ╟─63332502-359d-42e2-8ee6-1c2cfec9e656
# ╟─06e28c47-3e43-4ad2-9717-ba799ab983b2
# ╟─3ef381b4-9d2e-454d-b248-c31b802005e4
# ╟─c2bafdde-5635-4809-917b-d86da7e7ed00
# ╟─0b4b3faa-260c-4485-a57e-8adee27a788c
# ╟─f3fba586-98d2-4faa-8487-964b38617db1
# ╟─1df6068d-1223-45e8-bc16-90d9a2df6487
# ╟─20e091fc-6d37-4044-a80c-a1b1a808ef55
# ╟─de61b8b5-c79f-400c-ac0d-1c54ac6a65d3
# ╟─f1ffafba-1e68-433e-99c0-996d0904f7e7
# ╟─6335d344-87d0-426d-969b-7d3d0df63ef5
# ╟─db2c8b5a-6c8c-4a47-bce0-03fbb5357a7a
# ╟─09ca50b3-c1fa-4a68-be9f-d8784d23b95c
# ╟─94853dea-cb83-4d41-8503-c5837b8df9e4
# ╟─9ecf45f2-48a5-4e6c-b5f6-38f7d70010fe
# ╟─66cd009b-0654-4546-8e45-27afdc4a0fc1
# ╟─f138d0cb-6c14-4bcb-a65c-015bf8b840e2
# ╟─83aae712-4fa8-4f92-9ede-85976f84a68c
# ╟─60843037-ec7c-496e-b9f6-7fed5fdc0221
# ╟─9ddc05cc-3be8-4757-a74d-1e9fe53e85f2
# ╟─a531dfdf-13e3-47cf-8749-11eea93e9d16
# ╟─d755d9ad-d109-4f80-ba2f-e3cdf158c7bf
# ╟─07c638c0-daea-48f3-8435-cd490ca13f97
# ╟─78f69312-3bb1-4b2d-84db-4da0154f52d2
# ╟─f0a1bac3-246b-46be-b494-e8159fe5905b
# ╟─41195afb-7e37-4ee1-bd7f-d004e3bacb3e
# ╟─ca197279-bd25-4c7b-9440-50a422d91df6
# ╟─c219b166-80e7-4a27-9391-c5e5a5f6187d
# ╟─a6b4a7f4-5a65-42ac-979b-b46f66ea9ce4
# ╟─34db0b16-4294-4a54-9634-3db02709a0b8
# ╟─476f3a02-a5c4-46a5-8feb-082c453936a4
# ╟─fee13f01-3167-4982-8db8-22c54d599c64
# ╟─8eb64a8f-792d-4846-9bba-8a3845e4ef61
# ╟─b01f3dab-e030-4b2d-ac91-cc707ba0d591
# ╟─87e2c7f9-745a-4ac6-89ac-28734f4cc630
# ╟─bc127fb8-c962-432e-9bcc-a78b6016ad86
# ╟─16d73146-deaf-405e-a8b4-a34e1c0d93d9
# ╟─7dc3e286-66a7-40fe-81dd-86f48003fae4
# ╟─cb2f6bb1-1657-4199-be0d-3b211d91bcea
# ╟─d966bb86-d999-42cc-91f1-6255298c807e
# ╟─fe1c43ac-e6c6-4eae-90a5-0406689bf1fd
# ╟─9dd297e6-378d-472d-9178-bcfb0b56d66a
# ╟─8d16d6fc-059f-448d-a1e5-5fc31b684f44
# ╟─d8dce3de-85c1-412b-974b-4d391ba38868
# ╟─82200042-5dc5-45de-a085-5bd4ecaaf872
# ╟─3857c43f-2ff9-4d34-b640-1f2c738df3cc
# ╟─05116d94-9873-4a2d-8ec1-ecd34f940803
# ╟─340539fc-f905-4c41-8370-3bdc565baad0
# ╟─ba0cc4f2-e277-4bca-895b-903e0706725c
# ╟─f8f3a861-dc93-4484-9afa-8818e1854ae0
# ╟─aada86d6-b33d-4bd0-93f9-067652ceee11
# ╟─061c5279-051f-441c-a0f5-ba8ebc9ac17b
# ╟─6b5ada3f-fb5e-4307-a001-e6fa21c85220
# ╟─4cfcdad0-25c0-4f26-8924-36c867f6fcb2
# ╟─b26293b4-b4ec-453c-942f-ca6e0ed8291d
# ╟─fd6926a9-16f5-44cd-9203-ac3743baf124
# ╟─4f5dfd1d-d1f5-4bbb-bd2e-f0d79c2a44e3
# ╟─cfc60ca3-2438-477b-8d8d-e44e00678861
# ╟─0025c197-d534-4093-82a7-a4c052c87c7b
# ╟─3e5a1b0c-2f6d-4c8e-9a71-5d2b8c4f6e13
# ╟─3841ebf2-08fe-4231-a83a-bf62587e93ba
# ╟─7c41d9e2-8b3f-4a65-b0d7-1e9f2a6c3d58
# ╟─d6fbd184-b7cc-448c-8afd-5afff58fa889
# ╟─3fa31dc8-c1b3-4dc3-b0bb-7d54343fdf38
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
