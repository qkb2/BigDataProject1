# Updated data
data = [
    ["tt2387089", 1, "nm1813959", "self", "\\N", '["Herself - Host"]'],
    ["tt0956162", 6, "nm1270819", "writer", "screenplay", "\\N"],
    ["tt0794745", 1, "nm0723910", "actress", "\\N", '["Pauline"]'],
    ["tt9449496", 9, "nm2412793", "writer", "\\N", "\\N"],
    ["tt9319512", 3, "nm10170208", "actor", "\\N", '["Riku Odajima"]'],
    ["tt2808286", 7, "nm3925477", "editor", "\\N", "\\N"],
    ["tt3455400", 3, "nm4576887", "editor", "\\N", "\\N"],
    ["tt5893228", 4, "nm5853904", "cinematographer", "\\N", "\\N"],
    ["tt5080734", 7, "nm0697426", "actress", "\\N", '["Chabe"]'],
    ["tt9319513", 3, "nm10170208", "director", "\\N", "\\N"],
    ["tt8614032", 2, "nm9937380", "actress", "\\N", '["Church goer"]'],
    ["tt9319514", 3, "nm10170208", "actor", "\\N", '["Riku Odajima"]'],
    ["tt9319500", 3, "nm10170208", "writer", "\\N", "\\N"],
    ["tt9177580", 1, "nm6393352", "self", "\\N", '["Herself - Narrator"]'],
    ["tt1931235", 3, "nm2038422", "director", "\\N", "\\N"],
    ["tt8779902", 1, "nm1765868", "actress", "\\N", "\\N"],
    ["tt6632104", 5, "nm0461921", "director", "\\N", "\\N"],
    ["tt7020816", 6, "nm0350907", "director", "\\N", "\\N"],
    ["tt9739322", 8, "nm7749575", "writer", "dialogue", "\\N"],
    ["tt0401828", 3, "nm1645880", "composer", "\\N", "\\N"],
    ["tt3181736", 9, "nm0470494", "actress", "\\N", '["Anna Lisková"]'],
    ["tt0626702", 8, "nm1859149", "writer", "writer", "\\N"],
    ["tt9319524", 3, "nm10170208", "director", "\\N", "\\N"],
    ["tt10760718", 4, "nm4110994", "actress", "\\N", "\\N"],
    ["tt9419513", 3, "nm10170208", "actor", "\\N", '["abcd"]'],
    ["tt9319599", 3, "nm10170208", "writer", "\\N", "\\N"]
]

# Extract the third column (IDs)
ids = [row[2] for row in data]

# Count unique IDs
unique_ids = set(ids)
print("Number of unique IDs:", len(unique_ids))
