# Semantic Anchors Reference

Anchors link documentation to code locations that survive refactoring.

## Anchor Types

### @function:name

Matches function or method definitions.

**Patterns detected:**
- Python: `def func_name(`, `async def func_name(`
- JavaScript/TypeScript: `function name(`, `async function name(`
- Arrow functions: `const name = (`, `const name = async (`
- Export: `export function name(`, `export const name =`

**Example:**
```markdown
### @function:authenticate | Authentication Logic
### fr: Logique d'authentification
```

### @class:Name

Matches class definitions.

**Patterns detected:**
- Python: `class ClassName:`, `@dataclass class ClassName`
- JavaScript/TypeScript: `class ClassName {`, `export class ClassName`

**Example:**
```markdown
### @class:AuthService | Authentication Service
### fr: Service d'authentification
```

### @method:Class.method

Matches a specific method within a class.

**Use when:** A class has many methods and you want to document one specifically.

**Example:**
```markdown
### @method:AuthService.validateToken | Token Validation
### fr: Validation du token
```

### @pattern:text

Matches the first line containing the specified text.

**Use when:** No function/class anchor fits, but you need to reference specific code.

**Example:**
```markdown
### @pattern:if __name__ == | Entry Point
### fr: Point d'entrée
```

**Caution:** Less stable than function/class anchors. Code changes may break the match.

### @chunk:id

Virtual anchor with no code location.

**Use when:** Documenting concepts, architecture decisions, or overviews that don't map to specific code.

**Example:**
```markdown
### @chunk:architecture-overview | System Architecture
### fr: Architecture du système
en: This section explains the overall system design...
fr: Cette section explique la conception globale du système...
```

## Best Practices

### Prefer Stable Anchors

Stability ranking (most to least stable):
1. `@function:name` - Functions rarely renamed
2. `@class:Name` - Classes rarely renamed
3. `@method:Class.method` - Methods may move
4. `@pattern:text` - Text may change
5. `@line:N-M` - Lines always change (avoid)

### One Anchor Per Concept

Don't create multiple anchors for the same logical unit. If a function is 50 lines, use one `@function` anchor, not multiple `@pattern` anchors.

### Naming Conventions

- Use exact code names: `@function:process_data` not `@function:processData` if Python
- Case-sensitive matching
- No spaces in anchor names

## Detection Patterns

The skill auto-detects anchors from git diff:

```
+ def authenticate(user, password):    → @function:authenticate
+ class UserService:                    → @class:UserService
+     def validate(self):              → @method:UserService.validate
```

## Multilingual Anchor Titles

Anchors themselves are code references (not translated), but titles are:

```markdown
### @function:authenticate | Authentication Handler
### fr: Gestionnaire d'authentification
### es: Manejador de autenticación
```
