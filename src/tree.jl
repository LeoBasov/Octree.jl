mutable struct Config
    aspect_ratio::AbstractFloat

    function Config(;aspect_ratio = 0.0)
        new(aspect_ratio)
    end
end

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
    config::Config

    Tree(root, positions, config) = new([i for i in eachindex(positions)], [root], [], config)
end

function build(positions; config = Config())
    root = _create_root(positions)
    tree = Tree(root, positions, config)

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
    boxes = _merge_boxes(boxes, tree.config.aspect_ratio)
    offset = parent.offset
    runner_idx = parent.offset + 1
    n_childre = length(boxes)

    resize!(tree.leafs, length(tree.leafs) + n_childre)
    resize!(parent.children, n_childre)

    for i in 1:n_childre
        leaf = Leaf(boxes[i])
        leaf.parent = parent_id
        leaf.offset = offset

        for elem_id in runner_idx:parent.offset + parent.n_elements
            if is_in_box(leaf.box, positions[tree.elements[elem_id]])
                tree.elements[elem_id], tree.elements[runner_idx] = tree.elements[runner_idx], tree.elements[elem_id]
                leaf.n_elements += 1
                runner_idx += 1
                offset += 1
            end
        end

        parent.children[i] = length(tree.leafs) - n_childre + i
        tree.leafs[length(tree.leafs) - n_childre + i] = leaf
    end

    for i in 1:n_childre
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

function _merge_boxes(_boxes, aspect_ratio)
    boxes = deepcopy(_boxes)

    if aspect_ratio == 0.0
        return boxes
    end

    diff = boxes[1].xmax - boxes[1].xmin
    merge = [false, false, false]

    merge[1] = diff[2] / diff[1] > aspect_ratio || diff[3] / diff[1] > aspect_ratio
    merge[2] = diff[1] / diff[2] > aspect_ratio || diff[3] / diff[2] > aspect_ratio
    merge[3] = diff[1] / diff[3] > aspect_ratio || diff[2] / diff[3] > aspect_ratio

    if merge[1] && merge[2]
        #TODO
    elseif merge[1] && merge[3]
        #TODO
    elseif merge[2] && merge[3]
        #TODO
    elseif merge[1]
        box1 = Cuboid(boxes[1].xmin, [boxes[2].xmax[1], boxes[1].xmax[2], boxes[1].xmax[3]])
        box2 = Cuboid(boxes[4].xmin, [boxes[3].xmax[1], boxes[4].xmax[2], boxes[4].xmax[3]])
        box3 = Cuboid(boxes[5].xmin, [boxes[6].xmax[1], boxes[5].xmax[2], boxes[5].xmax[3]])
        box4 = Cuboid(boxes[8].xmin, [boxes[7].xmax[1], boxes[8].xmax[2], boxes[8].xmax[3]])

        boxes = (box1, box2, box3, box4)
    elseif merge[2]
        box1 = Cuboid(boxes[1].xmin, [boxes[3].xmax[1], boxes[1].xmax[2], boxes[1].xmax[3]])
        box2 = Cuboid(boxes[2].xmin, [boxes[4].xmax[1], boxes[4].xmax[2], boxes[2].xmax[3]])
        box3 = Cuboid(boxes[5].xmin, [boxes[7].xmax[1], boxes[5].xmax[2], boxes[5].xmax[3]])
        box4 = Cuboid(boxes[6].xmin, [boxes[8].xmax[1], boxes[8].xmax[2], boxes[6].xmax[3]])

        boxes = (box1, box2, box3, box4)
    elseif merge[3]
        box1 = Cuboid(boxes[1].xmin, [boxes[1].xmax[1], boxes[1].xmax[2], boxes[5].xmax[3]])
        box2 = Cuboid(boxes[2].xmin, [boxes[2].xmax[1], boxes[2].xmax[2], boxes[6].xmax[3]])
        box3 = Cuboid(boxes[3].xmin, [boxes[3].xmax[1], boxes[3].xmax[2], boxes[7].xmax[3]])
        box4 = Cuboid(boxes[4].xmin, [boxes[4].xmax[1], boxes[4].xmax[2], boxes[8].xmax[3]])

        boxes = (box1, box2, box3, box4)
    end

    return boxes
end