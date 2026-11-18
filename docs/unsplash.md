# My Day Featured backgrounds

My Day chooses a random Unsplash Featured photograph when DartToDo opens. **No API key or Unsplash account is required for the default mode.** The frontend calls the local typed endpoint once per launch, then hotlinks the selected `images.unsplash.com` URL and shows photographer/Unsplash attribution.

## Default homepage source

The server requests `https://unsplash.com/` without account cookies, task data or an authorization header. It reads the homepage's serialized `window.__DEHYDRATED_DATA__` value as JSON data; it does not execute JavaScript, advertising or tracking scripts. Only the exact `['featured-photos-feed', null]` query's result pages are considered. Eligible objects must have `premium == false`, a valid `promoted_at`, no sponsorship, and validated image/attribution URLs.

This webpage data shape was observed on **17 November 2026**. It is an implementation detail of the public homepage, not a supported API contract. If Unsplash changes that shape, blocks the request, or takes too long, the app can still select a different photo from its last good metadata. The checked-in `flutter_todo_server/config/unsplash_featured_seed.json` is a dated set of 13 eligible photographs from that observed Featured gallery. It is an offline metadata fallback, not proof of a fresh homepage response.

Selection avoids the caller's previous photo when at least two eligible photos exist. Without a caller-provided previous ID, it avoids the backend's last choice, which is stored across server restarts. It also avoids the backend's last choice when that does not conflict with the caller's no-repeat requirement. With one eligible photo, repetition is unavoidable. The app does not promise that every launch completes a fresh network request.

## Data and failure boundaries

`Client.background.featured(previousId: ...)` returns `BackgroundPhoto?`. A photo contains its ID, hotlink URL, photographer name/profile URL, photo-page URL, `source` and `fromCache`. Source is `homepage`, `featured-seed`, or the optional API's `editorial`; `fromCache` separately records whether the selection used existing metadata. Null means no usable photo is available. Local task operations continue independently.

Homepage requests have a five-second deadline and a 3 MB body limit. API metadata/cache input is bounded to 2 MB. A failed homepage request causes a one-minute retry backoff. Sanitized metadata and the last selection are stored under the ignored `.dartnflutter/unsplash/` directory; raw HTML, scripts and API keys are not stored there. The frontend additionally caches a bounded last-good image/metadata pair for display fallback.

HTTPS hosts are restricted to `unsplash.com` for homepage/credit links, `images.unsplash.com` for images and `api.unsplash.com` for optional API metadata. Redirects are not followed by the server transport. Returned image query parameters, including `ixid`, are preserved when adding width/format parameters. Credit links add `utm_source=darttodo&utm_medium=referral`. Unsplash receives ordinary photo-request network information; tasks, notes, steps and attachments are never included.

Photographs retain their own [Unsplash license](https://unsplash.com/license), separate from this repository's original-code license. The seed contains public URLs/attribution, not redistributed image files. Attribution is retained even in the no-key homepage mode.

## Optional official API mode

For a deployment deliberately configured with `UNSPLASH_ACCESS_KEY` in the **server environment**, the existing adapter uses the official Editorial feed with `GET /photos`, `per_page=30` and a random page from 1 through 5. Feed metadata is reused for 15 minutes. The key is sent only in the API authorization header and is never returned to Flutter or cached. This mode is optional and was not configured with a real key in the trial. See the [official API documentation](https://unsplash.com/documentation#list-photos).

API mode tracks a selected photo using its validated `download_location` URL. It preserves that URL's query parameters and uses the authorized API request; it does not use the tracking response as an image. No unauthenticated tracking request is made in homepage/seed mode. Hotlinks and attribution follow the separately documented [API guidelines](https://help.unsplash.com/en/articles/2511245-unsplash-api-guidelines) and [download-event guidance](https://help.unsplash.com/en/articles/2511258-guideline-triggering-a-download).

## Verification

`flutter_todo_server/test/unit/unsplash_service_test.dart` uses injected transport/random/clock and synthetic payloads to check escaped JSON parsing, exact feed selection, premium/ad exclusion, URL boundaries, no-repeat selection, persistent cache/seed fallback, rate errors, timeouts, cancellation/closure, query preservation and optional API authorization/tracking. Those fixtures are not live Unsplash integration evidence.

`dart test test/unit/unsplash_transport_test.dart`, from the server package, adds eight deterministic checks around the real transport using zone-scoped fake HTTP clients. They cover split UTF-8/exact byte bounds, redirect/header policy, over-limit early termination, malformed data, connection/body errors, timeout cleanup and disposal of concurrent clients. [Backend coverage Round 6](quality/06-dart-backend-coverage.md) records its 40/40 reported transport lines; live external requests remain the separate smoke below.

From the server package, `dart run tool/unsplash_live_smoke.dart` checks actual homepage retrieval and distinct choices while reporting fresh/cache status individually. With the backend running, `dart run tool/background_live_smoke.dart` from the client package exercises the generated typed endpoint. A successful cached fallback is useful behavior and remains distinct from a fresh network observation. Native image display and app-reopen behavior require the separate Flutter/runtime checks.
