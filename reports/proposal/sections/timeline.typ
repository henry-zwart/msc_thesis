#import "@preview/gantty:0.5.1" as gantty
#import gantty: gantt
#import gantty.header: default-headers-drawer, default-month-header, default-year-header
#import gantty.milestones: default-milestones-drawer
#import gantty.drawers: default-drawer

// Setup the gantt binding to style as we wish for our project
#let gantt = gantt.with(
  drawer: (
    // Import the stylistic defaults
    ..default-drawer,
    // But change the headers to only show the month header
    headers: default-headers-drawer.with(
      headers: (default-year-header(), default-month-header(),),
    ),
    milestones: default-milestones-drawer.with(
      today-content: none
    )
  ),
)

Our tentative timeline is summarised in the Gantt chart below (@fig:gantt-chart). I expect to begin full-time 
work on this project in the new year (January 5), once I have completed my final course. Prior to this 
I will continue surveying related work for my literature review, and (ideally) establish access to the 
climate attitudes dataset. I intend to have completed the literature review by the start of February. 

Survey data extraction, transformation, and EDA can occur mostly in parallel with the literature review, 
with the exception of identifying relevant factors and questions to include in the model. Theoretical 
model development can happen concurrently with the literature review _writing_ component, but is 
contingent on having adequately surveyed the relevant theoretical background. 

#figure(
  gantt(yaml("../gantt.yaml")), 
  caption: [Tentative project timeline Gantt chart.]
) <fig:gantt-chart>
