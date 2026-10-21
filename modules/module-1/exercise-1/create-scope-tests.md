## Test Case 1: PRD Contains Required Sections

**Input:** A developer-ready PRD should contain sections that a developer will use to build the solution.

**Expected Output Criteria:**
- PRD contains a problem statement and why it exists.
- PRD contains personas, use cases, user stories, and acceptance criteria(AC) adhering to the format of Given/When/Then behavior.
- PRD contains technical requirements and constraints to understand the how.
- PRD contains non-functional requirements to understand the quality and performance expectations.
- PRD contains scope and boundaries to understand what is in scope and out of scope.
- PRD contains success metrics to understand the measure of success.
- PRD contains open questions, edge-case(s), and assumptions to understand what we don't know.
- PRD contains the dependencies and constraints to understand depenendencies and constraints.
- PRD contains changelog to understand the history of updates.

**Failure Criteria (must NOT occur):**
- PRD should not create or specify technical solutions that are not needed for implementation.

---

## Test Case 2: Timer Accuracy

**Input:** Implement a Pomodoro Timer with 25-minute work intervals and 5-minute break intervals.

**Expected Output Criteria:**
- PRD explicitly defines acceptable timer drift tolerance (ex: plus/minus 2 seconds over a 25 minute session)
- PRD uses timestamps driven from `Date.now()`.
- PRD calls out the issue of background throttling and identifies how to mitigate.
- PRD addresses the question, "if a laptop sleeps mid-session, the app must decide what to do on wake?" (example: continue, complete, or invalidate).
- PRD specifies whether or not pause timer is acceptable
- PRD states how active timer state is persisted or recovered.
- Acceptance Criteria is written and are testable.

**Failure Criteria (must NOT occur):**
- PRD defines background throttling without defining how to mitigate.
- PRD defines a setinterval without addressing timer drift.
- PRD addresses sleep without indication of what action to do.

---

## Test Case 3: Productivity Heat Map 

**Input:** A weekly productivity heat map should be included mapping user session history and persistence.
**Expected Output Criteria:**
- PRD defines the tracking metric and handling of incomplete sessions.
- PRD specifies weekly day-by-hour grid layout, boundaries, and navigation.
- PRD defines numerical intensity thresholds and accessibility requirements.
- PRD establishes client-only scope without backend or accounts.
- PRD defines storage location (localStorage vs. IndexedDB vs. server), data retention limit, and behavior when storage is unavailable
- PRD specifies a concrete storage schema with field names and types (e.g., { id, startTime,    endTime, completed: boolean, type: 'work' | 'break' })
- PRD defines how session data is stored, retained, and recovered after browser restart.

**Failure Criteria (must NOT occur):**
- PRD introduces backend, authentication or syncing to cloud as requirements.
- PRD omits metrics, grid definition, or heat intensity thresholds.
- PRD fails to handle incomplete sessions.

---

## Test Case 4: Browser APIs and Notifications

**Input:** Define browser dependencies, notifications, and behavior when the application is running.

**Expected Output Criteria:**
- PRD identifies required browser APIs and purpose.
- PRD defines visual, audio, and system notifications when a session ends.
- PRD defines the complete fallback chain: what the user sees/hears if notification permission is denied, if audio context is suspended due to no prior user gesture, and if the tab is closed.
- PRD defines expected behavior when the browser tab is hidden, closed or reopened.
- Acceptance Criteria are measurable and testable.

**Failure Criteria (must NOT occur):**
- PRD assumes browser notifications or audio always work.
- PRD introduces unnecessary backend services or approaches for basic notifications.
- PRD leaves background behaviors undefined.

---

## Test Case 5: Developer Open Questions

**Input:** Build a Pomodoro timer with work/break intervals, session tracking, and a weekly productivity heat map.

**Expected Output Criteria:**
- PRD defines timer transitions, controls, session completion, and interruption behavior.
- PRD addresses data retention, accessibility, UI/UX expectations, and analytics requirements.
- PRD identifies measurable non-functional requirements and how they will be verified.
- PRD establishes boundaries, dependencies, and a definition of done.
- PRD explicitly identifies unresolved decisions, assumptions, and questions requiring stakeholder input.
- PRD requirements are appropriate for a solo developer or small development team, without introducing unnecessary architectural complexity or enterprise-level dependencies.

**Failure Criteria (must NOT occur):**
- PRD leaves necessary development decisions ambiguous without identifying them as open questions.
- PRD contains non-functional requirements without measurable success criteria.
- PRD introduces unsupported functionality beyond the stated scope.
- PRD lacks sufficient information for developers to estimate and plan implementation.

---