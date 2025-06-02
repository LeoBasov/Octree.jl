using WriteVTK
using Octree

function write_vtk(file_name, tree)
    points::Matrix{Float64} = zeros(3, 8*length(tree.buttom_leafs))
    cells::Vector{MeshCell} = []
    sol::Matrix{Float64} = zeros(1, length(tree.buttom_leafs))
    idx = 0
    cell_idx = 1

    for leaf_id in tree.buttom_leafs
        leaf = tree.leafs[leaf_id]
        nodes = get_nodes(leaf.box)

        for i in 1:8
            points[1, idx + i] = nodes[i][1]
            points[2, idx + i] = nodes[i][2]
            points[3, idx + i] = nodes[i][3]
        end

        push!(cells, MeshCell(VTKCellTypes.VTK_VOXEL, [i + idx for i in 1:8]))
        sol[1, cell_idx] = leaf.n_elements
        idx += 8
        cell_idx += 1
    end

    vtk_grid(file_name, points, cells) do vtk
        vtk["number_elements", VTKCellData()] = sol
    end
end