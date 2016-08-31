#!/usr/bin/julia

function collect_pin_map(fname)
    pin_map = [Dict{String,String}(), Dict{String,String}()]
    open(fname) do fd
        cur_fmc = 0
        local cur_name::String = ""
        for line in eachline(fd)
            if cur_fmc != 0
                m = match(r"LOC *= *([a-zA-Z0-9]+)", line)::RegexMatch
                pin_map[cur_fmc][cur_name] = m[1]
                cur_fmc = 0
            else
                m = match(r"^#.* FMC([12])_([a-zA-Z0-9]+)", line)
                m === nothing && continue
                m = m::RegexMatch
                cur_fmc = parse(Int, m[1])::Int
                cur_name = m[2]
            end
        end
    end
    return pin_map
end

function rewrite_ucf(fname, pin_map)
    open(fname) do fd
        cur_fmc = 0
        local cur_name::String = ""
        for line in eachline(fd)
            if cur_fmc != 0
                m = match(r"^(.*LOC *= *)([a-zA-Z0-9]+)(.*)$", line)::RegexMatch
                other_fmc = cur_fmc == 1 ? 2 : 1
                @assert pin_map[cur_fmc][cur_name] == m[2]
                cur_fmc = 0
                println(m[1] * pin_map[other_fmc][cur_name] * m[3])
            else
                m = match(r"^#.* FMC([12])_([a-zA-Z0-9]+)", line)
                if m === nothing
                    print(line)
                    continue
                end
                m = m::RegexMatch
                cur_fmc = parse(Int, m[1])::Int
                cur_name = m[2]
                print(line)
            end
        end
    end
end

const pin_map = collect_pin_map(ARGS[1])
rewrite_ucf(ARGS[1], pin_map)
