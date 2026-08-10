/// The moment Letraverse was created. Set once, on the very first commit
/// of this project, and never touched again by any later change — the app
/// itself only ever reads it (Settings > About). Git history (commit
/// "genesis" + the `genesis` tag) is the durable record backing this date.
library;

final DateTime kAppGenesisUtc = DateTime.utc(2026, 8, 10, 12, 0, 0);
