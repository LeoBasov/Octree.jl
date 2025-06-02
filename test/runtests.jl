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
    N_positions = 10
    positions = create_positions(N_positions)
    tree = Octree.build(positions)
    root = tree.leafs[1]
    boxes = Octree._create_children_boxes(root.box)
    nodes = Octree.get_nodes(root.box)

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
    @test length(tree.buttom_leafs) == 8

    # box 1
    @test boxes[1].xmin == [-1.0, -2.0, -3.0]
    @test boxes[1].xmax == [1.5, 1.5, 1.5]

    # box 2
    @test boxes[2].xmin == [1.5, -2.0, -3.0]
    @test boxes[2].xmax == [4.0, 1.5, 1.5]

    # box 3
    @test boxes[3].xmin == [1.5, 1.5, -3.0]
    @test boxes[3].xmax == [4.0, 5.0, 1.5]

    # box 4
    @test boxes[4].xmin == [-1.0, 1.5, -3.0]
    @test boxes[4].xmax == [1.5, 5.0, 1.5]

    # second layer
    # box 5
    @test boxes[5].xmin == [-1.0, -2.0, 1.5]
    @test boxes[5].xmax == [1.5, 1.5, 6.0]

    # box 6
    @test boxes[6].xmin == [1.5, -2.0, 1.5]
    @test boxes[6].xmax == [4.0, 1.5, 6.0]

    # box 7
    @test boxes[7].xmin == [1.5, 1.5, 1.5]
    @test boxes[7].xmax == [4.0, 5.0, 6.0]

    # box 8
    @test boxes[8].xmin == [-1.0, 1.5, 1.5]
    @test boxes[8].xmax == [1.5, 5.0, 6.0]

    # nodes
    xmin = root.box.xmin
    xmax = root.box.xmax

    @test nodes[1] == xmin
    @test nodes[2] == [4.0, -2.0, -3.0]
    @test nodes[3] == [-1.0, 5.0, -3.0]
    @test nodes[4] == [4.0, 5.0, -3.0]
    @test nodes[5] == [-1.0, -2.0, 6.0]
    @test nodes[6] == [4.0, -2.0, 6.0]
    @test nodes[7] == [-1.0, 5.0, 6.0]
    @test nodes[8] == xmax
end