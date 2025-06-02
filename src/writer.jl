using WriteVTK
using Octree

function write_vtk(file_name, tree)
    points::Matrix{Float64} = zeros(3, 8*length(tree.buttom_leafs))
    cells::Vector{MeshCell} = []
    idx = 0

    for leaf_id in tree.buttom_leafs
        leaf = tree.leafs[leaf_id]
        nodes = get_nodes(leaf.box)

        for i in 1:8
            points[1, idx + i] = nodes[i][1]
            points[2, idx + i] = nodes[i][2]
            points[3, idx + i] = nodes[i][3]
        end

        push!(cells, MeshCell(VTKCellTypes.VTK_VOXEL, [i + idx for i in 1:8]))
        idx += 8
    end

    vtk_grid(file_name, points, cells) do vtk
        #vtk["temperature", VTKPointData()] = sol
    end
end