# Python Rules

## Types & Style
- Type hints on **all** function signatures (params + return).
- Use `from __future__ import annotations` for modern type syntax.
- f-strings over `.format()` or `%`. No string concatenation in loops.
- Prefer `pathlib.Path` over `os.path`.

## Data & Validation
- Pydantic `BaseModel` for all external data (API payloads, config, env vars).
- Use `dataclasses` for internal-only value objects without validation.
- Enums for fixed option sets (`from enum import StrEnum`).

## Async & I/O
- `async def` for I/O-bound operations. Don't block the event loop.
- Use `httpx` (async) over `requests` in async codebases.
- Connection pools for DB access; never open/close per request.

## Error Handling
- **No bare `except:`.** Always catch specific exceptions.
- Use custom exception classes for domain errors.
- Log with `structlog` or stdlib `logging` — never `print()` in production.

## Testing
- pytest for all tests. Fixtures over setup/teardown methods.
- Use `pytest.mark.parametrize` for input variations.
- Mock at I/O boundaries only. Prefer fakes over mocks when possible.
- Target behavior, not implementation details.
