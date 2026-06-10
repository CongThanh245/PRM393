# Journal Trend Analyzer - AI Coding Prompt

## Project Context

Build a Flutter mobile application named **Journal Trend Analyzer** for the PRM393 Mobile Programming Lab 02 assignment.

The application helps users explore academic publication trends for a selected research topic. It must retrieve scholarly publication data from the **OpenAlex API**, analyze the data, and present insights through mobile-friendly screens, charts, ranked lists, and a summary dashboard.

The app must run on Android devices or Android emulators.

## Primary Goal

Create a complete Flutter application that allows users to:

- Search research publications by topic or keyword.
- View publication details.
- Analyze publication activity over time.
- Identify top journals.
- Identify top contributing authors.
- Identify top influential papers.
- View a research trend dashboard summarizing key insights.

The app must use live data from OpenAlex. Do not use hard-coded publication datasets.

## Data Source

Use the OpenAlex API as the primary data source.

Suggested endpoint:

```text
https://api.openalex.org/works?search={keyword}
```

Useful OpenAlex fields may include:

- `id`
- `doi`
- `title`
- `display_name`
- `publication_year`
- `cited_by_count`
- `authorships`
- `primary_location`
- `host_venue`
- `locations`
- `abstract_inverted_index`

The app should fetch publication data directly from the mobile client through REST API calls.

## Out Of Scope

Do not implement the following features:

- Custom backend server.
- User registration.
- Login/logout.
- Authentication or authorization.
- Role-based access control.
- Database persistence.
- Cloud deployment.
- Real-time synchronization.
- Push notifications.
- Payment processing.
- Comments, likes, sharing, or other social features.
- Administrative dashboards.
- Machine learning model training or deployment.
- Web application deployment.

## Functional Requirements

### 1. Topic Search

The application must allow users to enter a research topic or keyword.

Example topics:

- Artificial Intelligence
- Software Engineering
- Data Science
- Cybersecurity
- Internet of Things
- Blockchain
- Any user-entered topic

Search results must show essential publication information:

- Publication title
- Publication year
- Citation count
- Journal or venue name

The search screen must include:

- Text input for keyword/topic.
- Search action.
- Loading state while fetching data.
- Error state if the API request fails.
- Empty state if no results are found.
- Scrollable list of publications.

### 2. Publication Details

The app must provide a dedicated detail screen for each publication.

The detail screen should show:

- Publication title
- Authors
- Publication year
- Journal or venue name
- Citation count
- DOI
- Abstract, if available

If the abstract is returned as `abstract_inverted_index`, reconstruct it into readable text.

### 3. Publication Trend Analysis

The app must analyze publication activity over time by grouping publications by publication year.

The result should show:

- Number of publications per year.
- Growth or decline trend for the selected topic.
- A chart that visualizes yearly publication counts.

Use an appropriate chart type such as:

- Line chart
- Bar chart

### 4. Top Journals

The app must identify journals or venues that have published the largest number of papers related to the selected topic.

The result should show:

- Journal or venue name
- Number of related publications

Present this as either:

- Ranked list
- Bar chart
- Combined list and chart

### 5. Top Contributing Authors

The app must identify authors who contribute the highest number of publications for the selected topic.

The result should show:

- Author name
- Number of publications

Present this as a ranked list or chart.

### 6. Top Influential Papers

The app must identify the most influential publications based on citation count.

The result should:

- Sort publications from highest citation count to lowest.
- Show title, year, journal, and citation count.

### 7. Research Trend Dashboard

The app must provide a dashboard summarizing key insights for the selected research topic.

The dashboard should include:

- Total publications
- Average citation count
- Most active publication year
- Top journal
- Top author
- Most influential paper
- Publication trend chart
- Quick links or sections for top journals, top authors, and top papers

## Required Screens

The application must contain at least four major screens:

1. **Search Screen**
   - Topic input
   - Search results list
   - Loading, empty, and error states

2. **Publication Detail Screen**
   - Detailed publication metadata
   - Authors, DOI, abstract, citation count

3. **Trend Analysis Dashboard Screen**
   - Summary cards or compact metrics
   - Publication trend visualization
   - Key insights

4. **Research Analytics Screen**
   - Top journals
   - Top authors
   - Top influential papers

Additional screens may be added if they improve usability.

## Technical Requirements

Use:

- Flutter
- Dart
- REST API integration
- Asynchronous data retrieval
- JSON parsing
- Chart visualization library
- Clean project structure
- State management

Recommended packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  provider: ^6.1.0
  fl_chart: ^0.68.0
  intl: ^0.19.0
```

Alternative state management libraries are acceptable if implemented cleanly, such as Riverpod, Bloc, or Cubit.

## Suggested Project Structure

```text
lib/
  main.dart
  app.dart
  models/
    publication.dart
    author_stat.dart
    journal_stat.dart
    trend_point.dart
    dashboard_summary.dart
  services/
    openalex_service.dart
  repositories/
    publication_repository.dart
  providers/
    research_provider.dart
  screens/
    search_screen.dart
    publication_detail_screen.dart
    dashboard_screen.dart
    analytics_screen.dart
  widgets/
    publication_card.dart
    metric_tile.dart
    trend_chart.dart
    ranked_stat_list.dart
    loading_view.dart
    error_view.dart
    empty_view.dart
  utils/
    abstract_parser.dart
    analytics_calculator.dart
```

## Data Model Guidance

Create a `Publication` model with fields similar to:

```dart
class Publication {
  final String id;
  final String? doi;
  final String title;
  final int? publicationYear;
  final int citedByCount;
  final List<String> authors;
  final String? journalName;
  final String? abstractText;
}
```

The model should parse OpenAlex JSON safely. Missing fields should not crash the app.

## Analytics Logic

Implement analytics functions that can:

- Group publications by year.
- Count publications per journal.
- Count publications per author.
- Sort publications by citation count.
- Calculate average citation count.
- Determine the most active publication year.
- Determine the top journal.
- Determine the top author.
- Determine the most influential paper.

Keep analytics logic separate from UI widgets.

## UI Requirements

The user interface must be:

- Responsive on Android phone screens.
- Visually consistent.
- Easy to navigate.
- Clear during loading, success, empty, and error states.
- Suitable for academic analytics rather than a marketing-style app.

Recommended navigation:

- Search screen as the first screen.
- Tap a publication to open detail screen.
- Use tabs, bottom navigation, or clear buttons to move between dashboard and analytics views.

Avoid clutter. Prioritize readable academic data.

## Error Handling Requirements

Handle:

- No internet connection.
- API request failure.
- Empty search keyword.
- No results found.
- Missing title, author, journal, DOI, or abstract.
- Malformed or unexpected JSON fields.

The app should show user-friendly messages instead of crashing.

## OpenAlex Abstract Reconstruction

OpenAlex may return abstracts as an inverted index:

```json
{
  "abstract_inverted_index": {
    "Research": [0],
    "trends": [1],
    "matter": [2]
  }
}
```

Convert this into readable text by placing each word at its indexed position.

Expected output:

```text
Research trends matter
```

## AI-Assisted Code Review Requirement

As part of the assignment, the project must include evidence of AI-assisted or automated code review.

Acceptable tools include:

- SonarQube
- Kodus AI
- CodeRabbit
- GitHub Copilot Code Review
- Similar AI/static analysis tools

The final report must document at least three issues, warnings, bugs, code smells, or security concerns found during review.

For each finding, include:

- Screenshot or evidence
- Description of the issue
- Fix or improvement made
- Short explanation

## Deliverables

### 1. Source Code

Submit the complete Flutter project through a GitHub repository.

Repository naming convention:

```text
PRM393_Lab2_StudentID
```

The repository must include:

- Full source code
- `pubspec.yaml`
- Required assets, if any
- Clear folder structure
- README file
- Any setup notes needed to run the app

### 2. Project Report

Submit a PDF report of approximately 5-10 pages.

The report should include:

- Project overview
- System design
- Implementation details
- OpenAlex API integration approach
- Screenshots of major features
- Topic search results
- Publication detail screen
- Trend analysis results
- Top journals
- Top authors
- Dashboard results
- AI-assisted code review findings
- Challenges encountered
- Lessons learned

### 3. Demonstration Video

Submit a demonstration video of approximately 5-10 minutes.

The video should demonstrate:

- Topic search
- Search results
- Publication detail view
- Trend analysis dashboard
- Top journals
- Top authors
- Top influential papers
- AI-assisted code review process or evidence

## Acceptance Criteria

The implementation is complete when:

- The Flutter app runs successfully on Android emulator or Android device.
- Users can search for a research topic.
- Publication data is retrieved dynamically from OpenAlex.
- Search results display title, year, citation count, and journal.
- Users can open a publication detail screen.
- The app displays publication trend analysis by year.
- The app identifies top journals.
- The app identifies top contributing authors.
- The app identifies top influential papers by citation count.
- The dashboard summarizes the selected topic.
- Loading, empty, and error states are implemented.
- The code is organized into models, services, screens, widgets, and analytics logic.
- The app does not require login, backend, or database.
- The project includes documentation and code review evidence.

## README Documentation Template

Use the following structure for the project README:

```markdown
# Journal Trend Analyzer

## Overview

Journal Trend Analyzer is a Flutter mobile application for exploring academic publication trends using OpenAlex data.

## Features

- Search publications by research topic
- View publication details
- Analyze publication trends by year
- View top journals
- View top contributing authors
- View top influential papers
- Research trend dashboard

## Tech Stack

- Flutter
- Dart
- OpenAlex API
- REST API
- JSON parsing
- Chart visualization

## API

Data is retrieved from OpenAlex:

https://api.openalex.org/works?search={keyword}

## Project Structure

Describe the main folders in `lib/`.

## How To Run

1. Install Flutter.
2. Run `flutter pub get`.
3. Start an Android emulator or connect an Android device.
4. Run `flutter run`.

## Screenshots

Add screenshots of:

- Search screen
- Publication detail screen
- Dashboard screen
- Analytics screen

## AI-Assisted Code Review

Document at least three findings from an AI-assisted or automated code review tool.

## Author

Student name and student ID.
```

## Prompt For AI Coding Agent

Use this instruction when asking an AI coding agent to build the app:

```text
Build a complete Flutter Android application named Journal Trend Analyzer.

The app must use OpenAlex API live data and must not use hard-coded publication datasets.

Implement topic search, publication results, publication detail view, publication trend analysis by year, top journals, top contributing authors, top influential papers, and a research trend dashboard.

Use a clean Flutter architecture with separate models, services, repositories/providers, screens, widgets, and analytics utilities.

Handle loading, empty, error, and missing-data states.

Use a chart library such as fl_chart for trend and ranking visualizations.

The first screen should be the topic search screen. Users should be able to search a topic, see results, tap a publication, and navigate to details. The dashboard and analytics screens should use the latest selected topic results.

Include a README with setup instructions, API details, feature list, project structure, screenshots placeholders, and AI-assisted code review section.

Do not implement login, backend, database, payment, social features, push notification, admin dashboard, cloud deployment, or machine learning model training.

Verify that the app builds and runs on Android emulator or Android device.
```
