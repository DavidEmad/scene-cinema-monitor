# Free hosting: GitHub Actions

The supplied workflow checks Scene approximately every five minutes, alerts when booking changes are detected, and sends a status message on the first normal check and approximately once an hour afterward. It runs on GitHub's computers; your PC can be off.

Standard hosted runners are free for public repositories. Private repositories have usage limits. This guide uses a public repository with private Telegram secrets. Official references:

- https://docs.github.com/en/billing/concepts/product-billing/github-actions
- https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule
- https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions

## 1. Create a public repository

Sign in at https://github.com/new. Name it `scene-cinema-monitor`, choose **Public**, and include a README to create the default branch. The source code and movie preferences will be public; credentials stay in secrets.

## 2. Upload the prepared files

Extract `scene-monitor-upload.zip`. In your GitHub repository choose **Add file → Upload files**, drag the extracted contents into the upload area, and commit to the default branch, usually `main`.

Upload the contents, not the ZIP itself or an extra enclosing folder. Include `.github`. Verify these paths exist at the repository root:

```text
.github/workflows/scene-monitor.yml
src/
test/
package.json
package-lock.json
README.md
HOSTING.md
```

The prepared ZIP excludes `.env`, `.git`, browser profiles, local data, inspection artifacts, and dependency folders. Do not upload the original working folder or paste the token into code, issues, logs, or chat.

## 3. Add two secrets

Open **Settings → Secrets and variables → Actions → New repository secret**. Create:

| Name | Value |
| --- | --- |
| `TELEGRAM_BOT_TOKEN` | Your BotFather token |
| `TELEGRAM_CHAT_ID` | Your destination chat ID |

Paste values without quotes. Your bot must already have received `/start` from that chat.

## 4. Test from GitHub

Open **Actions → Scene cinema monitor → Run workflow** on the default branch.

1. Choose mode **telegram-test**. Run it; wait for a green result and a Telegram TEST message.
2. Choose mode **success-test**. This checks the live **16 December 2026** schedule from GitHub. It sends a labeled test alert only if enabled booking links are confirmed. If the date is unavailable or GitHub is blocked, it fails honestly; inspect the failed step's log.
3. Choose mode **check**. This checks the real target, **25 December 2026**, and sends the initial hourly status. If a scheduled check already sent it, another normal check within the hour won't duplicate it.

## 5. Leave it enabled

Scheduled checks run at minutes 2, 7, 12, and so on each hour. There is no terminal to keep open. Hourly status reports include current availability and the last check time in Cairo. Booking alerts are sent when a check detects a relevant change.

GitHub can delay or drop scheduled runs during high load. Checks and hourly reports are approximate, not an exact-hour delivery guarantee. If you need strict timing, use the continuously running VM alternative in README.md.

The workflow sets `TARGET_DATE: '2026-12-25'` and `STATUS_INTERVAL_SECONDS: '3600'`. Do not run a local continuous monitor alongside it.

## State and failures

Only `data/state.json` is cached between jobs. It contains public schedule results, notification keys, and timestamps, without Telegram credentials or browser cookies. Caches can be evicted; lost state may cause a repeated alert or an early hourly report. Jobs run serially, and no pull-request-triggered workflow is configured.

A green check means the page was recognized and any due messages were accepted by Telegram. A red run means something failed. If the whole runner fails before the script starts, it cannot send Telegram updates; check Actions when an hourly message is missing.

Public scheduled workflows can be disabled after 60 days without repository activity. This movie's target is within that window from initial setup; review this rule if reusing the project.

The workflow skips checks once 25 December 2026 has passed in Cairo. To stop all scheduled jobs, open **Actions → Scene cinema monitor → ⋯ → Disable workflow**. You can do this any time.

No GitHub repository or hosting resource has been created by this project. Successful Actions runs in your account are the final cloud verification.
