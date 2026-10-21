# Pomodoro Timer: Scope Document

## Summary

This document scopes a Pomodoro timer application that guides users through 25-minute work intervals and 5-minute break intervals, records completed sessions, and presents a weekly productivity heat map. The goal of the first release is a focused, reliable timer with enough history to help users see when they work best. Anything not listed under In Scope is deferred.

## Problem Statement

People who want to work in focused blocks often rely on generic phone timers that offer no structure, no memory of past sessions, and no insight into their habits. This application provides the Pomodoro cycle out of the box and turns session history into a visual picture of weekly productivity.

## Goals

1. Let a user start, pause, resume, and reset a timed work or break interval with minimal friction.
2. Automatically alternate between 25-minute work intervals and 5-minute break intervals.
3. Persist every completed session so history survives page reloads and app restarts.
4. Show a weekly heat map that makes productive days and hours visible at a glance.

## Non-Goals

- Team or shared timers, social features, or leaderboards.
- Task or to-do management beyond an optional session label.
- Configurable interval lengths (fixed at 25/5 for the initial release).
- Long breaks after four work intervals (candidate for a later release).
- Native mobile apps and third-party integrations such as calendars or Teams.

## Target Users

Individual knowledge workers, students, and developers who want a lightweight way to structure focused work and review their own patterns. No account or administrator role is required.

## In Scope

### 1. Timer Core

- Work interval of 25 minutes and break interval of 5 minutes.
- Controls: start, pause, resume, reset, and skip to the next interval.
- A visible countdown in mm:ss format and a clear indicator of the current mode (Work or Break).
- Automatic transition from work to break and from break to work, with the next interval waiting for the user to start it by default.
- Audible and visual notification when an interval ends.
- The countdown stays accurate when the tab is in the background or the device sleeps, by computing remaining time from timestamps rather than counting ticks.

### 2. Session Tracking

- A session is recorded when a work interval runs to completion. Interrupted or reset intervals are not counted as completed, but may be stored with an "abandoned" status for transparency.
- Each record stores start time, end time, interval type, duration, completion status, and an optional short label.
- A daily summary showing completed work sessions and total focused minutes for today.
- A history view listing past sessions, filterable by date.
- Data is stored locally on the device for the initial release. Export to CSV is included so users can take their data elsewhere.

### 3. Weekly Productivity Heat Map

- A grid with days of the week on one axis and hours of the day on the other.
- Cell color intensity reflects the number of completed work sessions (or focused minutes) in that slot.
- Navigation to move between weeks, defaulting to the current week.
- A tooltip or detail panel on each cell showing the exact session count and focused minutes.
- A legend explaining the color scale, and a color scheme that meets WCAG AA contrast and does not rely on color alone (values available through tooltip and screen reader text).
- An empty state for weeks with no data.

## Out of Scope

Cloud sync, user accounts, multi-device history, push notifications when the app is closed, custom themes, gamification, and analytics beyond the weekly heat map and daily summary.

## Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1 | Timer runs 25-minute work and 5-minute break intervals | Must |
| FR-2 | User can start, pause, resume, reset, and skip | Must |
| FR-3 | Completed work sessions are persisted locally | Must |
| FR-4 | Daily summary of sessions and focused minutes | Must |
| FR-5 | Weekly heat map by day and hour | Must |
| FR-6 | Week-to-week navigation on the heat map | Should |
| FR-7 | Session history list with date filter | Should |
| FR-8 | Optional session label | Could |
| FR-9 | CSV export of session data | Could |

## Non-Functional Requirements

- **Accuracy:** Timer drift under one second over a full interval, including when backgrounded.
- **Performance:** Heat map renders in under 500 ms for one year of history.
- **Accessibility:** Keyboard operable, screen reader labels on controls and heat map cells, WCAG AA contrast.
- **Privacy:** All data stays on the device. No telemetry in the initial release.
- **Compatibility:** Current versions of Edge, Chrome, Safari, and Firefox on desktop, and usable on mobile browsers.

## Key User Flows

1. **Focus cycle:** User opens the app, starts a work interval, receives a notification at 25 minutes, starts the break, receives a notification at 5 minutes, and begins the next work interval. Completed sessions appear in the daily summary.
2. **Interruption:** User resets mid-interval. The interval is marked abandoned and does not count toward totals or the heat map.
3. **Review:** User opens the heat map, sees the current week, hovers over a cell to read the session count, and moves back a week to compare.

## Assumptions

- The initial release is a web application delivered as a single-page app, with local browser storage as the data store.
- Weeks start on Monday and use the device's local time zone.
- The heat map counts only completed work intervals, not breaks.

## Risks and Open Questions

| Risk or question | Mitigation or proposed answer |
|------------------|-------------------------------|
| Browsers throttle timers in background tabs | Use timestamp-based calculation and the Notifications API |
| Local storage can be cleared by the user | Offer CSV export and warn in the UI |
| Should heat map intensity use session count or focused minutes? | Start with session count; revisit after user feedback |
| Should the next interval auto-start? | Default to manual start, with a setting deferred to a later release |
| Time zone changes while traveling | Store timestamps in UTC and render in local time |

## Success Metrics

- A user can start their first work interval within 10 seconds of opening the app.
- At least 95 percent of completed intervals are recorded correctly in manual and automated testing.
- Heat map renders correctly for empty, partial, and full weeks.
- No critical accessibility defects found in an audit against WCAG 2.1 AA.

## Milestones

| Milestone | Deliverable |
|-----------|-------------|
| M1 | Timer core with work and break cycle, notifications |
| M2 | Session persistence and daily summary |
| M3 | Weekly heat map with navigation and legend |
| M4 | Accessibility pass, history view, CSV export, release candidate |

## Acceptance Criteria

- A full cycle of 25 minutes of work followed by 5 minutes of break completes and records one session.
- Pausing and resuming does not change total interval length.
- Reloading the page preserves all prior sessions and the heat map reflects them.
- The heat map for the current week matches the underlying session records exactly.
- All Must requirements pass in the supported browsers.
