gradle.settingsEvaluated {
    buildCache {
        remote<HttpBuildCache> {
            val remoteCacheUrl: String? by project
            url = uri(remoteCacheUrl)
            val remoteCacheUsername: String? by project
            val remoteCachePassword: String? by project
            credentials {
                username = remoteCacheUsername
                password = remoteCachePassword
            }
            isAllowInsecureProtocol = false
            isPush = true
        }
    }
}