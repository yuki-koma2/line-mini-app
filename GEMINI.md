# GEMINI.md

## Project Overview and Purpose

This project is a LINE MINI App built with Next.js. The purpose is to provide a seamless user experience within the LINE app, leveraging the LINE Front-end Framework (LIFF) to interact with LINE APIs.

## Architecture and Technology Stack

- **Framework:** Next.js (with App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Platform:** LINE MINI App (using LIFF)
- **Package Manager:** npm

## Coding Standards and Conventions

### General
- Follow standard TypeScript and React best practices.
- Use functional components with Hooks.
- Adhere to the default formatting provided by Prettier. Run `npm run lint` to check and fix formatting issues.
- All new components should be self-contained and reusable where possible.

### Naming Conventions
- **Components:** PascalCase (e.g., `UserProfile.tsx`)
- **Variables and Functions:** camelCase (e.g., `getUserProfile`)
- **Types and Interfaces:** PascalCase (e.g., `type UserProfile`)

### Logging
- Avoid using `console.log` for debugging. Instead, use a more structured logging library if one is introduced.

## Directory Structure Philosophy

- `app/`: Main application logic and pages. Follow the Next.js App Router conventions.
- `app/api/`: API routes.
- `components/`: Reusable React components. (This directory should be created if not present)
- `lib/`: Utility functions and helper scripts.
- `public/`: Static assets like images and fonts.
- `task_memory/`: Contains logs and documentation for completed tasks.

## Important Files and Dependencies

- `package.json`: Defines project scripts and dependencies.
- `next.config.ts`: Next.js configuration.
- `tsconfig.json`: TypeScript configuration.
- `app/page.tsx`: The main entry point of the application.
- `@line/liff`: The primary dependency for LIFF integration. All LIFF-related logic should be encapsulated to be easily manageable.

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. The commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

- **type:** `feat` (new feature), `fix` (bug fix), `docs` (documentation), `style` (formatting, missing semicolons, etc.), `refactor` (code refactoring), `test` (adding missing tests), `chore` (updating grunt tasks etc).

### Commit Granularity and Detail

-   **Commit in appropriate units:** Each commit should represent a single logical change or a small, cohesive set of related changes. Avoid large, monolithic commits that combine unrelated work.
-   **Detailed commit messages:** The commit message body should provide a comprehensive explanation of *what* was changed and *why*. Include details about the thought process, design decisions, challenges encountered, and how they were resolved. The more context, the better. This serves as a valuable record of the development process.

- **Development:** `npm run dev`
- **Build:** `npm run build`
- **Start:** `npm run start`
- **Lint:** `npm run lint`

## Test-Driven Development (TDD)

We adopt the t-wada style of Test-Driven Development (TDD). This approach emphasizes writing tests before writing any production code, guiding the design and ensuring code quality.

### Principles of t-wada TDD

1.  **Red (Write a failing test):** Write a small, focused test that describes a single piece of desired functionality. This test should fail because the functionality doesn't exist yet.
2.  **Green (Make the test pass):** Write the minimum amount of production code necessary to make the failing test pass. Do not write any more code than what is required to satisfy the test.
3.  **Refactor (Improve the code):** Once the test passes, refactor the code to improve its design, readability, and maintainability, without changing its external behavior. Ensure all tests still pass after refactoring.

This cycle (Red-Green-Refactor) is repeated for each small piece of functionality.

### Development Guidelines with TDD

-   **Always start with a test:** No production code should be written without a failing test first.
-   **Small steps:** Write tests and code in very small increments.
-   **Focus on one thing:** Each test should focus on a single responsibility or behavior.
-   **Refactor constantly:** Improve the code's internal structure as you go, keeping tests green.
-   **Tests as documentation:** Well-written tests serve as living documentation of the code's behavior.

## What to Avoid (Non-Negotiables)

- Do not commit sensitive information, such as LIFF ID or channel secrets, directly into the source code. Use environment variables (e.g., `.env.local`).
- **Do not run `git push`.** Committing changes is allowed, but pushing to the remote repository must be done manually by the user.

## Task Management and Logging

### Workflow

1.  **Understand and Plan:** Before starting a task, understand the requirements and create a clear plan. Define the goal of the task.
2.  **Execute:** Implement the planned changes.
3.  **Verify:** Test the changes to ensure they work as expected and don't introduce regressions.
4.  **Log:** Record the work done in the `task_memory` directory.

### Task Logging

-   Create a directory for each task under `task_memory/YYYYMMDD/{task_name}/`.
-   Inside the task directory, create markdown files to document the process, including:
    -   The initial plan.
    -   Investigation and findings.
    -   Code snippets and explanations.
    -   Final results and how to use the new feature.
-   The documentation should be clear enough for another engineer to understand the context and the changes made.
-   If you are unsure about anything, ask the user for clarification instead of making assumptions.