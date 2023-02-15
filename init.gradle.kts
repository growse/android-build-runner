gradle.settingsEvaluated {
    buildCache {
        remote<HttpBuildCache> {
            url = uri(System.getenv("GRADLE_REMOTE_CACHE_URL"))
            credentials {
                username = System.getenv("GRADLE_REMOTE_CACHE_USERNAME")
                password = System.getenv("GRADLE_REMOTE_CACHE_PASSWORD}")
            }
            isAllowInsecureProtocol = false
            isPush = true
        }
    }
}
