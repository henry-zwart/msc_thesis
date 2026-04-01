#import "@preview/gantty:0.5.1" as gantty
#import gantty: gantt
#import gantty.header: default-headers-drawer, default-month-header, default-year-header
#import gantty.milestones: default-milestones-drawer
#import gantty.drawers: default-drawer

#set page(width: 600pt, height: 450pt, fill: none)

// Setup the gantt binding to style as we wish for our project
#let gantt = gantt.with(
  drawer: (
    // Import the stylistic defaults
    ..default-drawer,
    // But change the headers to only show the month header
    headers: default-headers-drawer.with(
      headers: (default-year-header(), default-month-header(),),
    ),
    // milestones: default-milestones-drawer.with(
    //   today-content: none
    // )
  ),
)

#figure(
  gantt(yaml("gantt.yaml")), 
) <fig:gantt-chart>
