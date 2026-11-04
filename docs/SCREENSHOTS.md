# Screenshots

Captured on Wednesday 4 November 2026 on an **iPhone 17 Pro simulator** (iOS, debug build, status bar fixed at 9:41), then downscaled to 1000 px tall. The events are real: each tap went through the SDK into its database, and the Dashboard shows the queue as it was.

## Light

| Home | Shop | A product, after Buy |
|:---:|:---:|:---:|
| <img src="screenshots/home.png" width="250" alt="Home: 'Each button tracks an event with the TrackLite SDK. The Dashboard shows where it goes.' and three buttons, Get started, Share and Rate the app, each saying what it sends"> | <img src="screenshots/shop.png" width="250" alt="Shop: four products with a description and a price: Coffee beans $12.50, Travel mug $24.00, Pour-over kit $38.00, Hand grinder $65.00"> | <img src="screenshots/product.png" width="250" alt="Coffee beans, $12.50, a description, a Buy button with 'Sends purchase with product_id, price and currency.', and a SnackBar: Purchase tracked: Coffee beans"> |

| Profile, signed in | The Dashboard |
|:---:|:---:|
| <img src="screenshots/profile.png" width="250" alt="Profile: Signed in as alex, 'Every event from now on carries this id.', a Sign out button, and the anonymous id with why signing out starts a new one"> | <img src="screenshots/dashboard.png" width="250" alt="The Dashboard: the queue with Pending 4, Sending 0, Sent (ever) 3, Failed 0, each with its own icon; Flush now, Retry failed (disabled), Track 100 events; then Uploads: the last one, every 30 s, uploaded 1 event"> |

## Dark: failures and offline

The Dashboard's demo controls: the fake server's **Failures** at 100 %, then **Track 100 events**.

| The demo server | Failing, with backoff | Device offline | Recent events |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/demo-server-dark.png" width="200" alt="Dark mode: the Device offline switch off; the Demo server with Failures 0, 10, 50 and 100 % (100 % chosen) and Speed Fast, Normal, Slow; Requests received 7, Events stored 7, Duplicates dropped 0, Requests failed 2"> | <img src="screenshots/failures-dark.png" width="200" alt="Dark mode, Uploads: Last upload, every 30 s, Failed; Next retry at 03:49:08 (backoff after a server error); Online"> | <img src="screenshots/offline-dark.png" width="200" alt="Dark mode, the same section with Device offline on: the network row says Offline (simulated) with a crossed-out wifi icon"> | <img src="screenshots/events-dark.png" width="200" alt="Dark mode, Recent events: demo_burst n 100, 99, 98… each Pending, with '1 server error · retry at 03:52:10 · server error 500'"> |

## Large text

Accessibility text size **AX3** (about 235 %), light mode. Past 130 %, side-by-side layouts stack: the segments become wrapping chips, and an event's status chip moves under its details, so `screen_opened` isn't broken mid-word.

| Profile | The Dashboard | Recent events |
|:---:|:---:|:---:|
| <img src="screenshots/profile-large.png" width="250" alt="Profile at AX3: Signed in, alex, 'Every event from now on carries this id.' over three lines, Sign out, and the anonymous id wrapping"> | <img src="screenshots/dashboard-large.png" width="250" alt="The Dashboard at AX3: Pending 102, Sending 2, Sent (ever) 7, Failed 0, the three buttons full width, and the explanation wrapping"> | <img src="screenshots/events-large.png" width="250" alt="Recent events at AX3: screen_opened, 'screen: dashboard · 03:54:16', and a Sent chip below it; then screen_opened for home, also Sent"> |

"Sending 2" in the large-text Dashboard is the at-least-once path, caught by accident: the app was relaunched mid-upload, so those two claims stay `sending` until they expire (5 minutes), then go again.
