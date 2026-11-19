### A Pluto.jl notebook ###
# v1.0.3

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

# ╔═╡ 1d7e916c-bc21-4d72-8a5c-3af52bcec6b3
begin
    using PlutoUI
    using Plots
    using Statistics
    using Random
    using Printf
    gr()
    default(size=(880,420), legendfontsize=8, guidefontsize=9, titlefontsize=11, linewidth=2)
    TableOfContents(title="TCP congestion control", depth=2)
end

# ╔═╡ 3fee7eea-00de-4ab5-adb9-b0901058adfc
md"""
# TCP Congestion Control #
"""

# ╔═╡ 7460fad6-58bb-479e-9ce0-d065777ebcdf
md"""
# 0. How does the internet actually work?

### Building from the ground up

**We can think of the internet as a network of networks.** Your device connects to a local network (e.g., WiFi), which connects to other networks through routers. Data travels through a sequence of local networks and routers.
But how does information actually travel from a website's server to our computer?

### What happens when we open a website?

1. **URL: Where do we want to go?**  
   We enter a URL like `https://atlas.mit.edu`, which tells the browser what resource we want to access.

2. **DNS: Where is the website?**  
   The Domain Name System (DNS) translates the website's hostname (`atlas.mit.edu`) into an **IP address**, which identifies its network destination. For example, that address might lead to a server hosted at MIT, although it could also be hosted elsewhere.

3. **Connection: How do we communicate?**  
   Now that our computer knows the server's IP address, it establishes a connection using **TCP**¹ and **TLS**² to exchange data securely and reliably.

4. **HTTP Request: What information do we want?**  
   The browser sends an **HTTP request** asking for the webpage, and the server prepares a response.

5. **Packets and routers: How does the data travel?**  
   The response/information travels in small units called packets, which routers forward across networks toward our computer.

6. **Browser: How do we see the webpage?**  
   Our computer receives the data, and the browser processes the HTML, CSS, JavaScript, and other resources to display the page.

### So where does congestion come in?

Every network link has **limited capacity**, and our packets aren't traveling alone. When too many packets try to use the same link, they may have to wait in a queue or get dropped.

**What happens when packets arrive faster than a router can forward them?**

---

¹ **TCP (Transmission Control Protocol):** A protocol that helps computers communicate reliably over the internet and adjusts how much data is sent based on network conditions to help prevent congestion.

² **TLS (Transport Layer Security):** Encrypts communication and helps verify the server's identity.
"""

# ╔═╡ 58ca4912-24ce-45e6-8aaa-6001b8eed713

md"""
### Where does TCP fit?

TCP, or **Transmission Control Protocol**, is a set of rules that helps computers exchange data reliably and in the correct order. So if data gets lost along the way, TCP can retransmit it.

TCP also helps prevent **network congestion** by adjusting how much data a computer has in flight based on network conditions.

### How do these components work together?

| Component | Job | Analogy |
|:--|:--|:--|
| **DNS (Domain Name System)** | Finds the server's IP address | Looking up an address |
| **IP + routers** | Forward packets toward their destination | Roads and intersections |
| **TCP** | Ensures reliable delivery and controls congestion | A delivery service that tracks packages and adjusts shipments |
| **HTTP** | Requests and delivers webpage resources | Placing an order |

### So what happens when too much data is sent?

Multiple computers may share the **same network link**, which has limited capacity.

If packets (small units of data traveling through a network) arrive faster than a router can forward them, they accumulate in a **queue**. If the queue fills up, packets may be dropped.

**We will investigate how TCP knows when to send more data or slow down to avoid overwhelming the network.**

"""


# ╔═╡ 999e1d35-a973-4fd0-ba37-5233e79c4df8
md"""
# 1. The bottleneck: why fast senders can still have slow networks

**Picture this:** Imagine several cars trying to cross a one-lane bridge. Cars arrive faster than the bridge can let them through, so they start lining up, creating a traffic jam.

The same thing can happen with data traveling through the internet. When too many packets reach a router at once, some have to wait before they can be forwarded.

For a router:
- **Arrival rate:** How many packets arrive each round
- **Service capacity:** How many packets the router can forward each round
- **Buffer:** Temporary storage where packets wait until they can be forwarded

The **bottleneck** is the limited capacity of the link. If packets arrive faster than they can leave, the queue grows. Once the buffer is full, additional packets may be **dropped**.

### Example

Suppose 16 packets arrive at a router every round, but the router can only forward 10.

That means 6 extra packets are left waiting each round!

**What happens if we increase the buffer size (the amount of space available for waiting packets)?**

The router still won't be able to forward more packets; it will only allow more packets to wait in line.

A **fixed-rate sender** sends the same number of packets every round, regardless of network congestion.

### Let's experiment!

We can adjust the **arrival rate, service capacity, buffer size,** and **number of rounds** to see how they affect congestion.
"""

# ╔═╡ e6cebdaa-9be1-4505-a4b4-0368cd90438e
md"""
### Interactive controls — a fixed-rate sender

Offered packets / round: $(@bind offered Slider(2:1:25, default=16, show_value=true))

Router capacity (packets / round): $(@bind cap1 Slider(4:1:20, default=10, show_value=true))

Buffer size (packets): $(@bind buf1 Slider(0:5:100, default=30, show_value=true))

Simulation rounds: $(@bind rounds1 Slider(15:5:100, default=50, show_value=true))
"""

# ╔═╡ e809a2d5-cf89-490a-af58-d6872a600a75
begin
    # Each round: add packets, drop arrivals beyond buffer + this round's service,
    # serve up to capacity, and retain the remainder in the queue.
    function fixed_rate_sim(arrival::Real, capacity::Real, buffer::Real, n::Int)
        q=0.0
        queue=Float64[]; delivered=Float64[]; dropped=Float64[]; delays=Float64[]
        for _ in 1:n
            # Service can happen during the round; buffer holds only waiting packets.
            accepted=min(q+arrival, capacity+buffer)
            loss=max(q+arrival-(capacity+buffer), 0.0)
            served=min(accepted,capacity)
            q=max(accepted-served,0.0)
            push!(queue,q); push!(delivered,served); push!(dropped,loss)
            push!(delays,q/capacity) # rough queueing delay in units of rounds
        end
        (;queue,delivered,dropped,delays)
    end
    fixed=fixed_rate_sim(offered,cap1,buf1,rounds1)
    t1=1:rounds1
    p1_bottle=plot(t1,fixed.queue,label="Waiting packets",xlabel="Round",ylabel="Packets",title="Queue occupancy",ylim=(0,max(10,buf1+5)))
    hline!(p1_bottle,[buf1],label="Buffer limit",linestyle=:dash)
    p2_bottle=plot(t1,fixed.delivered,label="Delivered",xlabel="Round",ylabel="Packets / round",title="Throughput vs. packet drops",ylim=(0,max(offered,cap1)+4))
    plot!(p2_bottle,t1,fixed.dropped,label="Dropped")
    plot(
    p1_bottle, p2_bottle,
    layout=(1, 2),
    size=(1100, 450),
    left_margin=10Plots.mm,
    bottom_margin=10Plots.mm,
    right_margin=5Plots.mm,
    top_margin=5Plots.mm,
    dpi=120
)
end

# ╔═╡ 129ede27-b84d-4b85-a402-84464b496e42
md"""
### What should we see?

- **Left graph (Queue occupancy):** The queue grows when arrivals exceed capacity, until the buffer is full.
- **Right graph (Throughput vs. drops):** The router can only forward so many packets per round. Excess packets eventually get dropped.

**Takeaway:** A larger buffer lets more packets wait, but doesn't increase throughput beyond the router's capacity.

**Next question:** What if the sender could recognize congestion and slow down?
"""

# ╔═╡ 6d967058-13bd-42be-b281-29dab1d1c799
md"""
### Another way to visualize the bottleneck

Round to inspect: $(@bind packet_frame Slider(1:rounds1,default=1,show_value=true))
"""

# ╔═╡ ebdcbae9-0ac0-465f-b7d5-6cc82bb6ad3d
begin
    packet_round = packet_frame
    packet_arrival = Float64(offered)
    packet_served = fixed.delivered[packet_round]
    packet_waiting = fixed.queue[packet_round]
    packet_dropped = fixed.dropped[packet_round]
    packet_limit = max(Float64(buf1), 1.0)
    packet_chart = bar(
        ["Arriving", "Forwarded", "Waiting", "Dropped"],
        [packet_arrival, packet_served, packet_waiting, packet_dropped],
        color=[:royalblue, :seagreen, :orange, :firebrick],
        label="",
        ylabel="Packets",
        title="Router snapshot — round $(packet_round)",
        ylim=(0, max(26.0, Float64(buf1)+5, packet_arrival+5)),
        size=(950, 420),
        left_margin=12Plots.mm,
        bottom_margin=10Plots.mm,
        top_margin=5Plots.mm
    )
    hline!(packet_chart,[Float64(cap1)],linestyle=:dash,color=:black,label="Link capacity per round")
    packet_chart
end

# ╔═╡ 64745003-2f0c-4b39-af6b-ac6f715838f9

md"""
### What are we seeing?

This bar chart shows what happens at the router during a single round:

- **Arriving:** Packets entering the router
- **Forwarded:** Packets sent onward
- **Waiting:** Packets remaining in the queue
- **Dropped:** Packets discarded when the buffer is full

The values depend on the arrival rate, service capacity, and buffer size we selected earlier.

As long as more packets arrive than the router can forward, the queue grows until the buffer fills. After that, excess packets are dropped.

### Throughput vs. Latency

There are two important ways to measure network performance:

- **Throughput:** How much data is forwarded per round.
- **Latency:** How long it takes for data to reach its destination.

Even when a router is forwarding packets at full capacity, packets can still spend a long time waiting in its queue.

**Key takeaway:** A larger buffer allows more packets to wait and can delay packet drops, but it doesn't increase the router's capacity. Instead, it can increase latency.

"""


# ╔═╡ ae93dd58-1347-4e4c-8f24-3abc9884649d
md"""
# 2. TCP's core idea: send more, then slow down when needed

So far, we've seen what happens when a sender keeps sending packets at a fixed rate, even when the network is congested.

**But what if the sender could adjust how much data it sends based on network conditions?**

That's what TCP's **congestion control** helps accomplish.

### How does TCP know what's happening?

Communication! TCP uses feedback from the receiver:

- **Acknowledgement (ACK):** A message sent back by the receiver confirming that data has arrived.
- **Round-trip time (RTT):** The time it takes for data to reach the receiver and for an ACK to return.
- **Congestion window (`cwnd`):** A limit that TCP maintains on how much data it can send before waiting for acknowledgements.

For example, if `cwnd = 4` packets, the sender can have up to 4 packets traveling through the network without receiving ACKs for them yet. Once ACKs arrive, it can send more.

TCP automatically adjusts `cwnd` based on network conditions.

For our simulation, we'll use **RTT rounds**: each round represents one complete cycle of sending packets and receiving feedback.

### How does TCP adjust its sending?

We'll explore two main behaviors/phases (TCP does both):

**1. Slow start: Grow quickly**
- TCP starts with a small congestion window (`cwnd`).
- As ACKs arrive, `cwnd` approximately **doubles every RTT**.
- This continues until congestion is detected or `cwnd` reaches a threshold called **`ssthresh` (slow-start threshold)**.

**2. Congestion avoidance: Grow cautiously**
- Once `cwnd` reaches `ssthresh`, TCP switches to slower growth, increasing `cwnd` by roughly **one packet per RTT**.
- TCP can detect likely packet loss through missing acknowledgements, duplicate ACKs, or timeouts.
- When loss indicates congestion, TCP reduces its sending window, often by half.

This approach is called **AIMD (Additive Increase, Multiplicative Decrease)**

### Let's make a prediction

**Suppose TCP is sending 20 packets per round and detects congestion. Should it keep sending 20 packets, send even more, or slow down?**
"""


# ╔═╡ 0a56353c-d200-43c8-9f03-c373504f2f2a
begin
    function aimd_sim(;capacity=16.0,buffer=20.0,n=90,initial=1.0,ssthresh=16.0,mode=:reno)
        q=0.0; cwnd=initial; threshold=ssthresh
        wins=Float64[]; queues=Float64[]; goodput=Float64[]; drops=Float64[]; rtts=Float64[]
        for _ in 1:n
            send=cwnd
            accepted=min(q+send,capacity+buffer)
            loss=max(q+send-(capacity+buffer),0.0)
            delivered=min(accepted,capacity)
            q=max(accepted-delivered,0.0)
            push!(wins,cwnd);push!(queues,q);push!(goodput,delivered);push!(drops,loss)
            push!(rtts,1+q/capacity)
            if loss>1e-9
                threshold=max(cwnd/2,2.0)
                cwnd=max(cwnd/2,1.0) # simplified multiplicative decrease
            elseif mode==:reno
                cwnd = cwnd<threshold ? min(2cwnd,threshold) : cwnd+1
            else
                error("Unknown mode")
            end
        end
        (;wins,queues,goodput,drops,rtts)
    end
end

# ╔═╡ e6aea14b-afb8-44b5-a4a6-bcadd89c2072
md"""
Router capacity: $(@bind cap3 Slider(6:2:40,default=16,show_value=true))

Buffer size: $(@bind buf3 Slider(0:5:80,default=20,show_value=true))

Initial slow-start threshold: $(@bind thresh3 Slider(4:2:40,default=16,show_value=true))

Number of RTT rounds: $(@bind n3 Slider(30:10:150,default=90,show_value=true))
"""

# ╔═╡ 6a18bc30-2583-4829-8b44-e7b244a85555

begin
    a = aimd_sim(
        capacity=Float64(cap3),
        buffer=Float64(buf3),
        ssthresh=Float64(thresh3),
        n=n3
    )

    # Top graph: TCP congestion window
    p1_aimd = plot(
        1:n3, a.wins,
        label="Congestion window (cwnd)",
        xlabel="Time (RTT rounds)",
        ylabel="Congestion window (packets)",
        title="TCP Congestion Window Over Time",
        linewidth=2
    )

    hline!(
        p1_aimd, [cap3],
        linestyle=:dash,
        label="Router capacity (packets/round)"
    )

    # Bottom graph: Queue occupancy and packet loss
    p2_aimd = plot(
        1:n3, a.queues,
        label="Packets waiting in queue",
        xlabel="Time (RTT rounds)",
        ylabel="Packets waiting",
        title="Router Queue and Packet Loss",
        linewidth=2
    )

    loss_rounds = findall(>(0), a.drops)

    scatter!(
        p2_aimd,
        loss_rounds,
        a.queues[loss_rounds],
        label="Packet loss occurred",
        markersize=4
    )

    plot(
        p1_aimd, p2_aimd,
        layout=(2, 1),
        size=(1000, 750),
        left_margin=15Plots.mm,
        bottom_margin=10Plots.mm,
        right_margin=5Plots.mm,
        top_margin=5Plots.mm
    )
end


# ╔═╡ be68fb2b-d457-4fe8-94a5-b516040e6e93

md"""
### What are we seeing?

**Top graph (Congestion window):**
- TCP starts by increasing its sending window quickly (**slow start**).
- After reaching the slow-start threshold, it increases more gradually (**congestion avoidance**).
- When congestion is detected, the window drops, and TCP begins increasing it again.

**Bottom graph (Queue and packet loss):**
- As TCP sends more packets, the router's queue may grow.
- The dots indicate when packets are dropped because the buffer is full.
- After TCP slows down, the queue can shrink.

**Try adjusting the router capacity and buffer size.** How does that change when packet loss occurs?

**Key takeaway:** Unlike a fixed-rate sender, TCP adjusts its sending window in response to congestion, allowing it to use available capacity without continuously overwhelming the network.
"""

# ╔═╡ 5a4566b2-9d60-499f-a5f1-c102e356141c

md"""
### What are we seeing?

Notice the **sawtooth pattern**:

1. **Increase:** TCP increases its window to see how much data the network can handle.
2. **Congestion:** Eventually, too many packets arrive and the router's buffer fills, causing packet loss.
3. **Decrease:** TCP responds by cutting its window in half, allowing the queue to shrink.
4. **Repeat:** TCP gradually increases its window again to find available capacity.

### Why does TCP work this way?

Every network link has a limited **capacity**, meaning how much data it can transmit per unit of time. For example, our router might only be able to forward 20 packets per round.

But TCP doesn't know exactly how much capacity is available to it, since other computers may be using the same network link.

Instead, TCP gradually increases its sending window to see how much data the network can handle. If packets start getting dropped, TCP treats that as a sign of congestion and slows down.

**Why cut the window in half?**

This is part of **AIMD (Additive Increase, Multiplicative Decrease)**. Halving the window provides a substantial reduction in traffic when congestion occurs, while allowing TCP to gradually increase again afterward.

Using a fraction rather than subtracting a fixed amount also means larger sending windows make larger reductions. The factor of one-half is a design choice used in classic TCP congestion control, not a universal rule for every TCP algorithm.

This balances two goals:
- **Efficiency:** Use as much available network capacity as possible.
- **Congestion control:** Avoid sending more packets than the network can handle.

### Who uses TCP?

TCP doesn't belong to any one company. It's an **open internet standard** developed through the Internet Engineering Task Force (IETF).

TCP is implemented in operating systems such as **Windows, macOS, and Linux**. When an application uses TCP, the operating system typically handles acknowledgements, retransmissions, and congestion control automatically.

Different operating systems may use different congestion-control algorithms, so not every TCP connection behaves exactly like our simulation.

**Key takeaway:** TCP doesn't send at one fixed rate. It adjusts its sending window based on feedback to balance efficient data transfer with avoiding congestion.
"""


# ╔═╡ effc2fcd-933e-4cd5-86e2-56902af16b10

md"""
# 3. Two senders: can computers share the network fairly?

So far, we've looked at one computer sending data through a router. But in reality, **many computers share the same network links**.

What happens when two computers are sending data at the same time?

### Let's think about it

Imagine **Sender A** and **Sender B** sending data to their own receivers, but their packets must pass through the **same router**.

They aren't sending data to each other. They're two separate connections that happen to share part of the same network path.

- Each sender has its own **congestion window (`cwnd`)**, which controls how much data it can have in flight.
- Both share the same **bottleneck**, meaning they compete for the router's limited capacity.
- Each uses **AIMD** to adjust its window based on congestion.

Ideally, neither sender should dominate the shared link. We'd like both to get a reasonably fair share of the available capacity.

### Let's make a prediction

**Suppose Sender A starts with a much larger congestion window than Sender B.**

Will TCP's congestion control help them reach similar sending windows over time?

What if Sender A never slows down when congestion occurs?

Let's see what happens

"""


# ╔═╡ dd34a300-65ea-44d9-b62b-40d050707237
begin
    function two_flow_sim(;capacity=24.0,buffer=24.0,n=100,wa=4.0,wb=18.0,unresponsive=false)
        q=0.0
        a=Float64[]; b=Float64[]; da=Float64[]; db=Float64[]; queue=Float64[]
        for _ in 1:n
            offered=wa+wb
            accepted=min(q+offered,capacity+buffer)
            loss=max(q+offered-(capacity+buffer),0.0)
            served=min(accepted,capacity)
            q=max(accepted-served,0.0)
            fa=wa/max(offered,eps())
            push!(a,wa);push!(b,wb);push!(da,served*fa);push!(db,served*(1-fa));push!(queue,q)
            if loss>0
                wa=unresponsive ? wa : max(1.0,wa/2)
                wb=max(1.0,wb/2)
            else
                wa=unresponsive ? wa : wa+1
                wb+=1
            end
        end
        (;a,b,da,db,queue)
    end
end

# ╔═╡ fe5952f4-7ae4-475b-bdc2-71f5647fdddd
md"""
Sender A starting window: $(@bind wa4 Slider(1:2:39,default=5,show_value=true))

Sender B starting window: $(@bind wb4 Slider(1:2:39,default=25,show_value=true))

Shared capacity: $(@bind capacity4 Slider(8:2:40,default=24,show_value=true))
"""

# ╔═╡ fa6251ba-13e0-42d6-ae0c-63ca3a18e031
begin
    flows=two_flow_sim(capacity=Float64(capacity4),wa=Float64(wa4),wb=Float64(wb4))
    p1_flow=plot(flows.a,label="A window",xlabel="RTT round",ylabel="Packets",title="Two competing senders")
    plot!(p1_flow,flows.b,label="B window")
    p2_flow=plot(flows.da,label="A delivered",xlabel="RTT round",ylabel="Packets / round",title="Delivered throughput by sender")
    plot!(p2_flow,flows.db,label="B delivered")
    plot(p1_flow,p2_flow,layout=(2,1),size=(940,650))
end

# ╔═╡ a9b02d62-ae59-4129-990e-2b725a5a1eda
md"""
### Another way to visualize the bottleneck

When both senders respond to congestion, do their windows become similar? Enable the unresponsive sender and compare the shares. Let's see how allocation changes over time.

RTT round: $(@bind share_frame Slider(1:100,default=30,show_value=true))
"""

# ╔═╡ 2fee3561-989b-4a45-b327-2a30f8a38c59
begin
    flow_share_chart = bar(["Sender A", "Sender B"],
        [flows.da[share_frame],flows.db[share_frame]],
        color=[:royalblue,:darkorange],label="",ylabel="Packets forwarded per round",
        title="Shared bottleneck — round $(share_frame)",ylim=(0,Float64(capacity4)*1.12),size=(850,350))
    hline!(flow_share_chart,[Float64(capacity4)],linestyle=:dash,color=:gray,label="Shared link capacity")
    flow_share_chart
end

# ╔═╡ 07610299-a05b-442e-a548-3451bfc51e7b

md"""
### What are we seeing?

Our simulation models two computers sending packets through the same router. Both share its limited capacity.

Each round:
1. Each sender offers packets based on its own congestion window (`cwnd`).
2. The router forwards as many packets as its capacity allows.
3. We estimate how many packets from each sender get through, based on their share of the total traffic.
4. Each sender adjusts its congestion window in response to congestion.

**How does the router divide packets between senders?**

Many routers use queues that process packets roughly in the order they arrive, rather than reserving equal capacity for each sender.

If packets from both senders are well mixed, the proportion of packets forwarded from each sender may roughly reflect how much traffic each contributes.

Our simulation approximates this behavior using **proportional sharing**.

For example, suppose:
- Sender A offers **15 packets**.
- Sender B offers **5 packets**.
- The router can forward **10 packets**.

A contributes 75% of the total traffic, so our simulation assigns A **7.5 forwarded packets** and B **2.5**.

**Does this mean A can dominate the router?**

Initially, yes/ The router doesn't automatically reserve half its capacity for each sender. But when both senders use AIMD, they gradually increase their windows and reduce them when congestion occurs. Over time, this can help them move toward a more equal share.

### How do we measure fairness?

We can use **Jain's fairness index**, a standard measure of how equally resources are shared. It isn't part of TCP itself.

For two senders, the formula is:

``J = \dfrac{(x_1+x_2)^2}{2(x_1^2+x_2^2)}``

Here, `x₁` and `x₂` represent the throughputs (packets forwarded per round) of Senders A and B.

For example, if A receives 8 packets and B receives 2:

``J = \dfrac{(8+2)^2}{2(8^2+2^2)} = \dfrac{100}{136} \approx 0.74``

For two senders:
- **J = 1:** Equal sharing.
- **J = 0.5:** One sender gets everything.
- **J ≈ 0.74:** Unequal sharing.

**Key takeaway:** TCP's congestion control can help competing senders share a network more fairly, rather than letting one sender continuously overwhelm it.
"""


# ╔═╡ 4e76cf51-6aeb-4b30-9f3b-954f962ada86
begin
    tail=lastindex(flows.da)-19:lastindex(flows.da)
    xa=mean(flows.da[tail]);xb=mean(flows.db[tail])
    jain=(xa+xb)^2/(2*(xa^2+xb^2)+eps())
    md"""Say A delivered **$(round(xa,digits=1))** packets/round; B delivered **$(round(xb,digits=1))** packets/round. Jain fairness index: **$(round(jain,digits=3))**."""
end

# ╔═╡ 9b0bbd83-3d77-4d21-bd84-be1466edf4ef

md"""
# 4. Can we prevent congestion before packets are lost?

So far, we've seen how TCP reduces its sending window when packets are dropped.

But **packet loss isn't the first sign of congestion**. Before packets get dropped, they can start building up in the router's queue.

Think back to our one-lane bridge. Even if cars are getting across at full speed, a long line of waiting cars means more time spent in traffic.

So here's a question:

**Can we keep the router's queue shorter without reducing how much data gets through?**

### Two strategies

**1. Loss-responsive (what we saw before):** The sender increases its congestion window until packets are dropped, then cuts the window in half.

**2. Queue-sensitive:** The sender also watches how many packets are waiting. If the queue gets too long, it reduces its window by 15%, even before packet loss occurs.

We'll compare these two strategies using the same router.
"""


# ╔═╡ 1b0f3e54-4423-45b2-8d94-6c91dc71856d

begin
    function strategy_sim(;
        capacity=16.0,
        buffer=40.0,
        n=120,
        queue_target=5.0,
        delay_sensitive=false
    )
        q = 0.0
        w = 2.0

        windows = Float64[]
        delivered = Float64[]
        queues = Float64[]
        drops = Float64[]

        for round in 1:n
            # Sender offers packets according to its window
            offered = w

            # Previously queued packets + newly offered packets
            total = q + offered

            # Router can forward 'capacity' packets and
            # hold up to 'buffer' additional packets
            accepted = min(total, capacity + buffer)
            loss = max(0.0, total - (capacity + buffer))

            # Forward packets and update remaining queue
            served = min(accepted, capacity)
            q = max(0.0, accepted - served)

            push!(windows, w)
            push!(delivered, served)
            push!(queues, q)
            push!(drops, loss)

            # Congestion-control decision for next round
            if loss > 0
                w = max(1.0, w / 2)
            elseif delay_sensitive && q > queue_target
                w = max(1.0, 0.85 * w)
            else
                w += 1.0
            end
        end

        (; windows, delivered, queues, drops)
    end
end


# ╔═╡ ba877303-b37b-4fac-9862-5f93b1368726

md"""
### What is the queue target?

Our router has three important settings:

- **Capacity: 16 packets/round**: how many packets it can forward each round.
- **Buffer size: 40 packets**: the maximum number of packets that can wait.
- **Queue target:** The number of waiting packets we're comfortable with before the queue-sensitive sender slows down.

For example, if the queue target is **5**, the queue-sensitive sender reduces its window by 15% whenever more than 5 packets are waiting, assuming no packet loss occurred.

The queue target is **not a hard limit**. It's an early warning threshold that we choose.

Try changing it below:
"""


# ╔═╡ e7c627b4-65e6-4a02-8e58-f3f209f019a7

@bind target5 Slider(0:1:40, default=5, show_value=true)


# ╔═╡ 5a0837c1-c1fe-480f-b56e-ca65e7da077d

md"""
### Let's compare

We'll run the same router simulation twice, using the same capacity and buffer size. Only the sender's congestion-control strategy changes.

The graphs show:

**Top graph: Router queue size**
- **X-axis:** Time, measured in simulation rounds.
- **Y-axis:** Number of packets still waiting at the router after each round.
- **Dotted line:** Your chosen queue target. Only the queue-sensitive strategy uses this threshold.

**Bottom graph: Router throughput**
- **X-axis:** Time, measured in simulation rounds.
- **Y-axis:** Number of packets forwarded by the router each round.
- **Dotted line:** The router's maximum capacity of 16 packets per round.

**Prediction:** If we lower the queue target, will the router forward fewer packets, or can it keep working at full capacity with a shorter queue?
"""


# ╔═╡ 50919067-90c9-44a1-8e3d-589645eb92d4

let
    # Fixed router settings
    capacity5 = 16.0
    buffer5_fixed = 40.0
    rounds5 = 120

    # Run both strategies with identical router settings
    lossbased = strategy_sim(
        capacity=capacity5,
        buffer=buffer5_fixed,
        n=rounds5,
        delay_sensitive=false
    )

    delaybased = strategy_sim(
        capacity=capacity5,
        buffer=buffer5_fixed,
        n=rounds5,
        queue_target=Float64(target5),
        delay_sensitive=true
    )

    time5 = 1:rounds5

    # Top graph: queue size
    p1_strategy = plot(
        time5, lossbased.queues,
        label="Loss-responsive",
        color=:blue,
        linewidth=3,
        xlabel="Time (simulation rounds)",
        ylabel="Waiting packets",
        title="Router queue size over time",
        xlim=(1, 120),
        ylim=(0, 50),
        legend=:outertopright,
        left_margin=12Plots.mm,
        right_margin=5Plots.mm,
        bottom_margin=8Plots.mm,
        top_margin=5Plots.mm
    )

    plot!(
        p1_strategy, time5, delaybased.queues,
        label="Queue-sensitive",
        color=:orange,
        linewidth=3,
        linestyle=:dash
    )

    hline!(
        p1_strategy, [Float64(target5)],
        label="Queue target ($(target5) packets)",
        color=:gray,
        linestyle=:dot,
        linewidth=2
    )

    # Bottom graph: router throughput
    p2_strategy = plot(
        time5, lossbased.delivered,
        label="Loss-responsive",
        color=:blue,
        linewidth=3,
        xlabel="Time (simulation rounds)",
        ylabel="Packets forwarded / round",
        title="Router throughput over time",
        xlim=(1, 120),
        ylim=(0, 20),
        legend=:outertopright,
        left_margin=12Plots.mm,
        right_margin=5Plots.mm,
        bottom_margin=8Plots.mm,
        top_margin=5Plots.mm
    )

    plot!(
        p2_strategy, time5, delaybased.delivered,
        label="Queue-sensitive",
        color=:orange,
        linewidth=3,
        linestyle=:dash
    )

    hline!(
        p2_strategy, [capacity5],
        label="Router capacity (16 packets/round)",
        color=:gray,
        linestyle=:dot,
        linewidth=2
    )

    # Display both graphs
    plot(
        p1_strategy, p2_strategy,
        layout=(2, 1),
        size=(1050, 760),
        margin=8Plots.mm
    )
end


# ╔═╡ c312a4f4-344d-442e-b62b-787431f48340

md"""
### What did we learn?

**Look at the top graph first:**  The loss-responsive sender can allow a long queue to build up because it doesn't slow down until packets are dropped. The queue-sensitive sender reacts earlier. When the queue exceeds our target, it reduces its sending window, which can help keep fewer packets waiting.

**Now look at the bottom graph:** The router can only forward **16 packets per round**. Once it's already forwarding 16 packets, adding more packets to the queue doesn't make it faster.

This means **high throughput and short queues can sometimes coexist**.

However, if the queue-sensitive sender slows down too much, the router may not receive enough packets to stay busy, reducing throughput.

### What's the tradeoff?

We want:
- **High throughput:** Keep the router forwarding as much data as possible.
- **Low delay:** Avoid making packets wait unnecessarily.

**Key takeaway:** A full queue doesn't necessarily mean a faster network. Good congestion control tries to use the available capacity without creating unnecessary waiting.
"""


# ╔═╡ 6d2921a8-87d7-4255-ad5c-6e0db92cf5f2
md"""
# Takeaways #

1. **Capacity is limited:** Sending more packets than a router can handle creates queues and eventually packet loss, rather than increasing throughput.
2. **Feedback matters:** TCP adjusts its sending rate based on congestion, increasing when the network has room and slowing down when congestion is detected.
3. **Multiple senders interact:** When senders share a bottleneck, their behavior affects how fairly the available bandwidth is divided.
4. **Congestion control involves tradeoffs:** High throughput doesn't necessarily mean good performance. We also need to consider delay, packet loss, and fairness.

**The big idea:** Congestion control isn't just about sending data as fast as possible. It's about using the network efficiently without overwhelming it.
"""


# ╔═╡ 64280e86-16cf-43f1-9648-9bda316c4714

md"""
# Where to expand

Our simulations simplify how real networks work. There are several ways we could expand them:

- **Use real-world examples:** explore how congestion affects activities like video streaming, online gaming, and large file downloads
- **Explore real TCP congestion-control algorithms:** compare how TCP Reno, CUBIC, and BBR detect and respond to congestion
- **Simulate more senders and routers:** what happens when many devices share the same network, or when packets travel through multiple bottlenecks?
- **Model round-trip time (RTT):** explore how network delays affect how quickly senders receive feedback and adjust their sending rates
"""


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Plots = "~1.41.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.0"
manifest_format = "2.1"
project_hash = "e67e7ce83f4c1d44711549d3606a2992f69235ac"

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
version = "1.11.103+0"

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
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "f20e945b895d2009c6c28d8bbf40a5cd846f7c2f"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.0"

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
# ╟─3fee7eea-00de-4ab5-adb9-b0901058adfc
# ╟─1d7e916c-bc21-4d72-8a5c-3af52bcec6b3
# ╟─7460fad6-58bb-479e-9ce0-d065777ebcdf
# ╟─58ca4912-24ce-45e6-8aaa-6001b8eed713
# ╟─999e1d35-a973-4fd0-ba37-5233e79c4df8
# ╟─e6cebdaa-9be1-4505-a4b4-0368cd90438e
# ╟─e809a2d5-cf89-490a-af58-d6872a600a75
# ╟─129ede27-b84d-4b85-a402-84464b496e42
# ╟─6d967058-13bd-42be-b281-29dab1d1c799
# ╟─ebdcbae9-0ac0-465f-b7d5-6cc82bb6ad3d
# ╟─64745003-2f0c-4b39-af6b-ac6f715838f9
# ╟─ae93dd58-1347-4e4c-8f24-3abc9884649d
# ╟─0a56353c-d200-43c8-9f03-c373504f2f2a
# ╟─e6aea14b-afb8-44b5-a4a6-bcadd89c2072
# ╟─6a18bc30-2583-4829-8b44-e7b244a85555
# ╟─be68fb2b-d457-4fe8-94a5-b516040e6e93
# ╟─5a4566b2-9d60-499f-a5f1-c102e356141c
# ╟─effc2fcd-933e-4cd5-86e2-56902af16b10
# ╟─dd34a300-65ea-44d9-b62b-40d050707237
# ╟─fe5952f4-7ae4-475b-bdc2-71f5647fdddd
# ╟─fa6251ba-13e0-42d6-ae0c-63ca3a18e031
# ╟─a9b02d62-ae59-4129-990e-2b725a5a1eda
# ╟─2fee3561-989b-4a45-b327-2a30f8a38c59
# ╟─07610299-a05b-442e-a548-3451bfc51e7b
# ╟─4e76cf51-6aeb-4b30-9f3b-954f962ada86
# ╟─9b0bbd83-3d77-4d21-bd84-be1466edf4ef
# ╟─1b0f3e54-4423-45b2-8d94-6c91dc71856d
# ╟─ba877303-b37b-4fac-9862-5f93b1368726
# ╟─5a0837c1-c1fe-480f-b56e-ca65e7da077d
# ╟─e7c627b4-65e6-4a02-8e58-f3f209f019a7
# ╟─50919067-90c9-44a1-8e3d-589645eb92d4
# ╟─c312a4f4-344d-442e-b62b-787431f48340
# ╟─6d2921a8-87d7-4255-ad5c-6e0db92cf5f2
# ╟─64280e86-16cf-43f1-9648-9bda316c4714
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
