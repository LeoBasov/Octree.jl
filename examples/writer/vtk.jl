using Octree

function create_positions(N)
    positions = Vector{Vector{Float64}}(undef, N)
    radius = 1.0

    for i = 1:N - 1
        phi = rand() * 2.0 * pi
        theta = rand() * pi
        r = 0.01 * randn()
        theta1 = rand() * pi - 0.5 * pi

        dis = [r * sin(theta) * cos(phi), r * sin(theta) * sin(phi), r * cos(theta)]
        offset = [radius * sin(theta1), radius * cos(theta1), 0.0]
        dis += offset

        positions[i] = dis
    end
    
    positions[N] = [0.0, -1.0, 0.0]

    return positions
end

config = Config()

config.aspect_ratio = 1.5

particles = create_positions(20000)
tree = build(particles; config = config)
write_vtk("vtk_test", tree)

open("particles.csv", "w") do file
    write(file, "x,y,z\n")

    for pos in particles
        write(file, string(pos[1]) * "," * string(pos[2]) * "," * string(pos[3]) * "\n")
    end
end

print("done")