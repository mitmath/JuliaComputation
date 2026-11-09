# g(a,r,n) = geometric_sequence
# refers implicitly to  →    a,ar,ar²,…, arⁿ⁻¹

# state(i,t) = iteration number and current term (i.e. t = arⁱ)
# start = state(0,i)
# next = (i,t) → (i+1, r*t)
# done when i=n

struct geometric_sequence
    a :: Float64  # start
    r :: Float64  # ratio
    n :: Int   # number of terms
end

struct geometric_sequence_state 
    i :: Int     # iteration number
    t :: Float64 # current term  
end

iterate(g::geometric_sequence) =  geometric_sequence_state(0,g.a) # start

# next should return term and state
function iterate(g::geometric_sequence, s::geometric_sequence_state)
    s.t, geometric_sequence_state(s.i+1, g.r * s.t )
end