using Octree
using Test

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

@testset "tree.jl" begin
    N_positions = 100
    positions = create_positions(N_positions)
    tree = Octree.build(positions)
    root = tree.leafs[1]

    @test length(tree.elements) == N_positions

    @test root.box.xmin == [-1.0, -2.0, -3.0]
    @test root.box.xmax == [4.0, 5.0, 6.0]
    @test root.box.center == [1.5, 1.5, 1.5]
    @test root.box.volume == 5.0 * 7.0 * 9.0

    @test root.offset == 0
    @test root.n_elements == N_positions
    @test root.parent == 0
    @test length(root.children) == 8

    n_sum = 0

    for i in 1:8
        leaf = tree.leafs[root.children[i]]
        n_sum += leaf.n_elements
    end

    @test N_positions == n_sum
end