module SimpleImageLabeler

using CSV, DataFrames, JSON, ImageView, Images, FileIO, Random, Glob, Comonicon

"""
A simple tool for image labeling

# Args

- `filename`: output file in csv format

# Options
- `-i, --images-path=<directory>`: directory where images are located
- `-l, --labels=<labels>`: comma separated labels
- `-d, --default=<def-label>`: default label (captured with empty string and enter)
"""
@main function main(filename::String; images_path::String, labels::String="0,1", default=nothing)
    valid_labels = split(labels, ',')
    default = default === nothing ? first(valid_labels) : default

    if isfile(filename)
        @info "loading data from $filename"
        df = CSV.read(filename, DataFrame)
    else
        @info "reading $images_path files"
        files = glob(joinpath(images_path, "*"))
        labels = Any[missing for _ in files]
        df = DataFrame(; files, labels)
    end

    n = length(df.labels)
    L = shuffle!(findall(ismissing.(df.labels)))
    @info "using a labeled table with $(length(L)) labels of $n"

    while length(L) != 0
        exampleID = pop!(L)
        imgname = df.files[exampleID]
        img = load(imgname)

        while true
            imshow(img)
            println("$(length(L)+1)/$n - labels for $imgname>")
            input = readline(stdin) |> strip
            labels = if input in ("", default)
                0
            elseif input == "1"
                1
            elseif input == "save"
                CSV.write(filename, df)
                continue
            else
                println("please respond $labels or save")
                continue
            end

            df.labels[exampleID] = labels
            ImageView.closeall()
            break
        end

        CSV.write(filename, df)
    end
end


end
