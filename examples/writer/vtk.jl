using Octree

function create_positions(N, pos_min = [-1.0, -2.0, -3.0], pos_max = [4.0, 5.0, 6.0])
    positions = Vector{Vector{Float64}}(undef, N)
    diff = pos_max - pos_min

    for i = 1:N - 1
        positions[i] = pos_min + rand(3).*diff
    end

    positions[N - 1] = pos_min
    positions[N] = pos_max

    return positions
end

particles = create_positions(10000)
tree = build(particles)
write_vtk("vtk_test", tree)

print("done")