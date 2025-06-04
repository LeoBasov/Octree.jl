using Octree

function read_points(file_name)
    points = []

    open(file_name) do file
        while !eof(file)
            line = readline(file)
            splt = split(line, " ")

            if splt[1] == "#"
                continue
            elseif length(splt) == 3
                point = [parse(Float64, splt[1]), parse(Float64, splt[2]), parse(Float64, splt[3])]
                push!(points, point)
            end
        end
    end

    return points
end

config = Config()

config.aspect_ratio = 1.5 # max cell aspect ratio
config.n_min = 10 # min number of particles per cell for subdivision

file_name = "examples/writer/points_cylinder.asc"
points = read_points(file_name)

println(length(points))

tree = build(points; config = config)

@profview write_vtk("vtk_test", tree)

println("done")