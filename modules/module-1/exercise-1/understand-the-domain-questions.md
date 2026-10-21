# Understand the Domain: Pomodoro Timer PRD

## Prompt Used

> I am to create a product requirements document(PRD) for a pomodoro timer application.  The key task is to `"Write a scope document for a Pomodoro timer application with 25-minute work intervals, 5-minute break intervals, session tracking, and a weekly productivity heat map."`
>
> I need a clear picture of what a developer-ready PRD actually contains. To start, guide me by answering the questions listed below:
>
> 1. What sections would a skilled Product Manager always include in a scope document that a developer needs before beginning implementation? Think beyond the feature list: non-functional requirements, success criteria, explicit out-of-scope items, and open questions.
>
> 2. What implied technical requirements exist in this product description that are not stated explicitly? The description says "25-minute work intervals" — but `setInterval` in JavaScript drifts over time. Does a 25-minute timer that ends at 25:03 meet the product requirement? Who decides?
>
> 3. What does "weekly productivity heat map" mean specifically enough to implement? Is this client-side only? Does it survive a browser restart? What data gets stored, and where?
>
> 4. What does a developer need to know about browser API dependencies that this description implies but does not name? (Hint: audio notifications at break transitions, visual notifications, potential background tab behavior.)
>
> 5. What would a developer ask about during sprint planning that the bare product description leaves unanswered?
>
> output returned response to modules/module-1/exercise-1 named understand-the-domain-questions.md

## Response

Task: "Write a scope document for a Pomodoro timer application with 25-minute work intervals, 5-minute break intervals, session tracking, and a weekly productivity heat map."

The one-line description is a feature list. A developer-ready PRD turns each feature into testable behavior, states what is deliberately excluded, and records the decisions nobody has made yet. The answers below are my working notes for writing that document.

## 1. Sections a developer needs before implementation

A skilled PM includes these sections, and the ones past the feature list are what prevent rework.

| Section | What it must contain | Why a developer needs it |
|---|---|---|
| Problem statement and goals | Who has the problem, what changes for them, in two or three sentences | Lets the developer make sane calls when the spec is silent |
| Users and use cases | Primary persona (individual knowledge worker, desktop browser) and the core flow | Sets the platform and interaction assumptions |
| Success criteria | Measurable release gates, for example "timer completes within 1 second of 25:00 wall-clock in 95% of test runs" and "heat map renders 52 weeks of data in under 200 ms" | Defines done in a way QA can verify |
| In-scope functional requirements | Each feature as numbered requirements with acceptance criteria (Given/When/Then) | Removes interpretation from the work |
| Explicitly out of scope | Accounts and login, cross-device sync, mobile native apps, configurable intervals, long breaks, task lists, team features, export (until decided) | Stops scope creep and protects the estimate |
| Non-functional requirements | Timing accuracy, performance, browser support matrix, accessibility (WCAG 2.2 AA), privacy, offline behavior, data retention | These drive architecture more than features do |
| Data model and storage | Entities, fields, where they live, retention, migration plan for schema changes | Storage choice is hard to reverse |
| Technical constraints and dependencies | Browser APIs relied on, permission prompts, hosting, framework mandates | Surfaces platform risk early |
| UX notes | Flow diagrams, state machine for the timer, empty and error states, wireframes | Timer apps are state machines, and the states must be agreed |
| Assumptions and risks | What the PM believes but has not verified, with an owner for each | Makes hidden bets visible |
| Open questions | Each with an owner and a decision-by date | Keeps unknowns from being decided silently in code |
| Release plan | MVP versus later, rollout, rollback, analytics or none | Frames the sprint breakdown |

The sections most often missing from weak scope documents are non-functional requirements, out-of-scope items, and open questions. I will treat those as mandatory.

## 2. Implied technical requirements and the timing question

A 25-minute timer that ends at 25:03 does not meet the requirement as written, because the description never defines a tolerance. The PM owns the answer to "who decides." The developer proposes what is achievable, the PM sets the tolerance as a product requirement, and QA verifies against it. A defensible requirement is: the displayed countdown and the end-of-interval alert occur within one second of 25:00 wall-clock time, in the foreground and in a background tab.

The cause is that `setInterval` is not a clock. It guarantees a minimum delay, not an exact one, so decrementing a counter on each tick accumulates error. Browsers also throttle timers in hidden tabs: they clamp to roughly one second, and Chrome applies intensive throttling (about once per minute) to tabs hidden for more than five minutes. A countdown built on tick counting can be minutes off after a long background stretch.

The implied requirements are these.

1. Store an absolute end time (`Date.now() + 25 * 60 * 1000`) when the interval starts, and compute remaining time from the clock on every tick. The tick rate then affects only display smoothness, not accuracy.
2. Decide the clock source. `Date.now()` follows system clock changes (NTP corrections, manual changes, DST does not matter for epoch time). `performance.now()` is monotonic but may pause during device sleep in some browsers. I recommend `Date.now()` for the end timestamp plus a sanity check, and the PM should confirm that "laptop slept for 10 minutes mid-session" means the timer ends on wall-clock time.
3. Persist the end timestamp so a page reload or tab crash resumes the session instead of losing it.
4. Handle the end-of-interval event when the tab was hidden: on `visibilitychange`, recompute immediately and fire any overdue transition once, never twice.
5. Define pause and resume semantics, since pausing means storing remaining time and recomputing a new end time.
6. Decide what counts as a completed session when the tab is closed at minute 24.
7. Make the timer logic testable with an injected clock, so tests do not wait 25 real minutes.

## 3. What "weekly productivity heat map" must mean to be implementable

The phrase needs four decisions before a developer can build it.

**The axes and the metric.** My recommended default is a grid with days of the week on one axis and time-of-day buckets (hourly, 24 rows or a working-hours subset) on the other, with each cell colored by the number of completed work sessions in that bucket. The alternative is a calendar heat map with one cell per day colored by total focused minutes. These are different products. The PM must pick one. I would pick the day-by-hour grid because it answers "when am I productive," which is what the word productivity implies.

**What counts.** Only completed 25-minute work intervals should count. Abandoned or reset sessions should either be excluded or stored with a status and excluded from the count. Breaks never count. A session that spans an hour boundary needs a rule, and the simplest is to bucket by start time.

**Time handling.** Define the week start (Monday or Sunday, or locale-driven), the time zone (the device's local zone at the time of the session, stored with the record as an ISO timestamp plus offset), and what happens across DST changes and when the user travels.

**Storage and persistence.** For an MVP I would make this client-side only, using IndexedDB (or `localStorage` if the data stays small, since a year of sessions is a few thousand tiny records). It survives a browser restart. It does not survive clearing site data, private browsing, or switching browsers or devices, and the PRD should say so plainly and list sync and export as out of scope or as a later phase. Each stored record would look like this:

```json
{
  "id": "uuid",
  "type": "work",
  "startedAt": "2026-10-21T09:00:00-05:00",
  "endedAt": "2026-10-21T09:25:00-05:00",
  "plannedSeconds": 1500,
  "status": "completed"
}
```

Heat map rendering needs a color scale with a defined number of intensity steps, an empty state for a new user, a tooltip or accessible text equivalent for each cell (color alone fails accessibility), and a defined "which week" navigation (current week only, or previous weeks too).

## 4. Browser API dependencies the description implies

| Need | API | What the developer must know |
|---|---|---|
| Audio at transitions | Web Audio API or `HTMLAudioElement` | Autoplay policies block sound until the user has interacted with the page. The Start button click can unlock audio, so the sound should be primed then. iOS Safari is stricter and respects the silent switch. |
| Visual alerts when the tab is hidden | Notifications API | Permission must be requested from a user gesture, can be denied or dismissed, and must have a fallback. Notifications need HTTPS. |
| Fallback visual cues | `document.title` updates, favicon swap | Cheap, permission-free, and visible in a background tab. I recommend including the remaining time in the title. |
| Knowing when the tab is hidden | Page Visibility API | Needed to resync the countdown and fire overdue transitions on return. |
| Timer reliability in the background | Web Worker running the tick | Workers are throttled less than the main thread, but not immune. Audio playback can also exempt a tab from throttling. The PRD should state whether background accuracy is a hard requirement. |
| Keeping the screen on | Screen Wake Lock API | Optional, supported unevenly. Decide in or out of scope. |
| Persistence | IndexedDB or `localStorage` | Quotas, private mode behavior, and eviction under storage pressure. `navigator.storage.persist()` exists to request durable storage. |
| Multiple tabs | `BroadcastChannel` or the `storage` event | Two tabs running two timers will double-count sessions. Decide whether to allow one active timer and how to enforce it. |
| Dates and zones | `Intl.DateTimeFormat` | Week-start and locale handling for the heat map. |

True background operation when the tab is closed would need a service worker plus push, which means a server. That should be listed as out of scope unless the PM disagrees. The PRD also needs a browser support matrix (for example the latest two versions of Edge, Chrome, Safari, and Firefox), because several of these APIs differ across them.

## 5. What a developer would ask in sprint planning

I would expect these questions, and the PRD should answer them before the sprint starts.

**Timer behavior.** Can the user pause, resume, skip, or reset? Does a break start automatically after work, or does the user press a button? Does the next work interval start automatically after a break? Is there a long break after four work sessions, as the traditional technique has, or is it only 25 and 5? Are the durations configurable, or fixed? If the user resets at minute 10, does that session count?

**Tracking.** What is a "session," a single 25-minute interval or a work-plus-break cycle? Does the user label sessions with a task? Can sessions be edited or deleted? Is there a daily goal or counter?

**Heat map.** Which of the two designs in section 3 is intended? Which week start? Can the user view past weeks? What does a new user see?

**Platform and non-functionals.** Desktop only, or responsive mobile web? Which browsers? What is the accessibility bar? Is there a tolerance for timer accuracy, and does it apply in the background? Do we need to work offline, as a PWA?

**Data and privacy.** Is storage local only? Is there export, import, or a clear-data control? Is any analytics or telemetry collected, and if so with what consent?

**Delivery.** What stack and hosting are mandated? Are designs or wireframes available, including the sound asset and color scale? What is the test strategy for time-based code (injected clock, fake timers)? What is the definition of done, and who accepts it? How should the work be split into stories, and what is the smallest shippable slice? My suggestion is: timer state machine, then persistence, then notifications, then heat map.

Every question without an answer by sprint planning should land in the Open Questions section with an owner and a due date, not in a developer's head.
