# Mock Server Instructions

To simulate a real API environment, you can run a local mock server using JSON Server.

## Prerequisites
Ensure you have Node.js and npm installed on your machine.

## Setup
1. Open a terminal in this directory.
2. Install `json-server` globally or run it using `npx`:
   ```bash
   npx json-server --watch db.json --port 3000
   ```

## API Endpoint Details
- `GET /lessons` - Returns the list of lessons.
- `GET /quizzes` - Returns all quizzes.
- `GET /quizzes?lessonId={id}` - Returns the quiz for a specific lesson.