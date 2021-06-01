---
title: "Knative Community Meetup"
linkTitle: "Community Meetup"
weight: 30
type: "docs"
---

Welcome to the Knative Community Meetup page!

The virtual event is designed for end users, a space for our community to meet, get to know each other, and learn about uses and applications of Knative.

Catch up with past community meetups on our [YouTube channel](https://www.youtube.com/playlist?list=PLQjzPfIiEQLLyCyLBKLlwDLfE_A-P7nyg).

Here we will list all the information related to past and future events.

Stay tuned for new events by subscribing to our [calendar](https://calendar.google.com/calendar/embed?src=knative.team_9q83bg07qs5b9rrslp5jor4l6s%40group.calendar.google.com&ctz=America%2FLos_Angeles) ([iCal export file](https://calendar.google.com/calendar/ical/knative.team_9q83bg07qs5b9rrslp5jor4l6s%40group.calendar.google.com/public/basic.ics)) and following us on [Twitter](https://twitter.com/KnativeProject).

---

### 2020-05-14 – Knative Community Meetup #2

Video: https://youtu.be/24owwOKj86E

## Agenda
- Welcome! (5’)
  - Announce recording of meeting.
- Update from the Steering Committee (15’)
  - TOC election results (Tomas Isdal)
- Working groups updates (5’)
- Demo - "Automating service delivery with bindings" by Evan Anderson, software engineer at VMware (30’)
- Demo discussion / conversation (15’-20’)
- Close (5’)
- Take the [survey](https://docs.google.com/forms/d/e/1FAIpQLSebw2IOjmnStiUhPpnndpjyuBUoziZOw9PK9fnJeFBQX0QxWw/viewform)! (it’s good karma)

## TOC Election results
- Nghia Tran (Google) - new member
- Markus Thömmes (Red Hat) - new member
- Grant Rodgers (Google) - new member
- Matt Moore (VMWare) - existing member
- Evan Anderson (VMWare) - existing member
Congratulations to the newly elected members! ✨

## Working group updates
- Autoscaling WG
  - Big improvements to the autoscaling documentation, both internally and user-facing. Go check them out!
  - User facing docs: https://knative.dev/docs/serving/configuring-autoscaling/
  - Technical docs: https://github.com/knative/serving/blob/main/docs/scaling/SYSTEM.md
- A lot of improvements to the loadbalancing in Knative has landed, vastly improving latency for concurrency-limited revisions. Give HEAD a whirl if you’re seeing issues there.
- Speaking of issues: We need your input!
  - We’re preparing a questionnaire to gather structured feedback regarding the types of workloads you’re running and which settings you find yourself tweaking to make autoscaling work in your favor.
  - While we’re preparing that (will likely be sent out via the knative-users list), please feel free to give us free-form feedback on anything autoscaling. That can either be Github issues if you’re having issues, a thread on knative-users or send it to me privately if you can’t share publicly.

## Eventing
- Update on Brokers
  - https://github.com/knative/eventing/issues/3139

---

### 2020-04-16 – Knative Community Meetup #1
Video: https://www.youtube.com/watch?v=k0QJEyV4U-4

Agenda:
- Welcome! (5’)
  - Announce recording of meeting.
- Update from the Steering Committee (5’)
  - TOC election announcement (Brenda Chan)
- Working groups updates (15’-20’)
  - Eventing (Aleksander Slominski and Davy Odom)
  - Networking (Nghia Tran)
  - Operation (Vincent Hou)
  - Client (Roland Huss)
- [Demo - "Tracking the Bitcoin ledger" - by Johana Saladas (IBM) (30’)](https://www.youtube.com/watch?v=sGi_LuAaaT0)
- Demo discussion / conversation (15’-20’)
- Close (5’)
  - Take the [survey](https://docs.google.com/forms/d/e/1FAIpQLSebw2IOjmnStiUhPpnndpjyuBUoziZOw9PK9fnJeFBQX0QxWw/viewform)! (it’s good karma)

The demo for this first community meetup is "Tracking the Bitcoin ledger", designed and carried out by @josiemundi, software engineer at IBM. Thank you for volunteering, Johana!

Here are the resources from the demo:
- https://github.com/josiemundi/knative-eventing-blockchain-demo
- https://github.com/josiemundi/knative-bitcoin-websocket-eventsource

