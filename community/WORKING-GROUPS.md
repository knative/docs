# Knative Working Groups

Most community activity is organized into *working groups*.

Working groups follow the [contributing](CONTRIBUTING.md) guidelines although
each of these groups may operate a little differently depending on their needs
and workflow.

When the need arises, a new working group can be created. See the [working group
processes](WORKING-GROUP-PROCESSES.md) for working group proposal and creation
procedures.

The working groups generate design docs which are kept in a
[shared drive](https://drive.google.com/corp/drive/folders/0APnJ_hRs30R2Uk9PVA)
and are available for anyone to read and comment on. The shared drive
currently grants read access to
[knative-users@](https://groups.google.com/forum/#!forum/knative-users) and edit
and comment access to the
[knative-dev@](https://groups.google.com/forum/#!forum/knative-dev) Google group.

The current working groups are:

*   [API Core](#api-core)
*   [Build](#build)
*   [Events](#events)
*   [Networking](#networking)
*   [Observability](#observability)
*   [Productivity](#productivity)
*   [Scaling](#scaling)
<!-- TODO add charters for each group -->

## API Core

API [resources](../pkg/apis/serving), [validation](../pkg/webhook), and [semantics](../pkg/controller).

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | [https://meet.google.com/bzx-bjqa-rha](https://meet.google.com/bzx-bjqa-rha) <br>Or dial in:<br>(US) +1 262-448-6367<br>PIN: 923 539#
Community Meeting Calendar | Wednesdays 10:30a-11:00a PST <br>[Calendar Invitation](https://calendar.google.com/event?action=TEMPLATE&tmeid=MW81NXJkaXBxbzllY2JtdTk4aXMxNGk2N2NfMjAxODA3MTFUMTczMDAwWiBtYXR0bW9vckBnb29nbGUuY29t&tmsrc=mattmoor%40google.com&scp=ALL)
Meeting Notes              | [Notes](https://docs.google.com/document/d/1NC4klOdNaU-N-PsKLyXBqDKgNSHtxCDep29Ta2b5FK0/edit)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/1fpBW7VyiBISsKuVdgn1MrgFdtx_JGoC5)
Slack Channel              | [#api](https://knative.slack.com)

&nbsp;                                                   | Leads      | Company | Profile
-------------------------------------------------------- | ---------- | ------- | -------
<img width="30px" src="https://github.com/mattmoor.png"> | Matt Moore | Google  | [mattmoor](https://github.com/mattmoor)

## Build

[Build](https://github.com/knative/build), Builders, and Build templates

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | [meet.google.com/hau-nwak-tgm](https://meet.google.com/hau-nwak-tgm) <br>Or dial in:<br>(US) +1 219-778-6103‬ PIN: ‪573 000‬#
Community Meeting Calendar | Wednesdays 10:00a-10:30a PST <br>[Calendar Invitation](https://calendar.google.com/event?action=TEMPLATE&tmeid=MTBkb3MwYnVrbDd0djE0a2kzcmpmbjZndm9fMjAxODA4MTVUMTcwMDAwWiBqYXNvbmhhbGxAZ29vZ2xlLmNvbQ&tmsrc=jasonhall%40google.com&scp=ALL)
Meeting Notes              | [Notes](https://docs.google.com/document/d/1e7gMVFlJfkFdTcaWj2qETeRD9kSBG2Vh8mASPmQMYC0/edit)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/1ov16HvPam-v_FXAGEaUdHok6_hUAoIoe)
Slack Channel              | [#build-crd](https://knative.slack.com)

&nbsp;                                                   | Leads      | Company | Profile
-------------------------------------------------------- | ---------- | ------- | -------
<img width="30px" src="https://github.com/ImJasonH.png"> | Jason Hall | Google  | [ImJasonH](https://github.com/ImJasonH)
<img width="30px" src="https://github.com/mattmoor.png"> | Matt Moore | Google  | [mattmoor](https://github.com/mattmoor)

## Events

Event sources, bindings, FaaS framework, and orchestration

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | [meet.google.com/uea-zcwt-drt](https://meet.google.com/uea-zcwt-drt) <br>Or dial in:<br>(US) +1 919 525 1825<br>PIN: 356 842#
Community Meeting Calendar | Wednesdays 9:00a-9:30a PST<br>[Calendar Invitation](https://calendar.google.com/calendar/embed?src=google.com_5pce19kpifu8avnj0eo74sg84c%40group.calendar.google.com&ctz=America%2FLos_Angeles)
Meeting Notes              | [Notes](https://docs.google.com/document/d/1uGDehQu493N_XCAT5H4XEw5T9IWlPN1o19ULOWKuPnY/edit)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/1S22YmGl6B1ppYApwa1j5j9Nc6rEChlPo)
Slack Channel              | [#eventing](https://knative.slack.com/messages/C9JP909F0/)

&nbsp;                                                        | Leads       | Company | Profile
------------------------------------------------------------- | ----------- | ------- | -------
<img width="30px" src="https://github.com/vaikas-google.png"> | Ville Aikas | Google  | [vaikas-google](https://github.com/vaikas-google)

## Networking

Inbound and outbound network connectivity for [serving](https://github.com/knative/serving) workloads.
Specific areas of interest include: load balancing, routing, DNS configuration and TLS support.

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | Coming soon
Community Meeting Calendar | Coming soon
Meeting Notes              | [Notes](https://drive.google.com/open?id=1EE1t5mTfnTir2lEasdTMRNtuPEYuPqQCZbU3NC9mHOI)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/1oVDYbcEDdQ9EpUmkK6gE4C7aZ8u6ujsN)
Slack Channel              | [#networking](https://knative.slack.com)

&nbsp;                                                    | Leads            | Company | Profile
--------------------------------------------------------- | ---------------- | ------- | -------
<img width="30px" src="https://github.com/tcnghia.png"> | Nghia Tran | Google  | [tcnghia](https://github.com/tcnghia)
<img width="30px" src="https://github.com/mdemirhan.png"> | Mustafa Demirhan | Google  | [mdemirhan](https://github.com/mdemirhan)

## Observability

Logging, monitoring & tracing infrastructure

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | https://meet.google.com/kik-btis-sqz <br> Or dial in: <br> (US) +1 515-705-3725 <br>PIN: 704 774#
Community Meeting Calendar | [Calendar Invitation](https://calendar.google.com/event?action=TEMPLATE&tmeid=MDc4ZnRkZjFtbzZhZzBmdDMxYXBrM3B1YTVfMjAxODA4MDJUMTczMDAwWiBtZGVtaXJoYW5AZ29vZ2xlLmNvbQ&tmsrc=mdemirhan%40google.com&scp=ALL)
Meeting Notes              | [Notes](https://drive.google.com/open?id=1vWEpjf093Jsih3mKkpIvmWWbUQPxFkcyDxzNH15rQgE)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/10HcpZlI1PbFyzinO6HjfHbzCkBXrqXMy)
Slack Channel              | [#observability](https://knative.slack.com)

&nbsp;                                                    | Leads            | Company | Profile
--------------------------------------------------------- | ---------------- | ------- | -------
<img width="30px" src="https://github.com/mdemirhan.png"> | Mustafa Demirhan | Google  | [mdemirhan](https://github.com/mdemirhan)

## Scaling

Autoscaling

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | [Hangouts](https://meet.google.com/ick-mumc-mjv?hs=122)
Community Meeting Calendar | Wednesdays at 9:30am PST (join knative-dev@ for invite)
Meeting Notes              | [Notes](https://docs.google.com/document/d/1FoLJqbDJM8_tw7CON-CJZsO2mlF8Ia1cWzCjWX8HDAI/edit#heading=h.c0ufqy5rucfa)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/1qpGIPXVGoMm6IXb74gPrrHkudV_bjIZ9)
Slack Channel              | [#autoscaling](https://knative.slack.com)

&nbsp;                                                        | Leads          | Company | Profile
------------------------------------------------------------- | -------------- | ------- | -------
<img width="30px" src="https://github.com/josephburnett.png"> | Joseph Burnett | Google  | [josephburnett](https://github.com/josephburnett)

## Productivity

Project health, test framework, continuous integration & deployment, release, performance/scale/load testing infrastructure 

Artifact                   | Link
-------------------------- | ----
Forum                      | [knative-dev@](https://groups.google.com/forum/#!forum/knative-dev)
Community Meeting VC       | [Hangouts](https://meet.google.com/sps-vbhg-rfx)
Community Meeting Calendar | Every other Thursday at 2PM Pacific: [Calendar Invitation](https://calendar.google.com/calendar/event?eid=NW5zM21rbHVwZWgyNHFoMGpyY2JhMjB2bHRfMjAxODA5MTNUMjEwMDAwWiBnb29nbGUuY29tXzE4dW40ZnVoNnJva3FmOGhtZmZ0bTVvcXE0QGc)
Meeting Notes              | [Notes](https://docs.google.com/document/d/1aPRwYGD4XscRIqlBzbNsSB886PJ0G-vZYUAAUjoydko)
Document Folder            | [Folder](https://drive.google.com/corp/drive/folders/1oMYB4LQHjySuMChmcWYCyhH7-CSkz2r_)
Slack Channel              | [#productivity](https://knative.slack.com)

&nbsp;                                                    | Leads          | Company | Profile
--------------------------------------------------------- | -------------- | ------- | -------
<img width="30px" src="https://github.com/jessiezcc.png"> | Jessie Zhu     | Google  | [jessiezcc](https://github.com/jessiezcc)
<img width="30px" src="https://github.com/adrcunha.png">  | Adriano Cunha | Google  | [adrcunhua](https://github.com/adrcunha)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
