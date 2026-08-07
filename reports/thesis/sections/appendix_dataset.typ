= Climate Beliefs Dataset <apdx:dataset>

#set table(stroke: (x, y) => (y: if y == 1 { 0.5pt } else { 0pt }))
#figure(
  {
    set text(size: 9pt)
    table(
      columns: 2,
      align: (left, left),
      //column-gutter: 1em,
      table.header[Item][Question text],
      [CC Real], [Do you think that climate change is happening?],

      [CC Human], [Do you think rising temperatures are a result of human activities, natural causes, or both?],

      [CC Impact $X$],
      [How much do you think climate change is currently harming $X$ in general? Where $X$ is one of: "the world", "wealthy communities in the United States", "poor communities in the United States", "your local community"],

      [CC Others Worry], [How worried do you think most Americans are about global warming/climate change these days?],

      [CC Worry], [How worried are you about current and future global warming/climate change?],

      [Weather Worry],
      [How worried are you about an extreme weather event or natural disaster happening to you personally in the next year?],

      [CC Responsibility], [It is important that individuals take action on issues of climate change.],

      [CC Scientists], [Scientists with appropriate expertise should guide how we respond to climate change],

      [Policy: ICA (\*)],
      [Do you favour an international agreement committing the USA and other countries to reduce their carbon emissions?],

      [Policy: Tax fuel], [How much do you support/oppose a tax on the production/distribution of carbon-based fuelds?],

      [Policy: Auto], [How much do you support/oppose stronger carbon emissions standard for car manufacturers?],

      [Policy: Env. Reg.], [Which statement comes closer to your views?],

      [Political affiliation (\*\*)], [In politics today, do you consider yourself a:],

      [Political ideology], [What is your political ideology?],
    )
  },
  caption: [
    Complete set of filtered survey items used to construct the climate beliefs dataset
    (@subsec:dataset-dataset-construction)
  ],
  placement: none,
  outlined: false,
) <tab:apdx-dataset-all-items>

