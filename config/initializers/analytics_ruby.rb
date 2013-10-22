# Alias for convenience, initialize the Acme. Co project ..
Analytics = AnalyticsRuby
#secret is on prod only, since don't want info from the other deploys
Analytics.init(secret: ENV['SEGMENT_SECRET'])