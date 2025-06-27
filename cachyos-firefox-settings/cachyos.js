// Use LANG environment variable to choose locale
pref("intl.locale.requested", "");

// Use system-provided dictionaries
pref("spellchecker.dictionary_path", "/usr/share/hunspell");

// Disable default browser checking.
pref("browser.shell.checkDefaultBrowser", false);

// Don't disable extensions in the application directory
pref("extensions.autoDisableScopes", 11);

// Enable hardware acceleration
pref("media.hardware-video-decoding.force-enabled", true);
pref("media.webrtc.hw.h264.enabled", true);
pref("media.gpu-process-decoder", true);

// Performance & Graphics Tweaks
pref("gfx.canvas.accelerated.cache-items", 32768);
pref("gfx.canvas.accelerated.cache-size", 4096);
pref("gfx.content.skia-font-cache-size", 80);
pref("gfx.webrender.all", true);
pref("gfx.webrender.precache-shaders", true);
pref("gfx.webrender.program-binary-disk", true);
pref("layers.gpu-process.enabled", true); // Use dedicated GPU process

// JavaScript & Process Tweaks
pref("dom.ipc.forkserver.enable", true); // Enable Linux fork server for new processes
pref("javascript.options.baselinejit.threshold", 50); // Lower JIT threshold
pref("javascript.options.ion.threshold", 500); // Lower Ion threshold

// Memory & Cache Tweaks (Non-Disk)
pref("image.cache.size", 10485760); // Increase decoded image cache size (10MB)
pref("image.mem.decode_bytes_at_a_time", 65536); // Increase image decode chunk size
pref("image.mem.shared.unmap.min_expiration_ms", 120000);
pref("media.cache_readahead_limit", 7200); // Increase media readahead
pref("media.cache_resume_threshold", 3600); // Increase media resume threshold
pref("media.memory_cache_max_size", 1048576); // Increase media memory cache (1GB)
pref("media.memory_caches_combined_limit_kb", 3145728); // Increase combined media caches limit (3GB)
pref("network.buffer.cache.size", 65535); // Network buffer size
pref("network.ssl_tokens_cache_capacity", 32768); // Increase SSL token cache

// Remove Mozilla stuff
pref("app.normandy.api_url", "", locked);
pref("app.normandy.enabled", false, locked);
pref("breakpad.reportURL", "", locked);
pref("browser.contentanalysis.default_result", 0, locked);
pref("browser.contentanalysis.enabled", false, locked);
pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false, locked);
pref("browser.discovery.enabled", false, locked);
pref("browser.ml.enable", false, locked);
pref("browser.newtabpage.activity-stream.feeds.aboutpreferences", false, locked);
pref("browser.newtabpage.activity-stream.feeds.adsfeed", false, locked);
pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false, locked);
pref("browser.newtabpage.activity-stream.feeds.places", false, locked);
pref("browser.newtabpage.activity-stream.feeds.recommendationprovider", false, locked);
pref("browser.newtabpage.activity-stream.feeds.system.topsites", false, locked);
pref("browser.newtabpage.activity-stream.feeds.system.topstories", false, locked);
pref("browser.newtabpage.activity-stream.feeds.topsites", false, locked);
pref("browser.newtabpage.activity-stream.system.showSponsored", false, locked);
pref("browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint", 0, locked);
pref("browser.newtabpage.activity-stream.telemetry.ut.event", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.adsFeed.enabled", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.adsFeed.spocs.enabled", false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.adsFeed.tiles.enabled",	false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.endpoint", "", locked);
pref("browser.newtabpage.activity-stream.unifiedAds.spocs.enabled",	false, locked);
pref("browser.newtabpage.activity-stream.unifiedAds.tiles.enabled", false, locked);
pref("browser.places.interactions.enabled", false, locked);
pref("browser.tabs.crashReporting.sendReport", false, locked);
pref("browser.uitour.enabled", false, locked);
pref("browser.urlbar.suggest.addons", false, locked);
pref("browser.urlbar.suggest.quicksuggest.fakespot", false, locked);
pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false, locked);
pref("browser.urlbar.suggest.quicksuggest.sponsored", false, locked);
pref("browser.urlbar.suggest.quicksuggest.topsites", false, locked);
pref("browser.urlbar.suggest.trending", false, locked);
pref("browser.vpn_promo.enabled", false, locked);
pref("captivedetect.canonicalURL", "", locked);
pref("devtools.debugger.remote-enabled", false, locked);
pref("dom.private-attribution.submission.enabled", false, locked);
pref("dom.push.enabled", false, locked);
pref("dom.security.unexpected_system_load_telemetry_enabled", false, locked);
pref("extensions.abuseReport.enabled", false, locked);
pref("extensions.blocklist.enabled", false, locked);
pref("extensions.getAddons.showPane", false, locked);
pref("extensions.htmlaboutaddons.recommendations.enabled", false, locked);
pref("extensions.pocket.enabled", false, locked);
pref("media.gmp-gmpopenh264.autoupdate", false, locked);

// Reduces the CLRite base refresh period in the lack of a persistent
// background push service
pref("security.OCSP.enabled", 0);
pref("security.pki.crlite_mode", 2, locked);
pref("security.remote_settings.crlite_filters.enabled", true, locked);
pref("services.settings.poll_interval", 300);

// Remove telemetry
pref("browser.contentblocking.report.lockwise.enabled", false, locked);
pref("browser.contentblocking.report.monitor.enabled", false, locked);
pref("browser.discovery.enabled", false, locked);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false, locked);
pref("browser.newtabpage.activity-stream.showSponsored", false, locked);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false, locked);
pref("browser.newtabpage.activity-stream.telemetry", false, locked);
pref("browser.newtabpage.activity-stream.telemetry.ut.events", false, locked);
pref("browser.ping-centre.telemetry", false, locked);
pref("browser.search.serpEventTelemetryCategorization.enabled", false, locked);
pref("browser.search.serpEventTelemetryCategorization.regionEnabled", false, locked);
pref("browser.search.update", false, locked);
pref("browser.shopping.experience2023.enabled", false, locked);
pref("browser.startup.homepage_override.mstone", "ignore", locked);
pref("browser.urlbar.addons.featureGate", false, locked);
pref("browser.urlbar.fakespot.featureGate", false, locked);
pref("browser.urlbar.mdn.featureGate", false, locked);
pref("browser.urlbar.pocket.featureGate", false, locked);
pref("browser.urlbar.weather.featureGate", false, locked);
pref("browser.urlbar.yelp.featureGate", false, locked);
pref("datareporting.healthreport.uploadEnabled", false, locked);
pref("datareporting.policy.dataSubmissionEnabled", false, locked);
pref("datareporting.usage.uploadEnabled", false, locked);
pref("extensions.getAddons.cache.enabled", false, locked);
pref("network.captive-portal-service.enabled", false, locked);
pref("network.connectivity-service.enabled", false, locked);
pref("network.trr.confirmation_telemetry_enabled", false, locked);
pref("security.certerrors.recordEventTelemetry", false, locked);
pref("toolkit.coverage.endpoint.base", "", locked);
pref("toolkit.coverage.opt-out", true, locked);
pref("toolkit.telemetry.archive.enabled", false, locked);
pref("toolkit.telemetry.bhrPing.enabled", false, locked);
pref("toolkit.telemetry.cachedClientID", "", locked);
pref("toolkit.telemetry.cachedProfileGroupID", "", locked);
pref("toolkit.telemetry.coverage.opt-out", true, locked);
pref("toolkit.telemetry.enabled", false, locked);
pref("toolkit.telemetry.firstShutdownPing.enabled", false, locked);
pref("toolkit.telemetry.newProfilePing.enabled", false, locked);
pref("toolkit.telemetry.server", "data:,", locked);
pref("toolkit.telemetry.shutdownPingSender.enabled", false, locked);
pref("toolkit.telemetry.unified", false, locked);
pref("toolkit.telemetry.updatePing.enabled", false, locked);

// Remove Google safebrowsing
pref("browser.safebrowsing.allowOverride", false, locked);
pref("browser.safebrowsing.blockedURIs.enabled", false, locked);
pref("browser.safebrowsing.debug", false, locked);
pref("browser.safebrowsing.downloads.enabled", false, locked);
pref("browser.safebrowsing.downloads.remote.block_dangerous", false, locked);
pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false, locked);
pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false, locked);
pref("browser.safebrowsing.downloads.remote.block_uncommon", false, locked);
pref("browser.safebrowsing.downloads.remote.enabled", false, locked);
pref("browser.safebrowsing.downloads.remote.remote.url", "", locked);
pref("browser.safebrowsing.downloads.remote.url", "", locked);
pref("browser.safebrowsing.id", "", locked);
pref("browser.safebrowsing.malware.enabled", false, locked);
pref("browser.safebrowsing.phishing.enabled", false, locked);
pref("browser.safebrowsing.provider.google.advisoryName", "", locked);
pref("browser.safebrowsing.provider.google.advisoryURL", "", locked);
pref("browser.safebrowsing.provider.google.gethashURL", "", locked);
pref("browser.safebrowsing.provider.google.lists", "", locked);
pref("browser.safebrowsing.provider.google.pver", 0, locked);
pref("browser.safebrowsing.provider.google.reportMalwareMistakeURL", "", locked);
pref("browser.safebrowsing.provider.google.reportPhishMistakeURL", "", locked);
pref("browser.safebrowsing.provider.google.reportURL", "", locked);
pref("browser.safebrowsing.provider.google.updateURL", "", locked);
pref("browser.safebrowsing.provider.google4.advisoryName", "", locked);
pref("browser.safebrowsing.provider.google4.advisoryURL", "", locked);
pref("browser.safebrowsing.provider.google4.dataSharing.enabled", false, locked);
pref("browser.safebrowsing.provider.google4.dataSharingURL", "", locked);
pref("browser.safebrowsing.provider.google4.gethashURL", "", locked);
pref("browser.safebrowsing.provider.google4.lists", "", locked);
pref("browser.safebrowsing.provider.google4.pver", 0, locked);
pref("browser.safebrowsing.provider.google4.reportMalwareMistakeURL", "", locked);
pref("browser.safebrowsing.provider.google4.reportPhishMistakeURL", "", locked);
pref("browser.safebrowsing.provider.google4.reportURL", "", locked);
pref("browser.safebrowsing.provider.google4.updateURL", "", locked);
pref("browser.safebrowsing.provider.mozilla.gethashURL", "", locked);
pref("browser.safebrowsing.provider.mozilla.lastupdatetime", 0, locked);
pref("browser.safebrowsing.provider.mozilla.lists", "", locked);
pref("browser.safebrowsing.provider.mozilla.lists.base", "", locked);
pref("browser.safebrowsing.provider.mozilla.lists.content", "", locked);
pref("browser.safebrowsing.provider.mozilla.nextupdatetime", 0, locked);
pref("browser.safebrowsing.provider.mozilla.pver", 0, locked);
pref("browser.safebrowsing.provider.mozilla.reportURL", "", locked);
pref("browser.safebrowsing.provider.mozilla.updateURL", "", locked);
pref("browser.safebrowsing.reportPhishURL", "", locked);

// Performance tweaks
pref("browser.tabs.unloadOnLowMemory", true, locked); // Unload unused tabs
pref("content.notify.interval", 100000); // page reflow timer, lower redrawn rendering timer, increases responsiveness but increase total load time
pref("network.dnsCacheExpiration", 3600); // Time DNS entries are cached in seconds.
pref("network.http.max-connections", 1800); //https://kb.mozillazine.org/Network.http.max-connections
pref("network.http.max-persistent-connections-per-server", 10); //https://kb.mozillazine.org/Network.http.max-persistent-connections-per-server
pref("network.http.max-urgent-start-excessive-connections-per-host", 5); //Number of connections that we can open beyond the standard parallelism limit defined by max-persistent-connections-per-server/-proxy to handle urgent-start marked requests
pref("network.http.pacing.requests.enabled", false); //Disable pacing requests

// Privacy hardening
pref("browser.contentblocking.category", "strict"); // https://blog.mozilla.org/security/2021/02/23/total-cookie-protection/
pref("browser.download.autohideButton", false, locked); //do not hide download button automatically
pref("browser.download.start_downloads_in_tmp_dir", true, locked); //start downloads in temp
pref("dom.security.https_only_mode", true, locked); // only allow https in all windows, including private browsing
pref("network.predictor.enable-prefetch", false); // Disable speculative website loading
pref("network.predictor.enabled", false); // Disable speculative website loading
pref("network.prefetch-next", false); // https://developer.mozilla.org/en-US/docs/Glossary/Prefetch
pref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid"); // https://groups.google.com/a/mozilla.org/g/dev-platform/c/1vOSas0ptVQ?pli=1
pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com"); // allow embedded social content
pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com"); // allow embedded social content

// Desktop integration
pref("widget.use-xdg-desktop-portal.file-picker", 1);

// UI/Behavior Tweaks
pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
pref("general.smoothScroll.msdPhysics.enabled", true); // Use physics-based smooth scrolling
pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 200);
pref("general.smoothScroll.msdPhysics.regularSpringConstant", 250);
pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2.0"); // Ensure float format if needed
pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
pref("general.smoothScroll.currentVelocityWeighting", "1.0"); // Ensure float format if needed
pref("general.smoothScroll.stopDecelerationWeighting", "1.0"); // Ensure float format if needed
pref("mousewheel.default.delta_multiplier_y", 300); // Adjust mouse wheel scroll speed

// Feature Enablement
pref("layout.css.grid-template-masonry-value.enabled", true); // Enable CSS Masonry layout
