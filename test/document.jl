using DataStructures: OrderedDict

@testset "Document" begin

    dmeta = TextAnalysis.DocumentMetadata(Languages.English(), "test title", "test author", "test time", Dict(:k1 => "v1", :k2 => "v2"))
    @test (dmeta.language == Languages.English()) &&
          (dmeta.title == "test title") &&
          (dmeta.author == "test author") &&
          (dmeta.timestamp == "test time") &&
          (get(dmeta.custom, :k1, "") == "v1") &&
          (get(dmeta.custom, :k2, "") == "v2")

    # mutability
    dmeta.custom = nothing
    @test isnothing(dmeta.custom)

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd = StringDocument(sample_text1)
    fd = FileDocument(sample_file)
    td = TokenDocument(sample_text1)
    ngd = NGramDocument(sample_text1)

    @test isequal(text(sd), sample_text1)
    text!(sd, sample_text2)
    @test isequal(text(sd), sample_text2)
    text!(sd, sample_text1)
    @test isequal(text(sd), sample_text1)

    @test all(tokens(sd) .== ["This", "is", "a", "string"])
    @test "This" in keys(ngrams(sd, 1))
    @test "is" in keys(ngrams(sd, 1))
    @test "a" in keys(ngrams(sd, 1))
    @test "string" in keys(ngrams(sd, 1))

    @test ordered_vocab(sd) == OrderedDict("This" => 1, "is" => 2, "a" => 3, "string" => 4)
    @test ordered_vocab(["This", "is", "a", "string"]) == OrderedDict("This" => 1, "is" => 2, "a" => 3, "string" => 4)

    @test length(sd) == 16

    hamlet_text = "To be or not to be..."
    sd = StringDocument(hamlet_text)
    @test isa(sd, StringDocument)
    @test isequal(text(sd), hamlet_text)

    @test isa(fd, FileDocument)
    @test length(text(fd)) > 0

    my_tokens = ["To", "be", "or", "not", "to", "be..."]
    td = TokenDocument(my_tokens)
    @test isa(td, TokenDocument)
    @test all(tokens(td) .== my_tokens)

    my_ngrams = Dict{String,Int}()
    my_ngrams["To"] = 1
    my_ngrams["be"] = 2
    my_ngrams["or"] = 1
    my_ngrams["not"] = 1
    my_ngrams["to"] = 1
    my_ngrams["be..."] = 1
    ngd = NGramDocument(my_ngrams)
    @test isa(ngd, NGramDocument)
    @test "To" in keys(ngrams(ngd))

    sd = StringDocument(hamlet_text)
    td = TokenDocument(hamlet_text)
    ngd = NGramDocument(hamlet_text)

    d = Document("To be or not to be...")
    @test isa(d, StringDocument)
    d = Document(joinpath(dirname(@__FILE__), "data", "poem.txt"))
    @test isa(d, FileDocument)
    d = Document(["To", "be", "or", "not", "to", "be..."])
    @test isa(d, TokenDocument)
    ng = Dict{String,Int}()
    ng["a"] = 1
    ng["b"] = 3
    d = Document(ng)
    @test isa(d, NGramDocument)

    @test isequal(length(Document("this is text")), 12)

    # NGramDocument creation with multiple ngram complexity
    let N = ((), (2,), (Int32(2),), (1, 2), (Int32(1), Int16(2))), C = (1, 2, 2, [1, 2], [1, 2]), L = (4, 3, 3, 7, 7)
        for (n, c, l) in zip(N, C, L)
            ngd = NGramDocument(sample_text1, n...)
            @test ngram_complexity(ngd) == c
            @test length(ngd.ngrams) == l
        end
    end
end
