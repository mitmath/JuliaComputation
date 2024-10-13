using CUDA
using FLoops
using FoldsCUDA
using StaticArrays

function nbody(n, num_steps, dt; ArrayType=Array, box_size=1, dims=2)
    accelerations = ArrayType([SVector(Tuple(zeros(dims))) for i = 1:n])
    positions = ArrayType([SVector(Tuple(rand(dims) * box_size .- 0.5 * box_size)) for i = 1:n])
    masses = ArrayType(ones(n))
    last_positions = copy(positions)

    trajectories = zeros(eltype(positions), num_steps, 2)  # always "CPU" array

    for t in 1:num_steps
        # Equivalent:
        #     @floop for i in 1:n
        #         pᵢ = positions[i]
        #         mᵢ = masses[i]
        #         ...
        #     end

        @floop for (i, pᵢ, mᵢ) in zip(1:n, positions, masses)
            a = zero(accelerations[i])
            for (j, pⱼ, mⱼ) in zip(1:n, positions, masses)
                if j != i
                    r² = sum((pᵢ .- pⱼ) .^ 2)
                    𝟙 = (pᵢ .- pⱼ) ./ sqrt(r²)
                    G = 9.81
                    a += (G * mᵢ * mⱼ / r²) * 𝟙
                end
            end
            accelerations[i] = a
        end

        # verlet
        positions .= positions * 2 .- last_positions .+ accelerations * dt * dt

        last_positions .= positions

        # "Download" first two position data
        @views copy!(trajectories[t, :], positions[1:2])
    end

    return trajectories
end

# nbody(10, 20, 0.1)
positions = nbody(100, 10000, 0.1; ArrayType = CuArray)

using Plots
plot(
    map(p -> p.x, positions),
    map(p -> p.y, positions),
)
