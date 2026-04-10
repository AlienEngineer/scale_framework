## ATDD Rules

### Guildelines

 1. Functions/Methods can't be longer than 80 lines.
 2. Classes can't be longer than 150 lines.
 3. Files can't be longer than 200 lines.
 4. Constructors can have more than 3 parameters.
 5. Functions/Methods should have a maximum of 3 parameters.
 6. Change my tests to make them more readable and maintainable.
 7. If there's a need for adapt mocks or fakes do it without asking.
 8. If a test file has more than 3 tests, split it into multiple files.

### Things to avoid

 1. Avoid using more than 3 nested levels of code.
 2. Avoid using more than 3 levels of indentation.

### Preferred dependencies

 1. Use cubit for state management.
 2. Use get_it for dependency injection.
 3. Use mocktail for mocking in tests.

