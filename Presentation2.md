# Presentation 2 Speaker Notes

## Title

**Speed is not a shortcut: public tracking data needs context before it can evaluate hockey performance**

## Focused Topic

My broader animating question is about how computer vision and player-tracking data can make hockey evaluation more informative, transparent, and publicly accessible beyond current popular advanced metrics.

For this presentation, I narrowed that into one more critical question:

**Do public speed-burst leaderboards actually help evaluate hockey performance, or do they mostly describe an athletic trait without enough game context?**

This is different from my paper. The paper focused on pre-shot puck movement and shot danger. This presentation focuses on public NHL EDGE speed-burst tracking and asks whether it can support evaluative claims when compared with the traditional points leaderboard.

## Revised Thesis

NHL EDGE speed data is publicly interesting but analytically incomplete. Without context, speed-burst leaderboards describe a skating trait more than they evaluate performance.

The key point is not that speed is useless. It is that a burst count alone does not tell us whether the burst created value. To make the metric evaluative, we would need information about possession, zone, role, time on ice, opponent pressure, and what happened after the burst.

## Sources Used

1. **NHL EDGE launch/explainer article**
   - URL: https://www.nhl.com/news/nhl-edge-launches-website-for-puck-and-player-tracking-data
   - Used for background on what NHL EDGE is and why the NHL made tracking-derived data public.
   - Important context: NHL EDGE turns tracking into curated public metrics such as skating speed, skating distance, shot speed, shot location, and zone time.

2. **NHL EDGE skater speed leaderboard**
   - URL: https://www.nhl.com/nhl-edge/skaters/20252026/2/skating-speed/all
   - Data endpoint used: https://api-web.nhle.com/v1/edge/skater-speed-top-10/all/over-22/20252026/2
   - Used for the 2025-26 regular-season top 10 skaters by 22+ mph speed bursts.

3. **NHL skater stats leaders API**
   - Data endpoint used: https://api-web.nhle.com/v1/skater-stats-leaders/20252026/2?categories=points&limit=-1
   - Used for the 2025-26 regular-season points leaderboard.

Data was accessed on April 24, 2026.

## What I Did With The Data

I took the NHL EDGE top 10 skaters in 22+ mph bursts and joined them to the NHL points leaderboard by player ID. Then I compared each player's speed-burst rank to his points rank.

This is a descriptive summary analysis, not a causal model. It is deliberately limited because the public NHL EDGE leaderboard is itself limited.

Main findings:

- **Six of the top ten 22+ mph speed-burst leaders were outside the top 50 in points.**
- The burst-points correlation in this small top-speed sample is **r = 0.63** with Connor McDavid included.
- If Connor McDavid is removed, the burst-points correlation drops to **r = 0.24**.

That swing is why I am taking a more critical stance. The public speed-burst leaderboard is not meaningless, but it is too fragile and context-poor to use as a direct performance evaluation.

| Speed Rank | Player | Team | 22+ mph Bursts | Points | Points Rank |
|---:|---|---|---:|---:|---:|
| 1 | Connor McDavid | EDM | 151 | 138 | 1 |
| 2 | Owen Tippett | PHI | 61 | 51 | 123 |
| 3 | Tim Stützle | OTT | 46 | 83 | 22 |
| 4 | Nathan MacKinnon | COL | 45 | 127 | 3 |
| 5 | Martin Necas | COL | 37 | 100 | 7 |
| 6 | Josh Anderson | MTL | 36 | 23 | 369 |
| 7 | Brayden Point | TBL | 36 | 50 | 134 |
| 8 | Roope Hintz | DAL | 33 | 44 | 170 |
| 9 | Logan Cooley | UTA | 33 | 43 | 172 |
| 10 | Matthew Schaefer | NYI | 33 | 59 | 88 |

## Slide-By-Slide Notes

### Slide 1: Speed is not a shortcut

Open by saying that tracking data is exciting because it gives fans information that used to be much harder to access. But the title signals the core criticism: a public leaderboard can make a number look more evaluative than it really is.

Suggested timing: 30 seconds.

### Slide 2: Speed answers a narrow question

Explain the distinction between trait, context, and evaluation.

A speed-burst count can answer a narrow trait question: how often did this player cross 22 mph? It cannot answer the evaluative question by itself: did that burst create value?

The missing middle layer is context: possession, zone, role, time on ice, and outcome.

Suggested timing: 45 seconds.

### Slide 3: Thesis

State the revised thesis directly:

NHL EDGE speed data is publicly interesting but analytically incomplete. Without context, speed-burst leaderboards describe a skating trait more than they evaluate performance.

The three-step logic is: describe the trait, add game context, then judge performance.

Suggested timing: 45 seconds.

### Slide 4: Data I used

Describe the join:

- NHL EDGE gave the top 10 skaters by 22+ mph bursts.
- The NHL stats API gave the points leaderboard.
- I joined by player ID and compared speed-burst rank with points rank.

Make clear that this is not raw tracking data. It is a curated public output derived from tracking.

Suggested timing: 50 seconds.

### Slide 5: The leaderboard mixes different players

This is the main evidence slide.

The bar chart shows a speed-burst ranking. Connor McDavid is a huge outlier, and some elite scorers are also near the top. But six of the ten speed-burst leaders were outside the top 50 in points.

The interpretation should be careful: this does not prove speed is useless. It shows that speed-burst counts alone are not enough to evaluate performance.

Suggested timing: 1 minute 10 seconds.

### Slide 6: The scoring link is fragile

This slide makes the critical stance more explicit.

Within this small top-speed sample, the correlation between bursts and points is moderately positive with McDavid included. But when McDavid is removed, the relationship becomes much weaker.

This matters because it shows how dependent the story is on one extreme player. A public leaderboard can look meaningful, but without more context it is easy to overinterpret.

Suggested timing: 1 minute.

### Slide 7: Counterargument and missing data

Counterargument:

Speed may matter in ways that do not show up directly in points. A burst can create forecheck pressure, a controlled entry, a defensive recovery, or space for a teammate.

Response:

That is probably true, but it strengthens the critique. If speed matters through those mechanisms, the public data should show where the burst happened and what changed after it.

Future data source:

A public shift-level tracking file with player and puck trajectories connected to zone entries, possession changes, defender gap, puck-carrier status, and outcome.

Suggested timing: 1 minute.

### Slide 8: Bottom line and discussion question

Summarize the argument:

- NHL EDGE makes tracking public, but in a curated and simplified form.
- The speed leaderboard does not cleanly translate into scoring rank.
- Public tracking becomes evaluative only when speed is connected to context and outcome.

Discussion question:

When leagues publish tracking stats for fans, should they release more leaderboards quickly, or fewer metrics with enough context to prevent overinterpretation?

This asks the class to think about transparency and public literacy, not just whether tracking data is interesting.

Suggested timing: 50 seconds.

## Approximate Timing

| Slide | Time |
|---|---:|
| 1 | 0:30 |
| 2 | 0:45 |
| 3 | 0:45 |
| 4 | 0:50 |
| 5 | 1:10 |
| 6 | 1:00 |
| 7 | 1:00 |
| 8 | 0:50 |
| **Total** | **6:50** |

If I need to shorten the talk closer to exactly six minutes, the easiest cuts are:

- On Slide 5, do not name all five example players.
- On Slide 6, say only that the relationship weakens sharply after removing McDavid.
- On Slide 7, describe the future data source in one sentence.

## One-Sentence Version

Public speed-tracking leaderboards are useful as descriptive outputs, but they are not transparent performance metrics until they connect speed to context and outcome.
