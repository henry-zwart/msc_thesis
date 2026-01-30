import polars as pl

ResponseType = pl.Enum(
    [
        "Single response",
        "Multiple response",
        "Dropdown",
        "Text",
        "Slider",
        "Numeric",
        "Drag and drop (in order)",
    ]
)

ParticipantType = pl.Enum(["new", "repeating"])
