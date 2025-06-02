struct Cuboid
    xmin::Vector{AbstractFloat}
    xmax::Vector{AbstractFloat}
    center::Vector{AbstractFloat}
    volume::AbstractFloat

    function Cuboid(xmin, xmax)
        new(float(xmin), float(xmax), 0.5 * (float(xmax) + float(xmin)), prod(float(xmax) - float(xmin)))
    end
end

mutable struct Leaf
    box::Cuboid
    offset::Integer
    n_elements::Integer
    parent::Integer
    children::Vector{Integer}

    Leaf(box::Cuboid) = new(box, 0, 0, 0, [])
end

mutable struct Tree
    elements::Vector{Integer}
    leafs::Vector{Leaf}
    buttom_leafs::Vector{Integer}

    Tree(root, positions) = new([i for i in eachindex(positions)], [root], [])
end

function build(positions)
    root = _create_root(positions)
    tree = Tree(root, positions)

    _build_next_level!(tree, 1, positions)

    return tree
end

function _create_root(positions)
    box = _create_bounding_box(positions)
    root = Leaf(box)

    root.offset = 0
    root.n_elements = length(positions)
    root.parent = 0
    root.children = []

    return root
end

function _create_bounding_box(positions)
    xmin = [Inf, Inf, Inf]
    xmax = [-Inf, -Inf, -Inf]

    for pos in positions
        for i in 1:3
            xmin[i] = pos[i] < xmin[i] ? pos[i] : xmin[i]
            xmax[i] = pos[i] > xmax[i] ? pos[i] : xmax[i]
        end
    end

    return Cuboid(xmin, xmax)
end

function _build_next_level!(tree, parent_id, positions)
    parent = tree.leafs[parent_id]

    # dummy check
    if parent.n_elements < 10
        push!(tree.buttom_leafs, parent_id)
        return
    end

    boxes = _create_children_boxes(parent.box)
    offset = parent.offset
    runner_idx = parent.offset + 1

    resize!(tree.leafs, length(tree.leafs) + 8)
    resize!(parent.children, 8)

    for i in 1:8
        leaf = Leaf(boxes[i])
        leaf.parent = parent_id
        leaf.offset = offset

        for elem_id in runner_idx:parent.offset + parent.n_elements
            if is_in_box(leaf.box, positions[tree.elements[elem_id]])
                tree.elements[elem_id], tree.elements[runner_idx] = tree.elements[runner_idx], tree.elements[elem_id]
                leaf.n_elements += 1
                runner_idx += 1
            end
        end

        parent.children[i] = length(tree.leafs) - 8 + i
        tree.leafs[length(tree.leafs) - 8 + i] = leaf
    end

    for i in 1:8
        _build_next_level!(tree, parent.children[i], positions)
    end
end

function _create_children_boxes(box::Cuboid)
    box1 = Cuboid(box.xmin, box.center)
    box2 = Cuboid([box.center[1], box.xmin[2], box.xmin[3]], [box.xmax[1], box.center[2], box.center[3]])
    box3 = Cuboid([box.center[1], box.center[2], box.xmin[3]], [box.xmax[1], box.xmax[2], box.center[3]])
    box4 = Cuboid([box.xmin[1], box.center[2], box.xmin[3]], [box.center[1], box.xmax[2], box.center[3]])

    box5 = Cuboid([box.xmin[1], box.xmin[2], box.center[3]], [box.center[1], box.center[2], box.xmax[3]])
    box6 = Cuboid([box.center[1], box.xmin[2], box.center[3]], [box.xmax[1], box.center[2], box.xmax[3]])
    box7 = Cuboid([box.center[1], box.center[2], box.center[3]], [box.xmax[1], box.xmax[2], box.xmax[3]])
    box8 = Cuboid([box.xmin[1], box.center[2], box.center[3]], [box.center[1], box.xmax[2], box.xmax[3]])

    return (box1, box2, box3, box4, box5, box6, box7, box8)
end

function is_in_box(box::Cuboid, pos::Vector)
    inx = pos[1] <= box.xmax[1] && pos[1] >= box.xmin[1]
    iny = pos[2] <= box.xmax[2] && pos[2] >= box.xmin[2]
    inz = pos[3] <= box.xmax[3] && pos[3] >= box.xmin[3]

    return inx && iny && inz
end

function get_nodes(box::Cuboid)
    xmin = box.xmin
    xmax = box.xmax

    pos1 = [xmin[1], xmin[2], xmin[3]]
    pos2 = [xmax[1], xmin[2], xmin[3]]
    pos3 = [xmin[1], xmax[2], xmin[3]]
    pos4 = [xmax[1], xmax[2], xmin[3]]

    pos5 = [xmin[1], xmin[2], xmax[3]]
    pos6 = [xmax[1], xmin[2], xmax[3]]
    pos7 = [xmin[1], xmax[2], xmax[3]]
    pos8 = [xmax[1], xmax[2], xmax[3]]

    return (pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8)
end