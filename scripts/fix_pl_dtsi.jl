#!/usr/bin/julia -f

open(ARGS[1], "r") do f_in
    open(ARGS[2], "w") do f_out
        find_axi_dma = false
        level = 0
        for line in eachline(f_in)
            if !find_axi_dma && match(r"axi_dma_0", line) !== nothing
                find_axi_dma = true
                write(f_out, line)
                level += 1
                continue
            end
            if !find_axi_dma
                write(f_out, line)
                continue
            end
            line = replace(line, "\"xlnx,axi-dma\"", "\"xlnx,axi-dma-1.00.a\"")
            write(f_out, line)
            if match(r"{", line) !== nothing
                level += 1
            end
            if match(r"};", line) !== nothing
                level -= 1
                if level == 0
                    find_axi_dma = false
                    write(f_out, """
                          \t\tpulse_ctrl_stream@0 {
                          \t\t\tcompatible ="nacs,pulser-ctrl-stream";
                          \t\t\tdmas = <&axi_dma_0 0
                          \t\t\t        &axi_dma_0 1>;
                          \t\t\tdma-names = "axidma0", "axidma1";
                          \t\t};
                          """)
                end
            end
        end
    end
end
