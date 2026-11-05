# Scene cinema monitor

Watches **Avengers: Doomsday, 25 December 2026, Scene Cairo Festival City**, across every format on the supplied movie page. **Only Scene is active.**

- Checks every five minutes, with immediate alerts when a date is listed or enabled booking links are confirmed.
- Sends a status report on the first normal check, then approximately every hour, including when the date is unavailable or a site check fails.
- Runs headless locally or on GitHub's computers. Your PC can be off once cloud setup is complete.

See [HOSTING.md](HOSTING.md) for the free GitHub Actions setup. Nothing is hosted until configured in your account.

## Local use

Requires Node.js 22.9+ and Chrome. Existing `.env` holds your private Telegram credentials; environment variables override it in hosting.

```powershell
cd "C:\Users\David\Documents\ChatGPT\VOX Cinemas"
npm.cmd ci
npm.cmd run telegram:test
npm.cmd run check
npm.cmd start
```

`check` performs one cycle and exits. `start` runs continuously while this PC stays awake; Ctrl+C stops it. `npm.cmd run check -- --status-now` forces a status report after a real check. Do not run local continuous monitoring and the cloud workflow together, or run multiple copies against the same browser/state folder.

## Detection and delivery

The selected date and its completed AJAX response must match before links are evaluated. A listed date produces an early alert; enabled showtime links produce a booking-links alert. Links do not guarantee seats or purchase success. Blocked pages, errors, and missing structures mean unknown availability, not sold out.

`data/state.json` saves alert history and the last accepted hourly report. Messages are marked sent only after Telegram accepts them. Restarts normally suppress duplicates; a crash between sending and saving, or cache loss in hosting, can cause repeats. Hourly timing is approximate because reports are sent after checks complete. A stopped runner or unreachable Telegram cannot send a status message.

## Tests

```powershell
npm.cmd test
npm.cmd run success:test -- --site=scene --date=2026-12-16
npm.cmd run check -- --dry-run
```

The live success test shares the production checker and message formatter. It sends a clearly labeled TEST alert only if booking links are detected for its test date, without changing the real target or saved alert history. Each successful invocation intentionally sends a message.

Tests cover stale/wrong-day links, disabled times, format collection, blocked pages, AJAX completion, retry limits, and hourly reporting. Legacy VOX parsing/retry tests remain as regression coverage; VOX is excluded from the active sites list and all new checks.

## Optional VM alternative

The Dockerfile provides a continuously running Linux VM option, untested here:

```sh
docker build -t scene-monitor .
docker run -d --name scene-monitor --restart unless-stopped --env-file .env -v scene-monitor-state:/state scene-monitor
```

Keep the volume to preserve state. Do not run it alongside Actions. Local success does not establish cloud access; run the cloud test first.
