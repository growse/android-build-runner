gradle.settingsEvaluated {
    buildCache {
        remote<HttpBuildCache> {
            url = uri(System.getenv("GRADLE_REMOTE_CACHE_URL"))
            isAllowInsecureProtocol = false
            isPush = true
        }
    }
}