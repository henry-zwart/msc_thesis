Demographic: 
- State 
- county 
- zip code 
- education level
- gender 
- age
- race 
- income

*Note:* the survey includes some drag-and-drop/ordering questions. These could provide some interesting info.

Extreme weather:
- Yes/no experienced different forms of extreme weather: in lifetime, last 10 years, since last survey wave(?)
- For most personally impactful event:
  - Event type
  - Date 
  - Personal impacts: physical harm, material, financial, mental
  - Rating public officials' handling 
  - Did it cause to feel socially distant or closer to community?
  - Do you *think* climate change made more probably or severe?
- Received assistance in last 10 years for extreme weather, from:
  - Any level of govt
  - Other institutions or groups
- Considered moving, had to move, or temporarily relocated due to weather
- Worry about extreme weather events happening to you in next year
- Level of preparation for future events
- Attitude toward people whose homes in disaster-prone areas were damaged
- Belief: prohib building in disaster-prone areas vs. prioritise civil liberties and individual decisions
- Recent storm in Texas:
  - Knowledge of the event
  - Causes of the storm
  - Causes of (power?) outages during storm
- Causes of increased wildfire frequency in West (of USA)
 


- `cc4`: Asks how much global warming/climate change is currently harming \<COMMUNITY OR LOCATION\>:
  - Scale: 1--4 (not at all --- a great deal), and "don't know".
  - A response $> 1$ indicates belief that climate change is happening
  - A response of $1$ indicates belief that climate change is not happening (when community/location is broad)
  - A response of $1$ indicates either belief in no-CC, or that no personal harm experienced (when community/location is local)


== Variable associations
Consistent groupings:
- *Politics*: `pol_ideology`, `pol_affiliation`
- *Extreme weather*: `ew5`, `ew6`
- *CC Behaviour Change*: `cvcc4_will`, `cvcc4_should`, `cvcc4_personal`
- *CC Rational*: `cc10`, `cc11`, `cc12`
- *CC Impacts*: `cc4`, `cc5` (sometimes with `cc3`; sometimes without `cc4_world`)
- *CC Policy 1*: `cc_pol_tax`, `cc_pol_car`
- *CC Policy 2*: `cc_ica`, `pol7`


Consistently high betweenness centrality:
- `cvcc6`
- `cvcc5_world`
- `cc6`
- `cc3`

Consistently low betweenness centrality:
- `pol7_pi`
- `pol_ideology`
- `ew6`
- `cc12`
- `cc11`
- `cc2`


=== Partial correlation
- *CC Impacts*: `cc4`, `cc5`
- *CC Behaviour change*: `cvcc4_should`, `cvcc4_personal`, `cvcc4_will`
- *EW*: `ew5`, `ew6`
- *Politics*: `pol_affiliation`, `pol_ideology`
- *CC Policy*: `cvcc6`, `cvcc9_cc`, `cc_pol_tax`, `cc_pol_car`, `cc_ica`, `pol7`
- *CC Rational*: `cc10`, `cc11`, `cc12`
- *CC Nature*: `cc1`, `cc2`
- *CC Concern*: `cc3`, `cc4`

Ungrouped relations:
- `pol7_pi`: `cvcc_worryothers`, `pol7`
- `cvcc_worryothers`: `cc4_wealthUS`, `ew5`, `cc10`, `pol7_pi`, `cvcc4_will`, `pol7`, `cc11`, `cc6`

Highest betweenness centrality:
- `cvcc6`, `cvcc9_cc`, `cc_pol_car`, `cc_pol_tax`, `cc5_world`

Lowest betweenness centrality:
- `cc10`, `pol7_pi`, `pol_ideology`, `pol_affiliation`, `cc12`

=== Regularised partial correlation
- *CC Impacts*: `cc4`, `cc5`
- *CC Behaviour change*: `cvcc4_should`, `cvcc4_personal`, `cvcc4_will`
- *EW*: `ew5`, `ew6`
- *Politics*: `pol_affiliation`, `pol_ideology`
- *CC Policy*: `cvcc6`, `cvcc9_cc`, `cc_pol_tax`, `cc_pol_car`, `cc_ica`, `pol7`
- *CC Rational*: `cc10`, `cc11`, `cc12`
- *CC Nature*: `cc1`, `cc2`
- *CC Concern*: `cc3`, `cc4`

Ungrouped relations:
- `pol7_pi`: `cvcc_worryothers`, `pol7`
- `cvcc_worryothers`: `cc6`, `pol7_pi`, `cvcc4_will`, `cc4_wealthUS`

Highest betweenness centrality:
- `cc5_world`, `cc6`, `cc5_poorUS`, `cc3`, `cc5_comm`

Lowest betweenness centrality:
- `pol_ideology`, `cc12`, `cc11`, `pol7_pi`, `ew6`

=== Distance correlation
- *CC Rational*: `cc10`, `cc11`, `cc12`
- *CC General*: `cc3`, `cc6`, `cc4`, `cc5`
- *Politics*: `pol_affiliation`, `pol_ideology`

Highest betweenness centrality:
- `cc3`, `cc6`, `cc5_world`, `cc5_poorUS`, `cc5_comm`

Lowest betweenness centrality:
- `cc10`, `ew6`, `cvcc_worryothers`, `pol7_pi`, `cc2`

=== Contemporaneous correlation
- *CC Impacts*: `cc3`, `cc4` (except `cc4_world`), `cc5`
- *CC Urgency(?)*: `cc3`, `pol_affiliation`, `cvcc6`, `cvcc4_personal`, `cc6`, `cvcc_worryothers`
- *CC Policy*: `cc_pol_tax`, `cc_pol_car`
- *CC Policy 2*: `cc_ica`, `pol7`
- *CC Nature*: `cc1`, `cc2`
- *CC Status (general)*: `cc1`, `cc4_world`
- *CC Behaviour change*: `cvcc4_will`, `cvcc4_should`
- *EW*: `ew5`, `ew6`
- *CC Rational*: `cc10`, `cc11`, `cc12`

Ungrouped relations:
- `cvcc9_cc`: `cc3`, `cvcc6`, `cvcc4_personal`, `cc4_world`, `pol7`, `cvcc4_should`
- `pol7_pi`: `pol_affiliation`, `cvcc_worryothers`
- `pol_ideology`: `pol_affiliation`

Highest betweenness centrality:
- `cc3`, `pol_affiliation`, `cvcc4_should`, `cvcc4_will`, `cvcc4_personal`

Lowest betweenness centrality:
- `cc12`, `pol_ideology`, `ew6`, `pol7_pi`, `cc2`

=== Temporal correlation
No identifiable clusters in matrix. *Perhaps in network?*

Highest betweenness centrality:
- `cvcc4_personal`, `cvcc4_should`, `cvcc6`, `pol7`, `cc_ica`

Lowest betweenness centrality:
- `cc12`, `cc5_poorUS`, `pol_ideology`, `pol7_pi`, `cc11`

=== Contemporaneous correlation (regularised)
- *CC Future Impacts*: `cc5`
- *CC Local/US Impacts (?):* `cc4_comm`, `cc4_poorUS`, `cc4_wealthUS`
- *CC Behaviour change*: `cvcc4_will`, `cvcc4_should`, `cvcc4_personal`
- *CC Policy 1*: `cc_pol_tax`, `cc_pol_car`
- *CC Policy 2*: `cc_ica`, `pol7`
- *Politics*: `pol_affiliation`, `pol_ideology`
- *CC Status (general)*: `cc1`, `cc4_world`, `cc3`, `cc6`
- *Unknown*: `cvcc6`, `cvcc9_cc`
- *EW*: `ew5`, `ew6`
- *CC Rational*: `cc10`, `cc11`, `cc12`

Ungrouped relations:
- `cc2`: `cc1`, `pol7_pi`
- `cvcc_worryothers`: `cvcc4_will`, `cc6`, `cc12`
- `pol7_pi`: `pol7`

Highest betweenness centrality:
- `cc4_world`, `cc4_poorUS`, `cc4_comm`, `cc4_wealthUS`, `cc1`

Lowest betweenness centrality:
- `ew6`, `pol7_pi`, `pol_affiliation`, `pol_ideology`, `cc2`

=== Temporal correlation (regularised)
No identifiable clusters in matrix. *Perhaps in network?*

Highest betweenness centrality:
- `cc6`, `ew5`, `cc3`, `cvcc6`, `cvcc9_cc`

Lowest betweenness centrality:
- `cc4_world`, `cc5_world`, `cc11`, `cc5_poorUS`, `pol7_pi`


=== Ranks: Highest/lowest betweenness (fraction)
Highest:
- `cvcc6`: Partial, Temporal, Temporal (reg)
- `cvcc9_cc`: Partial, Temporal (reg)
- `cc_pol_car`: Partial
- `cc_pol_tax`: Partial
- `cc5_world`: Partial, Partial (reg), Distance
- `cc6`: Partial (reg), Distance, Temporal (reg)
- `cc5_poorUS`: Partial (reg), Distance
- `cc3`: Partial (reg), Distance, Contemporaneous, Temporal (reg)
- `cc5_comm`: Partial (reg), Distance
- `pol_affiliation`: Contemporaneous
- `cvcc4_should`: Contemporaneous, Temporal
- `cvcc4_will`: Contemporaneous
- `cvcc4_personal`: Contemporaneous, Temporal
- `pol7`: Temporal
- `cc_ica`: Temporal
- `cc4_world`: Contemporaneous (reg)
- `cc4_poorUS`: Contemporaneous (reg)
- `cc4_comm`: Contemporaneous (reg)
- `cc4_wealthUS`: Contemporaneous (reg)
- `cc1`: Contemporaneous (reg)
- `ew5`: Temporal (reg)

Lowest:
- `cc10`: Partial, Distance
- `pol7_pi`: Partial, Partial (reg), Distance, Contemporaneous, Temporal, Contemporaneous (reg), Temporal (reg)
- `pol_ideology`: Partial, Partial (reg), Contemporaneous, Temporal, Contemporaneous (reg)
- `pol_affiliation`: Partial, Contemporaneous (reg)
- `cc12`: Partial, Partial (reg), Contemporaneous, Temporal
- `cc11`: Partial (reg), Temporal, Temporal (reg)
- `ew6`: Partial (reg), Distance, Contemporaneous, Contemporaneous (reg)
- `cvcc_worryothers`: Distance
- `cc2`: Distance, Contemporaneous, Contemporaneous (reg)
- `cc5_poorUS`: Temporal, Temporal (reg)
- `cc4_world`: Temporal (reg)
- `cc5_world`: Temporal (reg)


== Variable associations

Consistent groups:
- *CC Impact*: `cc4`, `cc5`
- *EW*: `ew5`, `ew6`
- *CC Rational*: `cc10`, `cc11`, `cc12`
- *CC Behaviour Change*: `cvcc4_personal`, `cvcc4_should`, `cvcc4_will`, `cvcc6`, 
- *CC Policies*: `cc_pol_car`, `cc_pol_tax`, `cc_ica`, `pol7`, `pol7_pi`, 
- *Politics*: `pol_ideology`, `pol_affiliation`
- *Trust in state*: `pol_laws_cong`, `pol_trust_cong`, `pol_trust_state`
- *Trust in general*: `pol_trust_sci`, `pol_trust_news`, `pol_trust_epa`

Connectors:
- `cc6`: (*EW*, *CC Impact*, *CC Behaviour Change*)
- `cvcc_worryothers`: (`cc6`, *CC Rational*, *CC Behaviour Change*, *CC Policies*)
- `cc3`: (`cc6`, `cc1`, *CC Impact*)
- `cc1`: (`cc2`, `cc3`, *CC Impact*, *CC Policies*)
- `cc2`: (`cc1`, maybe *CC Impact* and *Trust in general*)
- `cvcc9_cc`: (*CC Policies*, *Trust in general*)

*CC Policies* less tight in contemporaneous network. `pol_laws_cong` not part of *Trust in state* in contemporaneous network.

=== High Pearson correlation
High association groups:
- *CC*: `cc1`, `cc3`, `cc6`, `cc4`, `cc5`, `cvcc6`, `cvcc9_cc`, `cc_ica`, `cc_pol_tax`, `cc_pol_car`.
- *CC_SOC*: `cc10`, `cc11`, `cc12`
- *CC_CHG*: `cvcc4_should`, `cvcc4_personal`
- *GOVT*: `pol_trust_state`, `pol_trust_cong`, `pol_laws_cong`
- *TRUST*: `pol_trust_io`, `pol_trust_news`, `pol_trust_epa`, `pol_trust_sci`
- *POL*: `pol7`, `pol_affiliation`, `pol_ideology`
- *EW*: `ew5`, `ew6`

Between-group associations:
- *CC*: `ew5`, `cc10`, `cc2`, `cvcc_worryothers`
- *CC_SOC*:
- *CC_CHG*: `cvcc4_will`
- *GOVT*: 
- *TRUST*: `pol_trust_state`, `pol_trust_cong`, *CC*
- *POL*: *CC*, `pol_trust_io`, `pol_trust_news`, `pol_trust_io`
- *EW*: `cvcc_worryothers`

=== Distance correlation
High association groups:
- *CC*: `cc1`, `cc3`, `cc6`, `cc4`, `cc5` 
- *CC_SOC*: `cc10`, `cc11`, `cc12`
- *CC_CHG*: `cvcc4_should`, `cvcc4_personal`
- *CC_POL*: `pol7`, `cvcc6`, `cvcc9_cc`, `cc_ica`, `cc_pol_tax`, `cc_pol_car`
- *GOVT*: `pol_trust_state`, `pol_trust_cong`, `pol_laws_cong`
- *TRUST*: `pol_trust_io`, `pol_trust_news`, `pol_trust_epa`, `pol_trust_sci`
- *POL*: `pol7`, `pol_affiliation`, `pol_ideology`
- *EW*: `ew5`, `ew6`

Between-group associations:
- *CC*: `cc10`, `cc12`, `ew5`, `cvcc_worryothers`, `cc2`, *CC_CHG*, *POL*, *TRUST*
- *CC_SOC*: 
- *CC_CHG*: `cvcc4_will`, `ew5`
- *CC_POL*: `cc10`, `cc12`, `ew5`, `cvcc_worryothers`, `cc2`, *CC_CHG*, *POL*, *TRUST*
- *GOVT*:
- *TRUST*: *GOVT*
- *POL*: *TRUST*
- *EW*:

=== Partial correlation
- *CC_IMPACT*: `cc4`, `cc5` 
- *TRUST_GEN*: `pol_trust_sci`, `pol_trust_io`, `pol_trust_epa`
- *TRUST_STATE*: `pol_trust_cong`, `pol_laws_cong`, `pol_trust_state`, `pol_trust_news`
- *POL*: `pol_affiliation`, `pol_ideology`
- *EW*: `ew5`, `ew6`
- *CC_SOC*: `cc10`, `cc11`, `cc12`
- *CC_CHG*: `cvcc4_should`, `cvcc4_personal`
- 

Any variables flagged which were low correlation in other?

Weak correlations:
- `pol7_pi`
- `pol8_pi`


Broadly high Pearson correlations ($> 0.5$). Particularly among:
- `cc4`, `cc5`, `cc1`, `cc3`, `cc6`, 
- Policy questions: `pol7`, `cc_pol_car`, `cc_pol_tax`, `cc_ica`
- Social norms: `cvcc6` (importance of individual action), `cvcc4_should`
- Attitudes: `cvcc9_cc` (scientists should guide response) 
- Trust: `sci`, `cdc`, `io`, `news`, `epa`
- Politics: `pol_affiliation`, `pol_ideology`

=== High distance correlation
Same set as Pearson
