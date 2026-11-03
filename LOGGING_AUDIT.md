# Logging audit

Audit of the logging added in `166265b` and `75f1ff3` on branch `SDK-6118-console-logs`.
Scope: the `CTNotificationContent` target plus `Sources/CTNotificationContentWrapper`.

## 1. Summary

**Verdict: the logging is good and unusually thorough, but two claims are not true as written, and one of them means SPM consumers get no logging at all.**

| | Count |
|---|---|
| Log call sites | 241 (202 Swift, 39 Objective-C macro) |
| Stray `print` / `NSLog` / `debugPrint` / direct `os_log` | 0 |
| Uniformity violations found | 8 |
| Fixed in this pass | 8 |
| Open issues (flagged, not changed) | 2 |

Level split: 81 `info`, 118 `error`, 3 `debug` (Swift); the Objective-C macros add 39 more.

**Open issues, highest first:**

1. **SPM consumers get none of this logging.** `Package.swift:27` points at a `binaryTarget`, `Framework/CTNotificationContent.xcframework`, which was last rebuilt in commit `0e13b7f` ("update CTNotificationContent.xcframework for v1.5.1") — *before* the logging commits. `git diff 77e0274..HEAD -- Framework/` is empty, and the shipped binary contains zero occurrences of the `[CleverTap][NotificationContent]` prefix and zero `ContentLogger` symbols. The xcframework has to be rebuilt and committed.
2. **"Always on, no toggle" is not true,** and the README contradicts the code. See §6.

The unredacted payload dump at `CTUtility.swift:82` was fixed in this pass — see §4 (V8).

---

## 2. Stage coverage table

| # | Stage | Covered | File:Line | Message | Silent exits |
|---|---|---|---|---|---|
| 1 | Process launch / principal class init | **No** | — | — | No `init`/`+load` line exists. `viewDidLoad` is the first line written. See §5 G1. |
| 2 | `viewDidLoad` of root VC | Yes | [CTNotificationViewController.m:105](CTNotificationContent/CTNotificationViewController.m:105) | `Extension view loaded, frame=%@` | None |
| 3 | `didReceive(_ notification:)` entry | Yes | [CTNotificationViewController.m:114](CTNotificationContent/CTNotificationViewController.m:114) | `Received notification, id=%@, payloadKeys=[%@]` | None |
| 4a | `pt_id` read | Yes | [:269](CTNotificationContent/CTNotificationViewController.m:269), [:276](CTNotificationContent/CTNotificationViewController.m:276), [:315](CTNotificationContent/CTNotificationViewController.m:315) | missing / wrong type / unknown value all covered | None |
| 4b | `pt_json` read or rebuilt | Yes | [:285](CTNotificationContent/CTNotificationViewController.m:285), [:288](CTNotificationContent/CTNotificationViewController.m:288), [:360](CTNotificationContent/CTNotificationViewController.m:360) | `Missing key=%@, building json from flat payload keys` | None. Serialization and UTF-8 failures log at [:351](CTNotificationContent/CTNotificationViewController.m:351) and [:357](CTNotificationContent/CTNotificationViewController.m:357). |
| 5 | Payload validation result | Yes | [CTUtility.swift:180](CTNotificationContent/Templates/Utility/CTUtility.swift:180) / [:172](CTNotificationContent/Templates/Utility/CTUtility.swift:172) | `Required keys missing, template=…, missing=[…]` | **Fixed** — the no-rules branch returned silently; now logs at [:156](CTNotificationContent/Templates/Utility/CTUtility.swift:156). |
| 6 | Template selection + reason | Yes | [:257](CTNotificationContent/CTNotificationViewController.m:257), [:265](CTNotificationContent/CTNotificationViewController.m:265), [:319](CTNotificationContent/CTNotificationViewController.m:319) | `Resolved template from pt_id=%@` | None. Every fallback names its reason. |
| 7 | Template VC instantiation | Yes | one `… controller started` per template | e.g. [CTCarouselController.swift:42](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:42) | **Fixed** — WebView had no start line; added at [CTWebViewController.swift:43](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:43). |
| 8 | Child VC added / laid out, incl. zero size | Yes | [:232](CTNotificationContent/CTNotificationViewController.m:232), [:237](CTNotificationContent/CTNotificationViewController.m:237), [:371](CTNotificationContent/CTNotificationViewController.m:371) | `Zero preferredContentSize, expanded view will not be visible, …` | None. Both the first layout and later resizes are checked. |
| 9 | Asset load start / success / failure | Yes | [CTUtility.swift:27–54](CTNotificationContent/Templates/Utility/CTUtility.swift:27) | start, bad URL, network error, bad status, empty body, decode failure, success all separate | **Fixed** — two `guard let self` returns in `CTCaptionedImageView` were silent. |
| 10 | `didReceive(_ response:)` | Yes | [:389](CTNotificationContent/CTNotificationViewController.m:389), [:396](CTNotificationContent/CTNotificationViewController.m:396) | `Handled action=%@, responseOption=%@` | None. Nil-controller branch logs at [:391](CTNotificationContent/CTNotificationViewController.m:391). |
| 11 | Memory warning | Yes | [:384](CTNotificationContent/CTNotificationViewController.m:384) | `Memory warning, the system may stop the extension` | None |

10 of 11 stages covered. Stage 1 is the only one with no line at all.

---

## 3. All log call sites

241 call sites across 18 files. All of them route through `CTContentLog`; none calls `os_log` directly. Rather than reproduce every line, the per-file counts and the compliance result:

| File | Calls | Compliant |
|---|---|---|
| [CTNotificationViewController.m](CTNotificationContent/CTNotificationViewController.m) | 37 | Y (1 fixed, see V1) |
| [BaseCTNotificationContentViewController.m](CTNotificationContent/BaseCTNotificationContentViewController.m) | 5 | Y |
| [CTCarouselController.swift](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift) | 26 | Y (1 open, see R7) |
| [CTRatingsViewController.swift](CTNotificationContent/Templates/Rating/Controller/CTRatingsViewController.swift) | 17 | Y |
| [CTTimerTemplateController.swift](CTNotificationContent/Templates/Timer/Controller/CTTimerTemplateController.swift) | 31 | Y |
| [CTVerticalImageController.swift](CTNotificationContent/Templates/VerticalImage/Controller/CTVerticalImageController.swift) | 18 | Y |
| [CTContentSliderController.swift](CTNotificationContent/Templates/ContentSlider/Controller/CTContentSliderController.swift) | 17 | Y (1 fixed, V6) |
| [CTZeroBezelController.swift](CTNotificationContent/Templates/ZeroBezel/Controller/CTZeroBezelController.swift) | 13 | Y |
| [CTSingleMediaController.swift](CTNotificationContent/Templates/SingleMedia/Controller/CTSingleMediaController.swift) | 13 | Y (1 fixed, V2) |
| [CTUtility.swift](CTNotificationContent/Templates/Utility/CTUtility.swift) | 22 | Y (1 fixed, V8) |
| [CTProductDisplayLinearViewController.swift](CTNotificationContent/Templates/ProductDisplay/Controller/CTProductDisplayLinearViewController.swift) | 10 | Y |
| [CTProductDisplayVerticalViewController.swift](CTNotificationContent/Templates/ProductDisplay/Controller/CTProductDisplayVerticalViewController.swift) | 10 | Y |
| [CTCaptionedImageView.swift](CTNotificationContent/Views/CTCaptionedImageView.swift) | 8 | Y (2 fixed, V3/V4) |
| [CTWebViewController.swift](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift) | 8 | Y (2 fixed, V5/V7) |
| [Extensions.swift](CTNotificationContent/Templates/Utility/Extensions.swift) | 2 | Y |
| [CTTimerBoxView.swift](CTNotificationContent/Templates/Timer/View/CTTimerBoxView.swift) | 1 | Y |

**Categories in use: exactly one** — `CTNotificationContent`, defined at [CTNotificationContentLogger.swift:20](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:20). Subsystem is `com.clevertap.sdk` at [:19](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:19), used in exactly one `OSLog` construction at [:27](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:27). Rule 2 passes.

---

## 4. Uniformity violations

### Fixed

| ID | Rule | Where | What |
|---|---|---|---|
| V1 | 4 | `CTNotificationViewController.m:93` | Hand-typed `from:@"CTContentStringValue"` instead of `__PRETTY_FUNCTION__`. The only hand-typed call site in the repo. Now uses the `CTContentLogError` macro. |
| V2 | 5 | `CTSingleMediaController.swift:51` | `"mediaType video and audio not supported yet…"` — only message starting lowercase, and the actual `mediaType` was not in `key=value` form. Now `"Unsupported mediaType=…, video and audio are not supported yet, …"`. |
| V3 | 5 | `CTCaptionedImageView.swift:76` | `guard let self = self else { return }` — silent, where 9 other sites log `"Controller deallocated before …"`. |
| V4 | 5 | `CTCaptionedImageView.swift:91` | Same, on the still-image path. |
| V5 | 5 | `CTWebViewController.swift` | Only template with no `"… controller started"` line. |
| V6 | 5 | `CTContentSliderController.swift:202` | Silent `return [:]`, where the sibling property at :191 logs. |
| V7 | 5 | `CTWebViewController.swift:64` | Silent `guard let jsonContent` return. |
| V8 | 6 | `CTUtility.swift:82` | Entire push payload dumped unredacted at always-on `.default`. Demoted to `debug`. See below. |

Rules 1, 2 and 3 had **zero** violations. Every emitted line goes out at `.default` ([CTNotificationContentLogger.swift:83](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:83)); there is no `.info`/`.debug`/`.error`/`.fault` `OSLogType` anywhere. Note the `info`/`error`/`debug` method names are the SDK's own severity vocabulary, not `OSLogType` values — they all emit `.default`. That is consistent with the stated design.

**V8 in detail — the payload dump.** The line was:

```swift
CTContentLog.error("Failed payload=\(data)")
```

This wrote the **entire push payload** — titles, message bodies, deeplinks with user ids, any custom key the customer attached — to disk at `.default`, always on, with no debug gate. Persisted logs come off the device in a sysdiagnose, so this is customer data at rest on every decode failure.

It contradicted the project's own deliberate decision three files over at [CTNotificationViewController.m:324](CTNotificationContent/CTNotificationViewController.m:324), where the same data is gated:

```objc
// The whole payload. This is the one thing that explains most reports, but
// it is long and it can hold customer data. So it needs the debug level.
CTContentLogDebug(@"Payload json=%@", self.jsonString ?: @"");
```

Fixed by demoting to `CTContentLog.debug` ([CTUtility.swift:84](CTNotificationContent/Templates/Utility/CTUtility.swift:84)). No diagnostic value is lost: the preceding line at [:81](CTNotificationContent/Templates/Utility/CTUtility.swift:81) already names the offending key via `String(describing: error)`, which is the part that actually explains the failure. The dump is still available to anyone who calls `setDebugLevel(1)`.

Both full-payload dumps in the SDK are now gated identically. Verified no other always-on log line interpolates a whole payload.

### Open — flagged, not changed

**R6 (privacy) — deeplink URLs, lower severity.** Roughly 30 sites log `url=\(deeplinkURL)` at always-on `.default` (e.g. [CTCarouselController.swift:385](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:385), [CTRatingsViewController.swift:329](CTNotificationContent/Templates/Rating/Controller/CTRatingsViewController.swift:329)). Deeplinks routinely carry user or campaign ids. This is arguably the right tradeoff — a deeplink that does not fire is a top support case and the URL is the whole diagnosis — so I would leave it, but it should be a conscious decision rather than an accident. If you want it tightened, log the scheme and host at `info` and the full URL at `debug`.

Note the `%{public}` requirement is already handled correctly and centrally: [CTNotificationContentLogger.swift:83](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:83) uses `%{public}@` for all three arguments, and because every message is interpolated into a Swift `String` before it reaches `os_log`, nothing can render as `<private>`. That is the right call for this use case — it is also precisely why R6 matters, since there is no redaction backstop.

**R7 (hot path) — `CTCarouselController.swift:447`.**

```swift
CTContentLog.info("Paging to index=\(currentItemIndex)/\(itemViews.count), direction=\(direction)")
```

`showNext` is driven by a repeating 3-second autoplay timer ([:467](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:467)), so an auto-carousel left on screen writes a persisted line every 3 seconds indefinitely. Not per-frame, so not severe, but it is the only unbounded log source in the SDK. Proposed fix: demote to `CTContentLog.debug`, and keep an `info` line only for user-initiated paging. The timer template already handles its equivalent correctly — [CTTimerTemplateController.swift:308](CTNotificationContent/Templates/Timer/Controller/CTTimerTemplateController.swift:308) puts its per-second tick behind `debug`.

No other per-frame, per-scroll or per-layout logging found.

---

## 5. Gaps

**G1 — No log at process launch / principal class init.** The earliest line is `viewDidLoad`. The claim says "first line logs that the extension started", and in practice `viewDidLoad` is close enough that this is a judgement call, not a defect. But `viewDidLoad` fires after the principal class is allocated, so a crash or a `NSExtensionPrincipalClass` misconfiguration between launch and `viewDidLoad` produces an empty log that looks identical to "the extension never launched". The in-code comment at [CTNotificationViewController.m:101-104](CTNotificationContent/CTNotificationViewController.m:101) tells the reader to interpret no-lines-at-all as "never started", which is exactly the ambiguity an init line would remove.

Suggested line, in an `+initialize` or an overridden `init`:

```objc
CTContentLogInfo(@"Extension process started, SDK version=%@", kCTNotificationContentVersion);
```

**G2 — Decode failures are attributed to the type, not the template.** [CTUtility.swift:67](CTNotificationContent/Templates/Utility/CTUtility.swift:67) and [:81](CTNotificationContent/Templates/Utility/CTUtility.swift:81) log `\(T.self)` (e.g. `TimerTemplateProperties`). A reader has to know the type-to-template mapping. Minor; the call site is recoverable from the `callSite` field.

No other silent early returns remain. The remaining unlogged `guard`s are all benign value fallbacks with no user-visible effect: [CTVerticalImageController.swift:235](CTNotificationContent/Templates/VerticalImage/Controller/CTVerticalImageController.swift:235) (optional CTA button absent), [:410](CTNotificationContent/Templates/VerticalImage/Controller/CTVerticalImageController.swift:410) and [CTTimerTemplateController.swift:84](CTNotificationContent/Templates/Timer/Controller/CTTimerTemplateController.swift:84) (idempotency guards on constraint activation), [Extensions.swift:36-37](CTNotificationContent/Templates/Utility/Extensions.swift:36) (nil colour), [CTUtility.swift:186](CTNotificationContent/Templates/Utility/CTUtility.swift:186) (`hasValue` predicate, whose result is logged by its caller).

---

## 6. Claims check

### CTContentLog

| Claim | Verdict | Evidence |
|---|---|---|
| New class wrapping `os_log`, subsystem `com.clevertap.sdk` | **Verified** | [CTNotificationContentLogger.swift:17,19,27](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:17). Note the Swift class is `CTContentLog` but the file and the Objective-C name are `CTNotificationContentLogger` — deliberate, to avoid a runtime clash with `CTLogger` in the main SDK ([:13-15](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:13)). |
| **Always on, no toggle** | **Not true** | [:37](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:37) declares `debugLevel`, [:46](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:46) `setDebugLevel`, and [:77](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:77) / [:108](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:108) gate `debug` behind it. Commit `75f1ff3` ("added debug level and static method to enable debug level logs") added this *after* the commit the claim describes. `info` and `error` are unconditional, so the claim is true for 239 of 241 call sites — but there is a toggle, and the two lines behind it are the two most diagnostic ones (the full payload, the timer tick). **The README was not updated**: line 476 still says "Logging is always on. There is nothing to enable in code", and `setDebugLevel` is documented nowhere. |
| Every line uses `.default`, persists to disk | **Verified** | Single emit path at [:83](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:83), `type: .default`. No other `OSLogType` in the repo. |
| Every line includes source file and method | **Verified** | `#fileID` / `#function` defaults at [:63,67,76](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:63), formatted by `callSite` at [:88](CTNotificationContent/Templates/Utility/CTNotificationContentLogger.swift:88); Objective-C uses `__PRETTY_FUNCTION__`. One hand-typed exception existed and was fixed (V1). |
| Survives a stripped Release build | **Verified** | See §7. |
| **Works for SPM consumers** | **Not true** | `Package.swift` exposes a `binaryTarget` at [:27](Package.swift:27) pointing at `Framework/CTNotificationContent.xcframework`. That binary contains 0 occurrences of `[CleverTap][NotificationContent]` and 0 `ContentLogger` symbols (`strings`/`nm`), and `git diff 77e0274..HEAD -- Framework/` is empty — it was last rebuilt in `0e13b7f` for v1.5.1. The source file *is* correctly in the Xcode target ([project.pbxproj:546](CTNotificationContent.xcodeproj/project.pbxproj:546)) and in the CocoaPods glob (`s.source_files = 'CTNotificationContent/**/*.{h,m,swift}'`), so **CocoaPods and direct Xcode consumers are fine**. Only SPM is stale, and it will stay stale until the xcframework is rebuilt. |

### Startup, validation, images, templates

| Claim | Verdict | Evidence |
|---|---|---|
| First line logs extension started | **Partially** | `viewDidLoad` at [:105](CTNotificationContent/CTNotificationViewController.m:105) is the first line, but there is nothing at process launch or principal class init. See G1. |
| Logs notification id and all payload keys | **Verified** | [:114](CTNotificationContent/CTNotificationViewController.m:114) |
| Logs which template was picked and why | **Verified** | [:257](CTNotificationContent/CTNotificationViewController.m:257), [:265](CTNotificationContent/CTNotificationViewController.m:265), [:319](CTNotificationContent/CTNotificationViewController.m:319); every fallback states its reason |
| Logs `pt_id` missing / unknown / wrong type | **Verified** | [:269](CTNotificationContent/CTNotificationViewController.m:269), [:315](CTNotificationContent/CTNotificationViewController.m:315), [:276](CTNotificationContent/CTNotificationViewController.m:276) — all three cases |
| Logs `pt_json` missing / malformed / rebuilt from flat keys | **Verified** | [:285](CTNotificationContent/CTNotificationViewController.m:285), [:288](CTNotificationContent/CTNotificationViewController.m:288), [:351](CTNotificationContent/CTNotificationViewController.m:351), [:357](CTNotificationContent/CTNotificationViewController.m:357), [:360](CTNotificationContent/CTNotificationViewController.m:360) |
| Logs zero size | **Verified** | [:232](CTNotificationContent/CTNotificationViewController.m:232) on first layout **and** [:371](CTNotificationContent/CTNotificationViewController.m:371) on later resize. The second one matters — images arrive after first layout, so this is the one that catches the real blank-view case. |
| Logs memory warnings | **Verified** | [:384](CTNotificationContent/CTNotificationViewController.m:384) |
| Logs response action by name, not raw number | **Verified** | `CTResponseOptionName` at [:23-33](CTNotificationContent/CTNotificationViewController.m:23) maps the enum, used at [:396](CTNotificationContent/CTNotificationViewController.m:396). Includes an `unknown(%lu)` default. (`actionIdentifier` was already a string.) |
| Validation runs before drawing or download | **Verified** | `logPayloadCheckForTemplate` is called at [:320](CTNotificationContent/CTNotificationViewController.m:320), inside `updateContentType`, which runs at [:118](CTNotificationContent/CTNotificationViewController.m:118) before the controller `switch` |
| Names every missing key in one line + says what the user sees | **Verified** | [CTUtility.swift:165-180](CTNotificationContent/Templates/Utility/CTUtility.swift:165). Deliberately does not short-circuit ([:163-164](CTNotificationContent/Templates/Utility/CTUtility.swift:163)), and each rule carries a user-visible `effect` string. |
| Covers basic, both carousels, timer, zero bezel, web view, rating, vertical image | **Verified** | [CTUtility.swift:122-144](CTNotificationContent/Templates/Utility/CTUtility.swift:122) — all 8 template ids present. Product display is checked separately via `isRequiredKeysProvided` ([:88](CTNotificationContent/Templates/Utility/CTUtility.swift:88)). |
| Images: start, size, byte count, duration | **Verified** | [:27](CTNotificationContent/Templates/Utility/CTUtility.swift:27) start; [:54](CTNotificationContent/Templates/Utility/CTUtility.swift:54) success with `elapsedMs`, `bytes` and pixel `size` |
| Each image failure logged separately | **Verified** | bad URL [:22](CTNotificationContent/Templates/Utility/CTUtility.swift:22), network error [:34](CTNotificationContent/Templates/Utility/CTUtility.swift:34), bad status [:39](CTNotificationContent/Templates/Utility/CTUtility.swift:39), empty body [:44](CTNotificationContent/Templates/Utility/CTUtility.swift:44), decode failure [:49](CTNotificationContent/Templates/Utility/CTUtility.swift:49) — five distinct branches |
| Timeout is 10s | **Verified, with one caveat** | [:12](CTNotificationContent/Templates/Utility/CTUtility.swift:12) `imageRequestTimeout = 10`, applied at [:30](CTNotificationContent/Templates/Utility/CTUtility.swift:30). Nothing else in the repo sets `timeoutInterval`, `timeoutIntervalForRequest` or `timeoutIntervalForResource`. Caveat: this applies only to `CTUtiltiy.checkImageUrlValid`. GIFs go through SDWebImage's `sd_setImage` instead (e.g. [CTCaptionedImageView.swift:78](CTNotificationContent/Views/CTCaptionedImageView.swift:78), [CTZeroBezelController.swift:150](CTNotificationContent/Templates/ZeroBezel/Controller/CTZeroBezelController.swift:150)), which uses its own downloader with a **15s** default (`_downloadTimeout = 15.0` in `SDWebImageDownloaderConfig.m:28`, SDWebImage 5.21.7, the version both `Podfile.lock` and `Package.resolved` pin) that this change does not touch. The stated rationale — a hung download outliving the extension — still applies to the GIF path. |
| Carousel: image count, skipped slides, page index, deeplink taps | **Verified** | [:167](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:167), [:196](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:196), [:182](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:182), [:447](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:447), [:385](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:385) |
| Timer: which key set the deadline, and the values | **Verified** | [:146](CTNotificationContent/Templates/Timer/Controller/CTTimerTemplateController.swift:146) `pt_timer_threshold`, [:154](CTNotificationContent/Templates/Timer/Controller/CTTimerTemplateController.swift:154) `pt_timer_end`, [:156](CTNotificationContent/Templates/Timer/Controller/CTTimerTemplateController.swift:156) neither |
| WebView: load start, failure, finish | **Verified** | [:59](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:59), [:116](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:116) + [:120](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:120), [:124](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:124). Both `didFail` and `didFailProvisionalNavigation` are covered — the provisional one is what actually fires for DNS and TLS failures. |
| All others: missing images, caption-only fallbacks | **Verified** | Present in every template controller |
| Wrong-typed payload value no longer aborts decoding | **Verified** | `CTContentStringValue` at [:82-96](CTNotificationContent/CTNotificationViewController.m:82) coerces `NSNumber` and returns `@""` otherwise; `createJSONData` at [:338-345](CTNotificationContent/CTNotificationViewController.m:338) skips unsupported types rather than failing |
| Empty view lists and decode failures handled | **Verified** | [CTUtility.swift:66-84](CTNotificationContent/Templates/Utility/CTUtility.swift:66); empty-list guards at [CTCarouselController.swift:240](CTNotificationContent/Templates/Carousel/Controller/CTCarouselController.swift:240) and [CTContentSliderController.swift:118](CTNotificationContent/Templates/ContentSlider/Controller/CTContentSliderController.swift:118) |
| README has the `log stream` command | **Verified** | [README.md:484](README.md:484) |
| README warns Console.app hides these under Errors and Faults | **Verified** | [README.md:507](README.md:507) |

---

## 7. Build verification

**Release build, stripping enabled — passes.**

```
xcodebuild -project CTNotificationContent.xcodeproj -scheme CTNotificationContent \
  -configuration Release -sdk iphoneos CODE_SIGNING_ALLOWED=NO \
  DEPLOYMENT_POSTPROCESSING=YES STRIP_INSTALLED_PRODUCT=YES build
** BUILD SUCCEEDED **
```

The project's own Release settings are `STRIP_INSTALLED_PRODUCT = YES`, `STRIP_STYLE = debugging`, `DEAD_CODE_STRIPPING = YES`, `DEPLOYMENT_POSTPROCESSING = NO` (so stripping runs on install/archive). The command above forces the archive-time behaviour.

Inspecting the resulting stripped `arm64` dylib:

| Check | Result |
|---|---|
| `[CleverTap][NotificationContent]` format string | present |
| `com.clevertap.sdk` subsystem string | present |
| `ContentLogger` symbols | 16 |
| Undefined `_os_log_impl` (i.e. calls really linked) | present |
| Sample messages (`Extension view loaded`, `Zero preferredContentSize`, `Memory warning`, `Required keys missing`, `Image download failed`) | all present |

Nothing is compiled out. The claim holds.

Note: forcing `STRIP_STYLE=all` **fails** the build — `Strip /…/SDWebImage.o` errors, because the SPM dependency produces a relocatable object that cannot be fully stripped. This is not a regression from the logging work, but it is worth knowing before anyone adds `STRIP_STYLE=all` to a CI config.

**README `log stream` predicate — syntactically valid.** `log` parses the predicate before opening the store, so a syntax error is distinguishable from a permissions error. The documented predicate and its `AND category == "CTNotificationContent"` variant both parse; a deliberately malformed control (`subsystem == `) is rejected with `Bad predicate`. Full end-to-end execution could not be verified here — `log stream` requires admin and the local log store is not readable in this sandbox. Verifying it against a real device is still worth doing.

---

## 8. Changes made in this pass

All changes are logging-only. No behaviour changed.

| File | Change |
|---|---|
| [CTNotificationViewController.m:93](CTNotificationContent/CTNotificationViewController.m:93) | Replaced the direct `[CTNotificationContentLogger logError:from:@"CTContentStringValue"]` call with the `CTContentLogError` macro, so the call site comes from `__PRETTY_FUNCTION__` instead of a hand-typed string (V1). |
| [CTSingleMediaController.swift:51](CTNotificationContent/Templates/SingleMedia/Controller/CTSingleMediaController.swift:51) | Re-worded to sentence case and put `mediaType` in `key=value` form (V2). |
| [CTCaptionedImageView.swift:76](CTNotificationContent/Views/CTCaptionedImageView.swift:76) | Added `"View deallocated before gif arrived"` on the previously silent `guard let self` (V3). |
| [CTCaptionedImageView.swift:91](CTNotificationContent/Views/CTCaptionedImageView.swift:91) | Added `"View deallocated before image arrived"` (V4). |
| [CTWebViewController.swift:43](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:43) | Added `"Web view controller started"`, matching every other template (V5). |
| [CTWebViewController.swift:67](CTNotificationContent/Templates/WebView/Controller/CTWebViewController.swift:67) | Added `"Nil payload data, rendering web view without caption texts or deeplink"` on the silent return (V7). |
| [CTContentSliderController.swift:203](CTNotificationContent/Templates/ContentSlider/Controller/CTContentSliderController.swift:203) | Added a `debug` line on the silent `return [:]` (V6). `debug` rather than `info` because the fallback-caption case makes this an expected state. |
| [CTUtility.swift:156](CTNotificationContent/Templates/Utility/CTUtility.swift:156) | Added `"No required key rules for template=…, skipping payload check"` so stage 5 always produces a line (V6/stage gap). |
| [CTUtility.swift:84](CTNotificationContent/Templates/Utility/CTUtility.swift:84) | Demoted the full-payload dump from `error` to `debug`, matching the existing gate at `CTNotificationViewController.m:324` (V8). |

Verified after the edits: `** BUILD SUCCEEDED **`, and all six new strings are present in the stripped Release binary.

### Recommended follow-ups, in order

1. Rebuild and commit `Framework/CTNotificationContent.xcframework`, otherwise this entire feature ships as a no-op to SPM users.
2. Update README §Debug Logs: document `setDebugLevel`, and correct "Logging is always on. There is nothing to enable in code."
3. Demote `CTCarouselController.swift:447` to `debug` (3-second autoplay loop).
5. Consider aligning the SDWebImage GIF download timeout (15s default) with the 10s used for still images, by setting `SDWebImageDownloaderConfig.defaultDownloaderConfig.downloadTimeout = 10` early in `viewDidLoad`. Note `SDWebImageDownloader.config` is declared `copy, readonly` (`SDWebImageDownloader.h:141`), so mutating it through the shared downloader has no effect — the default config must be changed before the shared downloader is first used.
