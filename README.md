# Hymnal

This application is a Hymnal + Mission Meetings Schedule application for the Old Apostolic Lutheran Church of America.

## Development Environment

The Hymnal app was developed in `Xcode@10.2` in `Swift@5`. The application targets a minimum of iOS 11.4, and is a Universal application (works on iPhone and iPad). Rotation functionality has been disabled on iPhone.

## Target User Base

This application is targetted exclusively to members of the Old Apostolic Lutheran Church of America. With this target user base, certain assumptions may be made:

- Users are already familiar with the contents and structure of the OALC hymnal.
- Users know what church meetings are, and roughly when the missions occur.
- The hymnal will be used in cases where a specific hymn number is given—i.e. hymnal browsing is not an application focus.

## Motivation for Development

Much of the OALC is stuck in a technological stone age. Meetings schedules are passed around in physical form between church localities, and as such it can often be difficult to get a copy of the schedule. Hymn books themselves are bulky objects, and can provide a deterrent to the impromptu singing of hymns at events such as home gatherings. I developed this app to provide a clean and simple meetings schedule that updates over time, as well as a beautiful hymn book UI that is always available in your pocket. Restraint was used to keep things as simple and as familiar as possible, as technological advances are often heavily scrutinized by the church members.

## Features

There are two main features of the Hymnal application.

### Hymn Book

The core feature of this application is the hymn book browser. The OALC hymn book has 365 songs; tapping the centre of the screen brings up the digit input for selecting a song. After inputting a hymn number, tapping on the "Open Hymn" button (or anywhere else on the screen) opens the hymn.

The Hymn Browser is a simple text view with an interface that tries to stay out of the way from the reading experience. Font size can be adjusted and a dark theme can be toggled using buttons on the bottom bar (as a fun bonus, this dark theme carries throughout the rest of the application). The text view scrolls to fit longer songs, and includes italicized text for Chorus/Refrain headers.

Simple song browsing is available from within the Hymn Browser by using the arrows in the bottom bar or by swiping the page left/right. Tapping the `X` brings the user back to the Home screen.

Note: Some songs have been removed from the Hymnal and are listed as blank pages. This is intentional, and is a reflection of the paper copy.

### Meetings Schedule

I developed a simple web API to provide dynamic meetings schedule data to the application; this is a basic clone of the paper copies supplied by the church localities. The API returns all meetings scheduled after the current date, and also includes locality information for each scheduled meeting. A refresh button is provided to force a fetch of the latest copy of the schedule.

#### Locality Information

Tapping on a specific row in the table brings up a locality information view (if one corresponds to that table row). This contains an image of the church building, the driving address, and a map of the location. As a slightly hidden bonus, tapping on either the driving address or the pin on the map brings up Apple Maps with driving directions to the locality.

Contact information for the church is provided in a separate view by selecting the Contact option in the navigation bar.

## Data Source

Locality information is taken from the [Old Apostolic Lutheran Church of America website](https://www.oldapostoliclutheranchurch.org).

Hymnal contents are taken from the public domain OALC Hymnal book pdf.
