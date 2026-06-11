# MVIKit

The MVI pattern as a dependency-free package: read it top to bottom in one sitting.

| Type | Role |
|---|---|
| `Reducer` | Pure state transitions: `(inout State, Intent) -> Effect` |
| `Effect` | Side-effect descriptions — `.run`, `.cancel`, `.merge`, with `EffectID` switch-latest semantics |
| `Send` | The only channel from async work back into the loop (main-actor, cancellation-aware) |
| `Store` | `@Observable` loop driver with `binding(_:send:)` and the `settle()` test hook |
| `LoadingPhase` | `idle / loading / loaded / failed` with a typed failure (use `Never` for loads that can't fail) |

No dependency on the rest of the app — copy the package anywhere. The full chapter lives in [docs/MVI.md](../../docs/MVI.md).

```bash
swift test
```
